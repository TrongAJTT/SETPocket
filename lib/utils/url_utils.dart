import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UriUtils {
  /// Opens a file with the OS using open_file package.
  static Future<void> openFile(String filePath, {BuildContext? context}) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở file: ${result.message}')),
        );
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi mở file: $e')),
        );
      }
    }
  }

  static String getFileName(String filePath) {
    return filePath.contains('/')
        ? filePath.split('/').last
        : filePath.split('\\').last;
  }

  /// Opens a URL in the default browser.
  static Future<void> launchInBrowser(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        late String e;
        if (url.isEmpty) {
          e = "The URL is empty.";
        } else {
          e = "There is no handler available, or that the application does not have permission to check. For example:\nOn recent versions of Android and iOS, this will always return false unless the application has been configuration to allow querying the system for launch support. See the README for details.\nOn web, this will always return false except for a few specific schemes that are always assumed to be supported (such as http(s)), as web pages are never allowed to query installed applications.";
        }
        _handleErrorOpenUrl(e, url, context);
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
      _handleErrorOpenUrl(e, url, context);
    }
  }

  static void _handleErrorOpenUrl(Object e, String url, BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error when opening URL'),
            content: SizedBox(
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Can not open the following URL:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: url),
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'URL',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: e.toString()),
                      maxLines: null,
                      expands: true,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Detail error:',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Đóng'),
              ),
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (context.mounted) {
                    SnackbarUtils.showTyped(
                      context,
                      'Link copied to clipboard',
                      SnackBarType.success,
                    );
                  }
                },
                child: const Text('Copy link'),
              ),
            ],
          );
        },
      );
    }
  }

  static void openInFileExplorer(String filePath) {
    if (Platform.isWindows) {
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          Process.run('explorer', [file.parent.path]);
        } else {
          throw Exception('File does not exist: $filePath');
        }
      } catch (e) {
        print('Error opening file explorer: $e');
      }
    }
  }

  static Future<void> createImageFileFromUint8List({
    required Uint8List data,
    required String fileName,
    String? directory,
  }) async {
    if (Platform.isWindows) {
      final directoryPath = directory ?? Directory.systemTemp.path;
      final filePath = '$directoryPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(data);
    } else if (Platform.isAndroid) {
      final directoryPath = directory ?? Directory.systemTemp.path;
      final filePath = '$directoryPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(data);
    } else {
      throw UnsupportedError('Unsupported platform for creating image files');
    }
  }

  static Future<void> deleteSystemTempFile({required String fileName}) async {
    final tempDir = Directory.systemTemp;
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    } else {
      print('File does not exist: $filePath');
    }
  }
}
