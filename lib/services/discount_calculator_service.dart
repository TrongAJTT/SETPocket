import 'package:setpocket/models/discount_calculator_models.dart';
import 'package:setpocket/services/hive_service.dart';

class DiscountCalculatorService {
  static const String _historyBoxName = 'discount_calculator_history';
  static const String _stateBoxName = 'discount_calculator_state';
  static const String _stateKey = 'current_state';

  // Discount Calculations
  static DiscountCalculationResult calculateDiscount({
    required double originalPrice,
    required double discountPercent,
  }) {
    final discountAmount = originalPrice * (discountPercent / 100);
    final finalPrice = originalPrice - discountAmount;
    final savedAmount = discountAmount;

    return DiscountCalculationResult(
      originalAmount: originalPrice,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      finalAmount: finalPrice,
      savedAmount: savedAmount,
    );
  }

  // Tip Calculations
  static TipCalculationResult calculateTip({
    required double billAmount,
    required double tipPercent,
    required int numberOfPeople,
  }) {
    final tipAmount = billAmount * (tipPercent / 100);
    final totalBill = billAmount + tipAmount;
    final perPersonAmount = totalBill / numberOfPeople;

    return TipCalculationResult(
      billAmount: billAmount,
      tipPercent: tipPercent,
      numberOfPeople: numberOfPeople,
      tipAmount: tipAmount,
      totalBill: totalBill,
      perPersonAmount: perPersonAmount,
    );
  }

  // Tax Calculations
  static TaxCalculationResult calculateTax({
    required double priceBeforeTax,
    required double taxRate,
  }) {
    final taxAmount = priceBeforeTax * (taxRate / 100);
    final priceAfterTax = priceBeforeTax + taxAmount;

    return TaxCalculationResult(
      priceBeforeTax: priceBeforeTax,
      taxRate: taxRate,
      taxAmount: taxAmount,
      priceAfterTax: priceAfterTax,
    );
  }

  // Markup Calculations
  static MarkupCalculationResult calculateMarkup({
    required double costPrice,
    required double markupPercent,
  }) {
    final markupAmount = costPrice * (markupPercent / 100);
    final sellingPrice = costPrice + markupAmount;
    final profitMargin = (markupAmount / sellingPrice) * 100;

    return MarkupCalculationResult(
      costPrice: costPrice,
      markupPercent: markupPercent,
      markupAmount: markupAmount,
      sellingPrice: sellingPrice,
      profitMargin: profitMargin,
    );
  }

  // History Management
  static Future<void> saveToHistory(DiscountCalculationHistory item) async {
    final box = await HiveService.getBox(_historyBoxName);
    await box.put(item.id, item.toMap());
  }

  static Future<List<DiscountCalculationHistory>> getHistory() async {
    final box = await HiveService.getBox(_historyBoxName);
    final items = box.values.map((item) {
      return DiscountCalculationHistory.fromMap(
          Map<String, dynamic>.from(item));
    }).toList();

    // Sort by timestamp, newest first
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  static Future<void> removeFromHistory(String id) async {
    final box = await HiveService.getBox(_historyBoxName);
    await box.delete(id);
  }

  static Future<void> clearHistory() async {
    final box = await HiveService.getBox(_historyBoxName);
    await box.clear();
  }

  // State Management
  static Future<void> saveCurrentState(DiscountCalculatorState state) async {
    final box = await HiveService.getBox(_stateBoxName);
    await box.put(_stateKey, state.toMap());
  }

  static Future<DiscountCalculatorState?> getCurrentState() async {
    final box = await HiveService.getBox(_stateBoxName);
    final stateMap = box.get(_stateKey);
    if (stateMap != null) {
      return DiscountCalculatorState.fromMap(
          Map<String, dynamic>.from(stateMap));
    }
    return null;
  }

  static Future<void> clearCurrentState() async {
    final box = await HiveService.getBox(_stateBoxName);
    await box.delete(_stateKey);
  }

  // Form State Management
  static Future<void> saveFormState(Map<String, String> formState) async {
    final box = await HiveService.getBox(_stateBoxName);
    await box.put('form_state', formState);
  }

  static Future<Map<String, String>> getFormState() async {
    final box = await HiveService.getBox(_stateBoxName);
    final formState = box.get('form_state');
    if (formState != null && formState is Map) {
      return Map<String, String>.from(formState);
    }
    return {};
  }

  static Future<void> clearFormState() async {
    final box = await HiveService.getBox(_stateBoxName);
    await box.delete('form_state');
  }
}
