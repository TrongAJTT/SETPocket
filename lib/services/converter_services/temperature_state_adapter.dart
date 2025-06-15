import 'package:setpocket/services/app_logger.dart';

import '../converter_services/converter_service_base.dart';
import '../converter_services/temperature_state_service.dart';
import '../../models/converter_models/converter_base.dart';
import '../../models/converter_models/temperature_state_model.dart';

/// Adapter để bridge TemperatureStateService với ConverterStateService
class TemperatureStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    logInfo(
        'TemperatureStateAdapter: Saving state with ${state.cards.length} cards');
    logInfo(
        'TemperatureStateAdapter: Global visible units: ${state.globalVisibleUnits}');
    logInfo(
        'TemperatureStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode.name}');

    // Convert ConverterState to TemperatureStateModel
    final temperatureState = TemperatureStateModel(
      cards: state.cards
          .map((card) => TemperatureCardState(
                unitCode: card.baseUnitId,
                amount: card.baseValue,
                name: card.name,
                visibleUnits: card.visibleUnits, // Save per-card visible units
              ))
          .toList(),
      visibleUnits: state.globalVisibleUnits.toList(),
      lastUpdated: DateTime.now(),
      isFocusMode: state.isFocusMode,
      viewMode: state.viewMode.name,
    );

    logInfo(
        'TemperatureStateAdapter: Converted to TemperatureStateModel with ${temperatureState.cards.length} cards');
    for (int i = 0; i < temperatureState.cards.length; i++) {
      final card = temperatureState.cards[i];
      logInfo(
          'TemperatureStateAdapter: Card $i - Name: ${card.name}, Unit: ${card.unitCode}, Amount: ${card.amount}, VisibleUnits: ${card.visibleUnits?.length ?? 0}');
    }

    await TemperatureStateService.saveState(temperatureState);
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('TemperatureStateAdapter: Loading state for $converterType');
      final temperatureState = await TemperatureStateService.loadState();

      logInfo(
          'TemperatureStateAdapter: Loaded TemperatureStateModel with ${temperatureState.cards.length} cards');
      logInfo(
          'TemperatureStateAdapter: Global visible units from loaded state: ${temperatureState.visibleUnits}');
      logInfo(
          'TemperatureStateAdapter: Focus mode: ${temperatureState.isFocusMode}, View mode: ${temperatureState.viewMode}');

      // Convert TemperatureStateModel to ConverterState
      final cards = temperatureState.cards.map((card) {
        // Use per-card visible units if available, otherwise fall back to global
        final cardVisibleUnits =
            card.visibleUnits ?? temperatureState.visibleUnits;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in cardVisibleUnits) {
          values[unit] = unit == card.unitCode ? card.amount : 0.0;
        }

        final convertedCard = ConverterCardState(
          name: card.name ?? 'Card ${temperatureState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode,
          baseValue: card.amount,
          visibleUnits: cardVisibleUnits,
          values: values,
        );

        logInfo(
            'TemperatureStateAdapter: Converted card - Name: ${convertedCard.name}, BaseUnit: ${convertedCard.baseUnitId}, BaseValue: ${convertedCard.baseValue}, VisibleUnits: ${convertedCard.visibleUnits.length}');
        return convertedCard;
      }).toList();

      // Parse view mode
      final viewMode = ConverterViewMode.values.firstWhere(
        (mode) => mode.name == temperatureState.viewMode,
        orElse: () => ConverterViewMode.cards,
      );

      final converterState = ConverterState(
        cards: cards,
        globalVisibleUnits: temperatureState.visibleUnits.toSet(),
        lastUpdated: temperatureState.lastUpdated,
        isFocusMode: temperatureState.isFocusMode,
        viewMode: viewMode,
      );

      logInfo(
          'TemperatureStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode.name}');

      return converterState;
    } catch (e) {
      logError(
          'TemperatureStateAdapter: Error loading state, creating default: $e');

      // Return proper default state with default temperature units instead of empty state
      const defaultUnits = {
        'celsius',
        'fahrenheit',
      };

      final defaultCard = ConverterCardState(
        name: 'Card 1',
        baseUnitId: 'celsius',
        baseValue: 25.0,
        visibleUnits: defaultUnits.toList(),
        values: {
          for (String unit in defaultUnits) unit: unit == 'celsius' ? 25.0 : 0.0
        },
      );

      logInfo(
          'TemperatureStateAdapter: Created default state with ${defaultUnits.length} units');

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
    await TemperatureStateService.clearState();
  }
}
