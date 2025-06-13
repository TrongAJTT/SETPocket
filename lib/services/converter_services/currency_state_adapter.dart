import '../converter_services/converter_service_base.dart';
import '../converter_services/currency_state_service.dart';
import '../../models/converter_models/converter_base.dart';
import '../../models/converter_models/currency_state_model.dart';

/// Adapter để bridge CurrencyStateService với ConverterStateService
class CurrencyStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    // Convert ConverterState to CurrencyStateModel
    final currencyState = CurrencyStateModel(
      cards: state.cards
          .map((card) => CurrencyCardState(
                currencyCode: card.baseUnitId,
                amount: card.baseValue,
                name: card.name,
                currencies: card.visibleUnits.toList(),
              ))
          .toList(),
      visibleCurrencies: state.globalVisibleUnits.toList(),
      lastUpdated: DateTime.now(),
      isFocusMode: state.isFocusMode,
      viewMode: state.viewMode.name, // Convert enum to string
    );

    await CurrencyStateService.saveState(currencyState);
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      final currencyState = await CurrencyStateService.loadState();

      // Convert CurrencyStateModel to ConverterState
      final cards = currencyState.cards.map((card) {
        final visibleUnits = card.currencies ?? currencyState.visibleCurrencies;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in visibleUnits) {
          values[unit] = unit == card.currencyCode ? card.amount : 0.0;
        }

        return ConverterCardState(
          name:
              card.name ?? 'Converter ${currencyState.cards.indexOf(card) + 1}',
          baseUnitId: card.currencyCode,
          baseValue: card.amount,
          visibleUnits: visibleUnits,
          values: values,
        );
      }).toList();

      // Parse view mode from string with fallback
      ConverterViewMode viewMode;
      try {
        viewMode = ConverterViewMode.values.firstWhere(
          (mode) => mode.name == currencyState.viewMode,
          orElse: () => ConverterViewMode.cards,
        );
      } catch (e) {
        viewMode = ConverterViewMode.cards;
      }

      return ConverterState(
        cards: cards,
        globalVisibleUnits: currencyState.visibleCurrencies.toSet(),
        lastUpdated: currencyState.lastUpdated,
        isFocusMode: currencyState.isFocusMode,
        viewMode: viewMode,
      );
    } catch (e) {
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
  Future<void> clearState(String converterType) async {
    await CurrencyStateService.clearState();
  }
}
