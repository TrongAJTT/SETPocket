import 'package:setpocket/models/converter_models/weight_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/settings_service.dart';

class WeightStateServiceIsar {
  static const String _stateKey = 'weight_converter_state';

  /// Load weight converter state
  static Future<WeightStateModel> loadState() async {
    try {
      logInfo('WeightStateServiceIsar: Loading weight converter state');

      final isar = IsarService.isar;

      // Try to find existing state
      final existingState =
          await isar.weightStateModels.get(fastHash(_stateKey));

      if (existingState != null) {
        logInfo(
            'WeightStateServiceIsar: Found existing state with ${existingState.cards.length} cards');
        return existingState;
      }

      // Create default state
      final defaultState = WeightStateModel(
        cards: [
          WeightCardState(
            unitCode: 'grams',
            amount: 0.0,
            name: 'Card 1',
            visibleUnits: ['grams', 'kilograms', 'pounds', 'ounces'],
          ),
        ],
        visibleUnits: [
          'grams',
          'kilograms',
          'pounds',
          'ounces',
          'tons',
          'stones'
        ],
        lastUpdated: DateTime.now(),
        isFocusMode: false,
        viewMode: 'cards',
      );

      // Save default state
      await saveState(defaultState);

      logInfo(
          'WeightStateServiceIsar: Created and saved default state with ${defaultState.cards.length} cards');
      return defaultState;
    } catch (e) {
      logError('WeightStateServiceIsar: Error loading state: $e');
      // Return minimal default state on error
      return WeightStateModel(
        cards: [
          WeightCardState(
            unitCode: 'grams',
            amount: 0.0,
            name: 'Card 1',
            visibleUnits: ['grams', 'kilograms'],
          ),
        ],
        visibleUnits: ['grams', 'kilograms'],
        lastUpdated: DateTime.now(),
        isFocusMode: false,
        viewMode: 'cards',
      );
    }
  }

  /// Save weight converter state
  static Future<void> saveState(WeightStateModel state) async {
    try {
      // Check if feature is enabled
      final enabled = await SettingsService.getFeatureStateSaving();
      if (!enabled) {
        logInfo(
            'WeightStateServiceIsar: State saving is disabled, skipping save');
        return;
      }

      logInfo(
          'WeightStateServiceIsar: Saving weight converter state with ${state.cards.length} cards');

      final isar = IsarService.isar;

      // Update timestamp
      final updatedState = state.copyWith(lastUpdated: DateTime.now());

      await isar.writeTxn(() async {
        await isar.weightStateModels
            .put(updatedState..id = fastHash(_stateKey));
      });

      logInfo('WeightStateServiceIsar: Successfully saved state');
    } catch (e) {
      logError('WeightStateServiceIsar: Error saving state: $e');
      rethrow;
    }
  }

  /// Clear weight converter state
  static Future<void> clearState() async {
    try {
      logInfo('WeightStateServiceIsar: Clearing weight converter state');

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.weightStateModels.delete(fastHash(_stateKey));
      });

      logInfo('WeightStateServiceIsar: Successfully cleared state');
    } catch (e) {
      logError('WeightStateServiceIsar: Error clearing state: $e');
      rethrow;
    }
  }

  /// Force clear all cache (for recovery from corruption)
  static Future<void> forceClearAllCache() async {
    try {
      logInfo(
          'WeightStateServiceIsar: Force clearing all weight converter cache');

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.weightStateModels.clear();
      });

      logInfo('WeightStateServiceIsar: Successfully force cleared all cache');
    } catch (e) {
      logError('WeightStateServiceIsar: Error force clearing cache: $e');
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
      final state = await isar.weightStateModels.get(fastHash(_stateKey));
      return state != null;
    } catch (e) {
      logError('WeightStateServiceIsar: Error checking state existence: $e');
      return false;
    }
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      final isar = IsarService.isar;
      final state = await isar.weightStateModels.get(fastHash(_stateKey));

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
      logError('WeightStateServiceIsar: Error getting state size: $e');
      return 0;
    }
  }

  /// Create default state for specific units
  static WeightStateModel createDefaultStateForUnits(List<String> units) {
    return WeightStateModel(
      cards: [
        WeightCardState(
          unitCode: units.isNotEmpty ? units.first : 'grams',
          amount: 0.0,
          name: 'Card 1',
          visibleUnits: units.take(4).toList(),
        ),
      ],
      visibleUnits: units,
      lastUpdated: DateTime.now(),
      isFocusMode: false,
      viewMode: 'cards',
    );
  }

  /// Migrate from Hive if needed
  static Future<void> migrateFromHive() async {
    try {
      logInfo('WeightStateServiceIsar: Starting migration from Hive');

      // Check if we already have data in Isar
      if (await hasState()) {
        logInfo(
            'WeightStateServiceIsar: Isar data already exists, skipping migration');
        return;
      }

      // Try to load from Hive and migrate
      // Note: Since Hive is being removed, we'll just create default state
      await loadState();
      logInfo('WeightStateServiceIsar: Migration completed with default state');
    } catch (e) {
      logError('WeightStateServiceIsar: Migration error: $e');
    }
  }
}
