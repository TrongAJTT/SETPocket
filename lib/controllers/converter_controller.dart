import 'package:flutter/material.dart';
import 'dart:async';
import '../models/converter_models/converter_base.dart';
import '../services/converter_services/converter_service_base.dart';
import '../services/app_logger.dart';
import '../services/number_format_service.dart';
import '../services/settings_service.dart';

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
  void _notifyListenersDebounced() {
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
      // Load saved state
      await _loadState();

      // If no saved state, create default
      if (_state.cards.isEmpty) {
        _createDefaultState();
      }

      // Initialize text controllers
      _initializeControllers();

      // Perform conversions for loaded state to populate all unit values
      for (int i = 0; i < _state.cards.length; i++) {
        final card = _state.cards[i];
        _updateCardConversions(i, card.baseUnitId, card.baseValue);
      }

      // Refresh data if needed
      if (_converterService.requiresRealTimeData) {
        await _refreshData();
      }

      _notifyListenersDebounced();
    } catch (e) {
      logError('Error initializing converter controller: $e');
      _createDefaultState();
      _initializeControllers();
      _notifyListenersDebounced();
    }
  }

  Future<void> _loadState() async {
    try {
      logInfo(
          'ConverterController: Loading state for ${_converterService.converterType}');

      // Debug: check if feature state saving is enabled
      try {
        final settings = await SettingsService.getSettings();
        logInfo(
            'ConverterController: Feature state saving enabled: ${settings.featureStateSavingEnabled}');
      } catch (e) {
        logError('ConverterController: Error checking settings: $e');
      }

      final loadedState =
          await _stateService.loadState(_converterService.converterType);
      _state = loadedState;
      logInfo(
          'ConverterController: Loaded state with ${_state.cards.length} cards, focus: ${_state.isFocusMode}, view: ${_state.viewMode.name}');
    } catch (e) {
      logError('ConverterController: Error loading state: $e');
      _createDefaultState();
    }
  }

  void _createDefaultState() {
    final defaultUnits = _converterService.defaultVisibleUnits;
    final firstUnit = defaultUnits.first;

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
  }

  void _initializeControllers() {
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
      await _stateService.saveState(_converterService.converterType, _state);
      logInfo('Saved state with ${_state.cards.length} cards');
    } catch (e) {
      logError('Error saving state: $e');
    }
  }

  Future<void> _refreshData() async {
    if (!_converterService.requiresRealTimeData) return;

    _state = _state.copyWith(isLoading: true);
    _notifyListenersDebounced();

    try {
      await _converterService.refreshData();

      // Update all conversions in batch
      _isUpdatingControllers = true;
      for (int i = 0; i < _state.cards.length; i++) {
        _updateCardConversions(
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

    _notifyListenersDebounced();
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

    _updateCardConversions(cardIndex, defaultUnit, 1.0);
    await _saveState();
    _notifyListenersDebounced();
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
    _notifyListenersDebounced();
  }

  Future<void> updateCardName(int cardIndex, String newName) async {
    if (cardIndex >= _state.cards.length) return;

    final updatedCard = _state.cards[cardIndex].copyWith(name: newName);
    final newCards = List<ConverterCardState>.from(_state.cards);
    newCards[cardIndex] = updatedCard;

    _state = _state.copyWith(cards: newCards);
    await _saveState();
    _notifyListenersDebounced();
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

    _updateCardConversions(cardIndex, baseUnit, updatedCard.baseValue);
    await _saveState();
    _notifyListenersDebounced();
  }

  void onValueChanged(int cardIndex, String unitId, String valueText) {
    if (cardIndex >= _state.cards.length) return;

    final value = double.tryParse(valueText) ?? 0.0;
    _updateCardConversions(cardIndex, unitId, value);

    // Save state after value changes to ensure persistence (async but don't block UI)
    _saveState().catchError((e) {
      logError('Error saving state after value change: $e');
    });
  }

  void _updateCardConversions(
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
    _notifyListenersDebounced();
  }

  Future<void> updateGlobalVisibleUnits(Set<String> newUnits) async {
    _state = _state.copyWith(globalVisibleUnits: newUnits);

    // Update all cards to use new global units (optional - might want to keep individual card units)
    // This depends on your UX preference

    await _saveState();
    _notifyListenersDebounced();
  }

  Future<void> setViewMode(ConverterViewMode mode) async {
    if (_state.viewMode != mode) {
      _state = _state.copyWith(viewMode: mode);
      await _saveState();
      _notifyListenersDebounced();
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
    _notifyListenersDebounced();
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

  Future<void> resetLayout() async {
    _disposeControllers();
    _createDefaultState();
    _initializeControllers();
    await _saveState();
    _notifyListenersDebounced();
  }

  Future<void> refreshData() async {
    await _refreshData();
  }

  /// Toggle focus mode on/off
  Future<void> toggleFocusMode() async {
    _state = _state.copyWith(isFocusMode: !_state.isFocusMode);
    await _saveState();
    _notifyListenersDebounced();
  }

  /// Set focus mode state
  Future<void> setFocusMode(bool enabled) async {
    if (_state.isFocusMode != enabled) {
      _state = _state.copyWith(isFocusMode: enabled);
      await _saveState();
      _notifyListenersDebounced();
    }
  }

  @override
  void dispose() {
    _notifyTimer?.cancel();
    _disposeControllers();
    super.dispose();
  }
}
