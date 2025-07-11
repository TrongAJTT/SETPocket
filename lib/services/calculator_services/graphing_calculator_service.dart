import 'package:setpocket/services/settings_models_service.dart';

class GraphingCalculatorService {
  static Future<bool> getRememberHistory() async {
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    return settings.rememberHistory;
  }
}
