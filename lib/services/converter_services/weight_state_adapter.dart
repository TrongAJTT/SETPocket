import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/weight_state_model.dart';
import 'package:setpocket/services/converter_services/weight_state_service.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/app_logger.dart';

class WeightStateAdapter implements ConverterStateService {
  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('WeightStateAdapter: Loading state for $converterType');

      final weightState = await WeightStateService.loadState();
      logInfo(
          'WeightStateAdapter: Loaded WeightStateModel with ${weightState.cards.length} cards');

      // Convert WeightStateModel to generic ConverterState
      final cards = weightState.cards.map((card) {
        final visibleUnits = card.visibleUnits ??
            [
              'newtons',
              'kilogram_force',
              'pound_force',
              'dyne',
              'kilopond',
              'gram_force'
            ];
        logInfo(
            'WeightStateAdapter: Converted card - Name: ${card.name}, BaseUnit: ${card.unitCode}, BaseValue: ${card.amount}, VisibleUnits: ${visibleUnits.length}');

        // Create values map for all visible units
        final values = <String, double>{};
        for (final unit in visibleUnits) {
          if (unit == card.unitCode) {
            values[unit] = card.amount;
          } else {
            values[unit] = 0.0; // Will be calculated by controller
          }
        }

        return ConverterCardState(
          name: card.name ?? 'Card ${weightState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode,
          baseValue: card.amount,
          visibleUnits: visibleUnits,
          values: values,
        );
      }).toList();

      final globalVisibleUnits = weightState.visibleUnits.isNotEmpty
          ? weightState.visibleUnits.toSet()
          : {
              'newtons',
              'kilogram_force',
              'pound_force',
              'dyne',
              'kilopond',
              'gram_force'
            };

      logInfo(
          'WeightStateAdapter: Global visible units from loaded state: $globalVisibleUnits');
      logInfo(
          'WeightStateAdapter: Focus mode: ${weightState.isFocusMode}, View mode: ${weightState.viewMode}');

      final converterState = ConverterState(
        cards: cards,
        globalVisibleUnits: globalVisibleUnits,
        isFocusMode: weightState.isFocusMode,
        viewMode: weightState.viewMode == 'table'
            ? ConverterViewMode.table
            : ConverterViewMode.cards,
      );

      logInfo(
          'WeightStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits.length}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode}');

      return converterState;
    } catch (e) {
      logError('WeightStateAdapter: Error loading state: $e');

      // Return default state on error
      return const ConverterState(
        cards: [
          ConverterCardState(
            name: 'Card 1',
            baseUnitId: 'newtons',
            baseValue: 1.0,
            visibleUnits: [
              'newtons',
              'kilogram_force',
              'pound_force',
              'dyne',
              'kilopond',
              'gram_force'
            ],
            values: {
              'newtons': 1.0,
              'kilogram_force': 0.0,
              'pound_force': 0.0,
              'dyne': 0.0,
              'kilopond': 0.0,
              'gram_force': 0.0,
            },
          ),
        ],
        globalVisibleUnits: {
          'newtons',
          'kilogram_force',
          'pound_force',
          'dyne',
          'kilopond',
          'gram_force'
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
          'WeightStateAdapter: Saving state with ${state.cards.length} cards');
      logInfo(
          'WeightStateAdapter: Global visible units: ${state.globalVisibleUnits}');
      logInfo(
          'WeightStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode}');

      // Convert generic ConverterState to WeightStateModel
      final weightCards = state.cards.map((card) {
        logInfo(
            'WeightStateAdapter: Card ${state.cards.indexOf(card)} - Name: ${card.name}, Unit: ${card.baseUnitId}, Amount: ${card.baseValue}, VisibleUnits: ${card.visibleUnits.length}');

        return WeightCardState(
          unitCode: card.baseUnitId,
          amount: card.baseValue,
          name: card.name,
          visibleUnits: card.visibleUnits,
          createdAt: DateTime.now(),
        );
      }).toList();

      final weightState = WeightStateModel(
        cards: weightCards,
        visibleUnits: state.globalVisibleUnits.toList(),
        lastUpdated: DateTime.now(),
        isFocusMode: state.isFocusMode,
        viewMode: state.viewMode.name,
      );

      logInfo(
          'WeightStateAdapter: Converted to WeightStateModel with ${weightState.cards.length} cards');

      await WeightStateService.saveState(weightState);
      logInfo('WeightStateAdapter: Successfully saved state');
    } catch (e) {
      logError('WeightStateAdapter: Error saving state: $e');
    }
  }

  @override
  Future<void> clearState(String converterType) async {
    try {
      logInfo('WeightStateAdapter: Clearing state for $converterType');
      await WeightStateService.clearState();
      logInfo('WeightStateAdapter: Successfully cleared state');
    } catch (e) {
      logError('WeightStateAdapter: Error clearing state: $e');
    }
  }
}
