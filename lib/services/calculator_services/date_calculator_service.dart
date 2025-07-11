import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/services/generation_history_service.dart';

// --- Local Models ---
// These are defined locally because the old shared model file was deleted.
enum DateCalculationType {
  addSubtract,
  difference,
  age,
  dateInfo,
}

class DateCalculationResult {
  final DateTime resultDate;
  final String description;

  DateCalculationResult({required this.resultDate, required this.description});

  Map<String, dynamic> toJson() => {
        'resultDate': resultDate.toIso8601String(),
        'description': description,
      };
}
// --- Service ---

class DateCalculatorService {
  static const _toolId = 'date_calculator';

  // --- Calculation Logic ---

  static DateCalculationResult calculateDate(
      DateTime startDate, int years, int months, int days, bool isAdding) {
    int direction = isAdding ? 1 : -1;
    DateTime resultDate = DateTime(
      startDate.year + (direction * years),
      startDate.month + (direction * months),
      startDate.day + (direction * days),
    );
    String operation = isAdding ? "plus" : "minus";
    String description =
        "${DateFormat.yMd().format(startDate)} $operation $years years, $months months, $days days";
    return DateCalculationResult(
        resultDate: resultDate, description: description);
  }

  static String calculateDifference(DateTime fromDate, DateTime toDate) {
    Duration difference = toDate.difference(fromDate).abs();
    int years = toDate.year - fromDate.year;
    int months = toDate.month - fromDate.month;
    int days = toDate.day - fromDate.day;

    if (days < 0) {
      months--;
      // Approximate days in previous month
      days += DateTime(toDate.year, toDate.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final totalDays = difference.inDays;
    return "$years years, $months months, $days days (Total: $totalDays days)";
  }

  // --- History Management ---

  static Future<void> saveToHistory(String title, dynamic result) async {
    final historyItem = UnifiedHistoryData(
      type: _toolId,
      title: title,
      value: jsonEncode(result is DateCalculationResult
          ? result.toJson()
          : {'result': result}),
      timestamp: DateTime.now(),
    );
    await GenerationHistoryService.addHistoryItem(historyItem);
  }

  static Future<List<UnifiedHistoryData>> getHistory() async {
    return GenerationHistoryService.getHistory(_toolId);
  }

  static Future<void> clearHistory() async {
    return GenerationHistoryService.clearHistory(_toolId);
  }
}
