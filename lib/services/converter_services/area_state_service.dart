import 'package:isar/isar.dart';
import 'package:setpocket/models/converter_models/area_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'dart:convert';

class AreaStateService {
  /// Load area converter state from Isar
  static Future<AreaStateModel> loadState() async {
    try {
      logInfo('AreaStateService: Loading area converter state');

      // Check if feature state saving is enabled
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        logInfo(
            'AreaStateService: Feature state saving disabled, returning default state');
        return _getDefaultState();
      }

      final isar = IsarService.isar;
      final states = await isar.areaStateModels.where().findAll();
      final state = states.isNotEmpty ? states.first : null;

      if (state == null) {
        logInfo('AreaStateService: No saved state found, creating default');
        return _getDefaultState();
      }

      // Validate and migrate state if needed
      final validatedState = _validateAndMigrateState(state);

      logInfo(
          'AreaStateService: Successfully loaded state with ${validatedState.cards.length} cards');
      return validatedState;
    } catch (e) {
      logError('AreaStateService: Error loading state: $e');

      return _getDefaultState();
    }
  }

  /// Save area converter state
  static Future<void> saveState(AreaStateModel state) async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        logInfo('AreaStateService: State saving is disabled, skipping save');
        return;
      }

      logInfo(
          'AreaStateService: Saving area converter state with ${state.cards.length} cards');

      final isar = IsarService.isar;

      // Update timestamp
      state.lastUpdated = DateTime.now();

      await isar.writeTxn(() async {
        await isar.areaStateModels.clear();
        await isar.areaStateModels.put(state);
      });

      logInfo('AreaStateService: Successfully saved state');
    } catch (e) {
      logError('AreaStateService: Error saving state: $e');
      rethrow;
    }
  }

  /// Clear area converter state
  static Future<void> clearState() async {
    try {
      logInfo('AreaStateService: Clearing area converter state');

      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        await isar.areaStateModels.clear();
      });

      logInfo('AreaStateService: Successfully cleared state');
    } catch (e) {
      logError('AreaStateService: Error clearing state: $e');
      rethrow;
    }
  }

  /// Force clear all cache data (for recovery from data corruption)
  static Future<void> forceClearAllCache() async {
    try {
      logInfo('AreaStateService: Force clearing all cache data');

      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        await isar.areaStateModels.clear();
      });

      logInfo('AreaStateService: All cache data cleared successfully');
    } catch (e) {
      logError('AreaStateService: Error force clearing cache: $e');
      rethrow;
    }
  }

  /// Get default area converter state
  static AreaStateModel _getDefaultState() {
    return AreaStateModel()
      ..cards = [
        AreaCardState.create(
          unitCode: 'square_meters',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: ['square_meters', 'square_feet', 'square_inches'],
        ),
      ]
      ..visibleUnits = ['square_meters', 'square_feet', 'square_inches']
      ..lastUpdated = DateTime.now()
      ..isFocusMode = false
      ..viewMode = 'cards';
  }

  /// Validate and migrate state data
  static AreaStateModel _validateAndMigrateState(AreaStateModel state) {
    try {
      // Ensure all cards have required fields
      final validCards = <AreaCardState>[];
      for (final card in state.cards) {
        if (card.unitCode != null &&
            card.unitCode!.isNotEmpty &&
            card.amount != null &&
            card.amount!.isFinite) {
          // Ensure card has visible units
          if (card.visibleUnits == null || card.visibleUnits!.isEmpty) {
            card.visibleUnits = [
              'square_meters',
              'square_feet',
              'square_inches'
            ];
          }

          // Ensure card has a name
          if (card.name == null || card.name!.isEmpty) {
            card.name = 'Card ${validCards.length + 1}';
          }

          validCards.add(card);
        }
      }

      // Ensure at least one card exists
      if (validCards.isEmpty) {
        validCards.add(AreaCardState.create(
          unitCode: 'square_meters',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: ['square_meters', 'square_feet', 'square_inches'],
        ));
      }

      // Ensure global visible units
      if (state.visibleUnits.isEmpty) {
        state.visibleUnits = ['square_meters', 'square_feet', 'square_inches'];
      }

      // Update state with validated data
      state.cards = validCards;

      logInfo(
          'AreaStateService: State validation completed with ${validCards.length} valid cards');
      return state;
    } catch (e) {
      logError('AreaStateService: Error validating state: $e');
      return _getDefaultState();
    }
  }

  /// Check if area converter state exists
  static Future<bool> hasState() async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        return false;
      }

      final isar = IsarService.isar;
      final count = await isar.areaStateModels.count();

      return count > 0;
    } catch (e) {
      logError('AreaStateService: Error checking state existence: $e');
      return false;
    }
  }

  /// Get the size of area converter state data in bytes
  static Future<int> getStateSize() async {
    try {
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        return 0;
      }

      final isar = IsarService.isar;
      final state = await isar.areaStateModels.where().findFirst();

      if (state == null) {
        return 0;
      }

      // Estimate size based on data structure
      int size = 100; // Base overhead
      int cardSize = state.cards.length * 200;
      int unitSize = state.visibleUnits.length * 20;
      size += cardSize;
      size += unitSize;
      return size;
    } catch (e) {
      logError('AreaStateService: Error calculating state size: $e');
      return 0;
    }
  }

  /// Debug export of the state to JSON
  static Future<String> debugExport() async {
    try {
      final isar = IsarService.isar;
      final json = await isar.areaStateModels.where().exportJson();
      return jsonEncode(json);
    } catch (e) {
      logError('AreaStateService: Error exporting state to JSON: $e');
      return 'Error exporting state to JSON: $e';
    }
  }
}
