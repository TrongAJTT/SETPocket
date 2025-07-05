import 'package:setpocket/models/converter_models/time_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';

class TimeStateServiceIsar {
  static const String _stateKey = 'time_converter_state';

  /// Load time converter state
  static Future<TimeStateModel> loadState() async {
    try {
      logInfo('TimeStateServiceIsar: Loading time converter state');

      final isar = IsarService.isar;

      // Try to find existing state
      final existingState = await isar.timeStateModels.get(fastHash(_stateKey));

      if (existingState != null) {
        logInfo(
            'TimeStateServiceIsar: Found existing state with ${existingState.cards.length} cards');
        return existingState;
      }

      // Create default state
      final defaultState = TimeStateModel(
        cards: [
          TimeCardState(
            unitCode: 'seconds',
            amount: 0.0,
            name: 'Card 1',
            visibleUnits: ['seconds', 'minutes', 'hours', 'days'],
          ),
        ],
        visibleUnits: [
          'seconds',
          'minutes',
          'hours',
          'days',
          'weeks',
          'months',
          'years'
        ],
        lastUpdated: DateTime.now(),
        isFocusMode: false,
        viewMode: 'cards',
      );

      // Save default state
      await saveState(defaultState);

      logInfo('TimeStateServiceIsar: Created and saved default state');
      return defaultState;
    } catch (e) {
      logError('TimeStateServiceIsar: Error loading state: $e');

      // Return default state on error
      return TimeStateModel(
        cards: [
          TimeCardState(
            unitCode: 'seconds',
            amount: 0.0,
            name: 'Card 1',
            visibleUnits: ['seconds', 'minutes', 'hours', 'days'],
          ),
        ],
        visibleUnits: [
          'seconds',
          'minutes',
          'hours',
          'days',
          'weeks',
          'months',
          'years'
        ],
        lastUpdated: DateTime.now(),
        isFocusMode: false,
        viewMode: 'cards',
      );
    }
  }

  /// Save time converter state
  static Future<void> saveState(TimeStateModel state) async {
    try {
      logInfo('TimeStateServiceIsar: Saving time converter state');

      final isar = IsarService.isar;

      // Update lastUpdated
      final updatedState = TimeStateModel(
        cards: state.cards,
        visibleUnits: state.visibleUnits,
        lastUpdated: DateTime.now(),
        isFocusMode: state.isFocusMode,
        viewMode: state.viewMode,
      );

      await isar.writeTxn(() async {
        await isar.timeStateModels.put(updatedState);
      });

      logInfo('TimeStateServiceIsar: State saved successfully');
    } catch (e) {
      logError('TimeStateServiceIsar: Error saving state: $e');
    }
  }

  /// Clear state
  static Future<void> clearState() async {
    try {
      logInfo('TimeStateServiceIsar: Clearing time converter state');

      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        await isar.timeStateModels.delete(fastHash(_stateKey));
      });

      logInfo('TimeStateServiceIsar: State cleared successfully');
    } catch (e) {
      logError('TimeStateServiceIsar: Error clearing state: $e');
    }
  }

  /// Force clear all cache (for recovery from corruption)
  static Future<void> forceClearAllCache() async {
    try {
      logInfo('TimeStateServiceIsar: Force clearing all time converter cache');

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.timeStateModels.clear();
      });

      logInfo('TimeStateServiceIsar: Successfully force cleared all cache');
    } catch (e) {
      logError('TimeStateServiceIsar: Error force clearing cache: $e');
      // Don't rethrow as this is a recovery operation
    }
  }

  /// Check if state exists
  static Future<bool> hasState() async {
    try {
      final isar = IsarService.isar;
      final state = await isar.timeStateModels.get(fastHash(_stateKey));
      return state != null;
    } catch (e) {
      logError('TimeStateServiceIsar: Error checking state existence: $e');
      return false;
    }
  }

  /// Get state size (for debugging)
  static Future<int> getStateSize() async {
    try {
      final isar = IsarService.isar;
      final state = await isar.timeStateModels.get(fastHash(_stateKey));

      if (state != null) {
        // Estimate size based on number of cards and other data
        double size = 0.0;
        size += state.cards.length * 100.0; // Estimate per card
        size += state.visibleUnits.length * 10.0; // Estimate per unit
        size += 50.0; // Other fields
        return size.round();
      }
      return 0;
    } catch (e) {
      logError('TimeStateServiceIsar: Error getting state size: $e');
      return 0;
    }
  }

  /// Create default state for specific units
  static TimeStateModel createDefaultStateForUnits(List<String> units) {
    return TimeStateModel(
      cards: [
        TimeCardState(
          unitCode: units.isNotEmpty ? units.first : 'seconds',
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
      logInfo('TimeStateServiceIsar: Starting migration from Hive');

      // Check if we already have data in Isar
      if (await hasState()) {
        logInfo(
            'TimeStateServiceIsar: Isar data already exists, skipping migration');
        return;
      }

      // Try to load from Hive and migrate
      // Note: Since Hive is being removed, we'll just create default state
      await loadState();
      logInfo('TimeStateServiceIsar: Migration completed with default state');
    } catch (e) {
      logError('TimeStateServiceIsar: Migration error: $e');
    }
  }
}
