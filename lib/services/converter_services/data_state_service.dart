import '../../models/converter_models/data_state_model.dart';
import '../../services/app_logger.dart';
import '../../services/hive_service.dart';

class DataStateService {
  static const String _boxName = 'data_converter_state';

  // Get the state from Hive
  static Future<DataStateModel> loadState() async {
    try {
      logInfo('Loading data converter state from Hive');

      final box = await HiveService.getBox<DataStateModel>(_boxName);
      final state = box.get('state');

      if (state != null) {
        logInfo('Data converter state loaded successfully');
        return state;
      } else {
        logInfo('No saved data converter state found, creating default');
        return DataStateModel.createDefault();
      }
    } catch (e) {
      logError('Error loading data converter state: $e');
      return DataStateModel.createDefault();
    }
  }

  // Save the state to Hive
  static Future<void> saveState(DataStateModel state) async {
    try {
      logInfo('Saving data converter state to Hive');

      state.lastUpdated = DateTime.now();
      final box = await HiveService.getBox<DataStateModel>(_boxName);
      await box.put('state', state);

      logInfo('Data converter state saved successfully');
    } catch (e) {
      logError('Error saving data converter state: $e');
    }
  }

  // Clear the state (reset to default)
  static Future<void> clearState() async {
    try {
      logInfo('Clearing data converter state');

      final box = await HiveService.getBox<DataStateModel>(_boxName);
      await box.delete('state');

      logInfo('Data converter state cleared successfully');
    } catch (e) {
      logError('Error clearing data converter state: $e');
    }
  }

  // Get the size of cached state data
  static Future<int> getCacheSize() async {
    try {
      final box = await HiveService.getBox<DataStateModel>(_boxName);
      final state = box.get('state');

      if (state != null) {
        // Estimate size based on JSON representation
        final json = state.toJson();
        final jsonString = json.toString();
        return jsonString.length * 2; // Rough estimate (UTF-16)
      }

      return 0;
    } catch (e) {
      logError('Error calculating data converter cache size: $e');
      return 0;
    }
  }

  // Check if we have saved state
  static Future<bool> hasState() async {
    try {
      final box = await HiveService.getBox<DataStateModel>(_boxName);
      return box.containsKey('state');
    } catch (e) {
      logError('Error checking data converter state existence: $e');
      return false;
    }
  }
}
