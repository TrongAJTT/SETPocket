import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:setpocket/widgets/p2p/local_file_manager_widget.dart';
import 'package:setpocket/controllers/p2p_controller.dart';
import 'package:setpocket/services/app_logger.dart';

class P2LanLocalFilesScreen extends StatefulWidget {
  const P2LanLocalFilesScreen({super.key});

  @override
  State<P2LanLocalFilesScreen> createState() => _P2LanLocalFilesScreenState();
}

class _P2LanLocalFilesScreenState extends State<P2LanLocalFilesScreen> {
  String? _localPath;
  bool _isLoading = true;
  late P2PController _controller;

  @override
  void initState() {
    super.initState();
    _controller = P2PController();
    _initializeLocalPath();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeLocalPath() async {
    try {
      // Wait for controller initialization
      await _controller.initialize();

      // Get the actual path used by P2P service
      String basePath;
      if (_controller.transferSettings != null) {
        basePath = _controller.transferSettings!.downloadPath;
        logInfo('Using P2P service download path: $basePath');
      } else {
        // Fallback to default calculation if settings not available
        if (Platform.isAndroid) {
          final appDocDir = await getApplicationDocumentsDirectory();
          basePath = '${appDocDir.parent.path}/files/p2lan_transfer';
        } else if (Platform.isIOS) {
          final appDocDir = await getApplicationDocumentsDirectory();
          basePath = '${appDocDir.path}/P2LAN';
        } else {
          basePath = '${Platform.environment['HOME']}/Downloads/P2LAN';
        }
        logInfo('Using fallback path: $basePath');
      }

      // Ensure directory exists
      final directory = Directory(basePath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        logInfo('Created P2LAN local directory: $basePath');
      }

      setState(() {
        _localPath = basePath;
        _isLoading = false;
      });

      logInfo('P2LAN local path initialized: $basePath');
    } catch (e) {
      logError('Failed to initialize local path: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('P2LAN Files'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_localPath == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('P2LAN Files'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Không thể khởi tạo thư mục cục bộ',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Vui lòng thử lại sau',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return LocalFileManagerWidget(
      basePath: _localPath!,
      viewSubfolders: true,
      viewOnly: false,
      title: 'P2LAN Files',
    );
  }
}
