import 'package:flutter/material.dart';
import 'dart:async';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/settings_models_service.dart';

class ConverterController extends ChangeNotifier {
  final ConverterServiceBase _converterService;
  final ConverterStateService _stateService;

  ConverterState _state = const ConverterState(
    cards: [],
    globalVisibleUnits: {},
  );

  final Map<int, Map<String, TextEditingController>> _cardControllers = {};

  // Debounce timer to reduce rapid updates
  Timer? _notifyTimer;

  // Prevent recursive updates
  bool _isUpdatingControllers = false;

  ConverterController({
    required ConverterServiceBase converterService,
    required ConverterStateService stateService,
  })  : _converterService = converterService,
        _stateService = stateService;

  // Getters
  ConverterState get state => _state;
  ConverterViewMode get viewMode => _state.viewMode;
  ConverterServiceBase get converterService => _converterService;
  List<ConverterUnit> get units => _converterService.units;
  Map<int, Map<String, TextEditingController>> get cardControllers =>
      _cardControllers;

  bool get isLoading => _state.isLoading;
  bool get isFocusMode => _state.isFocusMode;
  DateTime? get lastUpdated => _converterService.lastUpdated;
  bool get isUsingLiveData => _converterService.isUsingLiveData;
  bool get requiresRealTimeData => _converterService.requiresRealTimeData;

