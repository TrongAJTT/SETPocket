import 'package:setpocket/models/converter_models/number_system_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/converter_services/number_system_state_service_isar.dart';

class NumberSystemStateService {
  /// Load number system converter state
  static Future<NumberSystemStateModel> loadState() async {
    logInfo('NumberSystemStateService: Delegating to NumberSystemStateServiceIsar');
    
    // Run migration first time
    await NumberSystemStateServiceIsar.migrateFromHive();
    
    return await NumberSystemStateServiceIsar.loadState();
  }

  /// Save number system converter state
  static Future<void> saveState(NumberSystemStateModel state) async {
    logInfo('NumberSystemStateService: Delegating to NumberSystemStateServiceIsar');
    return await NumberSystemStateServiceIsar.saveState(state);
  }

  /// Clear number system converter state
  static Future<void> clearState() async {
    logInfo('NumberSystemStateService: Delegating to NumberSystemStateServiceIsar');
    return await NumberSystemStateServiceIsar.clearState();
  }

  /// Check if state exists
  static Future<bool> hasState() async {
    return await NumberSystemStateServiceIsar.hasState();
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    return await NumberSystemStateServiceIsar.getStateSize();
  }
}
