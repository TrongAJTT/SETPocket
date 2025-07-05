// ignore_for_file: non_constant_identifier_names

import 'package:isar/isar.dart';
import 'package:setpocket/models/converter_models/mass_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';

class MassStateServiceIsar {
  // Check if feature state saving is enabled
  static Future<bool> _isFeatureStateSavingEnabled() async {
    try {
      final enabled = await SettingsService.getFeatureStateSaving();
      logInfo('MassStateServiceIsar: Feature state saving enabled: $enabled');
      return enabled;
    } catch (e) {
      logError(
          'MassStateServiceIsar: Error checking feature state saving settings: $e');
      // Default to enabled if error occurs
      logInfo('MassStateServiceIsar: Using default enabled=true due to error');
      return true;
    }
  }

  // Save mass converter state
  Future<void> saveState(MassStateModel state) async {
    try {
      logInfo(
          'MassStateServiceIsar: Attempting to save state with ${state.cards.length} cards');

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'MassStateServiceIsar: Feature state saving is disabled, skipping save');
        return;
      }

      final isar = IsarService.isar;

      logInfo(
          'MassStateServiceIsar: Saving mass converter state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');

      // Update timestamp
      state.lastUpdated = DateTime.now();

      await isar.writeTxn(() async {
        await isar.massStateModels.clear();
        await isar.massStateModels.put(state);
      });

      logInfo('MassStateServiceIsar: State saved successfully');
    } catch (e) {
      logError('MassStateServiceIsar: Error saving state: $e');
      // Don't rethrow to avoid breaking the app
    }
  }

  // Load mass converter state
  Future<MassStateModel?> loadState() async {
    try {
      logInfo('MassStateServiceIsar: Attempting to load mass converter state');

      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'MassStateServiceIsar: Feature state saving is disabled, returning null');
        return null;
      }

      final isar = IsarService.isar;
      final state = await isar.massStateModels.where().findFirst();

      if (state != null) {
        logInfo(
            'MassStateServiceIsar: Loaded mass converter state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');
        return state;
      } else {
        logInfo('MassStateServiceIsar: No saved mass converter state found');
        return null;
      }
    } catch (e) {
      logError('MassStateServiceIsar: Error loading state: $e');
      return null;
    }
  }

  // Clear mass converter state
  Future<void> clearState() async {
    try {
      logInfo('MassStateServiceIsar: Clearing mass converter state');

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.massStateModels.clear();
      });

      logInfo('MassStateServiceIsar: Mass converter state cleared');
    } catch (e) {
      logError('MassStateServiceIsar: Error clearing state: $e');
    }
  }

  // Get estimated data size
  Future<int> getDataSize() async {
    try {
      final isar = IsarService.isar;
      final states = await isar.massStateModels.where().findAll();

      int totalSize = 0;
      for (final state in states) {
        // Estimate size based on state data
        totalSize += state.cards.length * 100; // Estimate per card
        totalSize += 50; // Base state overhead
      }

      return totalSize;
    } catch (e) {
      logError('MassStateServiceIsar: Error calculating data size: $e');
      return 0;
    }
  }

  // Check if state exists
  Future<bool> hasState() async {
    try {
      final isar = IsarService.isar;
      final count = await isar.massStateModels.count();
      return count > 0;
    } catch (e) {
      logError('MassStateServiceIsar: Error checking state existence: $e');
      return false;
    }
  }

  // Get state size (alias for getDataSize for compatibility)
  Future<int> getStateSize() async {
    return await getDataSize();
  }
}
