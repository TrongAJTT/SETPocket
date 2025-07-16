import 'package:flutter/widgets.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlUtils {
  /// Opens a URL in the default browser.
  static Future<void> launchInBrowser(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: show snackbar with error
        if (context.mounted) {
          SnackbarUtils.showTyped(
            context,
            'Could not open URL: $url',
            SnackBarType.error,
          );
        }
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
      if (context.mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error opening URL: $e',
          SnackBarType.error,
        );
      }
    }
  }
}
