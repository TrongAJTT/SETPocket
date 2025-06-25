import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/file_storage_service.dart';
import 'package:setpocket/widgets/generic/option_slider.dart';

class P2PDataTransferSettingsDialog extends StatefulWidget {
  final P2PDataTransferSettings? currentSettings;
  final Function(P2PDataTransferSettings) onSettingsChanged;

  const P2PDataTransferSettingsDialog({
    super.key,
    this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<P2PDataTransferSettingsDialog> createState() =>
      _P2PDataTransferSettingsDialogState();
}

class _P2PDataTransferSettingsDialogState
    extends State<P2PDataTransferSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late P2PDataTransferSettings _currentSettings;

  // --- New Slider Option Definitions using Bytes ---
  static final List<SliderOption<int>> _fileSizeOptions = [
    SliderOption(value: 50 * 1024 * 1024, label: '50 MB'),
    SliderOption(value: 100 * 1024 * 1024, label: '100 MB'),
    SliderOption(value: 200 * 1024 * 1024, label: '200 MB'),
    SliderOption(value: 500 * 1024 * 1024, label: '500 MB'),
    SliderOption(value: 1 * 1024 * 1024 * 1024, label: '1 GB'),
    SliderOption(value: 2 * 1024 * 1024 * 1024, label: '2 GB'),
    SliderOption(value: 5 * 1024 * 1024 * 1024, label: '5 GB'),
    SliderOption(value: 10 * 1024 * 1024 * 1024, label: '10 GB'),
    SliderOption(value: 20 * 1024 * 1024 * 1024, label: '20 GB'),
    SliderOption(value: 50 * 1024 * 1024 * 1024, label: '50 GB'),
    SliderOption(value: -1, label: 'Unlimited'),
  ];

  // Use the same options for both sliders to maintain consistency
  static final List<SliderOption<int>> _totalSizeOptions = _fileSizeOptions;

  // Find the closest option for a slider based on byte value
  static int _getNearestOptionValue(
      int bytes, List<SliderOption<int>> options) {
    if (bytes < 0) return -1; // Unlimited
    if (options.isEmpty) return 0;

    // Find the exact match first
    for (final option in options) {
      if (option.value == bytes) {
        return option.value;
      }
    }

    // If no exact match, find the closest one
    final closest = options.reduce(
        (a, b) => (a.value - bytes).abs() < (b.value - bytes).abs() ? a : b);
    return closest.value;
  }

  // Options for the Send tab sliders
  static final List<SliderOption<int>> _concurrentTasksOptions =
      List.generate(6, (i) => SliderOption(value: i + 1, label: '${i + 1}'))
        ..add(const SliderOption(value: 7, label: 'Unlimited'));

  static final List<SliderOption<int>> _chunkSizeOptions = [
    const SliderOption(value: 128, label: '128 KB'),
    const SliderOption(value: 256, label: '256 KB'),
    const SliderOption(value: 512, label: '512 KB'),
    const SliderOption(value: 1024, label: '1 MB'),
    const SliderOption(value: 2048, label: '2 MB'),
    const SliderOption(value: 5120, label: '5 MB'),
    const SliderOption(value: 10240, label: '10 MB'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize with current settings or create new default settings
    if (widget.currentSettings != null) {
      _currentSettings = widget.currentSettings!.copyWith();
    } else {
      // Create default settings if none provided
      _currentSettings = _createDefaultSettings();
    }

    // Set default path if empty
    _initializeDefaultPath();
  }

  Future<void> _initializeDefaultPath() async {
    if (_currentSettings.downloadPath.isEmpty) {
      final defaultPath = await _getDefaultDownloadPath();
      setState(() {
        _currentSettings.downloadPath = defaultPath;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _getDefaultDownloadPath() async {
    return await FileStorageService.instance.getAppDownloadsDirectory();
  }

  /// Create default transfer settings
  P2PDataTransferSettings _createDefaultSettings() {
    // Default path will be set by _initializeDefaultPath()
    return P2PDataTransferSettings(
      downloadPath: '', // Will be filled by _initializeDefaultPath
      createDateFolders: true,
      maxReceiveFileSize: 100 * 1024 * 1024, // 100MB in Bytes
      maxTotalReceiveSize: 1 * 1024 * 1024 * 1024, // 1GB in Bytes
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP',
      maxChunkSize: 512, // 512KB
    );
  }

  void _saveSettings() {
    widget.onSettingsChanged(_currentSettings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('P2P Data Transfer Settings'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, minWidth: 400),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Receive', icon: Icon(Icons.download)),
                  Tab(text: 'Send', icon: Icon(Icons.upload)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReceiveTab(),
                    _buildSendTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildReceiveTab() {
    final validFileSizeValue = _getNearestOptionValue(
      _currentSettings.maxReceiveFileSize,
      _fileSizeOptions,
    );

    final validTotalSizeValue = _getNearestOptionValue(
      _currentSettings.maxTotalReceiveSize,
      _totalSizeOptions,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Download Location Section ---
          Text(
            'Download Location',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller:
                TextEditingController(text: _currentSettings.downloadPath),
            decoration: InputDecoration(
              hintText: 'Select download folder',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              suffixIcon: IconButton(
                onPressed: _selectDownloadPath,
                icon: const Icon(Icons.folder_open),
              ),
            ),
            readOnly: true,
            onTap: _selectDownloadPath,
          ),
          const SizedBox(height: 12),

          // --- Storage Permission Info for Android ---
          if (Platform.isAndroid) ...[
            _buildPermissionInfoCard(),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final defaultPath = await _getDefaultDownloadPath();
                setState(() {
                  _currentSettings.downloadPath = defaultPath;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Use App-specific folder'),
            ),
            const SizedBox(height: 24),
          ],

          // --- Create Date Folders ---
          Card(
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              title: const Text('Create date folders'),
              subtitle: const Text('Organize files by date (YYYY-MM-DD)'),
              value: _currentSettings.createDateFolders,
              onChanged: (value) {
                setState(() {
                  _currentSettings.createDateFolders = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // --- Limits Section ---
          Text(
            'Receiving Limits',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          OptionSlider<int>(
            icon: Icons.insert_drive_file_outlined,
            label: 'Maximum File Size',
            subtitle: 'Limit the size of a single incoming file.',
            currentValue: validFileSizeValue,
            options: _fileSizeOptions,
            onChanged: (value) {
              setState(() {
                _currentSettings.maxReceiveFileSize = value;
              });
            },
          ),
          const SizedBox(height: 12),
          OptionSlider<int>(
            icon: Icons.inventory_2_outlined,
            label: 'Maximum Total Receive Size',
            subtitle: 'Limit the total size of all files in one transfer.',
            currentValue: validTotalSizeValue,
            options: _totalSizeOptions,
            onChanged: (value) {
              setState(() {
                _currentSettings.maxTotalReceiveSize = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Protocol Section ---
          Text(
            'Protocol',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'TCP',
                    label: Text('TCP'),
                    icon: Icon(Icons.sync_alt),
                  ),
                  ButtonSegment<String>(
                    value: 'UDP',
                    label: Text('UDP (Exp)'),
                    icon: Icon(Icons.network_check),
                  ),
                ],
                selected: {_currentSettings.sendProtocol},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _currentSettings.sendProtocol = newSelection.first;
                  });
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Performance Section ---
          Text(
            'Performance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // --- Max Concurrent Tasks ---
          OptionSlider<int>(
            icon: Icons.dynamic_feed_outlined,
            label: 'Concurrent Tasks',
            subtitle: 'Limit the number of simultaneous transfers.',
            currentValue: _currentSettings.maxConcurrentTasks,
            options: _concurrentTasksOptions,
            onChanged: (value) {
              setState(() {
                _currentSettings.maxConcurrentTasks = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // --- Max Chunk Size ---
          OptionSlider<int>(
            icon: Icons.burst_mode_outlined,
            label: 'Chunk Size',
            subtitle: 'Size of data packets sent over the network.',
            currentValue: _currentSettings.maxChunkSize,
            options: _chunkSizeOptions,
            onChanged: (value) {
              setState(() {
                _currentSettings.maxChunkSize = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionInfoCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FutureBuilder<AndroidDeviceInfo?>(
      future: Platform.isAndroid ? DeviceInfoPlugin().androidInfo : null,
      builder: (context, snapshot) {
        bool showWarning = false;
        if (snapshot.hasData && snapshot.data != null) {
          showWarning = (snapshot.data!.version.sdkInt ?? 0) >= 30;
        }

        if (!showWarning) {
          return const SizedBox.shrink();
        }

        return Card(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Android 11+ Storage Access',
                        style: textTheme.titleSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Due to new storage rules, selecting a custom download folder may not work reliably. Using the app-specific folder is recommended for best results.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectDownloadPath() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Download Folder',
    );
    if (path != null) {
      setState(() {
        _currentSettings.downloadPath = path;
      });
    }
  }
}
