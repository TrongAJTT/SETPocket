import 'package:isar/isar.dart';
import 'package:setpocket/models/converter_models/speed_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';

class SpeedStateServiceIsar {
  // Save speed converter state
  static Future<void> saveState(SpeedStateModel state) async {
    try {
      final isar = IsarService.isar;
      
      // Update timestamp
      state.lastUpdated = DateTime.now();

      await isar.writeTxn(() async {
        // Clear existing state and save new one
        await isar.speedStateModels.clear();
        await isar.speedStateModels.put(state);
      });

      logInfo('SpeedStateServiceIsar: State saved successfully');
    } catch (e) {
      logError('SpeedStateServiceIsar: Error saving state: $e');
      rethrow;
    }
  }

  // Load speed converter state
  static Future<SpeedStateModel> loadState() async {
    try {
      final isar = IsarService.isar;
      
      final state = await isar.speedStateModels.where().anyId().findFirst();
      
      if (state != null) {
        logInfo('SpeedStateServiceIsar: State loaded successfully');
        return state;
      } else {
        logInfo('SpeedStateServiceIsar: No state found, returning default');
        return SpeedStateModel.createDefault();
      }
    } catch (e) {
      logError('SpeedStateServiceIsar: Error loading state: $e');
      return SpeedStateModel.createDefault();
    }
  }

  // Clear all speed converter state
  static Future<void> clearState() async {
    try {
      final isar = IsarService.isar;
      
      await isar.writeTxn(() async {
        await isar.speedStateModels.clear();
      });

      logInfo('SpeedStateServiceIsar: State cleared successfully');
    } catch (e) {
      logError('SpeedStateServiceIsar: Error clearing state: $e');
      rethrow;
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      final isar = IsarService.isar;
      final count = await isar.speedStateModels.count();
      return count > 0;
    } catch (e) {
      logError('SpeedStateServiceIsar: Error checking state: $e');
      return false;
    }
  }

  // Get state creation date
  static Future<DateTime?> getStateDate() async {
    try {
      final state = await loadState();
      return state.lastUpdated;
    } catch (e) {
      logError('SpeedStateServiceIsar: Error getting state date: $e');
      return null;
    }
  }
}
