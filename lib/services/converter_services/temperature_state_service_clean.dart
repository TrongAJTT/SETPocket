// import 'package:hive/hive.dart';
import 'package:setpocket/models/converter_models/temperature_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/converter_services/temperature_state_service_isar.dart';

class TemperatureStateService {
  // Initialize the state service - no longer needed for Isar
  static Future<void> initialize() async {
    logInfo('TemperatureStateService: Initialize called - using Isar backend');
  }

  // Check if feature state saving is enabled
  static Future<bool> _isFeatureStateSavingEnabled() async {
    try {
      final enabled = await SettingsService.getFeatureStateSaving();
      logInfo(
          'TemperatureStateService: Feature state saving enabled: $enabled');
      return enabled;
    } catch (e) {
      logError(
          'TemperatureStateService: Error checking feature state saving settings: $e');
      // Default to enabled if error occurs
      logInfo(
          'TemperatureStateService: Using default enabled=true due to error');
      return true;
    }
  }

  // Save converter state
  static Future<void> saveState(TemperatureStateModel state) async {
    try {
      await TemperatureStateServiceIsar.saveState(state);
      logInfo('TemperatureStateService: State saved successfully via Isar');
    } catch (e) {
      logError('TemperatureStateService: Error saving state: $e');
      rethrow;
    }
  }

  // Load converter state
  static Future<TemperatureStateModel> loadState() async {
    try {
      final state = await TemperatureStateServiceIsar.loadState();
      
      if (state != null) {
        logInfo('TemperatureStateService: State loaded successfully via Isar');
        return state;
      } else {
        logInfo('TemperatureStateService: No saved state found, creating default');
        return TemperatureStateModel.createDefault();
      }
    } catch (e) {
      logError('TemperatureStateService: Error loading state: $e');
      return TemperatureStateModel.createDefault();
    }
  }

  // Clear saved state
  static Future<void> clearState() async {
    try {
      await TemperatureStateServiceIsar.clearState();
      logInfo('TemperatureStateService: State cleared successfully via Isar');
    } catch (e) {
      logError('TemperatureStateService: Error clearing state: $e');
      rethrow;
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      return await TemperatureStateServiceIsar.hasState();
    } catch (e) {
      logError('TemperatureStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get state size (for cache service)
  static Future<int> getStateSize() async {
    try {
      final state = await loadState();
      
      // Estimate size based on data
      final cardsSize = state.cards.length * 50; // Rough estimate per card
      final unitsSize = state.visibleUnits.length * 20; // Rough estimate per unit
      const baseSize = 100; // Base size for metadata
      return cardsSize + unitsSize + baseSize;
    } catch (e) {
      logError('TemperatureStateService: Error getting state size: $e');
      return 0;
    }
  }

  // Get state date
  static Future<DateTime?> getStateDate() async {
    try {
      return await TemperatureStateServiceIsar.getStateDate();
    } catch (e) {
      logError('TemperatureStateService: Error getting state date: $e');
      return null;
    }
  }

  // Close the service - no longer needed for Isar
  static Future<void> close() async {
    logInfo('TemperatureStateService: Close called - using Isar backend');
  }
}
