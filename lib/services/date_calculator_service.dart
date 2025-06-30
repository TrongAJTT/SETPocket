import 'dart:convert';
import 'package:setpocket/models/date_calculator_models.dart';
import 'package:setpocket/services/hive_service.dart';
import 'package:setpocket/services/calculator_history_service.dart';
import 'package:setpocket/services/graphing_calculator_service.dart';

class DateCalculatorService {
  static const String _historyBoxName = 'date_calculator_history';
  static const String _stateBoxName = 'date_calculator_state';
  static const String _stateKey = 'current_state';

  // History management
  Future<List<DateCalculationHistory>> getHistory(
      [DateCalculationType? type]) async {
    final historyEnabled = await GraphingCalculatorService.getRememberHistory();
    if (!historyEnabled) return [];

    try {
      final box = await HiveService.getBox(_historyBoxName);
      final List<DateCalculationHistory> history = [];

      for (var key in box.keys) {
        final data = box.get(key);
        if (data != null && data is Map) {
          try {
            final item = DateCalculationHistory.fromJson(
                Map<String, dynamic>.from(data));
            if (type == null || item.type == type) {
              history.add(item);
            }
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

  Future<void> saveToHistory(DateCalculationHistory item) async {
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
        'date',
      );

      // Keep only the latest 100 items
      await _cleanupHistory();
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  String _formatCalculationForHistory(DateCalculationHistory item) {
    switch (item.type) {
      case DateCalculationType.dateDifference:
        return 'Date Diff: ${_formatDate(DateTime.parse(item.inputs['startDate']))} - ${_formatDate(DateTime.parse(item.inputs['endDate']))}';
      case DateCalculationType.addSubtract:
        String operation = '';
        int years = item.inputs['years'] ?? 0;
        if (years != 0) operation += '${years > 0 ? "+" : ""}$years' 'Y ';

        int months = item.inputs['months'] ?? 0;
        if (months != 0) operation += '${months > 0 ? "+" : ""}$months' 'M ';

        int days = item.inputs['days'] ?? 0;
        if (days != 0) operation += '${days > 0 ? "+" : ""}$days' 'D';

        operation = operation.trim();
        if (operation.startsWith('+')) {
          operation = operation.substring(1);
        }

        return 'From ${_formatDate(DateTime.parse(item.inputs['baseDate']))}: $operation';
      case DateCalculationType.age:
        return 'Age at ${_formatDate(DateTime.now())}: Born ${_formatDate(DateTime.parse(item.inputs['birthDate']))}';
      case DateCalculationType.workingDays:
        return 'Working Days: ${_formatDate(DateTime.parse(item.inputs['startDate']))} - ${_formatDate(DateTime.parse(item.inputs['endDate']))}';
      case DateCalculationType.timezone:
        return 'Timezone: ${item.inputs['fromTimezone']} → ${item.inputs['toTimezone']}';
      case DateCalculationType.recurring:
        return 'Recurring: ${item.inputs['pattern']} from ${_formatDate(DateTime.parse(item.inputs['startDate']))}';
      case DateCalculationType.countdown:
        return 'Countdown to ${item.inputs['eventName']} from ${_formatDate(DateTime.now())}';
      case DateCalculationType.dateInfo:
        return 'Info for ${_formatDate(DateTime.parse(item.inputs['selectedDate']))}';
      case DateCalculationType.timeUnit:
        return 'Time Unit: ${item.inputs['value']} ${item.inputs['fromUnit']} → ${item.inputs['toUnit']}';
      case DateCalculationType.nthWeekday:
        return 'Nth Weekday: ${item.inputs['weekday']} #${item.inputs['occurrence']} in ${item.inputs['month']}/${item.inputs['year']}';
    }
  }

  String _formatResultForHistory(DateCalculationHistory item) {
    switch (item.type) {
      case DateCalculationType.dateDifference:
        return '${item.results['totalDays']} days (${item.results['years']}y ${item.results['months']}m ${item.results['days']}d)';
      case DateCalculationType.addSubtract:
        return item.results['resultDate'];
      case DateCalculationType.age:
        return '${item.results['years']}y ${item.results['months']}m ${item.results['days']}d';
      case DateCalculationType.workingDays:
        return '${item.results['workingDays']} working days';
      case DateCalculationType.timezone:
        return item.results['convertedDateTime'];
      case DateCalculationType.recurring:
        return '${item.results['dates'].length} dates generated';
      case DateCalculationType.countdown:
        return '${item.results['totalDays']} days remaining';
      case DateCalculationType.dateInfo:
        return 'Week ${item.results['weekInYear']}, Day ${item.results['dayInYear']}';
      case DateCalculationType.timeUnit:
        return '${item.results['convertedValue']} ${item.inputs['toUnit']}';
      case DateCalculationType.nthWeekday:
        return item.results['date'];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _cleanupHistory() async {
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

  Future<void> removeFromHistory(String id) async {
    try {
      final box = await HiveService.getBox(_historyBoxName);
      await box.delete(id);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> clearHistory([DateCalculationType? type]) async {
    try {
      if (type == null) {
        final box = await HiveService.getBox(_historyBoxName);
        await box.clear();
      } else {
        final history = await getHistory();
        final box = await HiveService.getBox(_historyBoxName);
        for (final item in history) {
          if (item.type == type) {
            await box.delete(item.id);
          }
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  // State management
  Future<DateCalculatorState?> getCurrentState() async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      final data = box.get(_stateKey);
      if (data != null && data is Map) {
        return DateCalculatorState.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      // Return null if error
    }
    return null;
  }

  Future<void> saveCurrentState(DateCalculatorState state) async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      await box.put(_stateKey, state.toJson());
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> clearCurrentState() async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      await box.delete(_stateKey);
    } catch (e) {
      // Silently fail
    }
  }

  // Cache info for settings integration
  Future<Map<String, dynamic>> getCacheInfo() async {
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

  Future<void> clearAllData() async {
    await clearHistory();
    await clearCurrentState();
  }

  // Calculation helpers
  Map<String, int> calculateDateDifference(
      DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate);
    final totalDays = difference.inDays;

    // Calculate simplified distance (years, months, days)
    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;
    int days = endDate.day - startDate.day;

    if (days < 0) {
      months--;
      days += DateTime(endDate.year, endDate.month, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    // For simplified display, if we have excess days that can form a month, convert them
    int simplifiedYears = years;
    int simplifiedMonths = months;
    int simplifiedDays = days;

    // Convert excess days to months (assuming 30 days = 1 month for display)
    if (simplifiedDays >= 30) {
      simplifiedMonths += simplifiedDays ~/ 30;
      simplifiedDays = simplifiedDays % 30;
    }

    // Convert excess months to years
    if (simplifiedMonths >= 12) {
      simplifiedYears += simplifiedMonths ~/ 12;
      simplifiedMonths = simplifiedMonths % 12;
    }

    return {
      'years': years,
      'months': months,
      'days': days,
      'simplifiedYears': simplifiedYears,
      'simplifiedMonths': simplifiedMonths,
      'simplifiedDays': simplifiedDays,
      'totalDays': totalDays,
      'totalWeeks': (totalDays / 7).round(),
      'totalMonths': (totalDays / 30).round(),
      'totalHours': difference.inHours,
      'totalMinutes': difference.inMinutes,
    };
  }

  Map<String, dynamic> calculateAddSubtractDate(
      DateTime baseDate, int years, int months, int days) {
    DateTime result = DateTime(
      baseDate.year + years,
      baseDate.month + months,
      baseDate.day,
    );
    result = result.add(Duration(days: days));

    return {
      'resultDate': result.toIso8601String(),
      'weekday': result.weekday,
    };
  }

  Map<String, dynamic> calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final diff = calculateDateDifference(birthDate, now);

    final nextBirthday = DateTime(
      now.year +
          (now.month > birthDate.month ||
                  (now.month == birthDate.month && now.day >= birthDate.day)
              ? 1
              : 0),
      birthDate.month,
      birthDate.day,
    );

    final daysUntilBirthday = nextBirthday.difference(now).inDays;

    return {
      'years': diff['years'],
      'months': diff['months'],
      'days': diff['days'],
      'totalDays': diff['totalDays'],
      'daysUntilBirthday': daysUntilBirthday,
      'nextBirthday': nextBirthday.toIso8601String(),
    };
  }

  int calculateWorkingDays(
    DateTime startDate,
    DateTime endDate, {
    List<int> excludedWeekdays = const [6, 7], // Saturday, Sunday
    List<DateTime> excludedDates = const [],
  }) {
    int workingDays = 0;
    DateTime current = startDate;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      // Check if it's not a weekend (or other excluded weekday)
      if (!excludedWeekdays.contains(current.weekday)) {
        // Check if it's not a custom excluded date
        if (!excludedDates.any((date) =>
            date.year == current.year &&
            date.month == current.month &&
            date.day == current.day)) {
          workingDays++;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return workingDays;
  }

  List<DateTime> generateRecurringDates(
    DateTime startDate,
    RecurringPattern pattern,
    int interval,
    int occurrences,
  ) {
    final List<DateTime> dates = [];
    DateTime current = startDate;

    for (int i = 0; i < occurrences; i++) {
      dates.add(current);

      switch (pattern) {
        case RecurringPattern.daily:
          current = current.add(Duration(days: interval));
          break;
        case RecurringPattern.weekly:
          current = current.add(Duration(days: 7 * interval));
          break;
        case RecurringPattern.monthly:
          current = DateTime(
            current.year,
            current.month + interval,
            current.day,
          );
          break;
        case RecurringPattern.yearly:
          current = DateTime(
            current.year + interval,
            current.month,
            current.day,
          );
          break;
      }
    }

    return dates;
  }

  Map<String, dynamic> calculateCountdown(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    final days = (difference.inDays % 365) % 30;

    return {
      'totalDays': difference.inDays,
      'totalHours': difference.inHours,
      'totalMinutes': difference.inMinutes,
      'totalSeconds': difference.inSeconds,
      'years': years,
      'months': months,
      'days': days,
      'hours': difference.inHours % 24,
      'minutes': difference.inMinutes % 60,
      'seconds': difference.inSeconds % 60,
      'isExpired': difference.isNegative,
    };
  }

  int getWeekNumber(DateTime date) {
    // ISO 8601 week numbering
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday =
        startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));

    if (date.isBefore(firstMonday)) {
      // Date is in the last week of previous year
      return getWeekNumber(DateTime(date.year - 1, 12, 31));
    }

    final daysSinceFirstMonday = date.difference(firstMonday).inDays;
    return (daysSinceFirstMonday / 7).floor() + 1;
  }

  int getDayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  double convertTimeUnit(double value, TimeUnit fromUnit, TimeUnit toUnit) {
    // Convert to seconds first
    double seconds;
    switch (fromUnit) {
      case TimeUnit.seconds:
        seconds = value;
        break;
      case TimeUnit.minutes:
        seconds = value * 60;
        break;
      case TimeUnit.hours:
        seconds = value * 3600;
        break;
      case TimeUnit.days:
        seconds = value * 86400;
        break;
      case TimeUnit.weeks:
        seconds = value * 604800;
        break;
      case TimeUnit.months:
        seconds = value * 2629746; // Average month
        break;
      case TimeUnit.years:
        seconds = value * 31556952; // Average year
        break;
    }

    // Convert from seconds to target unit
    switch (toUnit) {
      case TimeUnit.seconds:
        return seconds;
      case TimeUnit.minutes:
        return seconds / 60;
      case TimeUnit.hours:
        return seconds / 3600;
      case TimeUnit.days:
        return seconds / 86400;
      case TimeUnit.weeks:
        return seconds / 604800;
      case TimeUnit.months:
        return seconds / 2629746; // Average month
      case TimeUnit.years:
        return seconds / 31556952; // Average year
    }
  }

  DateTime? findNthWeekdayInMonth(
      int year, int month, int weekday, int occurrence) {
    // weekday: 1=Monday, 7=Sunday
    // occurrence: 1=first, 2=second, etc., -1=last, -2=second to last, etc.

    if (occurrence == 0) return null;

    if (occurrence > 0) {
      // Find the nth occurrence from the beginning
      final firstDayOfMonth = DateTime(year, month, 1);
      final firstWeekdayOfMonth = firstDayOfMonth
          .add(Duration(days: (weekday - firstDayOfMonth.weekday + 7) % 7));

      final targetDate =
          firstWeekdayOfMonth.add(Duration(days: 7 * (occurrence - 1)));

      // Check if the date is still in the same month
      if (targetDate.month == month) {
        return targetDate;
      }
      return null;
    } else {
      // Find the nth occurrence from the end
      final lastDayOfMonth = DateTime(year, month + 1, 0);
      final lastWeekdayOfMonth = lastDayOfMonth
          .subtract(Duration(days: (lastDayOfMonth.weekday - weekday + 7) % 7));

      final targetDate =
          lastWeekdayOfMonth.add(Duration(days: 7 * (occurrence + 1)));

      // Check if the date is still in the same month
      if (targetDate.month == month) {
        return targetDate;
      }
      return null;
    }
  }

  Map<String, dynamic> calculateDateInfo(DateTime date) {
    // Ngày trong tuần (1=Monday, 7=Sunday)
    final weekday = date.weekday;

    // Ngày trong tháng (1-31)
    final dayInMonth = date.day;

    // Ngày trong năm (1-365/366)
    final dayInYear = getDayOfYear(date);

    // Tuần trong năm (ISO 8601)
    final weekInYear = getWeekNumber(date);

    // Tuần trong tháng (1-6)
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final weekInMonth = ((date.day - 1 + firstDayOfMonth.weekday - 1) ~/ 7) + 1;

    // Tháng hiện tại
    final month = date.month;

    // Năm hiện tại
    final year = date.year;

    // Kiểm tra năm nhuận
    final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

    // Số ngày trong tháng
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Số ngày trong năm
    final daysInYear = isLeapYear ? 366 : 365;

    return {
      'weekday': weekday,
      'dayInMonth': dayInMonth,
      'dayInYear': dayInYear,
      'weekInMonth': weekInMonth,
      'weekInYear': weekInYear,
      'month': month,
      'year': year,
      'isLeapYear': isLeapYear,
      'daysInMonth': daysInMonth,
      'daysInYear': daysInYear,
      'quarter': ((month - 1) ~/ 3) + 1,
    };
  }

  Future<DateCalculationHistory?> createHistoryItem(
    DateCalculationType type,
    Map<String, dynamic> data, {
    dynamic l10n,
  }) async {
    final state = DateCalculatorState.fromJson(data['state']);
    final result = data['result'];

    if (result == null) return null;

    final inputs = _getInputsFromState(type, state);
    final displayTitle = _getDisplayTitle(type, state, l10n);

    return DateCalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      displayTitle: displayTitle,
      inputs: inputs,
      results: Map<String, dynamic>.from(result),
      timestamp: DateTime.now(),
    );
  }

  String _getDisplayTitle(
      DateCalculationType type, DateCalculatorState state, dynamic l10n) {
    // This is a simplified version. In a real app, you'd use l10n.
    // For a real implementation, you'd pass the BuildContext and use it to format dates.
    // For now, we'll use a simple format.
    String formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

    switch (type) {
      case DateCalculationType.addSubtract:
        final addSubtractState =
            AddSubtractState.fromJson(state.tabStates['addSubtract']!);
        String operation = '';
        int years = addSubtractState.years;
        if (years != 0) operation += '${years > 0 ? "+" : ""}$years' 'Y ';
        int months = addSubtractState.months;
        if (months != 0) operation += '${months > 0 ? "+" : ""}$months' 'M ';
        int days = addSubtractState.days;
        if (days != 0) operation += '${days > 0 ? "+" : ""}$days' 'D';

        operation = operation.trim();
        if (operation.startsWith('+')) {
          operation = operation.substring(1);
        }
        return 'From ${formatDate(addSubtractState.baseDate)}: $operation';
      // Other cases would be handled here
      default:
        // You can create more detailed titles for other types here
        return 'Calculation Result';
    }
  }

  Map<String, dynamic> _getInputsFromState(
      DateCalculationType type, DateCalculatorState state) {
    switch (type) {
      case DateCalculationType.addSubtract:
        return state.tabStates['addSubtract']!;
      // Other cases
      default:
        return {};
    }
  }
}
