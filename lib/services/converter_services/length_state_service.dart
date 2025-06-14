import 'package:hive/hive.dart';
import 'package:setpocket/models/converter_models/length_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';

class LengthStateService {
  static const String _stateBoxName = 'length_states';
  static const String _stateKey = 'length_converter_state';
  static Box<LengthStateModel>? _stateBox;

  // Initialize the state service
  static Future<void> initialize() async {
    try {
      if (_stateBox == null || !_stateBox!.isOpen) {
        _stateBox = await Hive.openBox<LengthStateModel>(_stateBoxName);
        logInfo('LengthStateService: State box opened successfully');
      }
    } catch (e) {
      logError('LengthStateService: Error opening state box: $e');
      rethrow;
    }
  }

  // Check if feature state saving is enabled
  static Future<bool> _isFeatureStateSavingEnabled() async {
    try {
      final enabled = await SettingsService.getFeatureStateSaving();
      logInfo('LengthStateService: Feature state saving enabled: $enabled');
      return enabled;
    } catch (e) {
      logError(
          'LengthStateService: Error checking feature state saving settings: $e');
      // Default to enabled if error occurs
      logInfo('LengthStateService: Using default enabled=true due to error');
      return true;
    }
  }

  // Save converter state
  static Future<void> saveState(LengthStateModel state) async {
    try {
      logInfo(
          'LengthStateService: Attempting to save state with ${state.cards.length} cards');

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'LengthStateService: Feature state saving is disabled, skipping save');
        return;
      }

      await initialize();

      // Verify state before saving
      logInfo(
          'LengthStateService: State details - Cards: ${state.cards.length}, Units: ${state.visibleUnits.length}, Focus: ${state.isFocusMode}, View: ${state.viewMode}');
      for (int i = 0; i < state.cards.length; i++) {
        final card = state.cards[i];
        logInfo(
            'LengthStateService: Card $i - Unit: ${card.unitCode}, Amount: ${card.amount}');
      }

      await _stateBox!.put(_stateKey, state);
      await _stateBox!.flush(); // Force flush to disk for mobile reliability

      // Verify saved state
      final savedState = _stateBox!.get(_stateKey);
      if (savedState != null) {
        logInfo(
            'LengthStateService: State successfully saved and verified with ${savedState.cards.length} cards, focus: ${savedState.isFocusMode}, view: ${savedState.viewMode}');
      } else {
        logError(
            'LengthStateService: Failed to verify saved state - state is null after save');
      }
    } catch (e, stackTrace) {
      logError('LengthStateService: Error saving state: $e');
      logError('LengthStateService: Stack trace: $stackTrace');
      // Don't rethrow to avoid breaking the app
    }
  }

  // Load converter state
  static Future<LengthStateModel> loadState() async {
    try {
      logInfo('LengthStateService: Starting loadState');

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'LengthStateService: Feature state saving is disabled, returning default state');
        return LengthStateModel.createDefault();
      }

      await initialize();

      final savedState = _stateBox!.get(_stateKey);
      if (savedState != null) {
        logInfo(
            'LengthStateService: Loaded state with ${savedState.cards.length} cards, focus: ${savedState.isFocusMode}, view: ${savedState.viewMode}');
        return savedState;
      } else {
        logInfo('LengthStateService: No saved state found, creating default');
        return LengthStateModel.createDefault();
      }
    } catch (e) {
      logError('LengthStateService: Error loading state: $e');
      return LengthStateModel.createDefault();
    }
  }

  // Clear saved state
  static Future<void> clearState() async {
    try {
      logInfo('LengthStateService: Clearing length converter state');

      Box<LengthStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_stateBoxName)) {
        box = Hive.box<LengthStateModel>(_stateBoxName);
      } else {
        box = await Hive.openBox<LengthStateModel>(_stateBoxName);
        shouldClose = true;
      }

      await box.delete(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      logInfo('LengthStateService: Successfully cleared state');
    } catch (e) {
      logError('LengthStateService: Error clearing state: $e');
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

      Box box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_stateBoxName)) {
        box = Hive.box(_stateBoxName);
      } else {
        box = await Hive.openBox(_stateBoxName);
        shouldClose = true;
      }

      final hasData = box.containsKey(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      return hasData;
    } catch (e) {
      logError('LengthStateService: Error checking state existence: $e');
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

      Box box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_stateBoxName)) {
        box = Hive.box(_stateBoxName);
      } else {
        box = await Hive.openBox(_stateBoxName);
        shouldClose = true;
      }

      final state = box.get(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      if (state != null && state is LengthStateModel) {
        // Estimate size based on data
        final cardsSize = state.cards.length * 50; // Rough estimate per card
        final unitsSize =
            state.visibleUnits.length * 20; // Rough estimate per unit
        return cardsSize + unitsSize + 100; // Plus overhead
      }
      return 0;
    } catch (e) {
      logError('LengthStateService: Error calculating state size: $e');
      return 0;
    }
  }

  // Get state cache size (alias for backward compatibility)
  static Future<int> getStateCacheSize() async {
    return getStateSize();
  }

  // Debug: Print current state
  static Future<void> debugState() async {
    try {
      await initialize();

      final state = _stateBox!.get(_stateKey);

      logInfo('=== Length State Debug ===');
      if (state != null) {
        logInfo('Cards: ${state.cards.length}');
        for (int i = 0; i < state.cards.length; i++) {
          final card = state.cards[i];
          logInfo('  Card $i: ${card.unitCode} = ${card.amount}');
        }
        logInfo('Visible Units: ${state.visibleUnits.join(", ")}');
        logInfo('Last Updated: ${state.lastUpdated}');
      } else {
        logInfo('No state saved');
      }
      logInfo('Box Length: ${_stateBox!.length}');
      logInfo('=====================');
    } catch (e) {
      logError('LengthStateService: Error in debug: $e');
    }
  }
}
