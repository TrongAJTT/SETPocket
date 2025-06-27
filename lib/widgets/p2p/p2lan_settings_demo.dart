import 'package:flutter/material.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/widgets/p2p/p2lan_transfer_settings_helper.dart';

class P2LanSettingsDemo extends StatefulWidget {
  const P2LanSettingsDemo({super.key});

  @override
  State<P2LanSettingsDemo> createState() => _P2LanSettingsDemoState();
}

class _P2LanSettingsDemoState extends State<P2LanSettingsDemo> {
  P2PDataTransferSettings? _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = P2PDataTransferSettings(
      downloadPath: '/storage/emulated/0/Download',
      createDateFolders: true,
      maxReceiveFileSize: 100 * 1024 * 1024, // 100MB
      maxTotalReceiveSize: 5 * 1024 * 1024 * 1024, // 5GB
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP',
      maxChunkSize: 1024, // 1MB
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P2Lan Settings Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test the new adaptive settings UI',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                P2LanTransferSettingsHelper.showSettings(
                  context,
                  currentSettings: _currentSettings,
                  onSettingsChanged: (newSettings) {
                    setState(() {
                      _currentSettings = newSettings;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                P2LanTransferSettingsHelper.showQuickSettings(
                  context,
                  currentSettings: _currentSettings,
                  onSettingsChanged: (newSettings) {
                    setState(() {
                      _currentSettings = newSettings;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quick settings updated!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.tune),
              label: const Text('Quick Settings'),
            ),
            const SizedBox(height: 32),
            if (_currentSettings != null) ...[
              const Text(
                'Current Settings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Protocol: ${_currentSettings!.sendProtocol}'),
                      Text(
                          'Max File Size: ${_formatBytes(_currentSettings!.maxReceiveFileSize)}'),
                      Text(
                          'Max Total Size: ${_formatBytes(_currentSettings!.maxTotalReceiveSize)}'),
                      Text(
                          'Concurrent Tasks: ${_currentSettings!.maxConcurrentTasks}'),
                      Text('Chunk Size: ${_currentSettings!.maxChunkSize} KB'),
                      Text(
                          'Date Folders: ${_currentSettings!.createDateFolders ? "Yes" : "No"}'),
                    ],
                  ),
                ),
              ),
            ],
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
}
