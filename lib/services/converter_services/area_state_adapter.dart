import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/area_state_model.dart';
import 'package:setpocket/services/converter_services/area_state_service.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/app_logger.dart';

class AreaStateAdapter implements ConverterStateService {
  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('AreaStateAdapter: Loading state for $converterType');

      final areaState = await AreaStateService.loadState();
      logInfo(
          'AreaStateAdapter: Loaded AreaStateModel with ${areaState.cards.length} cards');

      // Convert AreaStateModel to generic ConverterState
      final cards = areaState.cards.map((card) {
        final visibleUnits = card.visibleUnits ??
            [
              'square_meters',
              'square_kilometers',
              'square_centimeters',
              'hectares',
              'acres',
              'square_feet'
            ];
        logInfo(
            'AreaStateAdapter: Converted card - Name: ${card.name}, BaseUnit: ${card.unitCode}, BaseValue: ${card.amount}, VisibleUnits: ${visibleUnits.length}');

        // Create values map for all visible units
        final values = <String, double>{};
        for (final unit in visibleUnits) {
          if (unit == card.unitCode) {
            values[unit] = card.amount ?? 1.0;
          } else {
            values[unit] = 0.0; // Will be calculated by controller
          }
        }

        return ConverterCardState(
          name: card.name ?? 'Card ${areaState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode ?? 'square_meters',
          baseValue: card.amount ?? 1.0,
          visibleUnits: visibleUnits,
          values: values,
        );
      }).toList();

      final globalVisibleUnits = areaState.visibleUnits.isNotEmpty
          ? areaState.visibleUnits.toSet()
          : {
              'square_meters',
              'square_kilometers',
              'square_centimeters',
              'hectares',
              'acres',
              'square_feet'
            };

      logInfo(
          'AreaStateAdapter: Global visible units from loaded state: $globalVisibleUnits');
      logInfo(
          'AreaStateAdapter: Focus mode: ${areaState.isFocusMode}, View mode: ${areaState.viewMode}');

      final converterState = ConverterState(
        cards: cards,
        globalVisibleUnits: globalVisibleUnits,
        isFocusMode: areaState.isFocusMode,
        viewMode: areaState.viewMode == 'table'
            ? ConverterViewMode.table
            : ConverterViewMode.cards,
      );

      logInfo(
          'AreaStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits.length}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode}');

      return converterState;
    } catch (e) {
      logError('AreaStateAdapter: Error loading state: $e');

      // Return default state on error
      return const ConverterState(
        cards: [
          ConverterCardState(
            name: 'Card 1',
            baseUnitId: 'square_meters',
            baseValue: 1.0,
            visibleUnits: [
              'square_meters',
              'square_kilometers',
              'square_centimeters',
              'hectares',
              'acres',
              'square_feet'
            ],
            values: {
              'square_meters': 1.0,
              'square_kilometers': 0.0,
              'square_centimeters': 0.0,
              'hectares': 0.0,
              'acres': 0.0,
              'square_feet': 0.0,
            },
          ),
        ],
        globalVisibleUnits: {
          'square_meters',
          'square_kilometers',
          'square_centimeters',
          'hectares',
          'acres',
          'square_feet'
        },
        isFocusMode: false,
        viewMode: ConverterViewMode.cards,
      );
    }
  }

  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    try {
      logInfo(
          'AreaStateAdapter: Saving state with ${state.cards.length} cards');
      logInfo(
          'AreaStateAdapter: Global visible units: ${state.globalVisibleUnits}');
      logInfo(
          'AreaStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode}');

      // Convert generic ConverterState to AreaStateModel
      final areaCards = state.cards.map((card) {
        logInfo(
            'AreaStateAdapter: Card ${state.cards.indexOf(card)} - Name: ${card.name}, Unit: ${card.baseUnitId}, Amount: ${card.baseValue}, VisibleUnits: ${card.visibleUnits.length}');

        return AreaCardState()
          ..unitCode = card.baseUnitId
          ..amount = card.baseValue
          ..name = card.name
          ..visibleUnits = card.visibleUnits
          ..createdAt = DateTime.now();
      }).toList();

      final areaState = AreaStateModel()
        ..cards = areaCards
        ..visibleUnits = state.globalVisibleUnits.toList()
        ..lastUpdated = DateTime.now()
        ..isFocusMode = state.isFocusMode
        ..viewMode = state.viewMode.name;

      logInfo(
          'AreaStateAdapter: Converted to AreaStateModel with ${areaState.cards.length} cards');

      await AreaStateService.saveState(areaState);
      logInfo('AreaStateAdapter: Successfully saved state');
    } catch (e) {
      logError('AreaStateAdapter: Error saving state: $e');
    }
  }

  @override
  Future<void> clearState(String converterType) async {
    try {
      logInfo('AreaStateAdapter: Clearing state for $converterType');
      await AreaStateService.clearState();
      logInfo('AreaStateAdapter: Successfully cleared state');
    } catch (e) {
      logError('AreaStateAdapter: Error clearing state: $e');
    }
  }
}
