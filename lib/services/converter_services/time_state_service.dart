import 'package:hive/hive.dart';
import 'package:setpocket/models/converter_models/time_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_service.dart';

class TimeStateService {
  static const String _boxName = 'time_state';
  static const String _stateKey = 'time_converter_state';

  /// Load time converter state
  static Future<TimeStateModel> loadState() async {
    try {
      logInfo('TimeStateService: Loading time converter state');

      Box<TimeStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<TimeStateModel>(_boxName);
      } else {
        box = await Hive.openBox<TimeStateModel>(_boxName);
        shouldClose = true;
      }

      final data = box.get(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      if (data == null) {
        logInfo('TimeStateService: No saved state found, returning default');
        return _getDefaultState();
      }

      TimeStateModel state;
      state = data;
      logInfo(
          'TimeStateService: Successfully loaded state with ${state.cards.length} cards');
      return state;
    } catch (e) {
      logError('TimeStateService: Error loading state: $e');

      // Handle specific casting errors
      if (e.toString().contains('DateTime') &&
          e.toString().contains('String')) {
        logInfo(
            'TimeStateService: Detected DateTime casting error, clearing corrupted data');
        await clearState();
      }

      return _getDefaultState();
    }
  }

  /// Save time converter state
  static Future<void> saveState(TimeStateModel state) async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        logInfo('TimeStateService: State saving is disabled, skipping save');
        return;
      }

      logInfo(
          'TimeStateService: Saving time converter state with ${state.cards.length} cards');

      Box<TimeStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<TimeStateModel>(_boxName);
      } else {
        box = await Hive.openBox<TimeStateModel>(_boxName);
        shouldClose = true;
      }

      // Update timestamp
      state.lastUpdated = DateTime.now();

      await box.put(_stateKey, state);

      if (shouldClose) {
        await box.close();
      }

      logInfo('TimeStateService: Successfully saved state');
    } catch (e) {
      logError('TimeStateService: Error saving state: $e');
      rethrow;
    }
  }

  /// Clear time converter state
  static Future<void> clearState() async {
    try {
      logInfo('TimeStateService: Clearing time converter state');

      Box<TimeStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<TimeStateModel>(_boxName);
      } else {
        box = await Hive.openBox<TimeStateModel>(_boxName);
        shouldClose = true;
      }

      await box.delete(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      logInfo('TimeStateService: Successfully cleared state');
    } catch (e) {
      logError('TimeStateService: Error clearing state: $e');
      rethrow;
    }
  }

  /// Force clear all cache (for recovery from corruption)
  static Future<void> forceClearAllCache() async {
    try {
      logInfo('TimeStateService: Force clearing all time converter cache');

      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<TimeStateModel>(_boxName);
        await box.clear();
        await box.close();
      }

      // Also try to delete the box file
      await Hive.deleteBoxFromDisk(_boxName);

      logInfo('TimeStateService: Successfully force cleared all cache');
    } catch (e) {
      logError('TimeStateService: Error force clearing cache: $e');
      // Don't rethrow as this is a recovery operation
    }
  }

  /// Check if state exists
  static Future<bool> hasState() async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        return false;
      }

      Box<TimeStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<TimeStateModel>(_boxName);
      } else {
        box = await Hive.openBox<TimeStateModel>(_boxName);
        shouldClose = true;
      }

      final hasData = box.containsKey(_stateKey);

      if (shouldClose) {
        await box.close();
      }

      return hasData;
    } catch (e) {
      logError('TimeStateService: Error checking state existence: $e');
      return false;
    }
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      Box<TimeStateModel> box;
      bool shouldClose = false;

      if (Hive.isBoxOpen(_boxName)) {
        box = Hive.box<TimeStateModel>(_boxName);
      } else {
        box = await Hive.openBox<TimeStateModel>(_boxName);
        shouldClose = true;
      }

      final state = box.get(_stateKey);
      int size = 0;

      if (state != null) {
        // Estimate size based on content
        size += state.cards.length * 200; // ~200 bytes per card
        size += state.visibleUnits.length * 20; // ~20 bytes per unit
        size += 100; // Base overhead
      }

      if (shouldClose) {
        await box.close();
      }

      return size;
    } catch (e) {
      logError('TimeStateService: Error calculating state size: $e');
      return 0;
    }
  }

  /// Get default time converter state
  static TimeStateModel _getDefaultState() {
    return TimeStateModel(
      cards: [
        TimeCardState(
          unitCode: 'seconds',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: ['seconds', 'minutes', 'hours', 'days'],
          createdAt: DateTime.now(),
        ),
      ],
      visibleUnits: ['seconds', 'minutes', 'hours', 'days'],
      lastUpdated: DateTime.now(),
      isFocusMode: false,
      viewMode: 'cards',
    );
  }
}
