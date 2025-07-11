import 'dart:math' as math;
import 'package:isar/isar.dart';
import 'package:setpocket/models/calculator_models/financial_models.dart'
    hide FinancialCalculatorState;
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/models/calculator_models/calculator_tools_data.dart';
import 'package:setpocket/services/calculator_services/calculator_tools_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/settings_models_service.dart';

class FinancialCalculatorService {
  static const String _toolCode = CalculatorToolCodes.financial;

  // Calculation Methods
  static LoanCalculationResult calculateLoan({
    required double amount,
    required double rate,
    required double term,
  }) {
    final double monthlyRate = rate / 100 / 12;
    final int numPayments = (term * 12).round();

    if (monthlyRate == 0) {
      final monthlyPayment = amount / numPayments;
      return LoanCalculationResult(
        monthlyPayment: monthlyPayment,
        totalPayment: amount,
        totalInterest: 0,
      );
    }

    final double monthlyPayment = amount *
        (monthlyRate * math.pow(1 + monthlyRate, numPayments)) /
        (math.pow(1 + monthlyRate, numPayments) - 1);

    final double totalPayment = monthlyPayment * numPayments;
    final double totalInterest = totalPayment - amount;

    return LoanCalculationResult(
      monthlyPayment: monthlyPayment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
    );
  }

  static InvestmentCalculationResult calculateInvestment({
    required double initial,
    required double monthly,
    required double rate,
    required double term,
  }) {
    final double monthlyRate = rate / 100 / 12;
    final int numPayments = (term * 12).round();

    double futureValue = initial * math.pow(1 + monthlyRate, numPayments);

    if (monthly > 0 && monthlyRate > 0) {
      futureValue +=
          monthly * (math.pow(1 + monthlyRate, numPayments) - 1) / monthlyRate;
    } else if (monthly > 0) {
      futureValue += monthly * numPayments;
    }

    final double totalContributions = initial + (monthly * numPayments);
    final double totalEarnings = futureValue - totalContributions;

    return InvestmentCalculationResult(
      futureValue: futureValue,
      totalContributions: totalContributions,
      totalEarnings: totalEarnings,
    );
  }

  static CompoundInterestCalculationResult calculateCompoundInterest({
    required double principal,
    required double rate,
    required double time,
    required double frequency,
  }) {
    final double rateDecimal = rate / 100;
    final double compoundAmount =
        principal * math.pow(1 + rateDecimal / frequency, frequency * time);
    final double compoundInterestEarned = compoundAmount - principal;

    return CompoundInterestCalculationResult(
      compoundAmount: compoundAmount,
      compoundInterestEarned: compoundInterestEarned,
    );
  }

  // State Management using new pattern
  static Future<Map<String, dynamic>?> getCurrentState() async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return null;

    return await CalculatorToolsService.getToolState(_toolCode);
  }

  static Future<void> saveCurrentState(Map<String, dynamic> stateData) async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return;

    await CalculatorToolsService.saveToolState(
      _toolCode,
      stateData,
      metadata: {
        'lastSaved': DateTime.now().toIso8601String(),
        'version': '1.0',
      },
    );
  }

  static Future<void> clearCurrentState() async {
    await CalculatorToolsService.clearToolState(_toolCode);
  }

  // History Management using UnifiedHistoryData
  static Future<List<UnifiedHistoryData>> getHistory() async {
    final isar = IsarService.isar;
    return await isar.unifiedHistoryDatas
        .filter()
        .typeEqualTo('financial')
        .sortByTimestampDesc()
        .findAll();
  }

  static Future<void> saveToHistory(Map<String, dynamic> item) async {
    final historyData = UnifiedHistoryData.financial(
      title: item['title'] ?? '',
      value: item['value'] ?? '',
      timestamp: DateTime.parse(item['timestamp']),
      subType: item['subType'] ?? 'loan',
      inputsData: Map<String, dynamic>.from(item['inputsData'] ?? {}),
      resultsData: Map<String, dynamic>.from(item['resultsData'] ?? {}),
      displayTitle: item['displayTitle'] ?? '',
    );

    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.unifiedHistoryDatas.put(historyData);
    });
  }

  static Future<void> removeFromHistory(String historyId) async {
    final isar = IsarService.isar;
    final id = int.tryParse(historyId);
    if (id != null) {
      await isar.writeTxn(() async {
        await isar.unifiedHistoryDatas.delete(id);
      });
    }
  }

  static Future<void> clearHistory() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.unifiedHistoryDatas
          .filter()
          .typeEqualTo('financial')
          .deleteAll();
    });
  }

  // Helper methods for state conversion
  static Map<String, dynamic> stateToMap({
    required int activeTabIndex,
    required Map<String, String> loanInputs,
    required Map<String, String> investmentInputs,
    required Map<String, String> compoundInputs,
    Map<String, dynamic>? loanResults,
    Map<String, dynamic>? investmentResults,
    Map<String, dynamic>? compoundResults,
  }) {
    return {
      'activeTabIndex': activeTabIndex,
      'loanInputs': loanInputs,
      'investmentInputs': investmentInputs,
      'compoundInputs': compoundInputs,
      'loanResults': loanResults,
      'investmentResults': investmentResults,
      'compoundResults': compoundResults,
      'lastModified': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic>? mapToState(Map<String, dynamic>? data) {
    if (data == null) return null;
    return {
      'activeTabIndex': data['activeTabIndex'] ?? 0,
      'loanInputs': Map<String, String>.from(data['loanInputs'] ?? {}),
      'investmentInputs':
          Map<String, String>.from(data['investmentInputs'] ?? {}),
      'compoundInputs': Map<String, String>.from(data['compoundInputs'] ?? {}),
      'loanResults': data['loanResults'] != null
          ? Map<String, dynamic>.from(data['loanResults'])
          : null,
      'investmentResults': data['investmentResults'] != null
          ? Map<String, dynamic>.from(data['investmentResults'])
          : null,
      'compoundResults': data['compoundResults'] != null
          ? Map<String, dynamic>.from(data['compoundResults'])
          : null,
      'lastModified': data['lastModified'],
    };
  }
}
