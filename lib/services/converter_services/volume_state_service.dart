import 'package:setpocket/models/converter_models/volume_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/converter_services/volume_state_service_isar.dart';

class VolumeStateService {
  /// Load volume converter state
  static Future<VolumeStateModel> loadState() async {
    logInfo('VolumeStateService: Delegating to VolumeStateServiceIsar');
    
    // Run migration first time
    await VolumeStateServiceIsar.migrateFromHive();
    
    return await VolumeStateServiceIsar.loadState();
  }

  /// Save volume converter state
  static Future<void> saveState(VolumeStateModel state) async {
    logInfo('VolumeStateService: Delegating to VolumeStateServiceIsar');
    return await VolumeStateServiceIsar.saveState(state);
  }

  /// Clear volume converter state
  static Future<void> clearState() async {
    logInfo('VolumeStateService: Delegating to VolumeStateServiceIsar');
    return await VolumeStateServiceIsar.clearState();
  }

  /// Check if state exists
  static Future<bool> hasState() async {
    return await VolumeStateServiceIsar.hasState();
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    return await VolumeStateServiceIsar.getStateSize();
  }

  /// Force clear all cache (for recovery from corruption)
  static Future<void> forceClearAllCache() async {
    logInfo('VolumeStateService: Delegating to VolumeStateServiceIsar');
    return await VolumeStateServiceIsar.forceClearAllCache();
  }
}
