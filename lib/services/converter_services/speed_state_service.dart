// import 'package:hive/hive.dart';
import 'package:setpocket/models/converter_models/speed_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/converter_services/speed_state_service_isar.dart';

class SpeedStateService {
  // Save speed converter state
  static Future<void> saveState(SpeedStateModel state) async {
    try {
      await SpeedStateServiceIsar.saveState(state);
      logInfo('SpeedStateService: State saved successfully via Isar');
    } catch (e) {
      logError('SpeedStateService: Error saving state: $e');
      rethrow;
    }
  }

  // Load speed converter state
  static Future<SpeedStateModel> loadState() async {
    try {
      final state = await SpeedStateServiceIsar.loadState();
      logInfo('SpeedStateService: State loaded successfully via Isar');
      return state;
    } catch (e) {
      logError('SpeedStateService: Error loading state: $e');
      logInfo('SpeedStateService: Creating default state due to error');
      return SpeedStateModel.createDefault();
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      return await SpeedStateServiceIsar.hasState();
    } catch (e) {
      logError('SpeedStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get state size for cache management  
  static Future<int> getStateSize() async {
    try {
      final state = await loadState();
      // Approximate size calculation
      int size = 0;
      size += state.cards.length * 100; // Approximate size per card
      size += state.visibleUnits.length * 20; // Approximate size per visible unit
      size += 100; // Base overhead
      return size;
    } catch (e) {
      logError('SpeedStateService: Error getting state size: $e');
      return 0;
    }
  }

  // Clear saved state
  static Future<void> clearState() async {
    try {
      await SpeedStateServiceIsar.clearState();
      logInfo('SpeedStateService: State cleared successfully via Isar');
    } catch (e) {
      logError('SpeedStateService: Error clearing state: $e');
      rethrow;
    }
  }

  // Get state date
  static Future<DateTime?> getStateDate() async {
    try {
      return await SpeedStateServiceIsar.getStateDate();
    } catch (e) {
      logError('SpeedStateService: Error getting state date: $e');
      return null;
    }
  }
}
