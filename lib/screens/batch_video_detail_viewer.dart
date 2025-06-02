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
import 'package:my_multi_tools/l10n/app_localizations.dart';

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
  int _selectedIndex = 0; // 0: Data, 1: Stats

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
        content: Text(AppLocalizations.of(context)!.error(message)),
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

      // First, try to get dimensions directly using our helper
      Map<String, int> dimensions = {'width': 0, 'height': 0};
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        try {
          dimensions = await _getVideoResolution(file.path);
          print(
              'Dimensions extracted: ${dimensions['width']} x ${dimensions['height']}');
        } catch (e) {
          print('Dimension extraction error: $e');
        }
      }

      if (kIsWeb) {
        // Web doesn't support detailed info extraction
        return _getBasicFileInfo(file, fileStats);
      }
      if (Platform.isWindows) {
        try {
          // Use video player method for other information
          VideoInfo info = await _getVideoInfoUsingVideoPlayer(file, fileStats);

          // If we successfully got dimensions earlier, use those values
          if (dimensions['width']! > 0 && dimensions['height']! > 0) {
            info = VideoInfo(
              name: info.name,
              extension: info.extension,
              createdDate: info.createdDate,
              sizeMB: info.sizeMB,
              duration: info.duration,
              totalBitrate: info.totalBitrate,
              frameWidth: dimensions['width']!,
              frameHeight: dimensions['height']!,
              framerate: info.framerate,
              audioBitrate: info.audioBitrate,
              audioChannels: info.audioChannels,
            );
          }

          return info;
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
              Map<String, dynamic>? videoStream;
              Map<String, dynamic>? audioStream;

              try {
                videoStream = streams.firstWhere(
                  (s) => s['codec_type'] == 'video',
                ) as Map<String, dynamic>;
              } catch (e) {
                videoStream = null;
              }

              try {
                audioStream = streams.firstWhere(
                  (s) => s['codec_type'] == 'audio',
                ) as Map<String, dynamic>;
              } catch (e) {
                audioStream = null;
              }

              final duration =
                  double.tryParse(json['format']?['duration'] ?? '0') ?? 0;
              final bitrate =
                  int.tryParse(json['format']?['bit_rate'] ?? '0') ?? 0;
              final width = videoStream != null
                  ? (int.tryParse(videoStream['width']?.toString() ?? '0') ?? 0)
                  : 0;
              final height = videoStream != null
                  ? (int.tryParse(videoStream['height']?.toString() ?? '0') ??
                      0)
                  : 0;
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
          final mediaInfo = await MediaInfo().getMediaInfo(file
              .path); // Safely extract and parse media info values with proper null handling
          final durationMs = mediaInfo['duration'] != null
              ? int.tryParse(mediaInfo['duration'].toString()) ?? 0
              : 0;

          final duration = Duration(milliseconds: durationMs);

          // Ensure width and height are properly extracted and converted
          final width = mediaInfo['width'] != null
              ? int.tryParse(mediaInfo['width'].toString()) ?? 0
              : 0;

          final height = mediaInfo['height'] != null
              ? int.tryParse(mediaInfo['height'].toString()) ?? 0
              : 0;

          final bitrate = mediaInfo['bitrate'] != null
              ? int.tryParse(mediaInfo['bitrate'].toString()) ?? 0
              : 0;

          final framerate = mediaInfo['framerate'] != null
              ? double.tryParse(mediaInfo['framerate'].toString()) ?? 0.0
              : 0.0;

          final audioBitrate = mediaInfo['audioBitrate'] != null
              ? int.tryParse(mediaInfo['audioBitrate'].toString()) ?? 0
              : 0;

          final audioChannels = mediaInfo['audioChannels'] != null
              ? int.tryParse(mediaInfo['audioChannels'].toString()) ?? 0
              : 0;

          // Debug print to verify extraction
          print('Media info width: $width, height: $height');

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
      // Attempt to get dimensions from thumbnail
      int width = 0;
      int height = 0;

      try {
        // Use a higher maxWidth to potentially get better dimension information
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 1280, // Higher resolution may provide better metadata
          quality: 50,
          timeMs: 1000, // Sample 1 second into the video for better frame
        );

        if (thumbnailPath != null) {
          // Try to get more accurate dimensions using FFmpeg if available
          try {
            final cmd =
                '-v quiet -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "${file.path}"';
            final session = await FFmpegKit.executeAsync('ffprobe $cmd');
            final returnCode = await session.getReturnCode();
            if (ReturnCode.isSuccess(returnCode)) {
              final output = await session.getOutput();
              if (output != null && output.isNotEmpty) {
                final dimensions = output.trim().split(',');
                if (dimensions.length >= 2) {
                  width = int.tryParse(dimensions[0]) ?? 640;
                  height = int.tryParse(dimensions[1]) ?? 360;
                  print("FFprobe dimensions: $width x $height");
                } else {
                  // Fallback to common dimensions
                  width = 640;
                  height = 360;
                }
              } else {
                width = 640;
                height = 360;
              }
            } else {
              // Fallback to common dimensions
              width = 640;
              height = 360;
            }
          } catch (e) {
            print('FFmpeg dimension extraction error: $e');
            // Fallback to common dimensions
            width = 640;
            height = 360;
          }
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

    // Filter out entries with zero dimensions to avoid skewing statistics
    final validInfos = infos
        .where((info) => info.frameWidth > 0 && info.frameHeight > 0)
        .toList();

    // If no valid videos with dimensions, use all videos but set dimensions to defaults
    final hasValidDimensions = validInfos.isNotEmpty;
    final infoList = hasValidDimensions ? validInfos : infos;

    final numericFields = {
      'sizeMB': (VideoInfo info) => info.sizeMB,
      'totalBitrate': (VideoInfo info) => info.totalBitrate.toDouble(),
      'frameWidth': (VideoInfo info) =>
          info.frameWidth > 0 ? info.frameWidth.toDouble() : 640.0,
      'frameHeight': (VideoInfo info) =>
          info.frameHeight > 0 ? info.frameHeight.toDouble() : 360.0,
      'framerate': (VideoInfo info) =>
          info.framerate > 0 ? info.framerate : 30.0,
      'audioBitrate': (VideoInfo info) => info.audioBitrate.toDouble(),
      'audioChannels': (VideoInfo info) => info.audioChannels.toDouble(),
    };

    Map<String, dynamic> stats = {};

    for (var field in numericFields.keys) {
      if (infoList.isEmpty) continue;

      final values = infoList.map(numericFields[field]!).toList();

      // Print debug information for dimensions
      if (field == 'frameWidth' || field == 'frameHeight') {
        print('$field values: $values');
      }

      // Ensure there are values to calculate stats from
      if (values.isNotEmpty) {
        stats[field] = {
          'max': values.reduce((a, b) => a > b ? a : b),
          'min': values.reduce((a, b) => a < b ? a : b),
          'avg': values.reduce((a, b) => a + b) / values.length,
          'common': _findMostCommon(values),
        };
      } else {
        // Default values if we can't calculate
        stats[field] = {
          'max': 0,
          'min': 0,
          'avg': 0,
          'common': 0,
        };
      }
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

  // Helper method to extract video dimensions using ffprobe
  Future<Map<String, int>> _getVideoResolution(String filePath) async {
    try {
      final cmd =
          '-v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$filePath"';
      final session = await FFmpegKit.executeAsync('ffprobe $cmd');
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final output = await session.getOutput();
        if (output != null && output.isNotEmpty) {
          final dimensions = output.trim().split('x');
          if (dimensions.length == 2) {
            final width = int.tryParse(dimensions[0]) ?? 0;
            final height = int.tryParse(dimensions[1]) ?? 0;
            print('Extracted dimensions: $width x $height from $filePath');
            return {'width': width, 'height': height};
          }
        }
      }
    } catch (e) {
      print('Error extracting video dimensions: $e');
    }
    return {'width': 0, 'height': 0};
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
        title: Text(AppLocalizations.of(context)!.batchVideoDetailViewer),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.addVideos,
            onPressed: isLoading ? null : pickVideos,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: AppLocalizations.of(context)!.help,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.help),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Help"),
                        const SizedBox(height: 12),
                        Text(AppLocalizations.of(context)!.features),
                        const SizedBox(height: 8),
                        Text('• ' +
                            AppLocalizations.of(context)!.featureViewMultiple),
                        Text('• ' +
                            AppLocalizations.of(context)!.featureSeeTechnical),
                        Text('• ' +
                            AppLocalizations.of(context)!.featureCompareStats),
                        const SizedBox(height: 12),
                        Text(AppLocalizations.of(context)!.addVideosBy),
                        Text('• ' +
                            AppLocalizations.of(context)!.clickAddButton),
                        Text(
                            '• ' + AppLocalizations.of(context)!.dragDropFiles),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.close),
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
              : _selectedIndex == 0
                  ? _buildDataTab(stats, dateFormat, headingStyle, isMobile)
                  : _buildStatsTab(stats, headingStyle),
      bottomNavigationBar: videoInfos.isNotEmpty
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.table_chart),
                  label: AppLocalizations.of(context)!.dataTab,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bar_chart),
                  label: AppLocalizations.of(context)!.statsTab,
                ),
              ],
            )
          : null,
      floatingActionButton: isMobile && !isLoading
          ? FloatingActionButton(
              onPressed: pickVideos,
              tooltip: AppLocalizations.of(context)!.addVideos,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDataTab(Map<String, dynamic> stats, DateFormat dateFormat,
      TextStyle headingStyle, bool isMobile) {
    final loc = AppLocalizations.of(context)!;
    return DragTarget<List<File>>(
      onWillAccept: (files) => files != null && files.isNotEmpty,
      onAcceptWithDetails: (details) async {
        final files = details.data;
        if (files.isNotEmpty) {
          List<PlatformFile> platformFiles = files
              .map((file) => PlatformFile(
                    path: file.path,
                    name: file.path.split(Platform.pathSeparator).last,
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
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            loc.dropFilesToAdd,
                            style: const TextStyle(
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
                          headingRowColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.surfaceVariant,
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
                                label: Text(loc.name, style: headingStyle)),
                            DataColumn(
                                label: Text(loc.ext, style: headingStyle)),
                            DataColumn(
                                label:
                                    Text(loc.createdDate, style: headingStyle)),
                            DataColumn(
                                label: Text(loc.sizeMB, style: headingStyle)),
                            DataColumn(
                                label: Text(loc.duration, style: headingStyle)),
                            DataColumn(
                                label: Text(loc.totalBitrate,
                                    style: headingStyle)),
                            DataColumn(
                                label: Text(loc.width, style: headingStyle)),
                            DataColumn(
                                label: Text(loc.height, style: headingStyle)),
                            DataColumn(
                                label:
                                    Text(loc.framerate, style: headingStyle)),
                            DataColumn(
                                label: Text(loc.audioBitrate,
                                    style: headingStyle)),
                            DataColumn(
                                label: Text(loc.audioChannels,
                                    style: headingStyle)),
                          ],
                          rows: [
                            ...videoInfos.map((info) => DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          _truncateText(info.name, 20),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(info.extension)),
                                    DataCell(Text(
                                        dateFormat.format(info.createdDate))),
                                    DataCell(
                                        Text(info.sizeMB.toStringAsFixed(2))),
                                    DataCell(
                                        Text(_formatDuration(info.duration))),
                                    DataCell(Text(
                                        '${(info.totalBitrate / 1000).toStringAsFixed(2)} kbps')),
                                    DataCell(Text(info.frameWidth > 0
                                        ? info.frameWidth.toString()
                                        : "N/A")),
                                    DataCell(Text(info.frameHeight > 0
                                        ? info.frameHeight.toString()
                                        : "N/A")),
                                    DataCell(Text(
                                        info.framerate.toStringAsFixed(2))),
                                    DataCell(Text(
                                        '${(info.audioBitrate / 1000).toStringAsFixed(2)} kbps')),
                                    DataCell(
                                        Text(info.audioChannels.toString())),
                                  ],
                                )),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
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
    );
  }

  Widget _buildStatsTab(Map<String, dynamic> stats, TextStyle headingStyle) {
    final loc = AppLocalizations.of(context)!;
    if (stats.isEmpty) {
      return Center(child: Text(loc.noStatsAvailable));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.videoStatsSummary,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          // Resolution Analysis Card
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.resolution,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Common Resolution',
                          '${stats['frameWidth']['common']}x${stats['frameHeight']['common']}',
                          Icons.aspect_ratio,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Max Resolution',
                          '${stats['frameWidth']['max']}x${stats['frameHeight']['max']}',
                          Icons.photo_size_select_large,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Min Resolution',
                          '${stats['frameWidth']['min']}x${stats['frameHeight']['min']}',
                          Icons.photo_size_select_small,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bitrate Analysis Card
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.bitrate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Average Video Bitrate',
                          '${(stats['totalBitrate']['avg'] / 1000).toStringAsFixed(2)} kbps',
                          Icons.high_quality,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Max Video Bitrate',
                          '${(stats['totalBitrate']['max'] / 1000).toStringAsFixed(2)} kbps',
                          Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Average Audio Bitrate',
                          '${(stats['audioBitrate']['avg'] / 1000).toStringAsFixed(2)} kbps',
                          Icons.audiotrack,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Common Audio Channels',
                          '${stats['audioChannels']['common']}',
                          Icons.surround_sound,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Filesize Analysis Card
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.fileSize,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Average Size',
                          '${stats['sizeMB']['avg'].toStringAsFixed(2)} MB',
                          Icons.sd_storage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Largest',
                          '${stats['sizeMB']['max'].toStringAsFixed(2)} MB',
                          Icons.arrow_upward,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Smallest',
                          '${stats['sizeMB']['min'].toStringAsFixed(2)} MB',
                          Icons.arrow_downward,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Framerate Analysis Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.framerate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Common Framerate',
                          '${stats['framerate']['common'].toStringAsFixed(2)} FPS',
                          Icons.timelapse,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Average Framerate',
                          '${stats['framerate']['avg'].toStringAsFixed(2)} FPS',
                          Icons.speed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    final loc = AppLocalizations.of(context)!;
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
                    ? loc.dropVideosHere
                    : loc.noVideosSelected,
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
                      isMobile ? loc.tapAddVideos : loc.dragDropOrAdd,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: pickVideos,
                      icon: const Icon(Icons.add),
                      label: Text(loc.addVideos),
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
