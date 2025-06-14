import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/time_state_model.dart';
import 'package:setpocket/services/converter_services/time_state_service.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/app_logger.dart';

class TimeStateAdapter implements ConverterStateService {
  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('TimeStateAdapter: Loading state for $converterType');

      final timeState = await TimeStateService.loadState();
      logInfo(
          'TimeStateAdapter: Loaded TimeStateModel with ${timeState.cards.length} cards');

      // Convert TimeStateModel to generic ConverterState
      final cards = timeState.cards.map((card) {
        final visibleUnits =
            card.visibleUnits ?? ['seconds', 'minutes', 'hours'];
        logInfo(
            'TimeStateAdapter: Converted card - Name: ${card.name}, BaseUnit: ${card.unitCode}, BaseValue: ${card.amount}, VisibleUnits: ${visibleUnits.length}');

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
          name: card.name ?? 'Card ${timeState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode,
          baseValue: card.amount,
          visibleUnits: visibleUnits,
          values: values,
        );
      }).toList();

      // Parse view mode from string with fallback
      ConverterViewMode viewMode;
      try {
        viewMode = ConverterViewMode.values.firstWhere(
          (mode) => mode.name == timeState.viewMode,
          orElse: () => ConverterViewMode.cards,
        );
      } catch (e) {
        viewMode = ConverterViewMode.cards;
      }

      return ConverterState(
        cards: cards,
        globalVisibleUnits: timeState.visibleUnits.toSet(),
        lastUpdated: timeState.lastUpdated,
        isFocusMode: timeState.isFocusMode,
        viewMode: viewMode,
      );
    } catch (e) {
      logError('TimeStateAdapter: Error loading state: $e');
      // Return default state if loading fails
      return const ConverterState(
        cards: [],
        globalVisibleUnits: {},
        isFocusMode: false,
        viewMode: ConverterViewMode.cards,
      );
    }
  }

  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    try {
      logInfo('TimeStateAdapter: Saving state for $converterType');

      // Convert generic ConverterState to TimeStateModel
      final cards = state.cards.map((card) {
        return TimeCardState(
          unitCode: card.baseUnitId,
          amount: card.baseValue,
          name: card.name,
          visibleUnits: card.visibleUnits,
          createdAt: DateTime.now(),
        );
      }).toList();

      final timeState = TimeStateModel(
        cards: cards,
        visibleUnits: state.globalVisibleUnits.toList(),
        lastUpdated: state.lastUpdated ?? DateTime.now(),
        isFocusMode: state.isFocusMode,
        viewMode: state.viewMode.name,
      );

      await TimeStateService.saveState(timeState);
      logInfo('TimeStateAdapter: Saved state successfully');
    } catch (e) {
      logError('TimeStateAdapter: Error saving state: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearState(String converterType) async {
    try {
      logInfo('TimeStateAdapter: Clearing state for $converterType');
      await TimeStateService.clearState();
      logInfo('TimeStateAdapter: Cleared state successfully');
    } catch (e) {
      logError('TimeStateAdapter: Error clearing state: $e');
      rethrow;
    }
  }
}
