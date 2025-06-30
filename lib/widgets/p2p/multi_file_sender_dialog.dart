import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/widgets/generic/radial_menu.dart';
import 'package:setpocket/widgets/p2p/file_type_radial_menu.dart';
import 'package:setpocket/services/file_directory_service.dart';
import 'package:setpocket/services/app_logger.dart';

class MultiFileSenderDialog extends StatefulWidget {
  final P2PUser targetUser;
  final Function(List<String> filePaths) onSendFiles;

  const MultiFileSenderDialog({
    super.key,
    required this.targetUser,
    required this.onSendFiles,
  });

  @override
  State<MultiFileSenderDialog> createState() => _MultiFileSenderDialogState();
}

class _MultiFileSenderDialogState extends State<MultiFileSenderDialog>
    with SingleTickerProviderStateMixin {
  final List<FileInfo> _selectedFiles = [];
  bool _isLoading = false;
  bool _filesSent = false;

  OverlayEntry? _radialMenuOverlay;

  // Track file picker results for cleanup
  final List<FilePickerResult> _filePickerResults = [];

  @override
  void dispose() {
    _hideRadialMenu();
    // 🔥 FIX: Only cleanup if dialog was cancelled (not sent)
    if (!_filesSent) {
      _cleanupFilePickerCache();
    }
    // 🔥 CLEANUP: Clear selected files list to free memory
    _selectedFiles.clear();
    super.dispose();
  }

  /// 🔥 NEW: Cleanup file picker temporary files
  Future<void> _cleanupFilePickerCache() async {
    try {
      // Clear file picker cache to free temporary files
      await FilePicker.platform.clearTemporaryFiles();

      // Clear our tracked results
      _filePickerResults.clear();

      logInfo(
          'MultiFileSenderDialog: Cleaned up file picker cache and temporary files');
    } catch (e) {
      logWarning(
          'MultiFileSenderDialog: Failed to cleanup file picker cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.send),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Send Files to ${widget.targetUser.displayName}')),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedFiles.isNotEmpty)
              Row(
                children: [
                  _buildEnhancedAddFilesButton(),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearAllFiles,
                    icon: const Icon(Icons.clear_all),
                    label: Text(l10n.clearAll),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            if (_selectedFiles.isNotEmpty) const SizedBox(height: 16),
            Expanded(
              child: _selectedFiles.isEmpty
                  ? _buildEmptyState()
                  : _buildFilesList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 🔥 CLEANUP: Safe to clean cache when canceling - files won't be used
            _cleanupFilePickerCache();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedFiles.isEmpty || _isLoading ? null : _sendFiles,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: Text(_isLoading ? l10n.sending : l10n.sendFiles),
        ),
      ],
    );
  }

  Widget _buildEnhancedAddFilesButton() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _isLoading ? null : _pickFiles,
      onLongPressStart: _isLoading
          ? null
          : (details) => _showRadialMenu(details.globalPosition),
      onSecondaryTapDown: _isLoading
          ? null
          : (details) => _showRadialMenu(details.globalPosition),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: _isLoading
              ? Theme.of(context).disabledColor
              : Theme.of(context).colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: _isLoading
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
                    : Theme.of(context).colorScheme.onPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.addFiles,
                style: TextStyle(
                  color: _isLoading
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.38)
                      : Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isShowingRadialMenu() => _radialMenuOverlay != null;

  void _showRadialMenu(Offset position) {
    if (_isShowingRadialMenu()) return;

    _radialMenuOverlay = OverlayEntry(
      builder: (context) {
        return FileTypeRadialMenu(
          initialPosition: position,
          onCancel: _hideRadialMenu,
          onCategorySelected: (category) {
            _hideRadialMenu();
            if (category != null) {
              _onCategorySelected(category);
            }
          },
        );
      },
    );
    Overlay.of(context).insert(_radialMenuOverlay!);
  }

  void _hideRadialMenu() {
    if (_radialMenuOverlay != null) {
      _radialMenuOverlay!.remove();
      _radialMenuOverlay = null;
    }
  }

  void _onCategorySelected(FileCategory? category) {
    if (category == null) {
      logInfo('Radial menu selection cancelled.');
      return;
    }
    logInfo('Category selected: ${category.label}');
    _pickFilesForCategory(category);
  }

  void _pickFilesForCategory(FileCategory category) async {
    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the file directory service to pick files for this category
      final result = await FileDirectoryService.pickFilesByCategory(
        category,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        // 🔥 TRACK: Store result for cleanup
        _filePickerResults.add(result);

        await _addFilesFromResult(result);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Added ${result.files.length} file(s) from ${FileDirectoryService.getCategoryDisplayName(category)}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      logError('Error picking files for category ${category.label}: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting files from ${category.label}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Pick files using the default file picker.
  void _pickFiles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        // 🔥 TRACK: Store result for cleanup
        _filePickerResults.add(result);

        await _addFilesFromResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addFilesFromResult(FilePickerResult result) async {
    for (final file in result.files) {
      if (file.path != null) {
        final fileInfo = await _createFileInfo(file.path!);

        // Check if file is already selected
        final isAlreadySelected = _selectedFiles.any(
          (existing) => existing.path == fileInfo.path,
        );

        if (!isAlreadySelected) {
          setState(() {
            _selectedFiles.add(fileInfo);
          });
        }
      }
    }
  }

  Future<FileInfo> _createFileInfo(String filePath) async {
    final file = File(filePath);
    final stat = await file.stat();
    final name = file.path.split(Platform.pathSeparator).last;
    final extension =
        name.contains('.') ? name.split('.').last.toLowerCase() : '';

    return FileInfo(
      path: filePath,
      name: name,
      size: stat.size,
      extension: extension,
    );
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });
    // 🔥 CLEANUP: Safe to cleanup cache when clearing files - they won't be used
    _cleanupFilePickerCache();
  }

  void _sendFiles() async {
    if (_selectedFiles.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // 🔥 FIX: Mark files as sent before calling back
      _filesSent = true;

      final filePaths = _selectedFiles.map((file) => file.path).toList();
      widget.onSendFiles(filePaths);

      if (mounted) {
        // 🔥 IMPORTANT: DO NOT cleanup cache here - files are still needed for transfer
        // Cache will be cleaned up by P2P service after transfer completes
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Icons.archive;
      case 'txt':
        return Icons.text_snippet;
      case 'json':
      case 'xml':
      case 'html':
      case 'css':
      case 'js':
      case 'dart':
      case 'java':
      case 'cpp':
      case 'py':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _isLoading ? null : _pickFiles,
      onLongPressStart: _isLoading
          ? null
          : (details) => _showRadialMenu(details.globalPosition),
      onSecondaryTapDown: _isLoading
          ? null
          : (details) => _showRadialMenu(details.globalPosition),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noFilesSelected,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tapRightClickForOptions,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildEnhancedAddFilesButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with total size
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Files (${_selectedFiles.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _formatTotalSize(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const Divider(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final fileInfo = _selectedFiles[index];
              return ListTile(
                leading: Icon(
                  _getFileIcon(fileInfo.extension),
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  fileInfo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_formatFileSize(fileInfo.size)} • ${fileInfo.extension.toUpperCase()}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeFile(index),
                  color: Colors.red,
                ),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.transferSummary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Files:', '${_selectedFiles.length}',
                context: context),
            _buildSummaryRow('Total Size:', _formatTotalSize(),
                context: context),
            _buildSummaryRow('Recipient:', widget.targetUser.displayName,
                context: context),
          ],
        ),
      ),
    );
  }

  String _formatTotalSize() {
    if (_selectedFiles.isEmpty) return '0 B';
    final totalSize =
        _selectedFiles.fold<int>(0, (sum, file) => sum + file.size);
    return _formatBytes(totalSize);
  }

  Widget _buildSummaryRow(String label, String value,
      {required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

class FileInfo {
  final String path;
  final String name;
  final int size;
  final String extension;

  FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.extension,
  });
}
