import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/parsers/markdown_info_parser.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/widgets/generic/generic_settings_helper.dart';
import 'package:setpocket/widgets/generic_info_screen.dart';

class FunctionInfo {
  static Future<void> show(BuildContext context, String featureName) async {
    try {
      // Get the locale to determine the language
      final locale = Localizations.localeOf(context);
      final langCode = locale.languageCode; // 'vi' or 'en'

      // Load the markdown file based on featureName and language
      final path = 'assets/func_info/${featureName}_$langCode.md';
      final content = await rootBundle.loadString(path);

      // Parse the markdown content
      final parser = MarkdownInfoParser();
      final infoPage = parser.parse(content);

      // Show the info page in a dialog
      if (context.mounted) {
        GenericSettingsHelper.showSettings(
          context,
          GenericSettingsConfig<SingleChildScrollView>(
            title: infoPage.title,
            settingsLayout: GenericInfoScreen(
              page: infoPage,
            ),
            onSettingsChanged: (newInfo) {
              // Handle any changes if needed
            },
            showActions: true,
            isCompact: false,
            // preferredSize: const Size.fromHeight(600), // Dialog size
            barrierDismissible: true,
          ),
        );
      }
    } catch (e) {
      // Handle errors gracefully
      logError('Error showing function info: $e');
      if (context.mounted) {
        SnackbarUtils.showTyped(
          context,
          'Could not load information for $featureName.',
          SnackBarType.error,
        );
      }
    }
  }
}

class FunctionInfoKeys {
  static const String scientificCalculator =
      'calculator_tools/scientificCalculator';
  static const String graphingCalculator =
      'calculator_tools/graphingCalculator';
  static const String bmiCalculator = 'calculator_tools/bmiCalculator';
  static const String financialCalculator =
      'calculator_tools/financialCalculator';
  static const String dateCalculator = 'calculator_tools/dateCalculator';
  static const String discountCalculator =
      'calculator_tools/discountCalculator';
}
