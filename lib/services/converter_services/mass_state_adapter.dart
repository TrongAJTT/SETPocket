import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/mass_state_service_isar.dart';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/mass_state_model.dart';
import 'package:setpocket/services/app_logger.dart';

/// Adapter để bridge MassStateService với ConverterStateService
class MassStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    try {
      logInfo(
          'MassStateAdapter: Saving state with ${state.cards.length} cards');
      logInfo(
          'MassStateAdapter: Global visible units: ${state.globalVisibleUnits}');
      logInfo(
          'MassStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode.name}');

      // Convert generic ConverterState to MassStateModel
      final massCards = state.cards.map((card) {
        return MassCardState()
          ..unitCode = card.baseUnitId
          ..amount = card.baseValue
          ..name = card.name
          ..visibleUnits = card.visibleUnits
          ..createdAt = DateTime.now();
      }).toList();

      final massState = MassStateModel()
        ..cards = massCards
        ..visibleUnits = state.globalVisibleUnits.toList()
        ..lastUpdated = DateTime.now()
        ..isFocusMode = state.isFocusMode
        ..viewMode = state.viewMode.name;

      logInfo(
          'MassStateAdapter: Converted to MassStateModel with ${massState.cards.length} cards');
      for (int i = 0; i < massState.cards.length; i++) {
        final card = massState.cards[i];
        logInfo(
            'MassStateAdapter: Card $i - Name: ${card.name}, Unit: ${card.unitCode}, Amount: ${card.amount}, VisibleUnits: ${card.visibleUnits?.length ?? 0}');
      }

      final massStateService = MassStateServiceIsar();
      await massStateService.saveState(massState);
      logInfo('MassStateAdapter: Successfully saved state');
    } catch (e) {
      logError('MassStateAdapter: Error saving state: $e');
      rethrow;
    }
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('MassStateAdapter: Loading state for $converterType');
      final massStateService = MassStateServiceIsar();
      final massState = await massStateService.loadState();

      if (massState == null) {
        logInfo('MassStateAdapter: No saved state found, returning default state');
        return ConverterState(
          cards: [],
          globalVisibleUnits: <String>{},
          isFocusMode: false,
          viewMode: ConverterViewMode.cards,
        );
      }

      logInfo(
          'MassStateAdapter: Loaded MassStateModel with ${massState.cards.length} cards');
      logInfo(
          'MassStateAdapter: Global visible units from loaded state: ${massState.visibleUnits}');
      logInfo(
          'MassStateAdapter: Focus mode: ${massState.isFocusMode}, View mode: ${massState.viewMode}');

      // Convert MassStateModel to ConverterState
      final cards = massState.cards.map((card) {
        // Use per-card visible units if available, otherwise fall back to global
        final cardVisibleUnits = card.visibleUnits ?? massState.visibleUnits;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in cardVisibleUnits) {
          values[unit] = unit == card.unitCode ? (card.amount ?? 0.0) : 0.0;
        }

        final convertedCard = ConverterCardState(
          name: card.name ?? 'Card ${massState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode ?? 'kilograms',
          baseValue: card.amount ?? 1.0,
          visibleUnits: cardVisibleUnits,
          values: values,
        );

        logInfo(
            'MassStateAdapter: Converted card - Name: ${convertedCard.name}, BaseUnit: ${convertedCard.baseUnitId}, BaseValue: ${convertedCard.baseValue}, VisibleUnits: ${convertedCard.visibleUnits.length}');
        return convertedCard;
      }).toList();

      // Parse view mode
      final viewMode = ConverterViewMode.values.firstWhere(
        (mode) => mode.name == massState.viewMode,
        orElse: () => ConverterViewMode.cards,
      );

      final converterState = ConverterState(
        cards: cards,
        globalVisibleUnits: massState.visibleUnits.toSet(),
        lastUpdated: massState.lastUpdated,
        isFocusMode: massState.isFocusMode,
        viewMode: viewMode,
      );

      logInfo(
          'MassStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits.length}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode.name}');

      return converterState;
    } catch (e) {
      logError('MassStateAdapter: Error loading state, creating default: $e');

      // Return proper default state with default mass units instead of empty state
      const defaultUnits = {
        'kilograms',
        'pounds',
        'ounces',
        'grams',
        'tonnes',
        'stones'
      };

      final defaultCard = ConverterCardState(
        name: 'Card 1',
        baseUnitId: 'kilograms',
        baseValue: 1.0,
        visibleUnits: defaultUnits.toList(),
        values: {
          for (String unit in defaultUnits)
            unit: unit == 'kilograms' ? 1.0 : 0.0
        },
      );

      logInfo(
          'MassStateAdapter: Created default state with ${defaultUnits.length} units');

      return ConverterState(
        cards: [defaultCard],
        globalVisibleUnits: defaultUnits,
        isFocusMode: false,
        viewMode: ConverterViewMode.cards,
      );
    }
  }

  @override
  Future<void> clearState(String converterType) async {
    try {
      logInfo('MassStateAdapter: Clearing state for $converterType');
      final massStateService = MassStateServiceIsar();
      await massStateService.clearState();
      logInfo('MassStateAdapter: State cleared successfully');
    } catch (e) {
      logError('MassStateAdapter: Error clearing state: $e');
      rethrow;
    }
  }
}
