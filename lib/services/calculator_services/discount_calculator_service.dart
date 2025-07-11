import 'package:setpocket/models/calculator_models/discount_calculator_models.dart';
import 'package:setpocket/services/calculator_services/calculator_tools_service.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/services/settings_models_service.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:isar/isar.dart';
import 'dart:convert';

class DiscountCalculatorService {
  static const String _toolCode = 'discount_calculator';

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

  // History Management using UnifiedHistoryData
  static Future<List<DiscountCalculationHistory>> getHistory() async {
    final isar = IsarService.isar;
    final unifiedHistory = await isar.unifiedHistoryDatas
        .filter()
        .typeEqualTo('discount_calculator')
        .sortByTimestampDesc()
        .findAll();

    return unifiedHistory.map((item) {
      // Parse the value field which contains JSON data
      Map<String, dynamic> valueData = {};
      try {
        valueData = jsonDecode(item.value) as Map<String, dynamic>;
      } catch (e) {
        // Handle legacy format or parsing errors
        valueData = {'inputsData': {}, 'resultsData': {}};
      }

      final inputsData =
          Map<String, dynamic>.from(valueData['inputsData'] ?? {});
      final resultsData =
          Map<String, dynamic>.from(valueData['resultsData'] ?? {});

      // Determine type from subType or try to infer
      DiscountCalculationType type = DiscountCalculationType.discount;
      if (item.subType != null) {
        try {
          type = DiscountCalculationType.values.firstWhere(
            (e) => e.name == item.subType,
            orElse: () => DiscountCalculationType.discount,
          );
        } catch (e) {
          type = DiscountCalculationType.discount;
        }
      }

      return DiscountCalculationHistory(
        id: item.id.toString(),
        type: type,
        displayTitle: item.displayTitle ?? item.title ?? 'Calculation',
        inputs: inputsData.map((key, value) => MapEntry(key, value.toString())),
        results:
            resultsData.map((key, value) => MapEntry(key, value.toString())),
        timestamp: item.timestamp,
      );
    }).toList();
  }

  static Future<void> saveToHistory(DiscountCalculationHistory item) async {
    // Check if history is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.rememberHistory) return;

    // Create UnifiedHistoryData from DiscountCalculationHistory
    final valueData = {
      'inputsData': item.inputs,
      'resultsData': item.results,
    };

    final historyData = UnifiedHistoryData(
      type: 'discount_calculator',
      title: item.type.name,
      value: jsonEncode(valueData),
      timestamp: item.timestamp,
      subType: item.type.name,
      displayTitle: item.displayTitle,
      inputsData: item.inputs,
      resultsData: item.results,
    );

    await GenerationHistoryService.addHistoryItem(historyData);
  }

  static Future<void> removeFromHistory(String id) async {
    final isar = IsarService.isar;
    final numericId = int.tryParse(id);
    if (numericId != null) {
      await isar.writeTxn(() async {
        await isar.unifiedHistoryDatas.delete(numericId);
      });
    }
  }

  static Future<void> clearHistory() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.unifiedHistoryDatas
          .filter()
          .typeEqualTo('discount_calculator')
          .deleteAll();
    });
  }

  // State Management using CalculatorToolsService
  static Future<void> saveCurrentState(DiscountCalculatorState state) async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return;

    await CalculatorToolsService.saveToolState(
      _toolCode,
      state.toMap(),
      metadata: {
        'lastSaved': DateTime.now().toIso8601String(),
        'version': '1.0',
      },
    );
  }

  static Future<DiscountCalculatorState?> getCurrentState() async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return null;

    final stateData = await CalculatorToolsService.getToolState(_toolCode);
    if (stateData == null) return null;

    try {
      return DiscountCalculatorState.fromMap(stateData);
    } catch (e) {
      // Return null if state is corrupted
      return null;
    }
  }

  static Future<void> clearCurrentState() async {
    await CalculatorToolsService.clearToolState(_toolCode);
  }

  // Form State Management using CalculatorToolsService
  static Future<void> saveFormState(Map<String, String> formState) async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return;

    await CalculatorToolsService.saveToolState(
      '${_toolCode}_form',
      formState,
      metadata: {
        'lastSaved': DateTime.now().toIso8601String(),
        'type': 'form_state',
      },
    );
  }

  static Future<Map<String, String>> getFormState() async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return {};

    final stateData =
        await CalculatorToolsService.getToolState('${_toolCode}_form');
    if (stateData == null) return {};

    // Convert to Map<String, String>
    return stateData.map((key, value) => MapEntry(key, value.toString()));
  }

  static Future<void> clearFormState() async {
    await CalculatorToolsService.clearToolState('${_toolCode}_form');
  }
}
