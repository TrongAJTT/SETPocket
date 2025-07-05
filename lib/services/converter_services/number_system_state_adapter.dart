import 'package:setpocket/services/app_logger.dart';

import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/number_system_state_service.dart';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/number_system_state_model.dart';

/// Adapter để bridge NumberSystemStateService với ConverterStateService
class NumberSystemStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    logInfo(
        'NumberSystemStateAdapter: Saving state with ${state.cards.length} cards');
    logInfo(
        'NumberSystemStateAdapter: Global visible units: ${state.globalVisibleUnits}');
    logInfo(
        'NumberSystemStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode.name}');

    // Convert ConverterState to NumberSystemStateModel
    final numberSystemState = NumberSystemStateModel(
      cards: state.cards.map((card) {
        final cardState = NumberSystemCardState(
          unitCode: card.baseUnitId,
          amount: card.baseValue,
          name: card.name,
          visibleUnits: card.visibleUnits,
        );
        logInfo(
            'NumberSystemStateAdapter: Card - Name: ${card.name}, Unit: ${card.baseUnitId}, Amount: ${card.baseValue}, VisibleUnits: ${card.visibleUnits.length}');
        return cardState;
      }).toList(),
      globalVisibleUnits: state.globalVisibleUnits.toList(),
      isFocusMode: state.isFocusMode,
      viewMode: state.viewMode.name,
      lastUpdated: DateTime.now(),
    );

    logInfo(
        'NumberSystemStateAdapter: Converted to NumberSystemStateModel with ${numberSystemState.cards.length} cards');
    for (int i = 0; i < numberSystemState.cards.length; i++) {
      final card = numberSystemState.cards[i];
      logInfo(
          'NumberSystemStateAdapter: Card $i - Name: ${card.name}, Unit: ${card.unitCode}, Amount: ${card.amount}, VisibleUnits: ${card.visibleUnits?.length}');
    }

    await NumberSystemStateService.saveState(numberSystemState);
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    logInfo('NumberSystemStateAdapter: Loading state for $converterType');

    final numberSystemState = await NumberSystemStateService.loadState();
    logInfo(
        'NumberSystemStateAdapter: Loaded NumberSystemStateModel with ${numberSystemState.cards.length} cards');

    // Convert NumberSystemStateModel to ConverterState
    final globalVisibleUnits =
        Set<String>.from(numberSystemState.globalVisibleUnits);
    logInfo(
        'NumberSystemStateAdapter: Global visible units from loaded state: ${numberSystemState.globalVisibleUnits}');

    final viewMode = numberSystemState.viewMode == 'table'
        ? ConverterViewMode.table
        : ConverterViewMode.cards;
    logInfo(
        'NumberSystemStateAdapter: Focus mode: ${numberSystemState.isFocusMode}, View mode: ${numberSystemState.viewMode}');

    final cards = numberSystemState.cards.map((cardState) {
      final visibleUnits =
          cardState.visibleUnits ?? globalVisibleUnits.toList();
      final values = <String, double>{
        for (String unit in visibleUnits) unit: cardState.amount
      };

      final card = ConverterCardState(
        name: cardState.name ?? 'Card 1',
        baseUnitId: cardState.unitCode,
        baseValue: cardState.amount,
        visibleUnits: visibleUnits,
        values: values,
      );

      logInfo(
          'NumberSystemStateAdapter: Converted card - Name: ${card.name}, BaseUnit: ${card.baseUnitId}, BaseValue: ${card.baseValue}, VisibleUnits: ${card.visibleUnits.length}');
      return card;
    }).toList();

    final converterState = ConverterState(
      cards: cards,
      globalVisibleUnits: globalVisibleUnits,
      isFocusMode: numberSystemState.isFocusMode,
      viewMode: viewMode,
    );

    logInfo(
        'NumberSystemStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode.name}');

    return converterState;
  }

  @override
  Future<void> clearState(String converterType) async {
    logInfo('NumberSystemStateAdapter: Clearing state for $converterType');
    await NumberSystemStateService.clearState();
  }
}
