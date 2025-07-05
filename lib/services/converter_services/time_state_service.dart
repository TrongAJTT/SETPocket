import 'package:setpocket/models/converter_models/time_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/converter_services/time_state_service_isar.dart';

class TimeStateService {
  /// Load time converter state
  static Future<TimeStateModel> loadState() async {
    logInfo('TimeStateService: Delegating to TimeStateServiceIsar');

    // Run migration first time
    await TimeStateServiceIsar.migrateFromHive();

    return await TimeStateServiceIsar.loadState();
  }

  /// Save time converter state
  static Future<void> saveState(TimeStateModel state) async {
    logInfo('TimeStateService: Delegating to TimeStateServiceIsar');
    return await TimeStateServiceIsar.saveState(state);
  }

  /// Clear time converter state
  static Future<void> clearState() async {
    logInfo('TimeStateService: Delegating to TimeStateServiceIsar');
    return await TimeStateServiceIsar.clearState();
  }

  /// Force clear all cache (for recovery from corruption)
  static Future<void> forceClearAllCache() async {
    logInfo('TimeStateService: Delegating to TimeStateServiceIsar');
    return await TimeStateServiceIsar.forceClearAllCache();
  }

  /// Check if state exists
  static Future<bool> hasState() async {
    return await TimeStateServiceIsar.hasState();
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    return await TimeStateServiceIsar.getStateSize();
  }
}
