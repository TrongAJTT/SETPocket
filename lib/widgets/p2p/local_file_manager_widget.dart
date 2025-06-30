import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/widgets/generic/option_grid_selector.dart';
import 'package:file_picker/file_picker.dart';

enum FileType { all, image, video, audio, document, archive, other }

enum SortCriteria { name, size, date, type }

enum SortOrder { ascending, descending }

class LocalFileManagerWidget extends StatefulWidget {
  final String basePath;
  final bool viewSubfolders;
  final bool viewOnly;
  final String title;

  const LocalFileManagerWidget({
    super.key,
    required this.basePath,
    this.viewSubfolders = true,
    this.viewOnly = false,
    this.title = 'File Manager',
  });

  @override
  State<LocalFileManagerWidget> createState() => _LocalFileManagerWidgetState();
}

class _LocalFileManagerWidgetState extends State<LocalFileManagerWidget> {
  List<FileSystemEntity> _allFiles = [];
  List<FileSystemEntity> _filteredFiles = [];
  String _searchQuery = '';
  FileType _selectedFileType = FileType.all;
  SortCriteria _sortCriteria = SortCriteria.name;
  SortOrder _sortOrder = SortOrder.ascending;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedFiles = {};
  bool _isSelectionMode = false;

  // Performance optimization caches
  final Map<String, FileStat> _fileStatCache = {};
  final Map<String, FileType> _fileTypeCache = {};
  DateTime? _lastDirectoryModified;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // 🔥 CLEANUP: Clear caches to free memory and prevent memory leaks
    _fileStatCache.clear();
    _fileTypeCache.clear();
    // 🔥 CLEANUP: Clear file lists to free memory
    _allFiles.clear();
    _filteredFiles.clear();
    _selectedFiles.clear();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directory = Directory(widget.basePath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Always clear caches when manually reloading to ensure fresh data
      _fileStatCache.clear();
      _fileTypeCache.clear();

      List<FileSystemEntity> files = [];

      if (widget.viewSubfolders) {
        files = await directory.list(recursive: true).toList();
      } else {
        files = await directory.list().toList();
      }

      // Filter out directories if we only want files for operations
      files = files.whereType<File>().toList();

      // Pre-populate file type cache for better performance
      await _populateFileTypeCache(files);

      setState(() {
        _allFiles = files;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      logError('Failed to load files: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _populateFileTypeCache(List<FileSystemEntity> files) async {
    final filesToProcess = files
        .where((file) => file is File && !_fileTypeCache.containsKey(file.path))
        .toList();

    for (final file in filesToProcess) {
      if (file is File) {
        final fileType = _getFileType(file.path);
        _fileTypeCache[file.path] = fileType;
      }
    }
  }

  void _applyFiltersAndSort() {
    _filteredFiles = _allFiles.where((file) {
      // Search filter
      if (_searchQuery.isNotEmpty &&
          !path
              .basename(file.path)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // File type filter
      if (_selectedFileType != FileType.all) {
        final fileType = _getFileType(file.path);
        if (fileType != _selectedFileType) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort files - async sort for better performance with large lists
    _filteredFiles.sort((a, b) {
      int comparison = 0;

      switch (_sortCriteria) {
        case SortCriteria.name:
          comparison = path
              .basename(a.path)
              .toLowerCase()
              .compareTo(path.basename(b.path).toLowerCase());
          break;
        case SortCriteria.size:
          // Use cached stats if available, otherwise fallback to sync
          if (_fileStatCache.containsKey(a.path) &&
              _fileStatCache.containsKey(b.path)) {
            final sizeA = _fileStatCache[a.path]!.size;
            final sizeB = _fileStatCache[b.path]!.size;
            comparison = sizeA.compareTo(sizeB);
          } else {
            final sizeA = (a as File).lengthSync();
            final sizeB = (b as File).lengthSync();
            comparison = sizeA.compareTo(sizeB);
          }
          break;
        case SortCriteria.date:
          // Use cached stats if available, otherwise fallback to sync
          if (_fileStatCache.containsKey(a.path) &&
              _fileStatCache.containsKey(b.path)) {
            final dateA = _fileStatCache[a.path]!.modified;
            final dateB = _fileStatCache[b.path]!.modified;
            comparison = dateA.compareTo(dateB);
          } else {
            final dateA = (a as File).lastModifiedSync();
            final dateB = (b as File).lastModifiedSync();
            comparison = dateA.compareTo(dateB);
          }
          break;
        case SortCriteria.type:
          final typeA = _getFileType(a.path);
          final typeB = _getFileType(b.path);
          comparison = typeA.index.compareTo(typeB.index);
          break;
      }

      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  FileType _getFileType(String filePath) {
    // Use cache if available
    if (_fileTypeCache.containsKey(filePath)) {
      return _fileTypeCache[filePath]!;
    }

    final extension = path.extension(filePath).toLowerCase();
    FileType fileType;

    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension)) {
      fileType = FileType.image;
    } else if (['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv']
        .contains(extension)) {
      fileType = FileType.video;
    } else if (['.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a']
        .contains(extension)) {
      fileType = FileType.audio;
    } else if ([
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx'
    ].contains(extension)) {
      fileType = FileType.document;
    } else if (['.zip', '.rar', '.7z', '.tar', '.gz'].contains(extension)) {
      fileType = FileType.archive;
    } else {
      fileType = FileType.other;
    }

    // Cache the result
    _fileTypeCache[filePath] = fileType;
    return fileType;
  }

  Future<FileStat> _getCachedFileStat(String filePath) async {
    // Use cache if available and not too old (1 minute cache)
    if (_fileStatCache.containsKey(filePath)) {
      return _fileStatCache[filePath]!;
    }

    // Get fresh stat and cache it
    final file = File(filePath);
    final stat = await file.stat();
    _fileStatCache[filePath] = stat;

    // Clean old cache entries (keep only last 100 entries for memory efficiency)
    if (_fileStatCache.length > 100) {
      final oldestKeys =
          _fileStatCache.keys.take(_fileStatCache.length - 50).toList();
      for (final key in oldestKeys) {
        _fileStatCache.remove(key);
      }
    }

    return stat;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _getFileIcon(String filePath) {
    final fileType = _getFileType(filePath);
    final extension = path.extension(filePath).toLowerCase();

    IconData iconData;
    Color iconColor;

    switch (fileType) {
      case FileType.image:
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case FileType.video:
        iconData = Icons.video_file;
        iconColor = Colors.red;
        break;
      case FileType.audio:
        iconData = Icons.audio_file;
        iconColor = Colors.purple;
        break;
      case FileType.document:
        iconData = _getDocumentIcon(extension);
        iconColor = _getDocumentColor(extension);
        break;
      case FileType.archive:
        iconData = Icons.archive;
        iconColor = Colors.brown;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
        break;
    }

    return Icon(iconData, color: iconColor);
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.txt':
      case '.rtf':
        return Icons.text_snippet;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      default:
        return Icons.description;
    }
  }

  Color _getDocumentColor(String extension) {
    switch (extension) {
      case '.pdf':
        return Colors.red.shade700;
      case '.doc':
      case '.docx':
        return Colors.blue;
      case '.txt':
      case '.rtf':
        return Colors.grey.shade700;
      case '.xls':
      case '.xlsx':
        return Colors.green.shade700;
      case '.ppt':
      case '.pptx':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _toggleSelection(String filePath) {
    setState(() {
      if (_selectedFiles.contains(filePath)) {
        _selectedFiles.remove(filePath);
        if (_selectedFiles.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedFiles.add(filePath);
        _isSelectionMode = true;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedFiles.length == _filteredFiles.length) {
        // If all files are selected, deselect all
        _selectedFiles.clear();
        _isSelectionMode = false;
      } else {
        // Select all filtered files
        _selectedFiles.clear();
        for (final file in _filteredFiles) {
          _selectedFiles.add(file.path);
        }
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _showSnackBar('Không thể mở file: ${result.message}');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi mở file: $e');
    }
  }

  Future<void> _shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      _showSnackBar('Lỗi khi chia sẻ file: $e');
    }
  }

  Future<void> _deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      _showSnackBar('Đã xóa file');
      _loadFiles();
    } catch (e) {
      _showSnackBar('Lỗi khi xóa file: $e');
    }
  }

  Future<void> _renameFile(String oldPath) async {
    final fileName = path.basename(oldPath);
    final controller = TextEditingController(text: fileName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên file'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên file mới',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Đổi tên'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != fileName) {
      try {
        final file = File(oldPath);
        final newPath = path.join(path.dirname(oldPath), newName);
        await file.rename(newPath);

        // Clear cache for this file and reload immediately
        _fileStatCache.remove(oldPath);
        _fileTypeCache.remove(oldPath);

        _showSnackBar('Đã đổi tên file');
        await _loadFiles(); // Wait for reload to complete
      } catch (e) {
        _showSnackBar('Lỗi khi đổi tên file: $e');
      }
    }
  }

  Future<void> _copyFile(String filePath) async {
    await _handleSimpleExternalOperation(filePath, isMove: false);
  }

  Future<void> _moveFile(String filePath) async {
    await _handleSimpleExternalOperation(filePath, isMove: true);
  }

  Future<String> _findUniqueFileName(
      String dirPath, String originalFileName) async {
    String destinationPath = path.join(dirPath, originalFileName);
    if (!await File(destinationPath).exists()) {
      return destinationPath;
    }

    String baseName = path.basenameWithoutExtension(originalFileName);
    String extension = path.extension(originalFileName);
    int counter = 1;

    while (true) {
      String newFileName = '$baseName ($counter)$extension';
      destinationPath = path.join(dirPath, newFileName);
      if (!await File(destinationPath).exists()) {
        return destinationPath;
      }
      counter++;
    }
  }

  Future<void> _handleSimpleExternalOperation(String sourcePath,
      {required bool isMove}) async {
    try {
      final String? destinationDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: isMove ? 'Di chuyển file đến...' : 'Sao chép file đến...',
      );

      if (destinationDir == null) {
        _showSnackBar('Hành động đã bị hủy');
        return;
      }

      final sourceFileName = path.basename(sourcePath);
      final destinationPath =
          await _findUniqueFileName(destinationDir, sourceFileName);
      final finalFileName = path.basename(destinationPath);

      final sourceFile = File(sourcePath);

      if (isMove) {
        await sourceFile.copy(destinationPath);
        await sourceFile.delete();
        _showSnackBar('Đã di chuyển file thành công thành "$finalFileName"');
        await _loadFiles();
      } else {
        await sourceFile.copy(destinationPath);
        _showSnackBar('Đã sao chép file thành công thành "$finalFileName"');
      }
    } catch (e) {
      logError('Lỗi khi thực hiện thao tác file đơn giản: $e');
      _showSnackBar('Đã xảy ra lỗi. Vui lòng kiểm tra quyền truy cập bộ nhớ.');
    }
  }

  Future<void> _showAdvancedCopyMoveDialog(String sourcePath) async {
    try {
      // Step 1: Let user pick an initial directory
      String? destinationDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Chọn thư mục đích',
      );

      if (destinationDir == null) {
        _showSnackBar('Hành động đã bị hủy');
        return;
      }

      final screenWidth = MediaQuery.of(context).size.width;

      // Step 2: Show advanced confirmation dialog
      final sourceFileName = path.basename(sourcePath);
      final newFileNameController = TextEditingController(text: sourceFileName);
      bool isMoveOperation = true; // Default to move

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Tùy chọn nâng cao'),
                contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                content: SizedBox(
                  width: screenWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Operation Type Selector
                        OptionGridSelector<bool>(
                          title: 'Chọn thao tác',
                          options: [
                            const OptionItem<bool>(
                              value: true,
                              label: 'Di chuyển',
                              icon: Icons.drive_file_move,
                              iconColor: Colors.blue,
                            ),
                            const OptionItem<bool>(
                              value: false,
                              label: 'Sao chép',
                              icon: Icons.copy,
                              iconColor: Colors.green,
                            ),
                          ],
                          selectedValue: isMoveOperation,
                          onSelectionChanged: (value) {
                            setDialogState(() => isMoveOperation = value);
                          },
                          crossAxisCount: 2,
                          aspectRatio: 2.5,
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        // Destination Picker
                        const Text('Đích đến:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(destinationDir ?? 'Chưa chọn'),
                          subtitle: const Text('Nhấn để chọn lại thư mục'),
                          trailing: const Icon(Icons.folder_open),
                          onTap: () async {
                            final newDir =
                                await FilePicker.platform.getDirectoryPath(
                              dialogTitle: 'Chọn thư mục đích',
                            );
                            if (newDir != null) {
                              setDialogState(() => destinationDir = newDir);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Filename Input
                        const Text('Tên file:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextField(
                          controller: newFileNameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Return the selected values when closing
                      Navigator.pop(context, {
                        'isMove': isMoveOperation,
                        'destination': destinationDir,
                        'fileName': newFileNameController.text.trim(),
                      });
                    },
                    child: const Text('Áp dụng'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result == null) {
        _showSnackBar('Hành động đã bị hủy');
        return;
      }

      // Step 3: Perform the operation
      final bool confirmedIsMove = result['isMove'];
      final String confirmedDestDir = result['destination'];
      final String newFileName = result['fileName'];

      if (newFileName.isEmpty) {
        _showSnackBar('Tên file không hợp lệ');
        return;
      }

      final destinationPath = path.join(confirmedDestDir, newFileName);
      final sourceFile = File(sourcePath);

      if (await File(destinationPath).exists()) {
        final replace = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('File đã tồn tại'),
            content: Text(
                'File "$newFileName" đã tồn tại ở thư mục đích. Bạn có muốn ghi đè không?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ghi đè'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        );
        if (replace != true) {
          _showSnackBar('Hành động đã bị hủy');
          return;
        }
      }

      if (confirmedIsMove) {
        await sourceFile.copy(destinationPath);
        await sourceFile.delete();
        _showSnackBar('Đã di chuyển file thành công');
      } else {
        await sourceFile.copy(destinationPath);
        _showSnackBar('Đã sao chép file thành công');
      }

      if (confirmedIsMove) {
        await _loadFiles();
      }
    } catch (e) {
      logError('Lỗi khi thực hiện thao tác file nâng cao: $e');
      _showSnackBar('Đã xảy ra lỗi. Vui lòng kiểm tra quyền truy cập bộ nhớ.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showFileActions(String filePath) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Mở trong ứng dụng'),
            onTap: () {
              Navigator.pop(context);
              _openFile(filePath);
            },
          ),
          if (!widget.viewOnly) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Đổi tên'),
              onTap: () {
                Navigator.pop(context);
                _renameFile(filePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Sao chép vào...'),
              onTap: () {
                Navigator.pop(context);
                _copyFile(filePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move),
              title: const Text('Di chuyển vào...'),
              onTap: () {
                Navigator.pop(context);
                _moveFile(filePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outlined),
              title: const Text('Di chuyển hoặc sao chép và đổi tên...'),
              onTap: () {
                Navigator.pop(context);
                _showAdvancedCopyMoveDialog(filePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(filePath);
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Chia sẻ'),
            onTap: () {
              Navigator.pop(context);
              _shareFile(filePath);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content:
            Text('Bạn có chắc muốn xóa file "${path.basename(filePath)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(filePath);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedFiles.length} đã chọn')
            : Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm file...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFiltersAndSort();
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFiltersAndSort();
                });
              },
            ),
          ),
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: Icon(_selectedFiles.length == _filteredFiles.length
                  ? Icons.deselect
                  : Icons.select_all),
              onPressed: _toggleSelectAll,
              tooltip: _selectedFiles.length == _filteredFiles.length
                  ? 'Bỏ chọn tất cả'
                  : 'Chọn tất cả',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed:
                  _selectedFiles.isNotEmpty ? _deleteSelectedFiles : null,
              tooltip: 'Xóa file đã chọn',
            ),
          ] else ...[
            // Filter and sort menu
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showFilterSortDialog,
              tooltip: 'Lọc và sắp xếp',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFiles,
              tooltip: 'Tải lại',
            ),
          ],
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _filteredFiles.isNotEmpty && !widget.viewOnly
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSelectionMode = !_isSelectionMode;
                  if (!_isSelectionMode) {
                    _selectedFiles.clear();
                  }
                });
              },
              child: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Không tìm thấy file nào khớp'
                  : 'Thư mục trống',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadFiles,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFiles,
      child: ListView.builder(
        itemCount: _filteredFiles.length,
        itemBuilder: (context, index) {
          final file = _filteredFiles[index] as File;
          final fileName = path.basename(file.path);
          final isSelected = _selectedFiles.contains(file.path);

          return ListTile(
            leading: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(file.path),
                  )
                : _getFileIcon(file.path),
            title: Text(fileName),
            subtitle: FutureBuilder<FileStat>(
              future: _getCachedFileStat(file.path),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final stat = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatFileSize(stat.size)),
                      Text(_formatDate(stat.modified)),
                    ],
                  );
                }
                return const SizedBox(height: 32, child: Text('...'));
              },
            ),
            trailing: widget.viewOnly
                ? null
                : IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showFileActions(file.path),
                  ),
            selected: isSelected,
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(file.path);
              } else {
                _openFile(file.path);
              }
            },
            onLongPress:
                widget.viewOnly ? null : () => _showFileActions(file.path),
          );
        },
      ),
    );
  }

  void _deleteSelectedFiles() async {
    if (_selectedFiles.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content:
            Text('Bạn có chắc muốn xóa ${_selectedFiles.length} file đã chọn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      int deletedCount = 0;
      for (final filePath in _selectedFiles) {
        try {
          await File(filePath).delete();
          deletedCount++;
        } catch (e) {
          logError('Failed to delete file $filePath: $e');
        }
      }

      setState(() {
        _selectedFiles.clear();
        _isSelectionMode = false;
      });

      _showSnackBar('Đã xóa $deletedCount file');
      _loadFiles();
    }
  }

  void _showFilterSortDialog() async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDialogHeight = screenHeight * 0.8; // 80% of screen height

    // Let the dialog manage its own state and return the final result.
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        // Temporary state holders for the dialog.
        FileType tempFileType = _selectedFileType;
        SortCriteria tempSortCriteria = _sortCriteria;
        SortOrder tempSortOrder = _sortOrder;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.tune,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Lọc và Sắp xếp'),
                ],
              ),
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: screenWidth, // Provide a fixed width to the content
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: maxDialogHeight,
                    maxWidth: 400,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        // File type filter section
                        OptionGridSelector<FileType>(
                          title: 'Lọc theo loại file',
                          options: _buildFileTypeOptions(),
                          selectedValue: tempFileType,
                          crossAxisCount: 3,
                          aspectRatio: 1.1,
                          onSelectionChanged: (value) {
                            setDialogState(() {
                              tempFileType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        // Sort section
                        SortOptionSelector<SortCriteria>(
                          title: 'Sắp xếp theo',
                          options: _buildSortOptions(),
                          selectedValue: tempSortCriteria,
                          isAscending: tempSortOrder == SortOrder.ascending,
                          onSelectionChanged: (value) {
                            setDialogState(() {
                              tempSortCriteria = value;
                            });
                          },
                          onOrderToggle: () {
                            setDialogState(() {
                              tempSortOrder =
                                  tempSortOrder == SortOrder.ascending
                                      ? SortOrder.descending
                                      : SortOrder.ascending;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null), // Cancel
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    // Return the selected values when closing
                    Navigator.pop(context, {
                      'fileType': tempFileType,
                      'sortCriteria': tempSortCriteria,
                      'sortOrder': tempSortOrder,
                    });
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            );
          },
        );
      },
    );

    // Apply the changes only if the user confirmed and the values have changed.
    if (result != null) {
      final newFileType = result['fileType'] as FileType;
      final newSortCriteria = result['sortCriteria'] as SortCriteria;
      final newSortOrder = result['sortOrder'] as SortOrder;

      if (newFileType != _selectedFileType ||
          newSortCriteria != _sortCriteria ||
          newSortOrder != _sortOrder) {
        setState(() {
          _selectedFileType = newFileType;
          _sortCriteria = newSortCriteria;
          _sortOrder = newSortOrder;
          _applyFiltersAndSort();
        });
      }
    }
  }

  List<OptionItem<FileType>> _buildFileTypeOptions() {
    return [
      const OptionItem(
        value: FileType.all,
        label: 'Tất cả',
        icon: Icons.folder,
        iconColor: Colors.blue,
      ),
      const OptionItem(
        value: FileType.image,
        label: 'Hình ảnh',
        icon: Icons.image,
        iconColor: Colors.green,
      ),
      const OptionItem(
        value: FileType.video,
        label: 'Video',
        icon: Icons.video_file,
        iconColor: Colors.red,
      ),
      const OptionItem(
        value: FileType.audio,
        label: 'Âm thanh',
        icon: Icons.audio_file,
        iconColor: Colors.purple,
      ),
      const OptionItem(
        value: FileType.document,
        label: 'Tài liệu',
        icon: Icons.description,
        iconColor: Colors.blue,
      ),
      const OptionItem(
        value: FileType.archive,
        label: 'Nén',
        icon: Icons.archive,
        iconColor: Colors.brown,
      ),
      const OptionItem(
        value: FileType.other,
        label: 'Khác',
        icon: Icons.insert_drive_file,
        iconColor: Colors.grey,
      ),
    ];
  }

  List<SortOptionItem<SortCriteria>> _buildSortOptions() {
    return [
      const SortOptionItem(
        value: SortCriteria.name,
        label: 'Tên',
        icon: Icons.sort_by_alpha,
        iconColor: Colors.blue,
      ),
      const SortOptionItem(
        value: SortCriteria.size,
        label: 'Kích thước',
        icon: Icons.data_usage,
        iconColor: Colors.orange,
      ),
      const SortOptionItem(
        value: SortCriteria.date,
        label: 'Ngày',
        icon: Icons.access_time,
        iconColor: Colors.green,
      ),
      const SortOptionItem(
        value: SortCriteria.type,
        label: 'Loại',
        icon: Icons.category,
        iconColor: Colors.purple,
      ),
    ];
  }
}
