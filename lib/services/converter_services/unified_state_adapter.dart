import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/converter_tools_data_service.dart';
import 'package:setpocket/services/app_logger.dart';

/// Temporary adapter to bridge old ConverterStateService interface to new unified services
class UnifiedStateAdapter implements ConverterStateService {
  final String toolCode;

  UnifiedStateAdapter(this.toolCode);

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      logInfo('UnifiedStateAdapter: Loading state for $converterType');

      // Try to load saved state first
      final savedStates = await ConverterToolsDataService.getStates(toolCode);

      if (savedStates != null && savedStates['states'] != null) {
        final stateList = savedStates['states'] as List;
        if (stateList.isNotEmpty) {
          // Convert saved state to ConverterState
          final cards = (savedStates['states'] as List)
              .map((cardData) => ConverterCardState(
                    name: cardData['name'] ?? 'Card 1',
                    baseUnitId: cardData['baseUnitId'] ?? '',
                    baseValue:
                        (cardData['baseValue'] as num?)?.toDouble() ?? 1.0,
                    visibleUnits:
                        List<String>.from(cardData['visibleUnits'] ?? []),
                    values: Map<String, double>.from(
                        (cardData['values'] as Map<String, dynamic>?)?.map(
                                (k, v) => MapEntry(k, (v as num).toDouble())) ??
                            {}),
                  ))
              .toList();

          final globalVisibleUnits =
              Set<String>.from(savedStates['globalVisibleUnits'] ?? []);

          logInfo(
              'UnifiedStateAdapter: Loaded saved state with ${cards.length} cards');

          return ConverterState(
            cards: cards,
            globalVisibleUnits: globalVisibleUnits,
            isFocusMode: savedStates['isFocusMode'] ?? false,
            viewMode: _parseViewMode(savedStates['viewMode']),
          );
        }
      }

      // If no saved state, create default state
      logInfo(
          'UnifiedStateAdapter: No saved state found, creating default for $converterType');
      return _createDefaultState(converterType);
    } catch (e) {
      logError(
          'UnifiedStateAdapter: Error loading state for $converterType: $e');
      return _createDefaultState(converterType);
    }
  }

  ConverterViewMode _parseViewMode(dynamic mode) {
    if (mode is String) {
      switch (mode) {
        case 'table':
          return ConverterViewMode.table;
        case 'cards':
        default:
          return ConverterViewMode.cards;
      }
    }
    return ConverterViewMode.cards;
  }

  ConverterState _createDefaultState(String converterType) {
    try {
      logInfo('UnifiedStateAdapter: Creating default state for $converterType');

      // Return a minimal fallback state - the actual default state will be created by ConverterController
      // using the service's defaultVisibleUnits
      return const ConverterState(
        cards: [],
        globalVisibleUnits: {},
        isFocusMode: false,
        viewMode: ConverterViewMode.cards,
      );
    } catch (e) {
      logError(
          'UnifiedStateAdapter: Error creating default state for $converterType: $e');
      return const ConverterState(
        cards: [],
        globalVisibleUnits: {},
      );
    }
  }

  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    try {
      logInfo(
          'UnifiedStateAdapter: Saving state for $converterType with ${state.cards.length} cards');

      // Convert ConverterState to JSON format for storage
      final stateData = {
        'states': state.cards
            .map((card) => {
                  'name': card.name,
                  'baseUnitId': card.baseUnitId,
                  'baseValue': card.baseValue,
                  'visibleUnits': card.visibleUnits,
                  'values': card.values,
                })
            .toList(),
        'globalVisibleUnits': state.globalVisibleUnits.toList(),
        'isFocusMode': state.isFocusMode,
        'viewMode': state.viewMode.toString().split('.').last,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await ConverterToolsDataService.saveStates(toolCode, stateData);
      logInfo(
          'UnifiedStateAdapter: Successfully saved state for $converterType');
    } catch (e) {
      logError(
          'UnifiedStateAdapter: Error saving state for $converterType: $e');
    }
  }

  @override
  Future<void> clearState(String converterType) async {
    try {
      logInfo('UnifiedStateAdapter: Clearing state for $converterType');
      await ConverterToolsDataService.clearStates(toolCode);
      logInfo(
          'UnifiedStateAdapter: Successfully cleared state for $converterType');
    } catch (e) {
      logError(
          'UnifiedStateAdapter: Error clearing state for $converterType: $e');
    }
  }
}
