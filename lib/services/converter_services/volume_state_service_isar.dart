import 'package:setpocket/models/converter_models/volume_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/settings_service.dart';

class VolumeStateServiceIsar {
  static const String _stateKey = 'volume_converter_state';

  /// Load volume converter state
  static Future<VolumeStateModel> loadState() async {
    try {
      logInfo('VolumeStateServiceIsar: Loading volume converter state');

      final isar = IsarService.isar;

      // Try to find existing state
      final existingState =
          await isar.volumeStateModels.get(fastHash(_stateKey));

      if (existingState != null) {
        logInfo(
            'VolumeStateServiceIsar: Found existing state with ${existingState.cards.length} cards');
        return existingState;
      }

      // Create default state
      final defaultState = VolumeStateModel.createDefault();

      // Save default state
      await saveState(defaultState);

      logInfo(
          'VolumeStateServiceIsar: Created and saved default state with ${defaultState.cards.length} cards');
      return defaultState;
    } catch (e) {
      logError('VolumeStateServiceIsar: Error loading state: $e');
      // Return minimal default state on error
      return VolumeStateModel.createDefault();
    }
  }

  /// Save volume converter state
  static Future<void> saveState(VolumeStateModel state) async {
    try {
      // Check if feature is enabled
      final enabled = await SettingsService.getFeatureStateSaving();
      if (!enabled) {
        logInfo(
            'VolumeStateServiceIsar: State saving is disabled, skipping save');
        return;
      }

      logInfo(
          'VolumeStateServiceIsar: Saving volume converter state with ${state.cards.length} cards');

      final isar = IsarService.isar;

      // Update timestamp
      final updatedState = state.copyWith(lastUpdated: DateTime.now());

      await isar.writeTxn(() async {
        await isar.volumeStateModels
            .put(updatedState..id = fastHash(_stateKey));
      });

      logInfo('VolumeStateServiceIsar: Successfully saved state');
    } catch (e) {
      logError('VolumeStateServiceIsar: Error saving state: $e');
      rethrow;
    }
  }

  /// Clear volume converter state
  static Future<void> clearState() async {
    try {
      logInfo('VolumeStateServiceIsar: Clearing volume converter state');

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.volumeStateModels.delete(fastHash(_stateKey));
      });

      logInfo('VolumeStateServiceIsar: Successfully cleared state');
    } catch (e) {
      logError('VolumeStateServiceIsar: Error clearing state: $e');
      rethrow;
    }
  }

  /// Force clear all cache (for recovery from corruption)
  static Future<void> forceClearAllCache() async {
    try {
      logInfo(
          'VolumeStateServiceIsar: Force clearing all volume converter cache');

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.volumeStateModels.clear();
      });

      logInfo('VolumeStateServiceIsar: Successfully force cleared all cache');
    } catch (e) {
      logError('VolumeStateServiceIsar: Error force clearing cache: $e');
      // Don't rethrow as this is a recovery operation
    }
  }

  /// Check if state exists
  static Future<bool> hasState() async {
    try {
      final enabled = await SettingsService.getFeatureStateSaving();
      if (!enabled) {
        return false;
      }

      final isar = IsarService.isar;
      final state = await isar.volumeStateModels.get(fastHash(_stateKey));
      return state != null;
    } catch (e) {
      logError('VolumeStateServiceIsar: Error checking state existence: $e');
      return false;
    }
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      final isar = IsarService.isar;
      final state = await isar.volumeStateModels.get(fastHash(_stateKey));

      if (state != null) {
        // Estimate size based on content
        int size = 0;
        size += state.cards.length * 200; // ~200 bytes per card
        size += state.visibleUnits.length * 20; // ~20 bytes per unit
        size += 100; // Base overhead
        return size;
      }
      return 0;
    } catch (e) {
      logError('VolumeStateServiceIsar: Error getting state size: $e');
      return 0;
    }
  }

  /// Migrate from Hive if needed
  static Future<void> migrateFromHive() async {
    try {
      logInfo('VolumeStateServiceIsar: Starting migration from Hive');

      // Check if we already have data in Isar
      if (await hasState()) {
        logInfo(
            'VolumeStateServiceIsar: Isar data already exists, skipping migration');
        return;
      }

      // Try to load from Hive and migrate
      // Note: Since Hive is being removed, we'll just create default state
      await loadState();
      logInfo('VolumeStateServiceIsar: Migration completed with default state');
    } catch (e) {
      logError('VolumeStateServiceIsar: Migration error: $e');
    }
  }
}

/// Fast hash function to generate Isar Id from String
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
