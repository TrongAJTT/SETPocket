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

    // Convert generic ConverterState to LengthStateModel
    final lengthCards = state.cards.map((card) {
      return LengthCardState()
        ..unitCode = card.baseUnitId
        ..amount = card.baseValue
        ..name = card.name
        ..visibleUnits = card.visibleUnits;
    }).toList();

    final lengthState = LengthStateModel()
      ..cards = lengthCards
      ..visibleUnits = state.globalVisibleUnits.toList()
      ..lastUpdated = DateTime.now()
      ..isFocusMode = state.isFocusMode
      ..viewMode = state.viewMode.name;

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
        final visibleUnits = card.visibleUnits ?? lengthState.visibleUnits;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in visibleUnits) {
          values[unit] = unit == card.unitCode ? (card.amount ?? 0.0) : 0.0;
        }

        return ConverterCardState(
          name: card.name ?? 'Card ${lengthState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode ?? 'meter',
          baseValue: card.amount ?? 1.0,
          visibleUnits: visibleUnits,
          values: values,
        );
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
