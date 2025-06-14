// ignore_for_file: non_constant_identifier_names

import 'package:hive_flutter/hive_flutter.dart';
import 'package:setpocket/models/converter_models/weight_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';

class WeightStateService {
  static const String _boxName = 'weight_state';

  /// Get the weight state box
  static Future<Box<WeightStateModel>> _getBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox<WeightStateModel>(_boxName);
      }
      return Hive.box<WeightStateModel>(_boxName);
    } catch (e) {
      logError('WeightStateService: Error opening box: $e');

      // If box is corrupted, try to delete and recreate
      try {
        if (Hive.isBoxOpen(_boxName)) {
          final box = Hive.box<WeightStateModel>(_boxName);
          await box.close();
        }
        await Hive.deleteBoxFromDisk(_boxName);
        logInfo('WeightStateService: Deleted corrupted box, creating new one');
        return await Hive.openBox<WeightStateModel>(_boxName);
      } catch (deleteError) {
        logError(
            'WeightStateService: Error deleting corrupted box: $deleteError');
        rethrow;
      }
    }
  }

  // Check if feature state saving is enabled
  static Future<bool> _isFeatureStateSavingEnabled() async {
    try {
      final enabled = await SettingsService.getFeatureStateSaving();
      logInfo('WeightStateService: Feature state saving enabled: $enabled');
      return enabled;
    } catch (e) {
      logError(
          'WeightStateService: Error checking feature state saving settings: $e');
      // Default to enabled if error occurs
      return true;
    }
  }

  /// Migrate old data if needed and clear incompatible cache
  static Future<void> _handleDataMigration() async {
    try {
      final box = await _getBox();

      // Check if there's old incompatible data
      if (box.containsKey('current_state')) {
        try {
          final dynamic rawData = box.get('current_state');

          // If raw data is not of expected type, clear it
          if (rawData is! WeightStateModel) {
            logInfo(
                'WeightStateService: Found incompatible data structure, clearing cache');
            await box.delete('current_state');
            return;
          }

          // Additional validation - check if the structure is complete
          final state = rawData;
          // Try to access all required fields to trigger any casting errors
          final _ = state.cards;
          final __ = state.visibleUnits;
          final ___ = state.lastUpdated;
          final ____ = state.isFocusMode;
          final _____ = state.viewMode;

          // Check each card structure
          for (final card in state.cards) {
            final ______ = card.unitCode;
            final _______ = card.amount;
            final ________ = card.name;
            final _________ = card.visibleUnits;
            final __________ = card.createdAt;
          }

          logInfo('WeightStateService: Data structure validation passed');
        } catch (e) {
          logError('WeightStateService: Data structure validation failed: $e');
          logInfo('WeightStateService: Clearing incompatible cache data');
          try {
            await box.delete('current_state');
          } catch (clearError) {
            logError('WeightStateService: Error clearing cache: $clearError');
            // If we can't clear, try to delete the entire box
            try {
              await box.close();
              await Hive.deleteBoxFromDisk(_boxName);
              logInfo('WeightStateService: Deleted corrupted box file');
            } catch (deleteBoxError) {
              logError(
                  'WeightStateService: Error deleting box: $deleteBoxError');
            }
          }
        }
      }
    } catch (e) {
      logError('WeightStateService: Error during data migration: $e');
      // If migration fails, try to delete the corrupted box file
      try {
        if (Hive.isBoxOpen(_boxName)) {
          final box = Hive.box<WeightStateModel>(_boxName);
          await box.close();
        }
        await Hive.deleteBoxFromDisk(_boxName);
        logInfo(
            'WeightStateService: Deleted corrupted box file due to migration error');
      } catch (deleteError) {
        logError(
            'WeightStateService: Error deleting corrupted box: $deleteError');
      }
    }
  }

  /// Load weight state from storage
  static Future<WeightStateModel> loadState() async {
    try {
      // Handle data migration first
      await _handleDataMigration();

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'WeightStateService: Feature state saving is disabled, returning default state');
        return WeightStateModel.createDefault();
      }

      final box = await _getBox();
      final state = box.get('current_state');

      if (state == null) {
        logInfo('WeightStateService: No saved state found, creating default');
        return WeightStateModel.createDefault();
      }

      logInfo(
          'WeightStateService: Loaded state with ${state.cards.length} cards');
      return state;
    } catch (e) {
      logError('WeightStateService: Error loading state: $e');

      // Clear corrupted data and return default
      try {
        await clearState();
        logInfo('WeightStateService: Cleared corrupted state data');
      } catch (clearError) {
        logError(
            'WeightStateService: Error clearing corrupted state: $clearError');
      }

      return WeightStateModel.createDefault();
    }
  }

  /// Save weight state to storage
  static Future<void> saveState(WeightStateModel state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'WeightStateService: Feature state saving is disabled, skipping save');
        return;
      }

      final box = await _getBox();
      await box.put('current_state', state);
      logInfo(
          'WeightStateService: Saved state with ${state.cards.length} cards');
    } catch (e) {
      logError('WeightStateService: Error saving state: $e');
    }
  }

  /// Clear weight converter state
  static Future<void> clearState() async {
    try {
      logInfo('WeightStateService: Clearing weight converter state');

      Box<WeightStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<WeightStateModel>(_boxName);
      } else {
        box = await Hive.openBox<WeightStateModel>(_boxName);
        shouldClose = true;
      }

      await box.delete('current_state');

      if (shouldClose) {
        await box.close();
      }

      logInfo('WeightStateService: Successfully cleared state');
    } catch (e) {
      logError('WeightStateService: Error clearing state: $e');
      rethrow;
    }
  }

  /// Force delete corrupted box file (for emergency recovery)
  static Future<void> forceDeleteCorruptedBox() async {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<WeightStateModel>(_boxName);
        await box.close();
        logInfo('WeightStateService: Closed open box before deletion');
      }

      await Hive.deleteBoxFromDisk(_boxName);
      logInfo('WeightStateService: Force deleted corrupted box file');
    } catch (e) {
      logError('WeightStateService: Error force deleting box: $e');
    }
  }

  /// Force clear all cache (for debugging/recovery)
  static Future<void> forceClearAllCache() async {
    try {
      await forceDeleteCorruptedBox();
      logInfo('WeightStateService: Force cleared all cache data');
    } catch (e) {
      logError('WeightStateService: Error force clearing cache: $e');
    }
  }

  /// Get default weight converter state
  // static WeightStateModel _getDefaultState() {
  //   return WeightStateModel(
  //     cards: [
  //       WeightCardState(
  //         unitCode: 'newtons',
  //         amount: 1.0,
  //         name: 'Card 1',
  //         visibleUnits: ['newtons', 'kilogram_force', 'pound_force'],
  //         createdAt: DateTime.now(),
  //       ),
  //     ],
  //     visibleUnits: ['newtons', 'kilogram_force', 'pound_force'],
  //     lastUpdated: DateTime.now(),
  //     isFocusMode: false,
  //     viewMode: 'cards',
  //   );
  // }

  /// Validate and migrate state data
  // static WeightStateModel _validateAndMigrateState(WeightStateModel state) {
  //   try {
  //     // Ensure all cards have required fields
  //     final validCards = <WeightCardState>[];
  //     for (final card in state.cards) {
  //       if (card.unitCode.isNotEmpty && card.amount.isFinite) {
  //         // Ensure card has visible units
  //         if (card.visibleUnits == null || card.visibleUnits!.isEmpty) {
  //           card.visibleUnits = ['newtons', 'kilogram_force', 'pound_force'];
  //         }

  //         // Ensure card has a name
  //         if (card.name == null || card.name!.isEmpty) {
  //           card.name = 'Card ${validCards.length + 1}';
  //         }

  //         validCards.add(card);
  //       }
  //     }

  //     // Ensure at least one card exists
  //     if (validCards.isEmpty) {
  //       validCards.add(WeightCardState(
  //         unitCode: 'newtons',
  //         amount: 1.0,
  //         name: 'Card 1',
  //         visibleUnits: ['newtons', 'kilogram_force', 'pound_force'],
  //         createdAt: DateTime.now(),
  //       ));
  //     }

  //     // Ensure global visible units
  //     if (state.visibleUnits.isEmpty) {
  //       state.visibleUnits = ['newtons', 'kilogram_force', 'pound_force'];
  //     }

  //     // Update state with validated data
  //     state.cards = validCards;

  //     logInfo(
  //         'WeightStateService: State validation completed with ${validCards.length} valid cards');
  //     return state;
  //   } catch (e) {
  //     logError('WeightStateService: Error validating state: $e');
  //     return _getDefaultState();
  //   }
  // }

  /// Check if weight converter state exists
  static Future<bool> hasState() async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        return false;
      }

      Box<WeightStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<WeightStateModel>(_boxName);
      } else {
        box = await Hive.openBox<WeightStateModel>(_boxName);
        shouldClose = true;
      }

      final hasData = box.containsKey('current_state');

      if (shouldClose) {
        await box.close();
      }

      return hasData;
    } catch (e) {
      logError('WeightStateService: Error checking state existence: $e');
      return false;
    }
  }

  /// Get the size of weight converter state data in bytes
  static Future<int> getStateSize() async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        return 0;
      }

      Box<WeightStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<WeightStateModel>(_boxName);
      } else {
        box = await Hive.openBox<WeightStateModel>(_boxName);
        shouldClose = true;
      }

      final stateData = box.get('current_state');

      if (shouldClose) {
        await box.close();
      }

      if (stateData == null) {
        return 0;
      }

      // Estimate size based on data structure
      int size = 0;
      size += stateData.cards.length * 200; // Approximate size per card
      size += stateData.visibleUnits.length * 20; // Approximate size per unit
      size += 100; // Base overhead
      return size;
    } catch (e) {
      logError('WeightStateService: Error calculating state size: $e');
      return 0;
    }
  }
}
