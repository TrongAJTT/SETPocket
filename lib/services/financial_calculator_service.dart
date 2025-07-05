import 'dart:convert';
import 'dart:math' show pow;
import 'package:isar/isar.dart';
import 'package:setpocket/models/financial_models.dart';
import 'package:setpocket/services/calculator_history_isar_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:uuid/uuid.dart';

class FinancialCalculatorService {
  static final _uuid = const Uuid();

  // History management
  static Future<List<FinancialCalculationHistory>> getHistory() async {
    final isar = IsarService.isar;
    return await isar.financialCalculationHistorys
        .where()
        .sortByTimestampDesc()
        .findAll();
  }

  static Future<void> saveToHistory(FinancialCalculationHistory item) async {
    final isar = IsarService.isar;
    if (item.id.isEmpty) {
      item.id = _uuid.v4();
    }

    await isar.writeTxn(() async {
      await isar.financialCalculationHistorys.put(item);
    });

    // Also save to general calculator history for consistency
    final String expression = _formatCalculationForHistory(item);
    final String result = _formatResultForHistory(item);
    await CalculatorHistoryIsarService.addHistoryItem(
      expression,
      result,
      'financial',
    );

    await _cleanupHistory();
  }

  static Future<void> _cleanupHistory() async {
    final isar = IsarService.isar;
    final count = await isar.financialCalculationHistorys.count();
    if (count > 100) {
      final toDelete = await isar.financialCalculationHistorys
          .where()
          .sortByTimestamp()
          .limit(count - 100)
          .findAll();
      await isar.writeTxn(() async {
        await isar.financialCalculationHistorys
            .deleteAll(toDelete.map((e) => e.isarId).toList());
      });
    }
  }

  static String _formatCalculationForHistory(FinancialCalculationHistory item) {
    switch (item.type) {
      case FinancialCalculationType.loan:
        return 'Loan: \$${item.inputs['amount']}, ${item.inputs['rate']}%, ${item.inputs['term']}yr';
      case FinancialCalculationType.investment:
        return 'Invest: \$${item.inputs['initial']}, \$${item.inputs['monthly']}/mo, ${item.inputs['rate']}%, ${item.inputs['term']}yr';
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
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.financialCalculationHistorys
          .filter()
          .idEqualTo(id)
          .deleteAll();
    });
  }

  static Future<void> clearHistory() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.financialCalculationHistorys.clear();
    });
  }

  // State management
  static Future<FinancialCalculatorState?> getCurrentState() async {
    final isar = IsarService.isar;
    return await isar.financialCalculatorStates.where().findFirst();
  }

  static Future<void> saveCurrentState(FinancialCalculatorState state) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.financialCalculatorStates.clear();
      await isar.financialCalculatorStates.put(state);
    });
  }

  static Future<void> clearCurrentState() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.financialCalculatorStates.clear();
    });
  }

  // Cache info for settings integration
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final isar = IsarService.isar;
      final history = await getHistory();
      final currentState = await getCurrentState();

      int historySize = 0;
      final historyItems =
          await isar.financialCalculationHistorys.where().findAll();
      for (final item in historyItems) {
        historySize += json.encode(item.toJson()).length;
      }

      int stateSize = 0;
      if (currentState != null) {
        stateSize = json.encode(currentState.toJson()).length;
      }

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
    required int frequency,
  }) {
    final n = frequency.toDouble();
    final r = rate / 100;

    final compoundAmount = principal * pow(1 + (r / n), n * time);
    final compoundInterestEarned = compoundAmount - principal;

    return CompoundInterestCalculationResult(
      compoundAmount: compoundAmount,
      compoundInterestEarned: compoundInterestEarned,
    );
  }
}
