import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/file_storage_service.dart';
import 'package:setpocket/services/network_security_service.dart';
import 'package:setpocket/widgets/generic/option_slider.dart';
import 'package:setpocket/widgets/generic/option_list_picker.dart';

class P2LanTransferSettingsLayout extends StatefulWidget {
  final P2PDataTransferSettings? currentSettings;
  final Function(P2PDataTransferSettings) onSettingsChanged;
  final VoidCallback? onCancel;
  final bool showActions;
  final bool isCompact;

  const P2LanTransferSettingsLayout({
    super.key,
    this.currentSettings,
    required this.onSettingsChanged,
    this.onCancel,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  State<P2LanTransferSettingsLayout> createState() =>
      _P2LanTransferSettingsLayoutState();
}

class _P2LanTransferSettingsLayoutState
    extends State<P2LanTransferSettingsLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late P2PDataTransferSettings _currentSettings;
  bool _hasChanges = false;
  String _customDisplayName = '';
  String _currentDeviceName = '';
  late TextEditingController _displayNameController;

  // Configuration options
  static final List<SliderOption<int>> _fileSizeOptions = [
    const SliderOption(value: 10 * 1024 * 1024, label: '10 MB'),
    const SliderOption(value: 50 * 1024 * 1024, label: '50 MB'),
    const SliderOption(value: 100 * 1024 * 1024, label: '100 MB'),
    const SliderOption(value: 200 * 1024 * 1024, label: '200 MB'),
    const SliderOption(value: 500 * 1024 * 1024, label: '500 MB'),
    const SliderOption(value: 1 * 1024 * 1024 * 1024, label: '1 GB'),
    const SliderOption(value: 2 * 1024 * 1024 * 1024, label: '2 GB'),
    const SliderOption(value: 5 * 1024 * 1024 * 1024, label: '5 GB'),
    const SliderOption(value: 10 * 1024 * 1024 * 1024, label: '10 GB'),
    const SliderOption(value: 50 * 1024 * 1024 * 1024, label: '50 GB'),
    const SliderOption(value: -1, label: 'Unlimited'),
  ];

  static final List<SliderOption<int>> _totalSizeOptions = [
    const SliderOption(value: 100 * 1024 * 1024, label: '100 MB'),
    const SliderOption(value: 500 * 1024 * 1024, label: '500 MB'),
    const SliderOption(value: 1 * 1024 * 1024 * 1024, label: '1 GB'),
    const SliderOption(value: 2 * 1024 * 1024 * 1024, label: '2 GB'),
    const SliderOption(value: 5 * 1024 * 1024 * 1024, label: '5 GB'),
    const SliderOption(value: 10 * 1024 * 1024 * 1024, label: '10 GB'),
    const SliderOption(value: 20 * 1024 * 1024 * 1024, label: '20 GB'),
    const SliderOption(value: 50 * 1024 * 1024 * 1024, label: '50 GB'),
    const SliderOption(value: 100 * 1024 * 1024 * 1024, label: '100 GB'),
    const SliderOption(value: -1, label: 'Unlimited'),
  ];

  static final List<SliderOption<int>> _concurrentTasksOptions = [
    const SliderOption(value: 1, label: '1'),
    const SliderOption(value: 2, label: '2'),
    const SliderOption(value: 3, label: '3 (Default)'),
    const SliderOption(value: 4, label: '4'),
    const SliderOption(value: 5, label: '5'),
    const SliderOption(value: 6, label: '6'),
    const SliderOption(value: 8, label: '8'),
    const SliderOption(value: 10, label: '10'),
    const SliderOption(value: 99, label: 'Unlimited'),
  ];

  static final List<SliderOption<int>> _chunkSizeOptions = [
    const SliderOption(value: 64, label: '64 KB'),
    const SliderOption(value: 128, label: '128 KB'),
    const SliderOption(value: 256, label: '256 KB'),
    const SliderOption(value: 512, label: '512 KB'),
    const SliderOption(value: 1024, label: '1 MB (Default)'),
    const SliderOption(value: 2048, label: '2 MB'),
    const SliderOption(value: 4096, label: '4 MB'),
    const SliderOption(value: 8192, label: '8 MB'),
    const SliderOption(value: 16384, label: '16 MB'),
  ];

  static final List<OptionItem<String>> _protocolOptions = [
    OptionItem.withDescription(
      'TCP',
      'TCP (Reliable)',
      'More reliable, better for important files',
    ),
    OptionItem.withDescription(
      'UDP',
      'UDP (Fast)',
      'Faster but less reliable, good for large files',
    ),
  ];

  static final List<OptionItem<String>> _fileOrganizationOptions = [
    OptionItem.withDescription(
      'none',
      'None',
      'Files go directly to download folder',
    ),
    OptionItem.withDescription(
      'date',
      'Create date folders',
      'Organize by date (YYYY-MM-DD)',
    ),
    OptionItem.withDescription(
      'sender',
      'Create sender folders',
      'Organize by sender display name',
    ),
  ];

  static final List<SliderOption<int>> _uiRefreshRateOptions = [
    const SliderOption(value: 0, label: 'Immediate'),
    const SliderOption(value: 1, label: '1 second'),
    const SliderOption(value: 2, label: '2 seconds'),
    const SliderOption(value: 3, label: '3 seconds'),
    const SliderOption(value: 4, label: '4 seconds'),
    const SliderOption(value: 5, label: '5 seconds'),
  ];

  static int _getNearestOptionValue(
      int bytes, List<SliderOption<int>> options) {
    if (bytes < 0) return -1;
    if (options.isEmpty) return options.first.value;

    SliderOption<int> closest = options.first;
    int minDiff = (closest.value - bytes).abs();

    for (final option in options) {
      final diff = (option.value - bytes).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = option;
      }
    }

    return closest.value;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _displayNameController = TextEditingController();
    _currentSettings =
        widget.currentSettings?.copyWith() ?? _createDefaultSettings();
    _initializeDefaultPath();
    _loadDeviceName();
  }

