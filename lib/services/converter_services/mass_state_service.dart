// ignore_for_file: non_constant_identifier_names

import 'package:hive_flutter/hive_flutter.dart';
import 'package:setpocket/models/converter_models/mass_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';

class MassStateService {
  static const String _boxName = 'mass_state';

  /// Get the mass state box
  static Future<Box<MassStateModel>> _getBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox<MassStateModel>(_boxName);
      }
      return Hive.box<MassStateModel>(_boxName);
    } catch (e) {
      logError('MassStateService: Error opening box: $e');

      // If box is corrupted, try to delete and recreate
      try {
        if (Hive.isBoxOpen(_boxName)) {
          final box = Hive.box<MassStateModel>(_boxName);
          await box.close();
        }
        await Hive.deleteBoxFromDisk(_boxName);
        logInfo('MassStateService: Deleted corrupted box, creating new one');
        return await Hive.openBox<MassStateModel>(_boxName);
      } catch (deleteError) {
        logError(
            'MassStateService: Error deleting corrupted box: $deleteError');
        rethrow;
      }
    }
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
        try {
          final dynamic rawData = box.get('current_state');

          // If raw data is not of expected type, clear it
          if (rawData is! MassStateModel) {
            logInfo(
                'MassStateService: Found incompatible data structure, clearing cache');
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
            final __________ =
                card.createdAt; // This might trigger the casting error
          }

          logInfo('MassStateService: Data structure validation passed');
        } catch (e) {
          logError('MassStateService: Data structure validation failed: $e');
          logInfo('MassStateService: Clearing incompatible cache data');
          try {
            await box.delete('current_state');
          } catch (clearError) {
            logError('MassStateService: Error clearing cache: $clearError');
            // If we can't clear, try to delete the entire box
            try {
              await box.close();
              await Hive.deleteBoxFromDisk(_boxName);
              logInfo('MassStateService: Deleted corrupted box file');
            } catch (deleteBoxError) {
              logError('MassStateService: Error deleting box: $deleteBoxError');
            }
          }
        }
      }
    } catch (e) {
      logError('MassStateService: Error during data migration: $e');
      // If migration fails, try to delete the corrupted box file
      try {
        if (Hive.isBoxOpen(_boxName)) {
          final box = Hive.box<MassStateModel>(_boxName);
          await box.close();
        }
        await Hive.deleteBoxFromDisk(_boxName);
        logInfo(
            'MassStateService: Deleted corrupted box file due to migration error');
      } catch (deleteError) {
        logError(
            'MassStateService: Error deleting corrupted box: $deleteError');
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
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        return false;
      }

      Box<MassStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<MassStateModel>(_boxName);
      } else {
        box = await Hive.openBox<MassStateModel>(_boxName);
        shouldClose = true;
      }

      final hasData = box.containsKey('current_state');

      if (shouldClose) {
        await box.close();
      }

      return hasData;
    } catch (e) {
      logError('MassStateService: Error checking state: $e');
      return false;
    }
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        return 0;
      }

      Box<MassStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<MassStateModel>(_boxName);
      } else {
        box = await Hive.openBox<MassStateModel>(_boxName);
        shouldClose = true;
      }

      final state = box.get('current_state');

      if (shouldClose) {
        await box.close();
      }

      if (state != null && state is MassStateModel) {
        // Rough estimation: each card = ~100 bytes, each visible unit = ~20 bytes
        int size = state.cards.length * 100;
        size += state.visibleUnits.length * 20;
        size += 50; // metadata overhead
        return size;
      }

      return 0;
    } catch (e) {
      logError('MassStateService: Error calculating state size: $e');
      return 0;
    }
  }

  /// Force delete corrupted box file (for emergency recovery)
  static Future<void> forceDeleteCorruptedBox() async {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<MassStateModel>(_boxName);
        await box.close();
        logInfo('MassStateService: Closed open box before deletion');
      }

      await Hive.deleteBoxFromDisk(_boxName);
      logInfo('MassStateService: Force deleted corrupted box file');
    } catch (e) {
      logError('MassStateService: Error force deleting box: $e');
    }
  }

  /// Force clear all cache (for debugging/recovery)
  static Future<void> forceClearAllCache() async {
    try {
      await forceDeleteCorruptedBox();
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
