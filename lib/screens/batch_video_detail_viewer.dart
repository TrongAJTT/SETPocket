import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:media_info/media_info.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'dart:convert';

class VideoInfo {
  final String name;
  final String extension;
  final DateTime createdDate;
  final double sizeMB;
  final Duration duration;
  final int totalBitrate;
  final int frameWidth;
  final int frameHeight;
  final double framerate;
  final int audioBitrate;
  final int audioChannels;

  VideoInfo({
    required this.name,
    required this.extension,
    required this.createdDate,
    required this.sizeMB,
    required this.duration,
    required this.totalBitrate,
    required this.frameWidth,
    required this.frameHeight,
    required this.framerate,
    required this.audioBitrate,
    required this.audioChannels,
  });
}

class BatchVideoDetailViewer extends StatefulWidget {
  const BatchVideoDetailViewer({super.key});

  @override
  State<BatchVideoDetailViewer> createState() => _BatchVideoDetailViewerState();
}

class _BatchVideoDetailViewerState extends State<BatchVideoDetailViewer> {
  List<VideoInfo> videoInfos = [];
  bool isLoading = false;

  Future<void> pickVideos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null) {
        await _processFiles(result.files);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _processFiles(List<PlatformFile> files) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<VideoInfo> newInfos = [];
      for (var file in files) {
        if (file.path != null) {
          final videoFile = File(file.path!);
          final videoInfo = await _getVideoInfo(videoFile);
          newInfos.add(videoInfo);
        }
      }

      setState(() {
        videoInfos = newInfos;
        isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<VideoInfo> _getVideoInfo(File file) async {
    try {
      final fileStats = await file.stat();

      if (kIsWeb) {
        // Web không hỗ trợ lấy thông tin chi tiết, sử dụng thông tin cơ bản
        return _getBasicFileInfo(file, fileStats);
      }
      if (Platform.isWindows) {
        try {
          // Sử dụng phương pháp ước tính
          return await _getVideoInfoUsingVideoPlayer(file, fileStats);
        } catch (e) {
          print('Basic video info error: $e');
          try {
            // Thử sử dụng ffprobe (dự phòng)
            final cmd =
                '-v quiet -print_format json -show_format -show_streams "${file.path}"';
            final session = await FFmpegKit.executeAsync('ffprobe $cmd');
            final returnCode = await session.getReturnCode();
            if (ReturnCode.isSuccess(returnCode)) {
              final output = await session.getOutput();
              final json = jsonDecode(output ?? '{}');
              final streams = json['streams'] as List<dynamic>? ?? [];
              final videoStream = streams.firstWhere(
                  (s) => s['codec_type'] == 'video',
                  orElse: () => null);
              final audioStream = streams.firstWhere(
                  (s) => s['codec_type'] == 'audio',
                  orElse: () => null);

              final duration =
                  double.tryParse(json['format']?['duration'] ?? '0') ?? 0;
              final bitrate =
                  int.tryParse(json['format']?['bit_rate'] ?? '0') ?? 0;
              final width = videoStream?['width'] ?? 0;
              final height = videoStream?['height'] ?? 0;
              final framerate = double.tryParse(
                      (videoStream?['avg_frame_rate'] ?? '0/1')
                          .toString()
                          .split('/')
                          .first) ??
                  0.0;
              final audioBitrate =
                  int.tryParse(audioStream?['bit_rate'] ?? '0') ?? 0;
              final audioChannels = audioStream?['channels'] ?? 0;

              return VideoInfo(
                name: file.path
                    .split(Platform.pathSeparator)
                    .last
                    .split('.')
                    .first,
                extension: file.path.split('.').last,
                createdDate: fileStats.changed,
                sizeMB: fileStats.size / (1024 * 1024),
                duration: Duration(seconds: duration.round()),
                totalBitrate: bitrate,
                frameWidth: width,
                frameHeight: height,
                framerate: framerate,
                audioBitrate: audioBitrate,
                audioChannels: audioChannels,
              );
            }
          } catch (ffmpegError) {
            print('FFmpeg plugin error: $ffmpegError');
          }
          // Nếu cả hai cách đều không hoạt động, sử dụng thông tin cơ bản
          return _getBasicFileInfo(file, fileStats);
        }
      } else {
        try {
          final mediaInfo = await MediaInfo().getMediaInfo(file.path);
          final durationMs =
              int.tryParse(mediaInfo['duration']?.toString() ?? '0') ?? 0;
          final duration = Duration(milliseconds: durationMs);
          final width =
              int.tryParse(mediaInfo['width']?.toString() ?? '0') ?? 0;
          final height =
              int.tryParse(mediaInfo['height']?.toString() ?? '0') ?? 0;
          final bitrate =
              int.tryParse(mediaInfo['bitrate']?.toString() ?? '0') ?? 0;
          final framerate =
              double.tryParse(mediaInfo['framerate']?.toString() ?? '0') ?? 0.0;
          final audioBitrate =
              int.tryParse(mediaInfo['audioBitrate']?.toString() ?? '0') ?? 0;
          final audioChannels =
              int.tryParse(mediaInfo['audioChannels']?.toString() ?? '0') ?? 0;

          return VideoInfo(
            name: file.path.split(Platform.pathSeparator).last.split('.').first,
            extension: file.path.split('.').last,
            createdDate: fileStats.changed,
            sizeMB: fileStats.size / (1024 * 1024),
            duration: duration,
            totalBitrate: bitrate,
            frameWidth: width,
            frameHeight: height,
            framerate: framerate,
            audioBitrate: audioBitrate,
            audioChannels: audioChannels,
          );
        } catch (e) {
          print('MediaInfo error: $e');
          return _getBasicFileInfo(file, fileStats);
        }
      }
    } catch (e) {
      print('Error getting video info: $e');
      final fileStats = await file.stat();
      return _getBasicFileInfo(file, fileStats);
    }
  }

  Future<VideoInfo> _getVideoInfoUsingVideoPlayer(
      File file, FileStat fileStats) async {
    try {
      // Thử lấy kích thước từ thumbnail (có thể không chính xác nhưng cho ta biết được nếu video hợp lệ)
      int width = 0;
      int height = 0;

      try {
        // Nếu có thể tạo thumbnail, video có khả năng hợp lệ
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 25,
        );

        if (thumbnailPath != null) {
          // Video hợp lệ, nhưng kích thước có thể không chính xác từ thumbnail nhỏ
          width = 640; // Giả định kích thước video phổ biến
          height = 360;
        }
      } catch (e) {
        print('Thumbnail generation error: $e');
      }

      // Ước lượng thời lượng dựa trên kích thước file (không chính xác)
      final estimatedSeconds = (fileStats.size / 1000000)
          .round(); // ~1MB/s cho video chất lượng thấp
      final estimatedDuration =
          Duration(seconds: estimatedSeconds > 0 ? estimatedSeconds : 0);

      return VideoInfo(
        name: file.path.split(Platform.pathSeparator).last.split('.').first,
        extension: file.path.split('.').last,
        createdDate: fileStats.changed,
        sizeMB: fileStats.size / (1024 * 1024),
        duration: estimatedDuration,
        totalBitrate: (fileStats.size *
                8 /
                (estimatedSeconds > 0 ? estimatedSeconds : 1) /
                1000)
            .round(), // Bitrate ước tính
        frameWidth: width,
        frameHeight: height,
        framerate: 30.0, // Giả định 30fps
        audioBitrate: 128, // Giả định 128kbps
        audioChannels: 2, // Giả định stereo
      );
    } catch (e) {
      print('Video info extraction error: $e');
      return _getBasicFileInfo(file, fileStats);
    }
  }

  // Phương pháp dự phòng để lấy thông tin cơ bản của video khi plugin không hoạt động
  VideoInfo _getBasicFileInfo(File file, FileStat fileStats) {
    return VideoInfo(
      name: file.path.split(Platform.pathSeparator).last.split('.').first,
      extension: file.path.split('.').last,
      createdDate: fileStats.changed,
      sizeMB: fileStats.size / (1024 * 1024),
      duration: const Duration(seconds: 0),
      totalBitrate: 0,
      frameWidth: 0,
      frameHeight: 0,
      framerate: 0,
      audioBitrate: 0,
      audioChannels: 0,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  Map<String, dynamic> _calculateStats(List<VideoInfo> infos) {
    if (infos.isEmpty) return {};

    final numericFields = {
      'sizeMB': (VideoInfo info) => info.sizeMB,
      'totalBitrate': (VideoInfo info) => info.totalBitrate.toDouble(),
      'frameWidth': (VideoInfo info) => info.frameWidth.toDouble(),
      'frameHeight': (VideoInfo info) => info.frameHeight.toDouble(),
      'framerate': (VideoInfo info) => info.framerate,
      'audioBitrate': (VideoInfo info) => info.audioBitrate.toDouble(),
      'audioChannels': (VideoInfo info) => info.audioChannels.toDouble(),
    };

    Map<String, dynamic> stats = {};

    for (var field in numericFields.keys) {
      final values = infos.map(numericFields[field]!).toList();
      stats[field] = {
        'max': values.reduce((a, b) => a > b ? a : b),
        'min': values.reduce((a, b) => a < b ? a : b),
        'avg': values.reduce((a, b) => a + b) / values.length,
        'common': _findMostCommon(values),
      };
    }

    return stats;
  }

  dynamic _findMostCommon(List<dynamic> values) {
    final counts = <dynamic, int>{};
    for (var value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats(videoInfos);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final isMobile = MediaQuery.of(context).size.width < 600;

    final headingStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Video Detail Viewer'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Videos',
            onPressed: isLoading ? null : pickVideos,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Help'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'This tool shows detailed information about video files.'),
                        SizedBox(height: 12),
                        Text('Features:'),
                        SizedBox(height: 8),
                        Text('• View multiple video files at once'),
                        Text(
                            '• See technical details like bitrate, resolution, etc'),
                        Text('• Compare stats across videos'),
                        SizedBox(height: 12),
                        Text('You can add videos by:'),
                        Text('• Clicking the + button'),
                        Text('• Dragging and dropping files'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : videoInfos.isEmpty
              ? _buildEmptyState(isMobile)
              : DragTarget<List<File>>(
                  onWillAccept: (files) => files != null && files.isNotEmpty,
                  onAcceptWithDetails: (details) async {
                    final files = details.data;
                    if (files.isNotEmpty) {
                      List<PlatformFile> platformFiles = files
                          .map((file) => PlatformFile(
                                path: file.path,
                                name: file.path
                                    .split(Platform.pathSeparator)
                                    .last,
                                size: file.lengthSync(),
                              ))
                          .toList();
                      await _processFiles(platformFiles);
                    }
                  },
                  builder: (context, candidates, rejects) => Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: candidates.isNotEmpty
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.2)
                              : null,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (candidates.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      width: double.infinity,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      child: const Text(
                                        'Drop files to add them',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Card(
                                    elevation: 2,
                                    clipBehavior: Clip.antiAlias,
                                    margin: EdgeInsets.zero,
                                    child: DataTable(
                                      headingRowHeight: 50,
                                      dataRowMinHeight: 48,
                                      dataRowMaxHeight: 64,
                                      horizontalMargin: 24,
                                      columnSpacing: 20,
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                        Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                      ),
                                      border: TableBorder(
                                        horizontalInside: BorderSide(
                                          width: 1,
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      columns: [
                                        DataColumn(
                                            label: Text('Name',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Ext',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Created Date',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Size (MB)',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Duration',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Total Bitrate',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Width',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Height',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Framerate',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Audio Bitrate',
                                                style: headingStyle)),
                                        DataColumn(
                                            label: Text('Audio Channels',
                                                style: headingStyle)),
                                      ],
                                      rows: [
                                        ...videoInfos.map((info) => DataRow(
                                              cells: [
                                                DataCell(
                                                  SizedBox(
                                                    width: 150,
                                                    child: Text(
                                                      _truncateText(
                                                          info.name, 20),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(Text(info.extension)),
                                                DataCell(Text(dateFormat
                                                    .format(info.createdDate))),
                                                DataCell(Text(info.sizeMB
                                                    .toStringAsFixed(2))),
                                                DataCell(Text(_formatDuration(
                                                    info.duration))),
                                                DataCell(Text(
                                                    '${(info.totalBitrate / 1000).toStringAsFixed(2)} kbps')),
                                                DataCell(Text(info.frameWidth
                                                    .toString())),
                                                DataCell(Text(info.frameHeight
                                                    .toString())),
                                                DataCell(Text(info.framerate
                                                    .toStringAsFixed(2))),
                                                DataCell(Text(
                                                    '${(info.audioBitrate / 1000).toStringAsFixed(2)} kbps')),
                                                DataCell(Text(info.audioChannels
                                                    .toString())),
                                              ],
                                            )),
                                        if (stats.isNotEmpty) ...[
                                          // MAX row with bold background
                                          DataRow(
                                            color: MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                                  .withOpacity(0.3),
                                            ),
                                            cells: [
                                              DataCell(Text('MAX',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              const DataCell(Text('')),
                                              const DataCell(Text('')),
                                              DataCell(Text(
                                                  stats['sizeMB']['max']
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              const DataCell(Text('')),
                                              DataCell(Text(
                                                  '${(stats['totalBitrate']['max'] / 1000).toStringAsFixed(2)} kbps',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  stats['frameWidth']['max']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  stats['frameHeight']['max']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  stats['framerate']['max']
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  '${(stats['audioBitrate']['max'] / 1000).toStringAsFixed(2)} kbps',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  stats['audioChannels']['max']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                            ],
                                          ),
                                          // MIN row with light background
                                          DataRow(
                                            color: MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant
                                                  .withOpacity(0.2),
                                            ),
                                            cells: [
                                              DataCell(Text('MIN',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              const DataCell(Text('')),
                                              const DataCell(Text('')),
                                              DataCell(Text(stats['sizeMB']
                                                      ['min']
                                                  .toStringAsFixed(2))),
                                              const DataCell(Text('')),
                                              DataCell(Text(
                                                  '${(stats['totalBitrate']['min'] / 1000).toStringAsFixed(2)} kbps')),
                                              DataCell(Text(stats['frameWidth']
                                                      ['min']
                                                  .toString())),
                                              DataCell(Text(stats['frameHeight']
                                                      ['min']
                                                  .toString())),
                                              DataCell(Text(stats['framerate']
                                                      ['min']
                                                  .toStringAsFixed(2))),
                                              DataCell(Text(
                                                  '${(stats['audioBitrate']['min'] / 1000).toStringAsFixed(2)} kbps')),
                                              DataCell(Text(
                                                  stats['audioChannels']['min']
                                                      .toString())),
                                            ],
                                          ),
                                          // AVG row with light background
                                          DataRow(
                                            color: MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant
                                                  .withOpacity(0.2),
                                            ),
                                            cells: [
                                              DataCell(Text('AVG',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              const DataCell(Text('')),
                                              const DataCell(Text('')),
                                              DataCell(Text(stats['sizeMB']
                                                      ['avg']
                                                  .toStringAsFixed(2))),
                                              const DataCell(Text('')),
                                              DataCell(Text(
                                                  '${(stats['totalBitrate']['avg'] / 1000).toStringAsFixed(2)} kbps')),
                                              DataCell(Text(stats['frameWidth']
                                                      ['avg']
                                                  .toStringAsFixed(2))),
                                              DataCell(Text(stats['frameHeight']
                                                      ['avg']
                                                  .toStringAsFixed(2))),
                                              DataCell(Text(stats['framerate']
                                                      ['avg']
                                                  .toStringAsFixed(2))),
                                              DataCell(Text(
                                                  '${(stats['audioBitrate']['avg'] / 1000).toStringAsFixed(2)} kbps')),
                                              DataCell(Text(
                                                  stats['audioChannels']['avg']
                                                      .toStringAsFixed(2))),
                                            ],
                                          ),
                                          // COMMON row with bold background
                                          DataRow(
                                            color: MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                                  .withOpacity(0.3),
                                            ),
                                            cells: [
                                              DataCell(Text('COMMON',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              const DataCell(Text('')),
                                              const DataCell(Text('')),
                                              DataCell(Text(
                                                  stats['sizeMB']['common']
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              const DataCell(Text('')),
                                              DataCell(Text(
                                                  '${(stats['totalBitrate']['common'] / 1000).toStringAsFixed(2)} kbps',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  stats['frameWidth']['common']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  stats['frameHeight']['common']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  stats['framerate']['common']
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  '${(stats['audioBitrate']['common'] / 1000).toStringAsFixed(2)} kbps',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                              DataCell(Text(
                                                  stats['audioChannels']
                                                          ['common']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (candidates.isNotEmpty)
                        Positioned.fill(
                          child: Container(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.05),
                            child: const Center(
                              child: Text(
                                'Drop videos here',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: isLoading ? null : pickVideos,
              tooltip: 'Add videos',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return DragTarget<List<File>>(
      onWillAccept: (files) => files != null && files.isNotEmpty,
      onAcceptWithDetails: (details) async {
        final files = details.data;
        if (files.isNotEmpty) {
          List<PlatformFile> platformFiles = [];
          for (var file in files) {
            platformFiles.add(
              PlatformFile(
                path: file.path,
                name: file.path.split(Platform.pathSeparator).last,
                size: file.lengthSync(),
              ),
            );
          }
          await _processFiles(platformFiles);
        }
      },
      builder: (context, candidateFiles, rejectedFiles) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: candidateFiles.isNotEmpty
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15)
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                size: 84,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                candidateFiles.isNotEmpty
                    ? 'Drop video files here'
                    : 'No videos selected',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      isMobile
                          ? 'Tap the + button to add videos'
                          : 'Drag and drop video files here or click the + button',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: pickVideos,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Videos'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
