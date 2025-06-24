import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/file_storage_service.dart';

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

  // Receive tab settings
  late TextEditingController _pathController;
  late bool _createDateFolders;
  late int _maxReceiveFileSize;

  // Send tab settings
  late String _protocol; // 'TCP' or 'UDP'
  late int _maxChunkSize; // in KB

  // Chunk size options in KB
  static const List<int> _chunkSizeOptions = [
    32,
    64,
    128,
    256,
    512,
    1024,
    2048,
    5120,
    10240
  ];
  static const Map<int, String> _chunkSizeLabels = {
    32: '32KB',
    64: '64KB',
    128: '128KB',
    256: '256KB',
    512: '512KB',
    1024: '1MB',
    2048: '2MB',
    5120: '5MB',
    10240: '10MB',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize with current settings or defaults
    final settings = widget.currentSettings;
    _pathController = TextEditingController(text: settings?.downloadPath ?? '');
    _createDateFolders = settings?.createDateFolders ?? false;
    _maxReceiveFileSize = settings?.maxReceiveFileSize ?? 100;
    _protocol = settings?.sendProtocol ?? 'TCP';
    _maxChunkSize = settings?.maxChunkSize ?? 512;

    // Set default path if empty
    _initializeDefaultPath();
  }

  Future<void> _initializeDefaultPath() async {
    if (_pathController.text.isEmpty) {
      final defaultPath = await _getDefaultDownloadPath();
      setState(() {
        _pathController.text = defaultPath;
      });
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _getDefaultDownloadPath() async {
    return await FileStorageService.instance.getAppDownloadsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('P2P Data Transfer Settings'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildReceiveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Download Location
          const Text(
            'Download Location',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    hintText: 'Select download folder',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _selectDownloadPath,
                icon: const Icon(Icons.folder_open),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Storage Permission Info for Android
          if (Platform.isAndroid) ...[
            _buildPermissionInfoCard(),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final defaultPath = await _getDefaultDownloadPath();
                setState(() {
                  _pathController.text = defaultPath;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Use Default Location'),
            ),
            const SizedBox(height: 24),
          ],

          // Create Date Folders
          Card(
            child: SwitchListTile(
              title: const Text('Create date folders'),
              subtitle: const Text('Organize files by date (YYYY-MM-DD)'),
              value: _createDateFolders,
              onChanged: (value) {
                setState(() {
                  _createDateFolders = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Max File Size
          const Text(
            'Maximum File Size (MB)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Slider(
                    value: _maxReceiveFileSize.toDouble(),
                    min: 1,
                    max: 1000,
                    divisions: 100,
                    label: '${_maxReceiveFileSize}MB',
                    onChanged: (value) {
                      setState(() {
                        _maxReceiveFileSize = value.round();
                      });
                    },
                  ),
                  Text(
                    'Current: ${_maxReceiveFileSize}MB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Protocol Selection
          const Text(
            'Transfer Protocol',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('TCP (Reliable)'),
                    subtitle: const Text('Guaranteed delivery, slower'),
                    value: 'TCP',
                    groupValue: _protocol,
                    onChanged: (value) {
                      setState(() {
                        _protocol = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('UDP (Fast)'),
                    subtitle: const Text('Faster but less reliable'),
                    value: 'UDP',
                    groupValue: _protocol,
                    onChanged: (value) {
                      setState(() {
                        _protocol = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Max Chunk Size
          const Text(
            'Maximum Chunk Size',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Slider(
                    value: _chunkSizeOptions.indexOf(_maxChunkSize).toDouble(),
                    min: 0,
                    max: (_chunkSizeOptions.length - 1).toDouble(),
                    divisions: _chunkSizeOptions.length - 1,
                    label: _chunkSizeLabels[_maxChunkSize],
                    onChanged: (value) {
                      setState(() {
                        _maxChunkSize = _chunkSizeOptions[value.round()];
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: ${_chunkSizeLabels[_maxChunkSize]}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Larger chunks = faster transfer but more memory usage',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionInfoCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.shade900.withOpacity(0.3)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Storage Permission',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Default location: App-specific folder (no permission needed)\n'
            '• Custom location: Requires storage permission\n'
            '• Storage permission allows access to all files on device',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.blue.shade100 : Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDownloadPath() async {
    // Show location options for Android
    if (Platform.isAndroid) {
      await _showLocationOptionsDialog();
    } else {
      // For other platforms, use file picker directly
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        setState(() {
          _pathController.text = selectedDirectory;
        });
      }
    }
  }

  Future<void> _showLocationOptionsDialog() async {
    final locations =
        await FileStorageService.instance.getAvailableDownloadLocations();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Download Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: locations.map((location) {
            return Card(
              child: ListTile(
                title: Text(location.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.description),
                    const SizedBox(height: 4),
                    Text(
                      location.path,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                leading: Icon(
                  location.requiresPermission ? Icons.security : Icons.folder,
                  color: location.isAvailable ? null : Colors.grey,
                ),
                trailing: location.requiresPermission && !location.isAvailable
                    ? const Icon(Icons.lock, color: Colors.orange)
                    : null,
                enabled: location.isAvailable,
                onTap: location.isAvailable
                    ? () async {
                        Navigator.of(context).pop();

                        if (location.requiresPermission) {
                          final hasPermission =
                              await _requestStoragePermission();
                          if (!hasPermission) return;
                        }

                        setState(() {
                          _pathController.text = location.path;
                        });
                      }
                    : null,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Custom path selection
              final hasPermission = await _requestStoragePermission();
              if (!hasPermission) return;

              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();
              if (selectedDirectory != null) {
                setState(() {
                  _pathController.text = selectedDirectory;
                });
              }
            },
            child: const Text('Custom Path'),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestStoragePermission() async {
    // Check Android SDK version
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;

    PermissionStatus status;

    if (sdkInt >= 30) {
      // Android 11+ (API 30+) - Use MANAGE_EXTERNAL_STORAGE
      status = await Permission.manageExternalStorage.status;

      if (!status.isGranted) {
        // Show explanation dialog first
        final shouldRequest = await _showPermissionExplanationDialog();
        if (!shouldRequest) return false;

        status = await Permission.manageExternalStorage.request();

        if (!status.isGranted) {
          await _showPermissionDeniedDialog();
          return false;
        }
      }
    } else {
      // Android 10 and below - Use legacy storage permission
      status = await Permission.storage.status;

      if (!status.isGranted) {
        status = await Permission.storage.request();

        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Storage permission is required to select download folder'),
              duration: Duration(seconds: 3),
            ),
          );
          return false;
        }
      }
    }

    return status.isGranted;
  }

  Future<bool> _showPermissionExplanationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Storage Permission Required'),
            content: const Text(
              'This app needs access to manage files on your device to set a custom download location for received files.\n\n'
              'Please grant "All files access" permission in the next screen.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showPermissionDeniedDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'Storage permission was denied. You can enable it manually in Settings > Apps > SETPocket > Permissions.\n\n'
          'Without this permission, you can only use the default download location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    final settings = P2PDataTransferSettings(
      downloadPath: _pathController.text,
      createDateFolders: _createDateFolders,
      maxReceiveFileSize: _maxReceiveFileSize,
      sendProtocol: _protocol,
      maxChunkSize: _maxChunkSize,
    );

    widget.onSettingsChanged(settings);
    Navigator.of(context).pop();
  }
}
