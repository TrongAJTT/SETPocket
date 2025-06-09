import 'package:hive/hive.dart';
import '../models/settings_model.dart';
import '../models/currency_cache_model.dart';

class SettingsService {
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';

  static Box<SettingsModel>? _settingsBox;

  // Initialize the settings service
  static Future<void> initialize() async {
    try {
      if (_settingsBox == null || !_settingsBox!.isOpen) {
        _settingsBox = await Hive.openBox<SettingsModel>(_settingsBoxName);
      }
    } catch (e) {
      // If there's a type error (backward compatibility issue), clear the box and recreate
      if (e.toString().contains('type') && e.toString().contains('subtype')) {
        try {
          await Hive.deleteBoxFromDisk(_settingsBoxName);
          _settingsBox = await Hive.openBox<SettingsModel>(_settingsBoxName);
          print(
              'SettingsService: Reset settings box due to compatibility issue');
        } catch (resetError) {
          print('SettingsService: Failed to reset settings box: $resetError');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  // Get current settings
  static Future<SettingsModel> getSettings() async {
    await initialize();

    try {
      final settings = _settingsBox!.get(_settingsKey);
      if (settings == null) {
        // Return default settings
        final defaultSettings = SettingsModel();
        await saveSettings(defaultSettings);
        return defaultSettings;
      }
      return settings;
    } catch (e) {
      // If reading fails due to compatibility, return default and save it
      if (e.toString().contains('type') && e.toString().contains('subtype')) {
        print('SettingsService: Settings read failed, using defaults: $e');
        final defaultSettings = SettingsModel();
        try {
          await _settingsBox!.clear();
          await saveSettings(defaultSettings);
        } catch (clearError) {
          print('SettingsService: Failed to clear settings: $clearError');
        }
        return defaultSettings;
      }
      rethrow;
    }
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

  // Update fetch timeout
  static Future<void> updateFetchTimeout(int timeoutSeconds) async {
    final currentSettings = await getSettings();
    final updatedSettings =
        currentSettings.copyWith(fetchTimeoutSeconds: timeoutSeconds);
    await saveSettings(updatedSettings);
  }

  // Get fetch timeout
  static Future<int> getFetchTimeout() async {
    final settings = await getSettings();
    return settings.fetchTimeoutSeconds;
  }

  // Update feature state saving enabled
  static Future<void> updateFeatureStateSaving(bool enabled) async {
    final currentSettings = await getSettings();
    final updatedSettings =
        currentSettings.copyWith(featureStateSavingEnabled: enabled);
    await saveSettings(updatedSettings);
  }

  // Get feature state saving enabled
  static Future<bool> getFeatureStateSaving() async {
    final settings = await getSettings();
    return settings.featureStateSavingEnabled;
  }

  // Clear settings (for testing or reset)
  static Future<void> clearSettings() async {
    await initialize();
    await _settingsBox!.delete(_settingsKey);
  }
}
