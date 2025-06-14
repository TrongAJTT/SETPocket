import 'package:hive/hive.dart';
import 'package:setpocket/models/converter_models/volume_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_service.dart';

class VolumeStateService {
  static const String _boxName = 'volume_state';
  static const String _stateKey = 'volume_converter_state';

  // Save volume converter state
  static Future<void> saveState(VolumeStateModel state) async {
    try {
      // Check if feature state saving is enabled
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        logInfo(
            'VolumeStateService: Feature state saving is disabled, not saving state');
        return;
      }

      final box = await Hive.openBox(_boxName);
      await box.put(_stateKey, state);

      logInfo(
          'VolumeStateService: Saved state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');
      await box.close();
    } catch (e) {
      logError('VolumeStateService: Error saving state: $e');
      rethrow;
    }
  }

  // Load volume converter state
  static Future<VolumeStateModel> loadState() async {
    try {
      // Check if feature state saving is enabled
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        logInfo(
            'VolumeStateService: Feature state saving is disabled, returning default state');
        return VolumeStateModel.createDefault();
      }

      final box = await Hive.openBox(_boxName);
      final state = box.get(_stateKey) as VolumeStateModel?;
      await box.close();

      if (state == null) {
        logInfo('VolumeStateService: No saved state found, creating default');
        return VolumeStateModel.createDefault();
      }

      logInfo(
          'VolumeStateService: Loaded state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');
      return state;
    } catch (e) {
      logError('VolumeStateService: Error loading state: $e');
      return VolumeStateModel.createDefault();
    }
  }

  // Clear volume converter state
  static Future<void> clearState() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.delete(_stateKey);
      await box.close();
      logInfo('VolumeStateService: Cleared volume state');
    } catch (e) {
      logError('VolumeStateService: Error clearing state: $e');
      rethrow;
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      final box = await Hive.openBox(_boxName);
      final hasState = box.containsKey(_stateKey);
      await box.close();
      return hasState;
    } catch (e) {
      logError('VolumeStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get cached data size (for cache management)
  static Future<int> getCacheSize() async {
    try {
      final box = await Hive.openBox(_boxName);
      int size = 0;

      for (var key in box.keys) {
        final value = box.get(key);
        if (value != null) {
          // Rough estimate of memory usage
          size += value.toString().length * 2; // UTF-16 encoding
        }
      }

      await box.close();
      return size;
    } catch (e) {
      logError('VolumeStateService: Error getting cache size: $e');
      return 0;
    }
  }

  // Force clear all cached data (for recovery from data corruption)
  static Future<void> forceClearAllCache() async {
    try {
      logInfo('VolumeStateService: Force clearing all cache data');

      // Delete the entire box
      await Hive.deleteBoxFromDisk(_boxName);

      logInfo('VolumeStateService: All cache data cleared successfully');
    } catch (e) {
      logError('VolumeStateService: Error force clearing cache: $e');
      rethrow;
    }
  }
}
