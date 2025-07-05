import 'package:isar/isar.dart';
import 'package:setpocket/models/converter_models/temperature_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/settings_service.dart';

class TemperatureStateServiceIsar {
  // Check if feature state saving is enabled
  static Future<bool> _isFeatureStateSavingEnabled() async {
    try {
      final enabled = await SettingsService.getFeatureStateSaving();
      logInfo(
          'TemperatureStateServiceIsar: Feature state saving enabled: $enabled');
      return enabled;
    } catch (e) {
      logError(
          'TemperatureStateServiceIsar: Error checking feature state saving setting: $e');
      logInfo(
          'TemperatureStateServiceIsar: Using default enabled=true due to error');
      return true;
    }
  }

  // Save temperature converter state
  static Future<void> saveState(TemperatureStateModel state) async {
    try {
      logInfo(
          'TemperatureStateServiceIsar: Attempting to save state with ${state.cards.length} cards');

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'TemperatureStateServiceIsar: Feature state saving is disabled, skipping save');
        return;
      }

      final isar = IsarService.isar;

      // Update timestamp
      state.lastUpdated = DateTime.now();

      await isar.writeTxn(() async {
        // Clear existing state and save new one
        await isar.temperatureStateModels.clear();
        await isar.temperatureStateModels.put(state);
      });

      logInfo(
          'TemperatureStateServiceIsar: Temperature converter state saved successfully');
    } catch (e) {
      logError(
          'TemperatureStateServiceIsar: Error saving temperature converter state: $e');
      rethrow;
    }
  }

  // Load temperature converter state
  static Future<TemperatureStateModel?> loadState() async {
    try {
      logInfo(
          'TemperatureStateServiceIsar: Attempting to load temperature converter state');

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'TemperatureStateServiceIsar: Feature state saving is disabled, returning null');
        return null;
      }

      final isar = IsarService.isar;
      final state = await isar.temperatureStateModels.where().anyId().findFirst();

      if (state != null) {
        logInfo(
            'TemperatureStateServiceIsar: Loaded temperature converter state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');
        return state;
      } else {
        logInfo(
            'TemperatureStateServiceIsar: No saved temperature converter state found');
        return null;
      }
    } catch (e) {
      logError(
          'TemperatureStateServiceIsar: Error loading temperature converter state: $e');
      return null;
    }
  }

  // Clear temperature converter state
  static Future<void> clearState() async {
    try {
      logInfo('TemperatureStateServiceIsar: Clearing temperature converter state');

      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        await isar.temperatureStateModels.clear();
      });

      logInfo(
          'TemperatureStateServiceIsar: Temperature converter state cleared successfully');
    } catch (e) {
      logError(
          'TemperatureStateServiceIsar: Error clearing temperature converter state: $e');
      rethrow;
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      final isar = IsarService.isar;
      final count = await isar.temperatureStateModels.count();
      return count > 0;
    } catch (e) {
      logError(
          'TemperatureStateServiceIsar: Error checking if state exists: $e');
      return false;
    }
  }

  // Get state creation date
  static Future<DateTime?> getStateDate() async {
    try {
      final state = await loadState();
      return state?.lastUpdated;
    } catch (e) {
      logError(
          'TemperatureStateServiceIsar: Error getting state date: $e');
      return null;
    }
  }
}
