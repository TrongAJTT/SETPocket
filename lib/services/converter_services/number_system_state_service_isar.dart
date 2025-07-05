import 'package:setpocket/models/converter_models/number_system_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/settings_service.dart';

class NumberSystemStateServiceIsar {
  static const String _stateKey = 'number_system_converter_state';

  /// Load number system converter state
  static Future<NumberSystemStateModel> loadState() async {
    try {
      logInfo(
          'NumberSystemStateServiceIsar: Loading number system converter state');

      final isar = IsarService.isar;

      // Try to find existing state
      final existingState =
          await isar.numberSystemStateModels.get(fastHash(_stateKey));

      if (existingState != null) {
        logInfo(
            'NumberSystemStateServiceIsar: Found existing state with ${existingState.cards.length} cards');
        return existingState;
      }

      // Create default state
      final defaultState = NumberSystemStateModel.createDefault();

      // Save default state
      await saveState(defaultState);

      logInfo(
          'NumberSystemStateServiceIsar: Created and saved default state with ${defaultState.cards.length} cards');
      return defaultState;
    } catch (e) {
      logError('NumberSystemStateServiceIsar: Error loading state: $e');
      // Return minimal default state on error
      return NumberSystemStateModel.createDefault();
    }
  }

  /// Save number system converter state
  static Future<void> saveState(NumberSystemStateModel state) async {
    try {
      // Check if feature is enabled
      final enabled = await SettingsService.getFeatureStateSaving();
      if (!enabled) {
        logInfo(
            'NumberSystemStateServiceIsar: State saving is disabled, skipping save');
        return;
      }

      logInfo(
          'NumberSystemStateServiceIsar: Saving number system converter state with ${state.cards.length} cards');

      final isar = IsarService.isar;

      // Update timestamp
      final updatedState = state.copyWith(lastUpdated: DateTime.now());

      await isar.writeTxn(() async {
        await isar.numberSystemStateModels
            .put(updatedState..id = fastHash(_stateKey));
      });

      logInfo('NumberSystemStateServiceIsar: Successfully saved state');
    } catch (e) {
      logError('NumberSystemStateServiceIsar: Error saving state: $e');
      rethrow;
    }
  }

  /// Clear number system converter state
  static Future<void> clearState() async {
    try {
      logInfo(
          'NumberSystemStateServiceIsar: Clearing number system converter state');

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.numberSystemStateModels.delete(fastHash(_stateKey));
      });

      logInfo('NumberSystemStateServiceIsar: Successfully cleared state');
    } catch (e) {
      logError('NumberSystemStateServiceIsar: Error clearing state: $e');
      rethrow;
    }
  }

  /// Force clear all cache (for recovery from corruption)
  static Future<void> forceClearAllCache() async {
    try {
      logInfo(
          'NumberSystemStateServiceIsar: Force clearing all number system converter cache');

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.numberSystemStateModels.clear();
      });

      logInfo(
          'NumberSystemStateServiceIsar: Successfully force cleared all cache');
    } catch (e) {
      logError('NumberSystemStateServiceIsar: Error force clearing cache: $e');
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
      final state = await isar.numberSystemStateModels.get(fastHash(_stateKey));
      return state != null;
    } catch (e) {
      logError(
          'NumberSystemStateServiceIsar: Error checking state existence: $e');
      return false;
    }
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      final isar = IsarService.isar;
      final state = await isar.numberSystemStateModels.get(fastHash(_stateKey));

      if (state != null) {
        // Estimate size based on content
        int size = 0;
        size += state.cards.length * 200; // ~200 bytes per card
        size += 100; // Base overhead
        return size;
      }
      return 0;
    } catch (e) {
      logError('NumberSystemStateServiceIsar: Error getting state size: $e');
      return 0;
    }
  }

  /// Migrate from Hive if needed
  static Future<void> migrateFromHive() async {
    try {
      logInfo('NumberSystemStateServiceIsar: Starting migration from Hive');

      // Check if we already have data in Isar
      if (await hasState()) {
        logInfo(
            'NumberSystemStateServiceIsar: Isar data already exists, skipping migration');
        return;
      }

      // Try to load from Hive and migrate
      // Note: Since Hive is being removed, we'll just create default state
      await loadState();
      logInfo(
          'NumberSystemStateServiceIsar: Migration completed with default state');
    } catch (e) {
      logError('NumberSystemStateServiceIsar: Migration error: $e');
    }
  }
}