  Future<void> _loadDeviceName() async {
    try {
      final deviceName = await NetworkSecurityService.getDeviceName();
      if (mounted) {
        setState(() {
          _currentDeviceName = deviceName;
          // Use saved custom display name if available, otherwise use device name
          _customDisplayName = _currentSettings.customDisplayName ?? deviceName;
          _displayNameController.text =
              _customDisplayName; // Set controller text
        });
      }
    } catch (e) {
      // Fallback to default name
      if (mounted) {
        setState(() {
          _currentDeviceName = 'My Device';
          _customDisplayName =
              _currentSettings.customDisplayName ?? 'My Device';
          _displayNameController.text =
              _customDisplayName; // Set controller text
        });
      }
    }
  }

  Future<void> _initializeDefaultPath() async {
    if (_currentSettings.downloadPath.isEmpty) {
      final defaultPath = await _getDefaultDownloadPath();
      if (mounted) {
        setState(() {
          _currentSettings.downloadPath = defaultPath;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<String> _getDefaultDownloadPath() async {
    return await FileStorageService.instance.getAppDownloadsDirectory();
  }

  P2PDataTransferSettings _createDefaultSettings() {
    return P2PDataTransferSettings(
      downloadPath: '',
      createDateFolders: true,
      maxReceiveFileSize: 100 * 1024 * 1024, // 100MB
      maxTotalReceiveSize: 5 * 1024 * 1024 * 1024, // 5GB
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP',
      maxChunkSize: 1024, // 1MB
      uiRefreshRateSeconds: 0, // Default to immediate updates
      enableNotifications: true, // Default to enable notifications
      createSenderFolders: false, // Default to date folders
    );
  }

  String? _getFileOrganizationValue() {
    if (_currentSettings.createSenderFolders) {
      return 'sender';
    } else if (_currentSettings.createDateFolders) {
      return 'date';
    } else {
      return 'none';
    }
  }

  void _setFileOrganizationValue(String? value) {
    setState(() {
      switch (value) {
        case 'sender':
          _currentSettings.createSenderFolders = true;
          _currentSettings.createDateFolders = false;
          break;
        case 'date':
          _currentSettings.createSenderFolders = false;
          _currentSettings.createDateFolders = true;
          break;
        case 'none':
        default:
          _currentSettings.createSenderFolders = false;
          _currentSettings.createDateFolders = false;
          break;
      }
    });
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _saveSettings() {
    // Include display name in settings
    final updatedSettings = _currentSettings.copyWith(
      customDisplayName:
          _customDisplayName.isNotEmpty ? _customDisplayName : null,
    );

    widget.onSettingsChanged(updatedSettings);
    setState(() {
      _hasChanges = false;
    });
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
            'Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentSettings = _createDefaultSettings();
                _hasChanges = true;
              });
              _initializeDefaultPath();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        // Header with tabs
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Generic', icon: Icon(Icons.person, size: 18)),
              Tab(text: 'Storage', icon: Icon(Icons.storage, size: 18)),
              Tab(text: 'Network', icon: Icon(Icons.network_check, size: 18)),
            ],
            labelStyle: TextStyle(fontSize: widget.isCompact ? 12 : 14),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGenericTab(),
              _buildStorageTab(),
              _buildNetworkTab(),
            ],
          ),
        ),

        // Actions
        if (widget.showActions) ...[
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Reset button - always show on left
                TextButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Reset'),
                ),
                const Spacer(),
                if (widget.onCancel != null) ...[
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                ],
                FilledButton.icon(
                  onPressed: _hasChanges ? _saveSettings : null,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save Settings'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenericTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Device Profile', Icons.person),
          const SizedBox(height: 16),

          // Display name customization
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Display Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize how your device appears to other users',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Device Display Name',
                      hintText: 'Enter custom display name...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.edit),
                      helperText: 'Default: $_currentDeviceName',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _customDisplayName = value;
                      });
                      _markChanged();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // User Preferences
          _buildSectionHeader('User Preferences', Icons.settings),
          const SizedBox(height: 16),

          Card(
            child: SwitchListTile.adaptive(
              title: const Text('Enable notifications'),
              subtitle: const Text('Get notified about transfer events'),
              value: _currentSettings.enableNotifications,
              onChanged: (value) {
                setState(() {
                  _currentSettings.enableNotifications = value;
                });
                _markChanged();
              },
              secondary: const Icon(Icons.notifications),
            ),
          ),

          const SizedBox(height: 24),

          // User Interface Performance
          _buildSectionHeader('User Interface Performance', Icons.tune),
          const SizedBox(height: 16),

          Card(
            child: OptionSlider<int>(
              icon: Icons.schedule,
              label: 'UI Refresh Rate',
              subtitle:
                  'Choose how often transfer progress updates in the UI. Higher frequencies work better on powerful devices.',
              options: _uiRefreshRateOptions,
              currentValue: _currentSettings.uiRefreshRateSeconds,
              onChanged: (value) {
                setState(() {
                  _currentSettings.uiRefreshRateSeconds = value;
                });
                _markChanged();
              },
            ),
          ),

          const SizedBox(height: 24),

          // Current Configuration
          _buildSectionHeader('Current Configuration', Icons.settings),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildConfigRow(
                      'Display Name',
                      _customDisplayName.isNotEmpty
                          ? _customDisplayName
                          : _currentDeviceName),
                  _buildConfigRow('Protocol', _currentSettings.sendProtocol),
                  _buildConfigRow('Max File Size',
                      _formatBytes(_currentSettings.maxReceiveFileSize)),
                  _buildConfigRow('Max Total Size',
                      _formatBytes(_currentSettings.maxTotalReceiveSize)),
                  _buildConfigRow('Concurrent Tasks',
                      '${_currentSettings.maxConcurrentTasks}'),
                  _buildConfigRow(
                      'Chunk Size', '${_currentSettings.maxChunkSize} KB'),
                  _buildConfigRow(
                      'Date Folders',
                      _currentSettings.createDateFolders
                          ? 'Enabled'
                          : 'Disabled'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Storage Information
          _buildSectionHeader('Storage Information', Icons.info),
          const SizedBox(height: 16),
          if (_currentSettings.downloadPath.isNotEmpty) ...[
            FutureBuilder<Map<String, String>>(
              future: _getStorageInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final info = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildConfigRowWithWrap(
                              'Download Path', _currentSettings.downloadPath),
                          if (info['totalSpace'] != null)
                            _buildConfigRow('Total Space', info['totalSpace']!),
                          if (info['freeSpace'] != null)
                            _buildConfigRow('Free Space', info['freeSpace']!),
                          if (info['usedSpace'] != null)
                            _buildConfigRow('Used Space', info['usedSpace']!),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
              },
            ),
          ] else ...[
            _buildInfoCard(
              'No Download Path Set',
              'Please select a download folder in the Storage tab to see storage information.',
              Icons.warning,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStorageTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Download Location', Icons.folder),
          const SizedBox(height: 16),

          // Download path selector
          InkWell(
            onTap: _selectDownloadPath,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download Folder',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentSettings.downloadPath.isEmpty
                              ? 'Select download folder...'
                              : _currentSettings.downloadPath,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _currentSettings.downloadPath.isEmpty
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                        : null,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),

          if (Platform.isAndroid) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              'Android Storage Access',
              'For security, it\'s recommended to use the app-specific folder. You can select other folders, but this may require additional permissions.',
              Icons.security,
            ),
            const SizedBox(height: 8),
            // Only show "Use App Folder" button if current path is not the app folder
            FutureBuilder<String>(
              future: _getDefaultDownloadPath(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final appFolderPath = snapshot.data!;
                  final isCurrentlyAppFolder =
                      _currentSettings.downloadPath == appFolderPath;

                  if (isCurrentlyAppFolder) {
                    return const SizedBox.shrink(); // Hide button
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        final defaultPath = await _getDefaultDownloadPath();
                        setState(() {
                          _currentSettings.downloadPath = defaultPath;
                        });
                        _markChanged();
                      },
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('Use App Folder'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],

          const SizedBox(height: 24),

          // Organization settings
          _buildSectionHeader('File Organization', Icons.auto_awesome),
          const SizedBox(height: 16),

          OptionListPicker<String>(
            options: _fileOrganizationOptions,
            selectedValue: _getFileOrganizationValue(),
            onChanged: (value) {
              _setFileOrganizationValue(value);
              _markChanged();
            },
            allowMultiple: false,
            allowNull: true,
            showSelectionControl: true,
            isCompact: widget.isCompact,
          ),

          const SizedBox(height: 24),

          // Size limits
          _buildSectionHeader('Size Limits', Icons.policy),
          const SizedBox(height: 16),

          OptionSlider<int>(
            icon: Icons.description,
            label: 'Maximum file size (per file)',
            subtitle: 'Larger files will be automatically rejected',
            options: _fileSizeOptions,
            currentValue: _getNearestOptionValue(
              _currentSettings.maxReceiveFileSize,
              _fileSizeOptions,
            ),
            onChanged: (value) {
              setState(() {
                _currentSettings.maxReceiveFileSize = value;
              });
              _markChanged();
            },
          ),

          const SizedBox(height: 16),

          OptionSlider<int>(
            icon: Icons.inventory_2,
            label: 'Maximum total size (per transfer batch)',
            subtitle:
                'Total size limit for all files in a single transfer request',
            options: _totalSizeOptions,
            currentValue: _getNearestOptionValue(
              _currentSettings.maxTotalReceiveSize,
              _totalSizeOptions,
            ),
            onChanged: (value) {
              setState(() {
                _currentSettings.maxTotalReceiveSize = value;
              });
              _markChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Transfer Protocol', Icons.lan),
          const SizedBox(height: 16),

          // Protocol selection using OptionListPicker
          OptionListPicker<String>(
            options: _protocolOptions,
            selectedValue: _currentSettings.sendProtocol.toUpperCase(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _currentSettings.sendProtocol = value;
                });
                _markChanged();
              }
            },
            allowMultiple: false,
            allowNull: false,
            showSelectionControl: true,
            isCompact: widget.isCompact,
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Performance Tuning', Icons.speed),
          const SizedBox(height: 16),

          OptionSlider<int>(
            icon: Icons.dynamic_feed,
            label: 'Concurrent transfers',
            subtitle: 'More transfers = faster overall but higher CPU usage',
            options: _concurrentTasksOptions,
            currentValue: _currentSettings.maxConcurrentTasks > 10
                ? 99
                : _currentSettings.maxConcurrentTasks,
            onChanged: (value) {
              setState(() {
                _currentSettings.maxConcurrentTasks = value;
              });
              _markChanged();
            },
          ),

          const SizedBox(height: 16),

          OptionSlider<int>(
            icon: Icons.data_usage,
            label: 'Transfer chunk size',
            subtitle: 'Higher sizes = faster transfers but more memory usage',
            options: _chunkSizeOptions,
            currentValue: _getNearestOptionValue(
              _currentSettings.maxChunkSize,
              _chunkSizeOptions,
            ),
            onChanged: (value) {
              setState(() {
                _currentSettings.maxChunkSize = value;
              });
              _markChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRowWithWrap(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon,
      {Color? color}) {
    return Card(
      color: color ??
          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 0) return 'Unlimited';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<Map<String, String>> _getStorageInfo() async {
    try {
      final directory = Directory(_currentSettings.downloadPath);
      if (await directory.exists()) {
        final stat = await directory.stat();
        // Note: Getting actual disk space requires platform-specific implementation
        return {
          'path': _currentSettings.downloadPath,
          'exists': 'Yes',
          'accessible': 'Yes',
        };
      } else {
        return {
          'path': _currentSettings.downloadPath,
          'exists': 'No',
          'accessible': 'No',
        };
      }
    } catch (e) {
      return {
        'path': _currentSettings.downloadPath,
        'error': e.toString(),
      };
    }
  }

  void _selectDownloadPath() async {
    String? path;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 30) {
          path = await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'Select Download Folder',
          );
        } else {
          if (await Permission.storage.request().isGranted) {
            path = await FilePicker.platform.getDirectoryPath(
              dialogTitle: 'Select Download Folder',
            );
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Storage permission is required to select custom folder'),
                ),
              );
            }
            return;
          }
        }
      } else {
        path = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select Download Folder',
        );
      }

      if (path != null && mounted) {
        setState(() {
          _currentSettings.downloadPath = path!;
        });
        _markChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting folder: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
