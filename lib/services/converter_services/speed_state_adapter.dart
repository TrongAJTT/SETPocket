import 'package:setpocket/services/app_logger.dart';

import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/speed_state_service.dart';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/speed_state_model.dart';

/// Adapter to bridge SpeedStateService with ConverterStateService
class SpeedStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    logInfo('SpeedStateAdapter: Saving state with ${state.cards.length} cards');
    logInfo(
        'SpeedStateAdapter: Global visible units: ${state.globalVisibleUnits}');
    logInfo(
        'SpeedStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode.name}');

    // Convert generic ConverterState to SpeedStateModel
    final speedCards = state.cards.map((card) {
      return SpeedCardState()
        ..unitCode = card.baseUnitId
        ..amount = card.baseValue
        ..name = card.name
        ..visibleUnits = card.visibleUnits;
    }).toList();

    final speedState = SpeedStateModel()
      ..cards = speedCards
      ..visibleUnits = state.globalVisibleUnits.toList()
      ..lastUpdated = DateTime.now()
      ..isFocusMode = state.isFocusMode
      ..viewMode = state.viewMode.name;

    logInfo(
        'SpeedStateAdapter: Converted to SpeedStateModel with ${speedState.cards.length} cards');
    for (int i = 0; i < speedState.cards.length; i++) {
      final card = speedState.cards[i];
      logInfo(
          'SpeedStateAdapter: Card $i - Name: ${card.name}, Unit: ${card.unitCode}, Amount: ${card.amount}, VisibleUnits: ${card.visibleUnits?.length ?? 0}');
    }

    await SpeedStateService.saveState(speedState);
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('SpeedStateAdapter: Loading state for $converterType');
      final speedState = await SpeedStateService.loadState();

      logInfo(
          'SpeedStateAdapter: Loaded SpeedStateModel with ${speedState.cards.length} cards');
      logInfo(
          'SpeedStateAdapter: Global visible units from loaded state: ${speedState.visibleUnits}');
      logInfo(
          'SpeedStateAdapter: Focus mode: ${speedState.isFocusMode}, View mode: ${speedState.viewMode}');

      // Convert SpeedStateModel to ConverterState
      final cards = speedState.cards.map((card) {
        // Use per-card visible units if available, otherwise fall back to global
        final cardVisibleUnits = card.visibleUnits ?? speedState.visibleUnits;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in cardVisibleUnits) {
          values[unit] = unit == card.unitCode ? (card.amount ?? 0.0) : 0.0;
        }

        final convertedCard = ConverterCardState(
          name: card.name ?? 'Card ${speedState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode ?? 'meters_per_second',
          baseValue: card.amount ?? 1.0,
          visibleUnits: cardVisibleUnits,
          values: values,
        );

        logInfo(
            'SpeedStateAdapter: Converted card - Name: ${convertedCard.name}, BaseUnit: ${convertedCard.baseUnitId}, BaseValue: ${convertedCard.baseValue}, VisibleUnits: ${convertedCard.visibleUnits.length}');
        return convertedCard;
      }).toList();

      // Parse view mode
      final viewMode = ConverterViewMode.values.firstWhere(
        (mode) => mode.name == speedState.viewMode,
        orElse: () => ConverterViewMode.cards,
      );

      final converterState = ConverterState(
        cards: cards,
        globalVisibleUnits: speedState.visibleUnits.toSet(),
        lastUpdated: speedState.lastUpdated,
        isFocusMode: speedState.isFocusMode,
        viewMode: viewMode,
      );

      logInfo(
          'SpeedStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode.name}');

      return converterState;
    } catch (e) {
      logError('SpeedStateAdapter: Error loading state, creating default: $e');

      // Return proper default state with default speed units instead of empty state
      const defaultUnits = {
        'kilometers_per_hour',
        'meters_per_second',
        'miles_per_hour',
        'knots',
        'feet_per_second',
        'mach'
      };

      final defaultCard = ConverterCardState(
        name: 'Card 1',
        baseUnitId: 'kilometers_per_hour',
        baseValue: 1.0,
        visibleUnits: defaultUnits.toList(),
        values: {
          for (String unit in defaultUnits)
            unit: unit == 'kilometers_per_hour' ? 1.0 : 0.0
        },
      );

      logInfo(
          'SpeedStateAdapter: Created default state with ${defaultUnits.length} units');

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
    await SpeedStateService.clearState();
  }
}
