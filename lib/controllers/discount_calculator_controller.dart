import 'package:flutter/material.dart';
import 'package:setpocket/models/discount_calculator_models.dart';
import 'package:setpocket/services/discount_calculator_service.dart';

class DiscountCalculatorController with ChangeNotifier {
  DiscountCalculationType _activeTab = DiscountCalculationType.discount;

  // Current results
  DiscountCalculationResult? _discountResult;
  TipCalculationResult? _tipResult;
  TaxCalculationResult? _taxResult;
  MarkupCalculationResult? _markupResult;

  // History
  List<DiscountCalculationHistory> _history = [];

  // Loading state
  bool _isLoading = false;
  // Form state storage
  Map<String, String> _formState = {};
  bool _formStateLoaded = false;

  DiscountCalculatorController() {
    _loadHistory();
    _loadFormState();
  }

  // Getters
  DiscountCalculationType get activeTab => _activeTab;
  DiscountCalculationResult? get discountResult => _discountResult;
  TipCalculationResult? get tipResult => _tipResult;
  TaxCalculationResult? get taxResult => _taxResult;
  MarkupCalculationResult? get markupResult => _markupResult;
  List<DiscountCalculationHistory> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  Map<String, String> get formState => Map.unmodifiable(_formState);
  bool get isFormStateLoaded => _formStateLoaded;

  void setActiveTab(DiscountCalculationType tab) {
    if (_activeTab != tab) {
      _activeTab = tab;
      notifyListeners();
    }
  }

  Future<void> calculateDiscount({
    required double originalPrice,
    required double discountPercent,
  }) async {
    if (originalPrice <= 0 || discountPercent < 0 || discountPercent > 100) {
      throw ArgumentError('Invalid input values');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = DiscountCalculatorService.calculateDiscount(
        originalPrice: originalPrice,
        discountPercent: discountPercent,
      );

      _discountResult = result;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> calculateTip({
    required double billAmount,
    required double tipPercent,
    required int numberOfPeople,
  }) async {
    if (billAmount <= 0 || tipPercent < 0 || numberOfPeople <= 0) {
      throw ArgumentError('Invalid input values');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = DiscountCalculatorService.calculateTip(
        billAmount: billAmount,
        tipPercent: tipPercent,
        numberOfPeople: numberOfPeople,
      );

      _tipResult = result;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> calculateTax({
    required double priceBeforeTax,
    required double taxRate,
  }) async {
    if (priceBeforeTax <= 0 || taxRate < 0) {
      throw ArgumentError('Invalid input values');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = DiscountCalculatorService.calculateTax(
        priceBeforeTax: priceBeforeTax,
        taxRate: taxRate,
      );

      _taxResult = result;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> calculateMarkup({
    required double costPrice,
    required double markupPercent,
  }) async {
    if (costPrice <= 0 || markupPercent < 0) {
      throw ArgumentError('Invalid input values');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = DiscountCalculatorService.calculateMarkup(
        costPrice: costPrice,
        markupPercent: markupPercent,
      );

      _markupResult = result;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual bookmark/save to history methods
  Future<void> saveDiscountToHistory() async {
    if (_discountResult == null) return;

    final historyItem = DiscountCalculationHistory(
      type: DiscountCalculationType.discount,
      displayTitle:
          'Discount ${_discountResult!.discountPercent.toStringAsFixed(1)}% on \$${_discountResult!.originalAmount.toStringAsFixed(2)}',
      inputs: {
        'originalPrice': _discountResult!.originalAmount.toString(),
        'discountPercent': _discountResult!.discountPercent.toString(),
      },
      results: {
        'discountAmount': _discountResult!.discountAmount.toString(),
        'finalAmount': _discountResult!.finalAmount.toString(),
        'savedAmount': _discountResult!.savedAmount.toString(),
      },
    );

    await DiscountCalculatorService.saveToHistory(historyItem);
    await _loadHistory();
  }

  Future<void> saveTipToHistory() async {
    if (_tipResult == null) return;

    final historyItem = DiscountCalculationHistory(
      type: DiscountCalculationType.tip,
      displayTitle:
          'Tip ${_tipResult!.tipPercent.toStringAsFixed(1)}% on \$${_tipResult!.billAmount.toStringAsFixed(2)} for ${_tipResult!.numberOfPeople} people',
      inputs: {
        'billAmount': _tipResult!.billAmount.toString(),
        'tipPercent': _tipResult!.tipPercent.toString(),
        'numberOfPeople': _tipResult!.numberOfPeople.toString(),
      },
      results: {
        'tipAmount': _tipResult!.tipAmount.toString(),
        'totalBill': _tipResult!.totalBill.toString(),
        'perPersonAmount': _tipResult!.perPersonAmount.toString(),
      },
    );

    await DiscountCalculatorService.saveToHistory(historyItem);
    await _loadHistory();
  }

  Future<void> saveTaxToHistory() async {
    if (_taxResult == null) return;

    final historyItem = DiscountCalculationHistory(
      type: DiscountCalculationType.tax,
      displayTitle:
          'Tax ${_taxResult!.taxRate.toStringAsFixed(1)}% on \$${_taxResult!.priceBeforeTax.toStringAsFixed(2)}',
      inputs: {
        'priceBeforeTax': _taxResult!.priceBeforeTax.toString(),
        'taxRate': _taxResult!.taxRate.toString(),
      },
      results: {
        'taxAmount': _taxResult!.taxAmount.toString(),
        'priceAfterTax': _taxResult!.priceAfterTax.toString(),
      },
    );

    await DiscountCalculatorService.saveToHistory(historyItem);
    await _loadHistory();
  }

  Future<void> saveMarkupToHistory() async {
    if (_markupResult == null) return;

    final historyItem = DiscountCalculationHistory(
      type: DiscountCalculationType.markup,
      displayTitle:
          'Markup ${_markupResult!.markupPercent.toStringAsFixed(1)}% on \$${_markupResult!.costPrice.toStringAsFixed(2)}',
      inputs: {
        'costPrice': _markupResult!.costPrice.toString(),
        'markupPercent': _markupResult!.markupPercent.toString(),
      },
      results: {
        'markupAmount': _markupResult!.markupAmount.toString(),
        'sellingPrice': _markupResult!.sellingPrice.toString(),
        'profitMargin': _markupResult!.profitMargin.toString(),
      },
    );

    await DiscountCalculatorService.saveToHistory(historyItem);
    await _loadHistory();
  }

  Future<void> removeFromHistory(String id) async {
    await DiscountCalculatorService.removeFromHistory(id);
    await _loadHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await DiscountCalculatorService.clearHistory();
    _history.clear();
    notifyListeners();
  }

  Future<void> clearTabData() async {
    _discountResult = null;
    _tipResult = null;
    _taxResult = null;
    _markupResult = null;
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    try {
      _history = await DiscountCalculatorService.getHistory();
      notifyListeners();
    } catch (e) {
      // Handle error silently - start with empty history
      _history = [];
    }
  }

  // Form state methods
  void saveFormField(String key, String value) {
    _formState[key] = value;
    _saveFormState();
  }

  String getFormField(String key) {
    return _formState[key] ?? '';
  }

  Future<void> _loadFormState() async {
    try {
      _formState = await DiscountCalculatorService.getFormState();
      _formStateLoaded = true;
      notifyListeners();
    } catch (e) {
      // Handle error silently - start with empty form state
      _formState = {};
      _formStateLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveFormState() async {
    try {
      await DiscountCalculatorService.saveFormState(_formState);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearFormState() async {
    _formState.clear();
    await DiscountCalculatorService.clearFormState();
    notifyListeners();
  }
}
