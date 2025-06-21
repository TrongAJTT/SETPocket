import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/file_storage_service.dart';

class FileStorageSettingsDialog extends StatefulWidget {
  final P2PFileStorageSettings? currentSettings;
  final Function(P2PFileStorageSettings) onSettingsChanged;

  const FileStorageSettingsDialog({
    super.key,
    this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<FileStorageSettingsDialog> createState() =>
      _FileStorageSettingsDialogState();
}

class _FileStorageSettingsDialogState extends State<FileStorageSettingsDialog> {
  late TextEditingController _pathController;
  late bool _askBeforeDownload;
  late bool _createDateFolders;
  late int _maxFileSize;

  @override
  void initState() {
    super.initState();

    // Initialize with current settings or defaults
    final settings = widget.currentSettings;
    _pathController = TextEditingController(text: settings?.downloadPath ?? '');
    _askBeforeDownload = settings?.askBeforeDownload ?? true;
    _createDateFolders = settings?.createDateFolders ?? false;
    _maxFileSize = settings?.maxFileSize ?? 100;

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
    super.dispose();
  }

  Future<String> _getDefaultDownloadPath() async {
    return await FileStorageService.instance.getAppDownloadsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('File Storage Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Download path
            const Text(
              'Download Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            // Permission info for Android
            if (Platform.isAndroid) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Storage Permission',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Default location: App-specific folder (no permission needed)\n'
                      '• Custom location: Requires storage permission\n'
                      '• Storage permission allows access to all files on device',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Reset to default button
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
            ],
            const SizedBox(height: 16),

            // Ask before download
            SwitchListTile(
              title: const Text('Ask before download'),
              subtitle: const Text('Show confirmation dialog for each file'),
              value: _askBeforeDownload,
              onChanged: (value) {
                setState(() {
                  _askBeforeDownload = value;
                });
              },
            ),

            // Create date folders
            SwitchListTile(
              title: const Text('Create date folders'),
              subtitle: const Text('Organize files by date (YYYY-MM-DD)'),
              value: _createDateFolders,
              onChanged: (value) {
                setState(() {
                  _createDateFolders = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Max file size
            const Text(
              'Maximum File Size (MB)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _maxFileSize.toDouble(),
              min: 1,
              max: 1000,
              divisions: 100,
              label: '${_maxFileSize}MB',
              onChanged: (value) {
                setState(() {
                  _maxFileSize = value.round();
                });
              },
            ),
            Text(
              'Current: ${_maxFileSize}MB',
              style: Theme.of(context).textTheme.bodySmall,
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
    final settings = P2PFileStorageSettings(
      downloadPath: _pathController.text,
      askBeforeDownload: _askBeforeDownload,
      createDateFolders: _createDateFolders,
      maxFileSize: _maxFileSize,
    );

    widget.onSettingsChanged(settings);
    Navigator.of(context).pop();
  }
}
