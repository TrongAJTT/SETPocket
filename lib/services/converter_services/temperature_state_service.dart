import 'package:hive/hive.dart';
import 'package:setpocket/models/converter_models/temperature_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';

class TemperatureStateService {
  static const String _stateBoxName = 'temperature_states';
  static const String _stateKey = 'temperature_converter_state';
  static Box<TemperatureStateModel>? _stateBox;

  // Initialize the state service
  static Future<void> initialize() async {
    try {
      if (_stateBox == null || !_stateBox!.isOpen) {
        _stateBox = await Hive.openBox<TemperatureStateModel>(_stateBoxName);
        logInfo('TemperatureStateService: State box opened successfully');
      }
    } catch (e) {
      logError('TemperatureStateService: Error opening state box: $e');
      rethrow;
    }
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
      logInfo(
          'TemperatureStateService: Attempting to save state with ${state.cards.length} cards');

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'TemperatureStateService: Feature state saving is disabled, skipping save');
        return;
      }

      await initialize();

      // Verify state before saving
      logInfo(
          'TemperatureStateService: State details - Cards: ${state.cards.length}, Units: ${state.visibleUnits.length}, Focus: ${state.isFocusMode}, View: ${state.viewMode}');
      for (int i = 0; i < state.cards.length; i++) {
        final card = state.cards[i];
        logInfo(
            'TemperatureStateService: Card $i - Unit: ${card.unitCode}, Amount: ${card.amount}');
      }

      await _stateBox!.put(_stateKey, state);
      await _stateBox!.flush(); // Force flush to disk for mobile reliability

      // Verify saved state
      final savedState = _stateBox!.get(_stateKey);
      if (savedState != null) {
        logInfo(
            'TemperatureStateService: State successfully saved and verified with ${savedState.cards.length} cards, focus: ${savedState.isFocusMode}, view: ${savedState.viewMode}');
      } else {
        logError(
            'TemperatureStateService: Failed to verify saved state - state is null after save');
      }
    } catch (e, stackTrace) {
      logError('TemperatureStateService: Error saving state: $e');
      logError('TemperatureStateService: Stack trace: $stackTrace');
      // Don't rethrow to avoid breaking the app
    }
  }

  // Load converter state
  static Future<TemperatureStateModel> loadState() async {
    try {
      logInfo('TemperatureStateService: Starting loadState');

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'TemperatureStateService: Feature state saving is disabled, returning default state');
        return TemperatureStateModel.createDefault();
      }

      await initialize();

      final savedState = _stateBox!.get(_stateKey);
      if (savedState != null) {
        logInfo(
            'TemperatureStateService: Loaded state with ${savedState.cards.length} cards, focus: ${savedState.isFocusMode}, view: ${savedState.viewMode}');
        return savedState;
      } else {
        logInfo(
            'TemperatureStateService: No saved state found, creating default');
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
      logInfo('TemperatureStateService: Clearing temperature converter state');

      Box<TemperatureStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_stateBoxName)) {
        box = Hive.box<TemperatureStateModel>(_stateBoxName);
      } else {
        box = await Hive.openBox<TemperatureStateModel>(_stateBoxName);
        shouldClose = true;
      }

      await box.delete(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      logInfo('TemperatureStateService: Successfully cleared state');
    } catch (e) {
      logError('TemperatureStateService: Error clearing state: $e');
      rethrow;
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        return false;
      }

      Box<TemperatureStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_stateBoxName)) {
        box = Hive.box<TemperatureStateModel>(_stateBoxName);
      } else {
        box = await Hive.openBox<TemperatureStateModel>(_stateBoxName);
        shouldClose = true;
      }

      final hasData = box.containsKey(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      return hasData;
    } catch (e) {
      logError('TemperatureStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get state size (for cache service)
  static Future<int> getStateSize() async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        return 0;
      }

      Box<TemperatureStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_stateBoxName)) {
        box = Hive.box<TemperatureStateModel>(_stateBoxName);
      } else {
        box = await Hive.openBox<TemperatureStateModel>(_stateBoxName);
        shouldClose = true;
      }

      final state = box.get(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      if (state != null) {
        // Estimate size based on data
        final cardsSize = state.cards.length * 50; // Rough estimate per card
        final unitsSize =
            state.visibleUnits.length * 20; // Rough estimate per unit
        const baseSize = 100; // Base size for metadata
        return cardsSize + unitsSize + baseSize;
      }

      return 0;
    } catch (e) {
      logError('TemperatureStateService: Error getting state size: $e');
      return 0;
    }
  }

  // Close the service
  static Future<void> close() async {
    try {
      if (_stateBox != null && _stateBox!.isOpen) {
        await _stateBox!.close();
        _stateBox = null;
        logInfo('TemperatureStateService: State box closed successfully');
      }
    } catch (e) {
      logError('TemperatureStateService: Error closing state box: $e');
    }
  }
}
