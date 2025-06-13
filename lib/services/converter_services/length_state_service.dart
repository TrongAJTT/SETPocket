import 'package:hive/hive.dart';
import '../../models/converter_models/length_state_model.dart';
import '../settings_service.dart';
import '../app_logger.dart';

class LengthStateService {
  static const String _stateBoxName = 'length_states';
  static const String _stateKey = 'length_converter_state';
  static Box<LengthStateModel>? _stateBox;

  // Initialize the state service
  static Future<void> initialize() async {
    try {
      if (_stateBox == null || !_stateBox!.isOpen) {
        _stateBox = await Hive.openBox<LengthStateModel>(_stateBoxName);
        print('LengthStateService: State box opened successfully');
      }
    } catch (e) {
      print('LengthStateService: Error opening state box: $e');
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
          'LengthStateService: State details - Cards: ${state.cards.length}, Units: ${state.visibleUnits.length}');
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
            'LengthStateService: State successfully saved and verified with ${savedState.cards.length} cards');
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
      await initialize();

      final savedState = _stateBox!.get(_stateKey);
      if (savedState != null) {
        logInfo(
            'LengthStateService: Loaded state with ${savedState.cards.length} cards');
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
      await initialize();

      await _stateBox!.delete(_stateKey);
      await _stateBox!.flush();

      print('LengthStateService: State cleared');
    } catch (e) {
      print('LengthStateService: Error clearing state: $e');
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      await initialize();
      return _stateBox!.containsKey(_stateKey);
    } catch (e) {
      print('LengthStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get state size (for cache service)
  static Future<int> getStateSize() async {
    try {
      await initialize();

      final state = _stateBox!.get(_stateKey);
      if (state != null) {
        // Estimate size based on data
        final cardsSize = state.cards.length * 50; // Rough estimate per card
        final unitsSize =
            state.visibleUnits.length * 20; // Rough estimate per unit
        return cardsSize + unitsSize + 100; // Plus overhead
      }
      return 0;
    } catch (e) {
      print('LengthStateService: Error calculating state size: $e');
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

      print('=== Length State Debug ===');
      if (state != null) {
        print('Cards: ${state.cards.length}');
        for (int i = 0; i < state.cards.length; i++) {
          final card = state.cards[i];
          print('  Card $i: ${card.unitCode} = ${card.amount}');
        }
        print('Visible Units: ${state.visibleUnits.join(", ")}');
        print('Last Updated: ${state.lastUpdated}');
      } else {
        print('No state saved');
      }
      print('Box Length: ${_stateBox!.length}');
      print('=====================');
    } catch (e) {
      print('LengthStateService: Error in debug: $e');
    }
  }
}
