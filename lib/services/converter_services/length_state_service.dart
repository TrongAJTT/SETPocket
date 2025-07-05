import 'package:isar/isar.dart';
import 'package:setpocket/models/converter_models/length_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';

class LengthStateService {
  static const String _stateKey = 'length_converter_state';

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

      final isar = IsarService.isar;

      // Verify state before saving
      logInfo(
          'LengthStateService: State details - Cards: ${state.cards.length}, Units: ${state.visibleUnits.length}, Focus: ${state.isFocusMode}, View: ${state.viewMode}');
      for (int i = 0; i < state.cards.length; i++) {
        final card = state.cards[i];
        logInfo(
            'LengthStateService: Card $i - Unit: ${card.unitCode}, Amount: ${card.amount}');
      }

      // Update timestamp
      state.lastUpdated = DateTime.now();

      await isar.writeTxn(() async {
        await isar.lengthStateModels.clear();
        await isar.lengthStateModels.put(state);
      });

      // Verify saved state
      final savedState = await isar.lengthStateModels
          .where()
          .findAll()
          .then((list) => list.isNotEmpty ? list.first : null);
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

      final isar = IsarService.isar;
      final savedState = await isar.lengthStateModels.where().findFirst();

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

      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        await isar.lengthStateModels.clear();
      });

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

      final isar = IsarService.isar;
      final count = await isar.lengthStateModels.count();

      return count > 0;
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

      final isar = IsarService.isar;
      final state = await isar.lengthStateModels.where().findFirst();

      if (state != null) {
        // Estimate size based on data
        final cardsSize = state.cards.length * 50; // Rough estimate per card
        final unitsSize =
            state.visibleUnits.length * 20; // Rough estimate per unit
        final baseSize = 100; // Base overhead

        return cardsSize + unitsSize + baseSize;
      }
      return 0;
    } catch (e) {
      logError('LengthStateService: Error calculating state size: $e');
      return 0;
    }
  }

  // Debug method
  static Future<void> debugState() async {
    try {
      final isar = IsarService.isar;
      final state = await isar.lengthStateModels.where().findFirst();
      logInfo('=== LENGTH STATE DEBUG ===');
      logInfo('State exists: ${state != null}');
      if (state != null) {
        logInfo('Cards: ${state.cards.length}');
        logInfo('Visible units: ${state.visibleUnits.length}');
        logInfo('Focus mode: ${state.isFocusMode}');
        logInfo('View mode: ${state.viewMode}');
        logInfo('Last updated: ${state.lastUpdated}');
      }
      logInfo('=== END DEBUG ===');
    } catch (e) {
      logError('LengthStateService: Error debugging state: $e');
    }
  }
}
