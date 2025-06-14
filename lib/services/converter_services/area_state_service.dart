import 'package:hive_flutter/hive_flutter.dart';
import 'package:setpocket/models/converter_models/area_state_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_service.dart';

class AreaStateService {
  static const String _boxName = 'area_converter_state';
  static const String _stateKey = 'area_state';

  /// Load area converter state from Hive
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

      final box = await Hive.openBox(_boxName);
      final stateData = box.get(_stateKey);

      if (stateData == null) {
        logInfo('AreaStateService: No saved state found, returning default');
        await box.close();
        return _getDefaultState();
      }

      AreaStateModel state;
      if (stateData is AreaStateModel) {
        state = stateData;
        logInfo(
            'AreaStateService: Loaded AreaStateModel with ${state.cards.length} cards');
      } else if (stateData is Map<String, dynamic>) {
        state = AreaStateModel.fromJson(stateData);
        logInfo(
            'AreaStateService: Converted Map to AreaStateModel with ${state.cards.length} cards');
      } else {
        logWarning(
            'AreaStateService: Invalid state data type: ${stateData.runtimeType}');
        await box.close();
        return _getDefaultState();
      }

      // Validate and migrate state if needed
      state = _validateAndMigrateState(state);

      await box.close();
      logInfo(
          'AreaStateService: Successfully loaded state with ${state.cards.length} cards');
      return state;
    } catch (e) {
      logError('AreaStateService: Error loading state: $e');

      // Handle specific casting errors
      if (e.toString().contains('DateTime') &&
          e.toString().contains('String')) {
        logInfo(
            'AreaStateService: Detected DateTime casting error, clearing corrupted data');
        await clearState();
      }

      return _getDefaultState();
    }
  }

  /// Save area converter state to Hive
  static Future<void> saveState(AreaStateModel state) async {
    try {
      // Check if feature state saving is enabled
      final settings = await SettingsService.getSettings();
      if (!settings.featureStateSavingEnabled) {
        logInfo(
            'AreaStateService: Feature state saving disabled, skipping save');
        return;
      }

      logInfo(
          'AreaStateService: Saving area converter state with ${state.cards.length} cards');

      final box = await Hive.openBox(_boxName);

      // Update timestamp
      state.lastUpdated = DateTime.now();

      await box.put(_stateKey, state);
      await box.close();

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

      final box = await Hive.openBox(_boxName);
      await box.delete(_stateKey);
      await box.close();

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

      final box = await Hive.openBox(_boxName);
      await box.clear();
      await box.close();

      logInfo('AreaStateService: All cache data cleared successfully');
    } catch (e) {
      logError('AreaStateService: Error force clearing cache: $e');
      rethrow;
    }
  }

  /// Get default area converter state
  static AreaStateModel _getDefaultState() {
    return AreaStateModel(
      cards: [
        AreaCardState(
          unitCode: 'square_meters',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'square_meters',
            'square_kilometers',
            'square_centimeters',
            'hectares',
            'acres',
            'square_feet'
          ],
          createdAt: DateTime.now(),
        ),
      ],
      visibleUnits: [
        'square_meters',
        'square_kilometers',
        'square_centimeters',
        'hectares',
        'acres',
        'square_feet'
      ],
      lastUpdated: DateTime.now(),
      isFocusMode: false,
      viewMode: 'cards',
    );
  }

  /// Validate and migrate state data
  static AreaStateModel _validateAndMigrateState(AreaStateModel state) {
    try {
      // Ensure all cards have required fields
      final validCards = <AreaCardState>[];
      for (final card in state.cards) {
        if (card.unitCode.isNotEmpty && card.amount.isFinite) {
          // Ensure card has visible units
          if (card.visibleUnits == null || card.visibleUnits!.isEmpty) {
            card.visibleUnits = [
              'square_meters',
              'square_kilometers',
              'square_centimeters',
              'hectares',
              'acres',
              'square_feet'
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
        validCards.add(AreaCardState(
          unitCode: 'square_meters',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'square_meters',
            'square_kilometers',
            'square_centimeters',
            'hectares',
            'acres',
            'square_feet'
          ],
          createdAt: DateTime.now(),
        ));
      }

      // Ensure global visible units
      if (state.visibleUnits.isEmpty) {
        state.visibleUnits = [
          'square_meters',
          'square_kilometers',
          'square_centimeters',
          'hectares',
          'acres',
          'square_feet'
        ];
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
}
