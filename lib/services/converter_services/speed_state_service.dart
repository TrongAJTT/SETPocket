import 'package:hive/hive.dart';
import 'package:setpocket/models/converter_models/speed_state_model.dart';
import 'package:setpocket/services/app_logger.dart';

class SpeedStateService {
  static const String _boxName = 'speed_state';
  static const String _stateKey = 'current_state';

  // Save speed converter state
  static Future<void> saveState(SpeedStateModel state) async {
    try {
      final box = await Hive.openBox<SpeedStateModel>(_boxName);
      await box.put(_stateKey, state);
      await box.close();
      logInfo('SpeedStateService: State saved successfully');
    } catch (e) {
      logError('SpeedStateService: Error saving state: $e');
      rethrow;
    }
  }

  // Load speed converter state
  static Future<SpeedStateModel> loadState() async {
    try {
      final box = await Hive.openBox<SpeedStateModel>(_boxName);
      final state = box.get(_stateKey);
      await box.close();

      if (state != null) {
        logInfo('SpeedStateService: State loaded successfully');
        return state;
      } else {
        logInfo('SpeedStateService: No saved state found, creating default');
        return SpeedStateModel.createDefault();
      }
    } catch (e) {
      logError('SpeedStateService: Error loading state: $e');
      logInfo('SpeedStateService: Creating default state due to error');
      return SpeedStateModel.createDefault();
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      final box = await Hive.openBox<SpeedStateModel>(_boxName);
      final hasState = box.containsKey(_stateKey);
      await box.close();
      return hasState;
    } catch (e) {
      logError('SpeedStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      final box = await Hive.openBox<SpeedStateModel>(_boxName);
      final state = box.get(_stateKey);
      await box.close();

      if (state != null) {
        // Approximate size calculation
        int size = 0;
        size += state.cards.length * 100; // Approximate size per card
        size +=
            state.visibleUnits.length * 20; // Approximate size per visible unit
        size += 100; // Base overhead
        return size;
      }
      return 0;
    } catch (e) {
      logError('SpeedStateService: Error getting state size: $e');
      return 0;
    }
  }

  // Clear saved state
  static Future<void> clearState() async {
    try {
      final box = await Hive.openBox<SpeedStateModel>(_boxName);
      await box.delete(_stateKey);
      await box.close();
      logInfo('SpeedStateService: State cleared successfully');
    } catch (e) {
      logError('SpeedStateService: Error clearing state: $e');
      rethrow;
    }
  }

  // Delete the entire box (for cache management)
  static Future<void> deleteBox() async {
    try {
      await Hive.deleteBoxFromDisk(_boxName);
      logInfo('SpeedStateService: Box deleted successfully');
    } catch (e) {
      logError('SpeedStateService: Error deleting box: $e');
      rethrow;
    }
  }
}
