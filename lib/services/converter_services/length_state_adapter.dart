import 'package:setpocket/services/app_logger.dart';

import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/length_state_service.dart';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/length_state_model.dart';

/// Adapter để bridge LengthStateService với ConverterStateService
class LengthStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    logInfo(
        'LengthStateAdapter: Saving state with ${state.cards.length} cards');
    logInfo(
        'LengthStateAdapter: Global visible units: ${state.globalVisibleUnits}');
    logInfo(
        'LengthStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode.name}');

    // Convert ConverterState to LengthStateModel
    final lengthState = LengthStateModel(
      cards: state.cards
          .map((card) => LengthCardState(
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
        'LengthStateAdapter: Converted to LengthStateModel with ${lengthState.cards.length} cards');
    for (int i = 0; i < lengthState.cards.length; i++) {
      final card = lengthState.cards[i];
      logInfo(
          'LengthStateAdapter: Card $i - Name: ${card.name}, Unit: ${card.unitCode}, Amount: ${card.amount}, VisibleUnits: ${card.visibleUnits?.length ?? 0}');
    }

    await LengthStateService.saveState(lengthState);
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('LengthStateAdapter: Loading state for $converterType');
      final lengthState = await LengthStateService.loadState();

      logInfo(
          'LengthStateAdapter: Loaded LengthStateModel with ${lengthState.cards.length} cards');
      logInfo(
          'LengthStateAdapter: Global visible units from loaded state: ${lengthState.visibleUnits}');
      logInfo(
          'LengthStateAdapter: Focus mode: ${lengthState.isFocusMode}, View mode: ${lengthState.viewMode}');

      // Convert LengthStateModel to ConverterState
      final cards = lengthState.cards.map((card) {
        // Use per-card visible units if available, otherwise fall back to global
        final cardVisibleUnits = card.visibleUnits ?? lengthState.visibleUnits;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in cardVisibleUnits) {
          values[unit] = unit == card.unitCode ? card.amount : 0.0;
        }

        final convertedCard = ConverterCardState(
          name: card.name ?? 'Card ${lengthState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode,
          baseValue: card.amount,
          visibleUnits: cardVisibleUnits,
          values: values,
        );

        logInfo(
            'LengthStateAdapter: Converted card - Name: ${convertedCard.name}, BaseUnit: ${convertedCard.baseUnitId}, BaseValue: ${convertedCard.baseValue}, VisibleUnits: ${convertedCard.visibleUnits.length}');
        return convertedCard;
      }).toList();

      // Parse view mode
      final viewMode = ConverterViewMode.values.firstWhere(
        (mode) => mode.name == lengthState.viewMode,
        orElse: () => ConverterViewMode.cards,
      );

      final converterState = ConverterState(
        cards: cards,
        globalVisibleUnits: lengthState.visibleUnits.toSet(),
        lastUpdated: lengthState.lastUpdated,
        isFocusMode: lengthState.isFocusMode,
        viewMode: viewMode,
      );

      logInfo(
          'LengthStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode.name}');

      return converterState;
    } catch (e) {
      logError('LengthStateAdapter: Error loading state, creating default: $e');

      // Return proper default state with default length units instead of empty state
      const defaultUnits = {
        'kilometer',
        'meter',
        'centimeter',
        'millimeter',
        'inch',
        'foot',
        'yard',
        'mile'
      };

      final defaultCard = ConverterCardState(
        name: 'Card 1',
        baseUnitId: 'meter',
        baseValue: 1.0,
        visibleUnits: defaultUnits.toList(),
        values: {
          for (String unit in defaultUnits) unit: unit == 'meter' ? 1.0 : 0.0
        },
      );

      logInfo(
          'LengthStateAdapter: Created default state with ${defaultUnits.length} units');

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
    await LengthStateService.clearState();
  }
}
