import 'package:hive/hive.dart';
import 'package:setpocket/models/converter_models/number_system_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_service.dart';

class NumberSystemStateService {
  static const String _boxName = 'number_system_state';
  static const String _stateKey = 'number_system_converter_state';

  // Save number system converter state
  static Future<void> saveState(NumberSystemStateModel state) async {
    try {
      // Check if feature state saving is enabled
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        logInfo(
            'NumberSystemStateService: Feature state saving is disabled, not saving state');
        return;
      }

      final box = await Hive.openBox(_boxName);
      await box.put(_stateKey, state);

      logInfo(
          'NumberSystemStateService: Saved state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');
      await box.close();
    } catch (e) {
      logError('NumberSystemStateService: Error saving state: $e');
      rethrow;
    }
  }

  // Load number system converter state
  static Future<NumberSystemStateModel> loadState() async {
    try {
      // Check if feature state saving is enabled
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        logInfo(
            'NumberSystemStateService: Feature state saving is disabled, returning default state');
        return NumberSystemStateModel.createDefault();
      }

      final box = await Hive.openBox(_boxName);
      final state = box.get(_stateKey) as NumberSystemStateModel?;
      await box.close();

      if (state == null) {
        logInfo(
            'NumberSystemStateService: No saved state found, creating default');
        return NumberSystemStateModel.createDefault();
      }

      logInfo(
          'NumberSystemStateService: Loaded state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');
      return state;
    } catch (e) {
      logError('NumberSystemStateService: Error loading state: $e');
      return NumberSystemStateModel.createDefault();
    }
  }

  // Clear number system converter state
  static Future<void> clearState() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.delete(_stateKey);
      await box.close();
      logInfo('NumberSystemStateService: Cleared number system state');
    } catch (e) {
      logError('NumberSystemStateService: Error clearing state: $e');
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
      logError('NumberSystemStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get state size in bytes (for cache management)
  static Future<int> getStateSize() async {
    try {
      final box = await Hive.openBox(_boxName);
      int size = 0;

      final state = box.get(_stateKey);
      if (state != null) {
        // Rough estimate of memory usage for the state
        size += state.toString().length * 2; // UTF-16 encoding
      }

      await box.close();
      return size;
    } catch (e) {
      logError('NumberSystemStateService: Error getting state size: $e');
      return 0;
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
      logError('NumberSystemStateService: Error getting cache size: $e');
      return 0;
    }
  }

  // Force clear all cached data (for recovery from data corruption)
  static Future<void> forceClearAllCache() async {
    try {
      logInfo('NumberSystemStateService: Force clearing all cache data');

      // Delete the entire box
      await Hive.deleteBoxFromDisk(_boxName);

      logInfo('NumberSystemStateService: All cache data cleared successfully');
    } catch (e) {
      logError('NumberSystemStateService: Error force clearing cache: $e');
      rethrow;
    }
  }
}
