import 'package:setpocket/services/app_logger.dart';

import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/data_state_service.dart';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/data_state_model.dart';

/// Adapter để bridge DataStateService với ConverterStateService
class DataStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    logInfo('DataStateAdapter: Saving state with ${state.cards.length} cards');
    logInfo(
        'DataStateAdapter: Global visible units: ${state.globalVisibleUnits}');
    logInfo(
        'DataStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode.name}');

    // Convert generic ConverterState to DataStateModel
    final dataCards = state.cards.map((card) {
      return DataCardState()
        ..unitCode = card.baseUnitId
        ..amount = card.baseValue
        ..name = card.name
        ..visibleUnits = card.visibleUnits;
    }).toList();

    final dataState = DataStateModel()
      ..cards = dataCards
      ..visibleUnits = state.globalVisibleUnits.toList()
      ..lastUpdated = DateTime.now()
      ..isFocusMode = state.isFocusMode
      ..viewMode = state.viewMode.name;

    await DataStateService.saveState(dataState);
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('DataStateAdapter: Loading state for $converterType');
      final dataState = await DataStateService.loadState();

      logInfo(
          'DataStateAdapter: Loaded DataStateModel with ${dataState.cards.length} cards');
      logInfo(
          'DataStateAdapter: Global visible units from loaded state: ${dataState.visibleUnits}');
      logInfo(
          'DataStateAdapter: Focus mode: ${dataState.isFocusMode}, View mode: ${dataState.viewMode}');

      // Convert DataStateModel to ConverterState
      final cards = dataState.cards.map((card) {
        final visibleUnits = card.visibleUnits ?? dataState.visibleUnits;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in visibleUnits) {
          values[unit] = unit == card.unitCode ? (card.amount ?? 0.0) : 0.0;
        }

        final convertedCard = ConverterCardState(
          name: card.name ?? 'Card ${dataState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode ?? 'kilobyte',
          baseValue: card.amount ?? 1024.0,
          visibleUnits: visibleUnits,
          values: values,
        );

        logInfo(
            'DataStateAdapter: Converted card - Name: ${convertedCard.name}, BaseUnit: ${convertedCard.baseUnitId}, BaseValue: ${convertedCard.baseValue}, VisibleUnits: ${convertedCard.visibleUnits.length}');
        return convertedCard;
      }).toList();

      // Parse view mode
      final viewMode = ConverterViewMode.values.firstWhere(
        (mode) => mode.name == dataState.viewMode,
        orElse: () => ConverterViewMode.cards,
      );

      final converterState = ConverterState(
        cards: cards,
        globalVisibleUnits: dataState.visibleUnits.toSet(),
        lastUpdated: dataState.lastUpdated,
        isFocusMode: dataState.isFocusMode,
        viewMode: viewMode,
      );

      logInfo(
          'DataStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode.name}');

      return converterState;
    } catch (e) {
      logError('DataStateAdapter: Error loading state, creating default: $e');

      // Return proper default state with default data storage units instead of empty state
      const defaultUnits = {
        'byte',
        'kilobyte',
        'megabyte',
        'gigabyte',
        'terabyte',
        'petabyte',
        'bit',
        'kilobit'
      };

      final defaultCard = ConverterCardState(
        name: 'Card 1',
        baseUnitId: 'kilobyte',
        baseValue: 1024.0,
        visibleUnits: defaultUnits.toList(),
        values: {
          for (String unit in defaultUnits)
            unit: unit == 'kilobyte' ? 1024.0 : 0.0
        },
      );

      logInfo(
          'DataStateAdapter: Created default state with ${defaultUnits.length} units');

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
    await DataStateService.clearState();
  }
}
