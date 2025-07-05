import 'package:isar/isar.dart';
import 'package:setpocket/models/converter_models/currency_state_model.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';

class CurrencyStateService {
  // Check if state saving is enabled
  static Future<bool> isStateSavingEnabled() async {
    try {
      final settings = await SettingsService.getSettings();
      final enabled = settings.featureStateSavingEnabled;
      logInfo('CurrencyStateService: State saving enabled: $enabled');
      return enabled;
    } catch (e) {
      logError(
          'CurrencyStateService: Error checking state saving settings: $e');
      // Default to enabled if error occurs
      return true;
    }
  }

  // Save currency converter state
  static Future<void> saveState(CurrencyStateModel state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await isStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'CurrencyStateService: State saving is disabled, skipping save');
        return;
      }

      final isar = IsarService.isar;

      logInfo(
          'CurrencyStateService: Saving converter state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');

      // Update timestamp
      state.lastUpdated = DateTime.now();

      await isar.writeTxn(() async {
        await isar.currencyStateModels.clear();
        await isar.currencyStateModels.put(state);
      });

      logInfo('CurrencyStateService: State saved successfully');
    } catch (e) {
      logError('CurrencyStateService: Error saving state: $e');
      // Don't rethrow to avoid breaking the app
    }
  }

  // Load currency converter state
  static Future<CurrencyStateModel> loadState() async {
    try {
      logInfo('CurrencyStateService: Starting loadState');

      // Check if feature state saving is enabled
      final enabled = await isStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'CurrencyStateService: State saving is disabled, returning default state');
        return CurrencyStateModel.getDefault();
      }

      final isar = IsarService.isar;
      final state = await isar.currencyStateModels.where().findFirst();

      if (state != null) {
        logInfo(
            'CurrencyStateService: Loaded state with ${state.cards.length} cards, focus: ${state.isFocusMode}, view: ${state.viewMode}');
        return state;
      } else {
        logInfo('CurrencyStateService: No saved state, returning default');
        return CurrencyStateModel.getDefault();
      }
    } catch (e) {
      logError('CurrencyStateService: Error loading state: $e');
      return CurrencyStateModel.getDefault();
    }
  }

  // Clear saved state
  static Future<void> clearState() async {
    try {
      logInfo('CurrencyStateService: Clearing currency converter state');

      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        await isar.currencyStateModels.clear();
      });

      logInfo('CurrencyStateService: Successfully cleared state');
    } catch (e) {
      logError('CurrencyStateService: Error clearing state: $e');
      rethrow;
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      final enabled = await isStateSavingEnabled();
      if (!enabled) {
        return false;
      }

      final isar = IsarService.isar;
      final count = await isar.currencyStateModels.count();

      return count > 0;
    } catch (e) {
      logError('CurrencyStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      final enabled = await isStateSavingEnabled();
      if (!enabled) {
        return 0;
      }

      final isar = IsarService.isar;
      final state = await isar.currencyStateModels.where().findFirst();

      if (state != null) {
        // Estimate size based on data structure
        int size = 0;
        size += (state.cards.length * 150).toInt(); // Approximate size per card
        size += (state.visibleCurrencies.length * 10)
            .toInt(); // Approximate size per currency
        size += 100; // Base overhead
        return size;
      }
      return 0;
    } catch (e) {
      logError('CurrencyStateService: Error calculating state size: $e');
      return 0;
    }
  }

  // Debug method
  static Future<void> debugState() async {
    try {
      final isar = IsarService.isar;
      final state = await isar.currencyStateModels.where().findFirst();
      logInfo('=== CURRENCY STATE DEBUG ===');
      logInfo('State exists: ${state != null}');
      if (state != null) {
        logInfo('Cards: ${state.cards.length}');
        logInfo('Visible currencies: ${state.visibleCurrencies.length}');
        logInfo('Focus mode: ${state.isFocusMode}');
        logInfo('View mode: ${state.viewMode}');
        logInfo('Last updated: ${state.lastUpdated}');
      }
      logInfo('=== END DEBUG ===');
    } catch (e) {
      logError('CurrencyStateService: Error debugging state: $e');
    }
  }
}
