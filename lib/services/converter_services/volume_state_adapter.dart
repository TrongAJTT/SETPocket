import 'package:setpocket/services/app_logger.dart';

import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/volume_state_service.dart';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/models/converter_models/volume_state_model.dart';

/// Adapter để bridge VolumeStateService với ConverterStateService
class VolumeStateAdapter implements ConverterStateService {
  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    logInfo(
        'VolumeStateAdapter: Saving state with ${state.cards.length} cards');
    logInfo(
        'VolumeStateAdapter: Global visible units: ${state.globalVisibleUnits}');
    logInfo(
        'VolumeStateAdapter: Focus mode: ${state.isFocusMode}, View mode: ${state.viewMode.name}');

    // Convert ConverterState to VolumeStateModel
    final volumeState = VolumeStateModel(
      cards: state.cards
          .map((card) => VolumeCardState(
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
        'VolumeStateAdapter: Converted to VolumeStateModel with ${volumeState.cards.length} cards');
    for (int i = 0; i < volumeState.cards.length; i++) {
      final card = volumeState.cards[i];
      logInfo(
          'VolumeStateAdapter: Card $i - Name: ${card.name}, Unit: ${card.unitCode}, Amount: ${card.amount}, VisibleUnits: ${card.visibleUnits?.length ?? 0}');
    }

    await VolumeStateService.saveState(volumeState);
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('VolumeStateAdapter: Loading state for $converterType');
      final volumeState = await VolumeStateService.loadState();

      logInfo(
          'VolumeStateAdapter: Loaded VolumeStateModel with ${volumeState.cards.length} cards');
      logInfo(
          'VolumeStateAdapter: Global visible units from loaded state: ${volumeState.visibleUnits}');
      logInfo(
          'VolumeStateAdapter: Focus mode: ${volumeState.isFocusMode}, View mode: ${volumeState.viewMode}');

      // Convert VolumeStateModel to ConverterState
      final cards = volumeState.cards.map((card) {
        // Use per-card visible units if available, otherwise fall back to global
        final cardVisibleUnits = card.visibleUnits ?? volumeState.visibleUnits;
        final values = <String, double>{};

        // Initialize all units with 0, then set base unit value
        for (String unit in cardVisibleUnits) {
          values[unit] = unit == card.unitCode ? card.amount : 0.0;
        }

        final convertedCard = ConverterCardState(
          name: card.name ?? 'Card ${volumeState.cards.indexOf(card) + 1}',
          baseUnitId: card.unitCode,
          baseValue: card.amount,
          visibleUnits: cardVisibleUnits,
          values: values,
        );

        logInfo(
            'VolumeStateAdapter: Converted card - Name: ${convertedCard.name}, BaseUnit: ${convertedCard.baseUnitId}, BaseValue: ${convertedCard.baseValue}, VisibleUnits: ${convertedCard.visibleUnits.length}');
        return convertedCard;
      }).toList();

      // Parse view mode
      final viewMode = ConverterViewMode.values.firstWhere(
        (mode) => mode.name == volumeState.viewMode,
        orElse: () => ConverterViewMode.cards,
      );

      final converterState = ConverterState(
        cards: cards,
        globalVisibleUnits: volumeState.visibleUnits.toSet(),
        lastUpdated: volumeState.lastUpdated,
        isFocusMode: volumeState.isFocusMode,
        viewMode: viewMode,
      );

      logInfo(
          'VolumeStateAdapter: Final ConverterState - Cards: ${converterState.cards.length}, GlobalUnits: ${converterState.globalVisibleUnits}, Focus: ${converterState.isFocusMode}, View: ${converterState.viewMode.name}');

      return converterState;
    } catch (e) {
      logError('VolumeStateAdapter: Error loading state, creating default: $e');

      // Return proper default state with default volume units instead of empty state
      const defaultUnits = {
        'cubic_meter',
        'liter',
        'milliliter',
        'cubic_centimeter',
        'hectoliter',
        'gallon_us',
        'gallon_uk',
        'cubic_foot'
      };

      final defaultCard = ConverterCardState(
        name: 'Card 1',
        baseUnitId: 'cubic_meter',
        baseValue: 1.0,
        visibleUnits: defaultUnits.toList(),
        values: {
          for (String unit in defaultUnits)
            unit: unit == 'cubic_meter' ? 1.0 : 0.0
        },
      );

      logInfo(
          'VolumeStateAdapter: Created default state with ${defaultUnits.length} units');

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
    await VolumeStateService.clearState();
  }
}
