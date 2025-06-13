import '../converter_services/converter_service_base.dart';
import '../converter_services/length_state_service.dart';
import '../../models/converter_models/converter_base.dart';
import '../../models/converter_models/length_state_model.dart';

/// Adapter để bridge LengthStateService với ConverterStateService
class LengthStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    // Convert ConverterState to LengthStateModel
    final lengthState = LengthStateModel(
      cards: state.cards
          .map((card) => LengthCardState(
                unitCode: card.baseUnitId,
                amount: card.baseValue,
              ))
          .toList(),
      visibleUnits: state.globalVisibleUnits.toList(),
      lastUpdated: DateTime.now(),
    );

    await LengthStateService.saveState(lengthState);
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      final lengthState = await LengthStateService.loadState();

      // Convert LengthStateModel to ConverterState
      final cards = lengthState.cards.map((card) {
        final visibleUnits = lengthState.visibleUnits;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in visibleUnits) {
          values[unit] = unit == card.unitCode ? card.amount : 0.0;
        }

        return ConverterCardState(
          name: 'Card ${lengthState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode,
          baseValue: card.amount,
          visibleUnits: visibleUnits,
          values: values,
        );
      }).toList();

      return ConverterState(
        cards: cards,
        globalVisibleUnits: lengthState.visibleUnits.toSet(),
        lastUpdated: lengthState.lastUpdated,
      );
    } catch (e) {
      // Return default state if loading fails
      return const ConverterState(
        cards: [],
        globalVisibleUnits: {},
      );
    }
  }

  @override
  Future<void> clearState(String converterType) async {
    await LengthStateService.clearState();
  }
}
