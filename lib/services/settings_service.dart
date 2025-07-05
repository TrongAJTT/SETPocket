import 'package:setpocket/models/settings_model.dart';
import 'package:setpocket/models/converter_models/currency_cache_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';

class SettingsService {
  // The singleton settings object will always have an ID of 1
  static const int _settingsId = 1;

  // No more Hive-specific initialization needed here.
  // Isar is initialized globally in main.dart.
  static Future<void> initialize() async {
    // This function is now a placeholder but kept for compatibility
    // in case it's called from somewhere else. It can be removed later.
    return;
  }

  // Get current settings from Isar
  static Future<SettingsModel> getSettings() async {
    final isar = IsarService.isar;
    var settings = await isar.settingsModels.get(_settingsId);

    if (settings == null) {
      logInfo("SettingsService: No settings found in Isar, creating defaults.");
      final defaultSettings = SettingsModel();
      await saveSettings(defaultSettings);
      return defaultSettings;
    }
    return settings;
  }

  // Save settings to Isar
  static Future<void> saveSettings(SettingsModel settings) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.settingsModels.put(settings);
    });
    logInfo("SettingsService: Settings saved to Isar.");
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

  // Update log retention days
  static Future<void> updateLogRetentionDays(int days) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(logRetentionDays: days);
    await saveSettings(updatedSettings);

    // Trigger immediate cleanup when retention period is reduced
    try {
      await AppLogger.instance.cleanupOldLogs();
      logInfo(
          'SettingsService: Triggered immediate log cleanup after retention change to $days days');
    } catch (e) {
      logError('SettingsService: Failed to trigger immediate log cleanup: $e');
    }
  } // Get log retention days with migration support

  static Future<int> getLogRetentionDays() async {
    final settings = await getSettings();
    int retentionDays = settings.logRetentionDays;

    // Migration: handle old values that don't fit new range
    if (retentionDays != -1) {
      // -1 is "forever", keep as is
      // Valid values: 5, 10, 15, 20, 25, 30
      List<int> validValues = [5, 10, 15, 20, 25, 30];

      if (retentionDays < 5) {
        // Migrate values below 5 to 5
        retentionDays = 5;
        await updateLogRetentionDays(retentionDays);
      } else if (retentionDays > 30) {
        // Migrate values above 30 to 30
        retentionDays = 30;
        await updateLogRetentionDays(retentionDays);
      } else if (!validValues.contains(retentionDays)) {
        // Find the closest valid value
        int closest = validValues.reduce((a, b) =>
            (retentionDays - a).abs() < (retentionDays - b).abs() ? a : b);
        retentionDays = closest;
        await updateLogRetentionDays(retentionDays);
      }
    }

    return retentionDays;
  }

  // Update fetch retry times
  static Future<void> updateFetchRetryTimes(int times) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(fetchRetryTimes: times);
    await saveSettings(updatedSettings);
  }

  // Get fetch retry times
  static Future<int> getFetchRetryTimes() async {
    final settings = await getSettings();
    return settings.fetchRetryTimes;
  }

  // Update save random tools state
  static Future<void> updateSaveRandomToolsState(bool enabled) async {
    final currentSettings = await getSettings();
    final updatedSettings =
        currentSettings.copyWith(saveRandomToolsState: enabled);
    await saveSettings(updatedSettings);
  }

  // Get save random tools state
  static Future<bool> getSaveRandomToolsState() async {
    final settings = await getSettings();
    return settings.saveRandomToolsState;
  }

  // Clear settings (for testing or reset)
  static Future<void> clearSettings() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.settingsModels.delete(_settingsId);
    });
  }
}