  // Debounced notify listeners
  @protected
  void notifyListenersDebounced() {
    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 50), () {
      if (!_isUpdatingControllers) {
        notifyListeners();
      }
    });
  }

  Future<void> initialize() async {
    logInfo(
        'Initializing ${_converterService.converterType} converter controller');

    try {
      // Ensure converter service is properly initialized
      final units = _converterService.units;
      logInfo(
          'ConverterController: Converter service has ${units.length} units available');

      if (units.isEmpty) {
        logError(
            'ConverterController: Converter service has no units available');
        throw Exception(
            'Converter service not properly initialized - no units available');
      }

      // Load saved state
      await loadState();

      // If no saved state, create default
      if (_state.cards.isEmpty) {
        createDefaultState();
      }

      // Initialize text controllers
      initializeControllers();

      // Perform conversions for loaded state to populate all unit values
      for (int i = 0; i < _state.cards.length; i++) {
        final card = _state.cards[i];
        updateCardConversions(i, card.baseUnitId, card.baseValue);
      }

      // Refresh data if needed
      if (_converterService.requiresRealTimeData) {
        await refreshData();
      }

      notifyListenersDebounced();
    } catch (e) {
      logError('Error initializing converter controller: $e');
      createDefaultState();
      initializeControllers();
      notifyListenersDebounced();
    }
  }

  @protected
  Future<void> loadState() async {
    try {
      logInfo(
          'ConverterController: Loading state for ${_converterService.converterType}');

      // Check if feature state saving is enabled
      final settings = await ExtensibleSettingsService.getGlobalSettings();
      logInfo(
          'ConverterController: Feature state saving enabled: ${settings.featureStateSavingEnabled}');

      if (settings.featureStateSavingEnabled) {
        // Load saved state when state saving is enabled
        final loadedState =
            await _stateService.loadState(_converterService.converterType);

        // Validate and fix the loaded state
        final validatedState = _validateAndFixState(loadedState);
        _state = validatedState;

        logInfo(
            'ConverterController: Loaded and validated state with ${_state.cards.length} cards, focus: ${_state.isFocusMode}, view: ${_state.viewMode.name}');
      } else {
        // Create default state when state saving is disabled
        logInfo(
            'ConverterController: State saving disabled, creating default state');
        createDefaultState();
      }
    } catch (e) {
      logError('ConverterController: Error loading state: $e');
      createDefaultState();
    }
  }

  /// Validates loaded state and fixes invalid unit IDs
  ConverterState _validateAndFixState(ConverterState loadedState) {
    try {
      // Get valid unit IDs from the converter service
      final availableUnits = _converterService.units;
      final validUnitIds = availableUnits.map((u) => u.id).toSet();
      final defaultUnits = _converterService.defaultVisibleUnits;

      logInfo(
          'ConverterController: Validating state with ${validUnitIds.length} available units: ${validUnitIds.take(5).join(', ')}...');

      // If state is empty or invalid, create default state
      if (loadedState.cards.isEmpty && loadedState.globalVisibleUnits.isEmpty) {
        logInfo('ConverterController: Empty loaded state, creating default');
        createDefaultState();
        return _state;
      }

      // Validate and fix global visible units
      final validGlobalUnits = loadedState.globalVisibleUnits
          .where((unitId) => validUnitIds.contains(unitId))
          .toSet();

      final invalidGlobalUnits = loadedState.globalVisibleUnits
          .where((unitId) => !validUnitIds.contains(unitId))
          .toSet();

      if (invalidGlobalUnits.isNotEmpty) {
        logError(
            'ConverterController: Found invalid global units: ${invalidGlobalUnits.join(', ')}');
      }

      if (validGlobalUnits.isEmpty) {
        logError(
            'ConverterController: No valid global units found in saved state, using defaults');
        validGlobalUnits.addAll(defaultUnits);
      }

      // Validate and fix cards
      final validCards = <ConverterCardState>[];

      for (int cardIndex = 0;
          cardIndex < loadedState.cards.length;
          cardIndex++) {
        final card = loadedState.cards[cardIndex];

        // Filter valid visible units for this card
        final validVisibleUnits = card.visibleUnits
            .where((unitId) => validUnitIds.contains(unitId))
            .toList();

        final invalidVisibleUnits = card.visibleUnits
            .where((unitId) => !validUnitIds.contains(unitId))
            .toList();

        if (invalidVisibleUnits.isNotEmpty) {
          logError(
              'ConverterController: Card "${card.name}" has invalid units: ${invalidVisibleUnits.join(', ')}');
        }

        // If no valid units, use default units
        if (validVisibleUnits.isEmpty) {
          logError(
              'ConverterController: Card "${card.name}" has no valid units, using defaults');
          validVisibleUnits.addAll(defaultUnits);
        }

        // Validate base unit ID
        String validBaseUnitId = card.baseUnitId;
        if (!validUnitIds.contains(card.baseUnitId)) {
          logError(
              'ConverterController: Invalid baseUnitId "${card.baseUnitId}" in card "${card.name}", using first valid unit');
          validBaseUnitId = validVisibleUnits.isNotEmpty
              ? validVisibleUnits.first
              : defaultUnits.first;
        }

        // Filter valid values
        final validValues = <String, double>{};
        for (final entry in card.values.entries) {
          if (validUnitIds.contains(entry.key)) {
            validValues[entry.key] = entry.value;
          }
        }

        // Create validated card
        final validatedCard = ConverterCardState(
          name: card.name,
          baseUnitId: validBaseUnitId,
          baseValue: card.baseValue,
          visibleUnits: validVisibleUnits,
          values: validValues,
        );

        validCards.add(validatedCard);
      }

      // If no valid cards, create default card
      if (validCards.isEmpty) {
        logError('ConverterController: No valid cards found, creating default');
        createDefaultState();
        return _state;
      }

      logInfo(
          'ConverterController: Validation complete: ${validCards.length} cards, ${validGlobalUnits.length} global units');

      return ConverterState(
        cards: validCards,
        globalVisibleUnits: validGlobalUnits,
        isFocusMode: loadedState.isFocusMode,
        viewMode: loadedState.viewMode,
      );
    } catch (e) {
      logError('ConverterController: Error validating state: $e');
      createDefaultState();
      return _state;
    }
  }

  @protected
  void createDefaultState() {
    try {
      final defaultUnits = _converterService.defaultVisibleUnits;
      logInfo(
          'ConverterController: Creating default state with units: ${defaultUnits.toList()}');

      if (defaultUnits.isEmpty) {
        logError(
            'ConverterController: No default visible units found for ${_converterService.converterType}');
        throw Exception('No default visible units available');
      }

      final firstUnit = defaultUnits.first;

      // Validate that the first unit exists in the converter service
      final firstUnitObject = _converterService.getUnit(firstUnit);
      if (firstUnitObject == null) {
        logError(
            'ConverterController: First unit $firstUnit not found in converter service');
        throw Exception('Default unit not found in converter service');
      }

      final defaultCard = ConverterCardState(
        name: 'Card 1', // Will be localized in UI
        baseUnitId: firstUnit,
        baseValue: 1.0,
        visibleUnits: defaultUnits.toList(),
        values: {
          for (String unit in defaultUnits) unit: unit == firstUnit ? 1.0 : 0.0
        },
      );

      _state = ConverterState(
        cards: [defaultCard],
        globalVisibleUnits: defaultUnits,
        isFocusMode: false,
        viewMode: ConverterViewMode.cards,
      );

      logInfo(
          'ConverterController: Default state created successfully with ${defaultUnits.length} units');
    } catch (e) {
      logError('ConverterController: Error creating default state: $e');

      // Fallback: Create a minimal state with available units
      final allUnits = _converterService.units;
      if (allUnits.isNotEmpty) {
        final fallbackUnits = allUnits.take(3).map((u) => u.id).toSet();
        final firstUnit = fallbackUnits.first;

        logInfo(
            'ConverterController: Using fallback units: ${fallbackUnits.toList()}');

        final defaultCard = ConverterCardState(
          name: 'Card 1',
          baseUnitId: firstUnit,
          baseValue: 1.0,
          visibleUnits: fallbackUnits.toList(),
          values: {
            for (String unit in fallbackUnits)
              unit: unit == firstUnit ? 1.0 : 0.0
          },
        );

        _state = ConverterState(
          cards: [defaultCard],
          globalVisibleUnits: fallbackUnits,
          isFocusMode: false,
          viewMode: ConverterViewMode.cards,
        );
      } else {
        logError(
            'ConverterController: No units available in converter service');
        rethrow;
      }
    }
  }

  @protected
  void initializeControllers() {
    _disposeControllers();

    for (int i = 0; i < _state.cards.length; i++) {
      final card = _state.cards[i];
      final controllers = <String, TextEditingController>{};

      for (String unitId in card.visibleUnits) {
        final value = card.values[unitId] ?? 0.0;
        controllers[unitId] =
            TextEditingController(text: _formatValue(value, unitId));
      }

      _cardControllers[i] = controllers;
    }
  }

  void _disposeControllers() {
    for (var cardControllers in _cardControllers.values) {
      for (var controller in cardControllers.values) {
        controller.dispose();
      }
    }
    _cardControllers.clear();
  }

  String _formatValue(double value, String unitId) {
    final unit = _converterService.getUnit(unitId);
    return unit?.formatValue(value) ?? NumberFormatService.formatNumber(value);
  }

  Future<void> _saveState() async {
    try {
      // Check if feature state saving is enabled before saving
      final settings = await ExtensibleSettingsService.getGlobalSettings();
      if (settings.featureStateSavingEnabled) {
        await _stateService.saveState(_converterService.converterType, _state);
        logInfo('Saved state with ${_state.cards.length} cards');
      } else {
        logInfo('State saving disabled - skipping save');
      }
    } catch (e) {
      logError('Error saving state: $e');
    }
  }

  Future<void> refreshData() async {
    if (!_converterService.requiresRealTimeData) return;

    _state = _state.copyWith(isLoading: true);
    notifyListenersDebounced();

    try {
      await _converterService.refreshData();

      // Update all conversions in batch
      _isUpdatingControllers = true;
      for (int i = 0; i < _state.cards.length; i++) {
        updateCardConversions(
            i, _state.cards[i].baseUnitId, _state.cards[i].baseValue);
      }
      _isUpdatingControllers = false;

      _state = _state.copyWith(
        isLoading: false,
        lastUpdated: _converterService.lastUpdated,
      );
    } catch (e) {
      logError('Error refreshing data: $e');
      _state = _state.copyWith(isLoading: false);
    }

    notifyListenersDebounced();
  }

  // Public methods
  Future<void> addCard() async {
    logInfo('Adding new converter card');

    final defaultUnit = _state.globalVisibleUnits.first;
    final cardName =
        'Card ${_state.cards.length + 1}'; // Will be localized in UI

    final newCard = ConverterCardState(
      name: cardName,
      baseUnitId: defaultUnit,
      baseValue: 1.0,
      visibleUnits: _state.globalVisibleUnits.toList(),
      values: {
        for (String unit in _state.globalVisibleUnits)
          unit: unit == defaultUnit ? 1.0 : 0.0
      },
    );

    final newCards = List<ConverterCardState>.from(_state.cards)..add(newCard);
    _state = _state.copyWith(cards: newCards);

    // Add controllers for new card
    final cardIndex = newCards.length - 1;
    final controllers = <String, TextEditingController>{};
    for (String unitId in newCard.visibleUnits) {
      final value = newCard.values[unitId] ?? 0.0;
      controllers[unitId] =
          TextEditingController(text: _formatValue(value, unitId));
    }
    _cardControllers[cardIndex] = controllers;

    updateCardConversions(cardIndex, defaultUnit, 1.0);
    await _saveState();
    notifyListenersDebounced();
  }

  Future<void> removeCard(int cardIndex) async {
    logInfo('Removing converter card at index $cardIndex');

    if (_state.cards.length <= 1) return; // Keep at least one card

    // Dispose controllers for removed card
    _cardControllers[cardIndex]
        ?.forEach((_, controller) => controller.dispose());
    _cardControllers.remove(cardIndex);

    // Shift controller indices
    final newControllers = <int, Map<String, TextEditingController>>{};
    for (var entry in _cardControllers.entries) {
      if (entry.key > cardIndex) {
        newControllers[entry.key - 1] = entry.value;
      } else {
        newControllers[entry.key] = entry.value;
      }
    }
    _cardControllers.clear();
    _cardControllers.addAll(newControllers);

    final newCards = List<ConverterCardState>.from(_state.cards)
      ..removeAt(cardIndex);
    _state = _state.copyWith(cards: newCards);

    await _saveState();
    notifyListenersDebounced();
  }

  Future<void> updateCardName(int cardIndex, String newName) async {
    if (cardIndex >= _state.cards.length) return;

    final updatedCard = _state.cards[cardIndex].copyWith(name: newName);
    final newCards = List<ConverterCardState>.from(_state.cards);
    newCards[cardIndex] = updatedCard;

    _state = _state.copyWith(cards: newCards);
    await _saveState();
    notifyListenersDebounced();
  }

  Future<void> updateCardUnits(int cardIndex, Set<String> newUnits) async {
    if (cardIndex >= _state.cards.length) return;

    final oldCard = _state.cards[cardIndex];
    final baseUnit = newUnits.contains(oldCard.baseUnitId)
        ? oldCard.baseUnitId
        : newUnits.first;

    // Preserve existing values where possible
    final newValues = <String, double>{};
    for (String unit in newUnits) {
      newValues[unit] = oldCard.values[unit] ?? (unit == baseUnit ? 1.0 : 0.0);
    }

    final updatedCard = oldCard.copyWith(
      baseUnitId: baseUnit,
      visibleUnits:
          newUnits.toList(), // newUnits is already a Set, so no duplicates
      values: newValues,
    );

    final newCards = List<ConverterCardState>.from(_state.cards);
    newCards[cardIndex] = updatedCard;
    _state = _state.copyWith(cards: newCards);

    // Update controllers
    _cardControllers[cardIndex]
        ?.forEach((_, controller) => controller.dispose());
    final controllers = <String, TextEditingController>{};
    for (String unitId in newUnits) {
      final value = newValues[unitId] ?? 0.0;
      controllers[unitId] =
          TextEditingController(text: _formatValue(value, unitId));
    }
    _cardControllers[cardIndex] = controllers;

    updateCardConversions(cardIndex, baseUnit, updatedCard.baseValue);
    await _saveState();
    notifyListenersDebounced();
  }

  void onValueChanged(int cardIndex, String unitId, String valueText) {
    if (cardIndex >= _state.cards.length) return;

    final value = double.tryParse(valueText) ?? 0.0;
    updateCardConversions(cardIndex, unitId, value);

    // Save state after value changes to ensure persistence (async but don't block UI)
    _saveState().catchError((e) {
      logError('Error saving state after value change: $e');
    });
  }

  @protected
  void updateCardConversions(
      int cardIndex, String baseUnitId, double baseValue) {
    if (cardIndex >= _state.cards.length) return;

    final card = _state.cards[cardIndex];
    final newValues = <String, double>{};
    final newStatuses = <String, ConversionStatus>{};

    // Prevent recursive controller updates
    _isUpdatingControllers = true;

    for (String unitId in card.visibleUnits) {
      if (unitId == baseUnitId) {
        newValues[unitId] = baseValue;
        newStatuses[unitId] = ConversionStatus.success;
      } else {
        try {
          final convertedValue =
              _converterService.convert(baseValue, baseUnitId, unitId);
          newValues[unitId] = convertedValue;
          newStatuses[unitId] = _converterService.getUnitStatus(unitId);

          // Update controller without triggering listeners
          final controller = _cardControllers[cardIndex]?[unitId];
          if (controller != null) {
            final newText = _formatValue(convertedValue, unitId);
            if (controller.text != newText) {
              controller.value = controller.value.copyWith(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
            }
          }
        } catch (e) {
          newValues[unitId] = 0.0;
          newStatuses[unitId] = ConversionStatus.failed;
          final controller = _cardControllers[cardIndex]?[unitId];
          if (controller != null && controller.text != '0.00') {
            controller.text = '0.00';
          }
        }
      }
    }

    final updatedCard = card.copyWith(
      baseUnitId: baseUnitId,
      baseValue: baseValue,
      values: newValues,
      statuses: newStatuses,
    );

    final newCards = List<ConverterCardState>.from(_state.cards);
    newCards[cardIndex] = updatedCard;
    _state = _state.copyWith(cards: newCards);

    _isUpdatingControllers = false;
    notifyListenersDebounced();
  }

  Future<void> updateGlobalVisibleUnits(Set<String> newUnits) async {
    _state = _state.copyWith(globalVisibleUnits: newUnits);

    // Update all cards to use new global units (optional - might want to keep individual card units)
    // This depends on your UX preference

    await _saveState();
    notifyListenersDebounced();
  }

  Future<void> setViewMode(ConverterViewMode mode) async {
    if (_state.viewMode != mode) {
      _state = _state.copyWith(viewMode: mode);
      await _saveState();
      notifyListenersDebounced();
    }
  }

  Future<void> reorderCards(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final cards = List<ConverterCardState>.from(_state.cards);
    final item = cards.removeAt(oldIndex);
    cards.insert(newIndex, item);

    // Reorder controllers
    final oldControllers = _cardControllers[oldIndex];
    _cardControllers.remove(oldIndex);

    // Shift other controllers
    final tempControllers = <int, Map<String, TextEditingController>>{};
    for (var entry in _cardControllers.entries) {
      final index = entry.key;
      if (index > oldIndex && index <= newIndex) {
        tempControllers[index - 1] = entry.value;
      } else if (index < oldIndex && index >= newIndex) {
        tempControllers[index + 1] = entry.value;
      } else {
        tempControllers[index] = entry.value;
      }
    }

    tempControllers[newIndex] = oldControllers!;
    _cardControllers.clear();
    _cardControllers.addAll(tempControllers);

    _state = _state.copyWith(cards: cards);
    await _saveState();
    notifyListenersDebounced();
  }

  // New methods for mobile card movement
  Future<void> moveCardToFirst(int cardIndex) async {
    if (cardIndex <= 0) return; // Already at first position
    await reorderCards(cardIndex, 0);
  }

  Future<void> moveCardToLast(int cardIndex) async {
    final lastIndex = _state.cards.length - 1;
    if (cardIndex >= lastIndex) return; // Already at last position
    await reorderCards(cardIndex, lastIndex);
  }

  Future<void> moveCardUp(int cardIndex) async {
    if (cardIndex <= 0) return; // Already at first position
    await reorderCards(cardIndex, cardIndex - 1);
  }

  Future<void> moveCardDown(int cardIndex) async {
    if (cardIndex >= _state.cards.length - 1) {
      return; // Already at last position
    }
    await reorderCards(cardIndex, cardIndex + 1);
  }

  // Helper method to check if platform is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  void setFocusMode(bool enabled) {
    if (_state.isFocusMode != enabled) {
      _state = _state.copyWith(isFocusMode: enabled);
      _saveState();
      notifyListenersDebounced();
    }
  }

  void resetLayout() {
    _disposeControllers();
    createDefaultState();
    initializeControllers();
    _saveState();
    notifyListenersDebounced();
  }

  Future<void> clearSavedState() async {
    try {
      logInfo(
          'ConverterController: Clearing saved state for ${_converterService.converterType}');
      await _stateService.clearState(_converterService.converterType);

      // Reset to default state
      _disposeControllers();
      createDefaultState();
      initializeControllers();
      notifyListenersDebounced();

      logInfo(
          'ConverterController: Successfully cleared saved state and reset to default');
    } catch (e) {
      logError('ConverterController: Error clearing saved state: $e');
    }
  }

  void toggleFocusMode() {
    _state = _state.copyWith(isFocusMode: !_state.isFocusMode);
    _saveState();
    notifyListenersDebounced();
  }

  @override
  void dispose() {
    _notifyTimer?.cancel();
    _disposeControllers();
    super.dispose();
  }
}
