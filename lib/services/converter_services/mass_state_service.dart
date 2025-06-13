import 'package:hive_flutter/hive_flutter.dart';
import 'package:setpocket/models/converter_models/mass_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';

class MassStateService {
  static const String _boxName = 'mass_state';

  /// Get the mass state box
  static Future<Box<MassStateModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<MassStateModel>(_boxName);
    }
    return Hive.box<MassStateModel>(_boxName);
  }

  // Check if feature state saving is enabled
  static Future<bool> _isFeatureStateSavingEnabled() async {
    try {
      final enabled = await SettingsService.getFeatureStateSaving();
      logInfo('MassStateService: Feature state saving enabled: $enabled');
      return enabled;
    } catch (e) {
      logError(
          'MassStateService: Error checking feature state saving settings: $e');
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
        final dynamic rawData = box.get('current_state');

        // If raw data is not of expected type, clear it
        if (rawData is! MassStateModel) {
          logInfo(
              'MassStateService: Found incompatible data structure, clearing cache');
          await box.delete('current_state');
          return;
        }

        // Additional validation - check if the structure is complete
        try {
          final state = rawData as MassStateModel;
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

          logInfo('MassStateService: Data structure validation passed');
        } catch (e) {
          logError('MassStateService: Data structure validation failed: $e');
          logInfo('MassStateService: Clearing incompatible cache data');
          await box.delete('current_state');
        }
      }
    } catch (e) {
      logError('MassStateService: Error during data migration: $e');
      // If migration fails, clear the cache to prevent further errors
      try {
        final box = await _getBox();
        await box.clear();
        logInfo(
            'MassStateService: Cleared all cache data due to migration error');
      } catch (clearError) {
        logError('MassStateService: Error clearing cache: $clearError');
      }
    }
  }

  /// Load mass state from storage
  static Future<MassStateModel> loadState() async {
    try {
      // Handle data migration first
      await _handleDataMigration();

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'MassStateService: Feature state saving is disabled, returning default state');
        return MassStateModel.createDefault();
      }

      final box = await _getBox();
      final state = box.get('current_state');

      if (state == null) {
        logInfo('MassStateService: No saved state found, creating default');
        return MassStateModel.createDefault();
      }

      logInfo(
          'MassStateService: Loaded state with ${state.cards.length} cards');
      return state;
    } catch (e) {
      logError('MassStateService: Error loading state: $e');

      // Clear corrupted data and return default
      try {
        await clearState();
        logInfo('MassStateService: Cleared corrupted state data');
      } catch (clearError) {
        logError(
            'MassStateService: Error clearing corrupted state: $clearError');
      }

      return MassStateModel.createDefault();
    }
  }

  /// Save mass state to storage
  static Future<void> saveState(MassStateModel state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'MassStateService: Feature state saving is disabled, skipping save');
        return;
      }

      final box = await _getBox();
      await box.put('current_state', state);
      logInfo('MassStateService: Saved state with ${state.cards.length} cards');
    } catch (e) {
      logError('MassStateService: Error saving state: $e');
    }
  }

  /// Clear saved mass state
  static Future<void> clearState() async {
    try {
      final box = await _getBox();
      await box.delete('current_state');
      logInfo('MassStateService: Cleared saved state');
    } catch (e) {
      logError('MassStateService: Error clearing state: $e');
    }
  }

  /// Check if saved state exists
  static Future<bool> hasState() async {
    try {
      final box = await _getBox();
      return box.containsKey('current_state');
    } catch (e) {
      logError('MassStateService: Error checking state: $e');
      return false;
    }
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      final box = await _getBox();
      final state = box.get('current_state');
      if (state == null) return 0;

      // Rough estimation: each card = ~100 bytes, each visible unit = ~20 bytes
      int size = state.cards.length * 100;
      size += state.visibleUnits.length * 20;
      size += 50; // metadata overhead

      return size;
    } catch (e) {
      logError('MassStateService: Error calculating state size: $e');
      return 0;
    }
  }

  /// Force clear all cache (for debugging/recovery)
  static Future<void> forceClearAllCache() async {
    try {
      final box = await _getBox();
      await box.clear();
      logInfo('MassStateService: Force cleared all cache data');
    } catch (e) {
      logError('MassStateService: Error force clearing cache: $e');
    }
  }

  /// Debug: Print current state info
  static Future<void> debugPrintState() async {
    try {
      final box = await _getBox();
      final state = box.get('current_state');

      logInfo('=== MASS STATE DEBUG ===');
      if (state != null) {
        logInfo('Cards: ${state.cards.length}');
        for (int i = 0; i < state.cards.length; i++) {
          final card = state.cards[i];
          logInfo('  Card $i: ${card.unitCode} = ${card.amount}');
        }
        logInfo('Visible Units: ${state.visibleUnits.join(", ")}');
        logInfo('Last Updated: ${state.lastUpdated}');
        logInfo('Focus Mode: ${state.isFocusMode}');
        logInfo('View Mode: ${state.viewMode}');
      } else {
        logInfo('No state saved');
      }
      logInfo('Box Length: ${box.length}');
      logInfo('=========================');
    } catch (e) {
      logError('MassStateService: Error in debug: $e');
    }
  }
}
