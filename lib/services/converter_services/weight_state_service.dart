import 'package:setpocket/models/converter_models/weight_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/converter_services/weight_state_service_isar.dart';

class WeightStateService {
  /// Load weight converter state
  static Future<WeightStateModel> loadState() async {
    logInfo('WeightStateService: Delegating to WeightStateServiceIsar');

    // Run migration first time
    await WeightStateServiceIsar.migrateFromHive();

    return await WeightStateServiceIsar.loadState();
  }

  /// Save weight converter state
  static Future<void> saveState(WeightStateModel state) async {
    logInfo('WeightStateService: Delegating to WeightStateServiceIsar');
    return await WeightStateServiceIsar.saveState(state);
  }

  /// Clear weight converter state
  static Future<void> clearState() async {
    logInfo('WeightStateService: Delegating to WeightStateServiceIsar');
    return await WeightStateServiceIsar.clearState();
  }

  /// Force clear all cache (for recovery from corruption)
  static Future<void> forceClearAllCache() async {
    logInfo('WeightStateService: Delegating to WeightStateServiceIsar');
    return await WeightStateServiceIsar.forceClearAllCache();
  }

  /// Check if state exists
  static Future<bool> hasState() async {
    return await WeightStateServiceIsar.hasState();
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    return await WeightStateServiceIsar.getStateSize();
  }
}
