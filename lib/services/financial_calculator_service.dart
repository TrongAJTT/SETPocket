import 'dart:convert';
import 'dart:math' show pow;
import 'package:setpocket/models/financial_models.dart';
import 'package:setpocket/services/hive_service.dart';
import 'package:setpocket/services/calculator_history_service.dart';
import 'package:setpocket/services/graphing_calculator_service.dart';

class FinancialCalculatorService {
  static const String _historyBoxName = 'financial_calculator_history';
  static const String _stateBoxName = 'financial_calculator_state';
  static const String _stateKey = 'current_state';

  // History management
  static Future<List<FinancialCalculationHistory>> getHistory() async {
    final historyEnabled = await GraphingCalculatorService.getRememberHistory();
    if (!historyEnabled) return [];

    try {
      final box = await HiveService.getBox(_historyBoxName);
      final List<FinancialCalculationHistory> history = [];

      for (var key in box.keys) {
        final data = box.get(key);
        if (data != null && data is Map) {
          try {
            final item = FinancialCalculationHistory.fromJson(
                Map<String, dynamic>.from(data));
            history.add(item);
          } catch (e) {
            // Skip invalid items
          }
        }
      }

      // Sort by timestamp, newest first
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return history;
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveToHistory(FinancialCalculationHistory item) async {
    final historyEnabled = await GraphingCalculatorService.getRememberHistory();
    if (!historyEnabled) return;

    try {
      final box = await HiveService.getBox(_historyBoxName);
      await box.put(item.id, item.toJson());

      // Also save to general calculator history for consistency
      final String expression = _formatCalculationForHistory(item);
      final String result = _formatResultForHistory(item);
      await CalculatorHistoryService.addHistoryItem(
        expression,
        result,
        'financial',
      );

      // Keep only the latest 100 items
      await _cleanupHistory();
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  static Future<void> _cleanupHistory() async {
    try {
      final history = await getHistory();
      if (history.length > 100) {
        final box = await HiveService.getBox(_historyBoxName);
        final itemsToRemove = history.skip(100);
        for (final item in itemsToRemove) {
          await box.delete(item.id);
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  static String _formatCalculationForHistory(FinancialCalculationHistory item) {
    switch (item.type) {
      case FinancialCalculationType.loan:
        return 'Loan: \$${item.inputs['amount']}, ${item.inputs['rate']}%, ${item.inputs['term']}yr';
      case FinancialCalculationType.investment:
        return 'Investment: \$${item.inputs['initial']}, \$${item.inputs['monthly']}/mo, ${item.inputs['rate']}%, ${item.inputs['term']}yr';
      case FinancialCalculationType.compoundInterest:
        return 'Compound: \$${item.inputs['principal']}, ${item.inputs['rate']}%, ${item.inputs['time']}yr, ${item.inputs['frequency']}/yr';
    }
  }

  static String _formatResultForHistory(FinancialCalculationHistory item) {
    switch (item.type) {
      case FinancialCalculationType.loan:
        return '\$${(item.results['monthlyPayment'] as double).toStringAsFixed(2)}/mo';
      case FinancialCalculationType.investment:
        return '\$${(item.results['futureValue'] as double).toStringAsFixed(2)}';
      case FinancialCalculationType.compoundInterest:
        return '\$${(item.results['compoundAmount'] as double).toStringAsFixed(2)}';
    }
  }

  static Future<void> removeFromHistory(String id) async {
    try {
      final box = await HiveService.getBox(_historyBoxName);
      await box.delete(id);
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> clearHistory() async {
    try {
      final box = await HiveService.getBox(_historyBoxName);
      await box.clear();
    } catch (e) {
      // Silently fail
    }
  }

  // State management
  static Future<FinancialCalculatorState?> getCurrentState() async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      final data = box.get(_stateKey);
      if (data != null && data is Map) {
        return FinancialCalculatorState.fromJson(
            Map<String, dynamic>.from(data));
      }
    } catch (e) {
      // Return null if error
    }
    return null;
  }

  static Future<void> saveCurrentState(FinancialCalculatorState state) async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      await box.put(_stateKey, state.toJson());
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> clearCurrentState() async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      await box.delete(_stateKey);
    } catch (e) {
      // Silently fail
    }
  }

  // Cache info for settings integration
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final history = await getHistory();
      final currentState = await getCurrentState();

      // Calculate size estimation
      int historySize = 0;
      for (final item in history) {
        historySize += json.encode(item.toJson()).length;
      }

      final stateSize =
          currentState != null ? json.encode(currentState.toJson()).length : 0;

      return {
        'items': history.length + (currentState != null ? 1 : 0),
        'size': historySize + stateSize,
        'history_count': history.length,
        'has_current_state': currentState != null,
      };
    } catch (e) {
      return {
        'items': 0,
        'size': 0,
        'history_count': 0,
        'has_current_state': false,
      };
    }
  }

  static Future<void> clearAllData() async {
    await clearHistory();
    await clearCurrentState();
  }

  // Calculation helpers
  static LoanCalculationResult calculateLoan({
    required double amount,
    required double rate,
    required double term,
  }) {
    final monthlyRate = rate / 100 / 12;
    final numberOfPayments = term * 12;

    double monthlyPayment;
    if (rate == 0) {
      monthlyPayment = amount / numberOfPayments;
    } else {
      monthlyPayment = amount *
          (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
          (pow(1 + monthlyRate, numberOfPayments) - 1);
    }

    final totalPayment = monthlyPayment * numberOfPayments;
    final totalInterest = totalPayment - amount;

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
    final monthlyRate = rate / 100 / 12;
    final numberOfMonths = term * 12;

    // Future value of initial investment
    final futureValueInitial = initial * pow(1 + monthlyRate, numberOfMonths);

    // Future value of monthly contributions (annuity)
    final futureValueAnnuity =
        monthly * ((pow(1 + monthlyRate, numberOfMonths) - 1) / monthlyRate);

    final futureValue = futureValueInitial + futureValueAnnuity;
    final totalContributions = initial + (monthly * numberOfMonths);
    final totalEarnings = futureValue - totalContributions;

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
    final rateDecimal = rate / 100;
    final compoundAmount =
        principal * pow(1 + rateDecimal / frequency, frequency * time);
    final compoundInterestEarned = compoundAmount - principal;

    return CompoundInterestCalculationResult(
      compoundAmount: compoundAmount,
      compoundInterestEarned: compoundInterestEarned,
    );
  }
}
