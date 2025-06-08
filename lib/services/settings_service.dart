import 'package:hive/hive.dart';
import '../models/settings_model.dart';
import '../models/currency_cache_model.dart';

class SettingsService {
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';

  static Box<SettingsModel>? _settingsBox;

  // Initialize the settings service
  static Future<void> initialize() async {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      _settingsBox = await Hive.openBox<SettingsModel>(_settingsBoxName);
    }
  }

  // Get current settings
  static Future<SettingsModel> getSettings() async {
    await initialize();

    final settings = _settingsBox!.get(_settingsKey);
    if (settings == null) {
      // Return default settings
      final defaultSettings = SettingsModel();
      await saveSettings(defaultSettings);
      return defaultSettings;
    }

    return settings;
  }

  // Save settings
  static Future<void> saveSettings(SettingsModel settings) async {
    await initialize();
    await _settingsBox!.put(_settingsKey, settings);
  }

  // Update currency fetch mode
  static Future<void> updateCurrencyFetchMode(CurrencyFetchMode mode) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(currencyFetchMode: mode);
    await saveSettings(updatedSettings);
  }

  // Get currency fetch mode
  static Future<CurrencyFetchMode> getCurrencyFetchMode() async {
    final settings = await getSettings();
    return settings.currencyFetchMode;
  }

  // Clear settings (for testing or reset)
  static Future<void> clearSettings() async {
    await initialize();
    await _settingsBox!.delete(_settingsKey);
  }
}
