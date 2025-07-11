import 'package:get/get.dart';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/calculator_services/date_calculator_service.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/services/calculator_services/calculator_tools_service.dart';
import 'package:setpocket/models/calculator_models/calculator_tools_data.dart';
import 'package:setpocket/services/settings_models_service.dart';

class DateCalculatorController extends GetxController {
  // --- UI State ---
  var activeTab = DateCalculationType.addSubtract.obs;
  var history = <UnifiedHistoryData>[].obs;
  var saveStateEnabled = true.obs;
  var historyEnabled = true.obs;
  final isDateConflict = false.obs;

  // --- Add/Subtract Tab State ---
  var startDate = DateTime.now().obs;
  var addSubtractYears = 0.obs;
  var addSubtractMonths = 0.obs;
  var addSubtractDays = 0.obs;
  var isAdding = true.obs;
  var addSubtractResultDate = ''.obs;
  var addSubtractResultDayOfWeek = ''.obs;

  // --- Difference Tab State ---
  var fromDate = DateTime.now().obs;
  var toDate = DateTime.now().add(const Duration(days: 1)).obs;
  var diffYears = 0.obs;
  var diffMonths = 0.obs;
  var diffDays = 0.obs;
  var diffTotalWeeks = 0.obs;
  var diffTotalDays = 0.obs;

  // --- Age Calculator Tab State ---
  var birthDate = DateTime(1990, 1, 1).obs;
  var currentAge = ''.obs;
  var nextBirthday = ''.obs;
  var daysUntilBirthday = 0.obs;
  var totalDaysLived = 0.obs;

  // --- Date Info Tab State ---
  var selectedDate = DateTime.now().obs;
  var dayOfWeek = ''.obs;
  var dayInMonth = 0.obs;
  var dayInYear = 0.obs;
  var weekInMonth = 0.obs;
  var weekInYear = 0.obs;
  var monthOfYear = ''.obs;
  var yearValue = 0.obs;
  var quarterOfYear = 0.obs;
  var isLeapYear = false.obs;
  var daysInMonth = 0.obs;
  var daysInYear = 0.obs;

  static const _toolId = CalculatorToolCodes.dateCalculator;

  @override
  void onInit() {
    super.onInit();
    _loadState();
    _loadHistory();
    checkDateConflict();
  }

  void onTabChanged(DateCalculationType newTab) {
    activeTab.value = newTab;
    calculate();
  }

  // --- Calculation ---
  void calculate() {
    switch (activeTab.value) {
      case DateCalculationType.addSubtract:
        _calculateAddSubtract();
        break;
      case DateCalculationType.difference:
        _calculateDifference();
        break;
      case DateCalculationType.age:
        _calculateAge();
        break;
      case DateCalculationType.dateInfo:
        _calculateDateInfo();
        break;
    }
    _saveState();
  }

  void _calculateAddSubtract() {
    final result = DateCalculatorService.calculateDate(
      startDate.value,
      addSubtractYears.value,
      addSubtractMonths.value,
      addSubtractDays.value,
      isAdding.value,
    );
    addSubtractResultDate.value =
        result.resultDate.toLocal().toString().split(' ')[0];
    addSubtractResultDayOfWeek.value =
        _getDayOfWeekName(result.resultDate.weekday);
  }

  void _calculateDifference() {
    final difference = toDate.value.difference(fromDate.value);
    diffTotalDays.value = difference.inDays;
    diffTotalWeeks.value = (difference.inDays / 7).floor();

    // Calculate difference in years, months, days
    int dYears = toDate.value.year - fromDate.value.year;
    int dMonths = toDate.value.month - fromDate.value.month;
    int dDays = toDate.value.day - fromDate.value.day;

    if (dDays < 0) {
      dMonths--;
      // Get the number of days in the previous month of toDate
      final daysInPrevMonth =
          DateTime(toDate.value.year, toDate.value.month, 0).day;
      dDays += daysInPrevMonth;
    }
    if (dMonths < 0) {
      dYears--;
      dMonths += 12;
    }

    diffYears.value = dYears;
    diffMonths.value = dMonths;
    diffDays.value = dDays;
  }

  void _calculateAge() {
    final now = DateTime.now();
    final age = now.difference(birthDate.value);

    // Calculate years, months, days
    var years = now.year - birthDate.value.year;
    var months = now.month - birthDate.value.month;
    var days = now.day - birthDate.value.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    currentAge.value = '$years years, $months months, $days days';
    totalDaysLived.value = age.inDays;

    // Calculate next birthday
    var nextBDay =
        DateTime(now.year, birthDate.value.month, birthDate.value.day);
    if (nextBDay.isBefore(now)) {
      nextBDay =
          DateTime(now.year + 1, birthDate.value.month, birthDate.value.day);
    }

    nextBirthday.value = nextBDay.toString().split(' ')[0];
    daysUntilBirthday.value = nextBDay.difference(now).inDays;
  }

  void _calculateDateInfo() {
    final date = selectedDate.value;

    // Basic info
    dayOfWeek.value = _getDayOfWeekName(date.weekday);
    dayInMonth.value = date.day;
    dayInYear.value = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    monthOfYear.value = _getMonthName(date.month);
    yearValue.value = date.year;
    quarterOfYear.value = ((date.month - 1) ~/ 3) + 1;

    // Advanced info
    isLeapYear.value = _isLeapYear(date.year);
    daysInMonth.value = DateTime(date.year, date.month + 1, 0).day;
    daysInYear.value = _isLeapYear(date.year) ? 366 : 365;

    // Week calculations
    weekInMonth.value = ((date.day - 1) ~/ 7) + 1;
    final firstDayOfYear = DateTime(date.year, 1, 1);
    weekInYear.value = ((date.difference(firstDayOfYear).inDays) ~/ 7) + 1;
  }

  String _getDayOfWeekName(int weekday) {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday];
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // --- State Management ---
  Future<void> _loadState() async {
    // Check if feature state saving is enabled
    final settings = await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) {
      // When state saving is disabled, don't load saved state (use defaults)
      return;
    }

    final state = await CalculatorToolsService.getToolState(_toolId);
    if (state != null) {
      try {
        // Add/Subtract state
        if (state.containsKey('startDate')) {
          startDate.value = DateTime.parse(state['startDate']);
        }
        addSubtractYears.value = state['addSubtractYears'] ?? 0;
        addSubtractMonths.value = state['addSubtractMonths'] ?? 0;
        addSubtractDays.value = state['addSubtractDays'] ?? 0;
        isAdding.value = state['isAdding'] ?? true;

        // Difference state
        if (state.containsKey('fromDate')) {
          fromDate.value = DateTime.parse(state['fromDate']);
        }
        if (state.containsKey('toDate')) {
          toDate.value = DateTime.parse(state['toDate']);
        }
        if (state.containsKey('diffYears')) {
          diffYears.value = state['diffYears'] ?? 0;
        }
        if (state.containsKey('diffMonths')) {
          diffMonths.value = state['diffMonths'] ?? 0;
        }
        if (state.containsKey('diffDays')) {
          diffDays.value = state['diffDays'] ?? 0;
        }
        if (state.containsKey('diffTotalWeeks')) {
          diffTotalWeeks.value = state['diffTotalWeeks'] ?? 0;
        }
        if (state.containsKey('diffTotalDays')) {
          diffTotalDays.value = state['diffTotalDays'] ?? 0;
        }

        // Age state
        if (state.containsKey('birthDate')) {
          birthDate.value = DateTime.parse(state['birthDate']);
        }

        // Date Info state
        if (state.containsKey('selectedDate')) {
          selectedDate.value = DateTime.parse(state['selectedDate']);
        }

        // Active tab
        if (state.containsKey('activeTab')) {
          final tabName = state['activeTab'];
          try {
            activeTab.value = DateCalculationType.values
                .firstWhere((e) => e.toString() == tabName);
          } catch (e) {
            activeTab.value = DateCalculationType.addSubtract;
          }
        }
      } catch (e) {
        // Ignore corrupted state
      }
    }
  }

  Future<void> _saveState() async {
    // Check if feature state saving is enabled
    final settings = await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return;

    final state = {
      'activeTab': activeTab.value.toString(),
      // Add/Subtract
      'startDate': startDate.value.toIso8601String(),
      'addSubtractYears': addSubtractYears.value,
      'addSubtractMonths': addSubtractMonths.value,
      'addSubtractDays': addSubtractDays.value,
      'isAdding': isAdding.value,
      // Difference
      'fromDate': fromDate.value.toIso8601String(),
      'toDate': toDate.value.toIso8601String(),
      // Age
      'birthDate': birthDate.value.toIso8601String(),
      // Date Info
      'selectedDate': selectedDate.value.toIso8601String(),
    };
    await CalculatorToolsService.saveToolState(_toolId, state);
  }

  // --- History Management ---
  Future<void> _loadHistory() async {
    history.value = await DateCalculatorService.getHistory();
  }

  Future<void> saveCurrentCalculationToHistory(AppLocalizations l10n) async {
    String title = activeTab.value.toString();
    String displayTitle;
    Map<String, dynamic> inputsData;
    Map<String, dynamic> resultsData;

    switch (activeTab.value) {
      case DateCalculationType.addSubtract:
        title = title;
        String postFix = _getAddSubtractPostFix(addSubtractYears.value, 'y') +
            _getAddSubtractPostFix(addSubtractMonths.value, 'm') +
            _getAddSubtractPostFix(addSubtractDays.value, 'd');
        displayTitle = '${startDate.value.toString().split(' ')[0]} $postFix';
        inputsData = {
          'startDate': startDate.value.toIso8601String(),
          'years': addSubtractYears.value,
          'months': addSubtractMonths.value,
          'days': addSubtractDays.value,
        };
        resultsData = {
          'resultDate': addSubtractResultDate.value,
          'dayOfWeek': addSubtractResultDayOfWeek.value,
        };
        break;
      case DateCalculationType.difference:
        title = title;
        displayTitle =
            '${fromDate.value.toString().split(' ')[0]} -> ${toDate.value.toString().split(' ')[0]}';
        inputsData = {
          'fromDate': fromDate.value.toIso8601String(),
          'toDate': toDate.value.toIso8601String(),
        };
        resultsData = {
          'years': diffYears.value,
          'months': diffMonths.value,
          'days': diffDays.value,
          'totalWeeks': diffTotalWeeks.value,
          'totalDays': diffTotalDays.value,
        };
        break;
      case DateCalculationType.age:
        title = title;
        displayTitle = birthDate.value.toString().split(' ')[0];
        inputsData = {
          'birthDate': birthDate.value.toIso8601String(),
        };
        resultsData = {
          'currentAge': currentAge.value,
          'totalDaysLived': totalDaysLived.value,
          'daysUntilBirthday': daysUntilBirthday.value,
          'nextBirthday': nextBirthday.value,
        };
        break;
      case DateCalculationType.dateInfo:
        title = title;
        displayTitle = selectedDate.value.toString().split(' ')[0];
        inputsData = {
          'selectedDate': selectedDate.value.toIso8601String(),
        };
        resultsData = {
          'dayOfWeek': dayOfWeek.value,
          'dayInMonth': dayInMonth.value,
          'dayInYear': dayInYear.value,
          'weekInMonth': weekInMonth.value,
          'weekInYear': weekInYear.value,
          'monthOfYear': monthOfYear.value,
          'year': yearValue.value,
          'quarter': quarterOfYear.value,
          'isLeapYear': isLeapYear.value,
          'daysInMonth': daysInMonth.value,
          'daysInYear': daysInYear.value,
        };
        break;
    }

    // Follow Financial Calculator format: embed inputsData and resultsData inside 'value' field
    final valueData = {
      'inputsData': inputsData,
      'resultsData': resultsData,
    };

    final newHistoryItem = UnifiedHistoryData(
      type: _toolId,
      title: title,
      value: jsonEncode(valueData), // Save as JSON string in value field
      timestamp: DateTime.now(),
      subType: activeTab.value.name,
      displayTitle: displayTitle,
    );

    await GenerationHistoryService.addHistoryItem(newHistoryItem);
    _loadHistory(); // Refresh history list
  }

  String _getAddSubtractPostFix(int value, String postFixChar) {
    if (value == 0) {
      return '';
    } else if (value > 0) {
      return ' +$value$postFixChar';
    } else {
      return ' $value$postFixChar';
    }
  }

  void checkDateConflict() {
    isDateConflict.value = !toDate.value.isAfter(fromDate.value);
  }

  void swapDifferenceDates() {
    final temp = fromDate.value;
    fromDate.value = toDate.value;
    toDate.value = temp;
    checkDateConflict();
  }

  Future<void> deleteHistoryItem(Id id) async {
    await GenerationHistoryService.deleteHistoryItem(id);
    _loadHistory();
  }

  Future<void> clearHistory() async {
    await DateCalculatorService.clearHistory();
    _loadHistory();
  }

  String getL10nNameFromTypeString(String typeString, AppLocalizations l10n) {
    switch (typeString) {
      case 'DateCalculationType.addSubtract':
        return l10n.addSubtractDate;
      case 'DateCalculationType.difference':
        return l10n.dateDifference;
      case 'DateCalculationType.age':
        return l10n.ageCalculator;
      case 'DateCalculationType.dateInfo':
        return l10n.dateInfo;
      default:
        return l10n.dateCalculator;
    }
  }

  // --- Utility Methods ---
  void clearCurrentTabData() async {
    switch (activeTab.value) {
      case DateCalculationType.addSubtract:
        startDate.value = DateTime.now();
        addSubtractYears.value = 0;
        addSubtractMonths.value = 0;
        addSubtractDays.value = 0;
        isAdding.value = true;
        addSubtractResultDate.value = '';
        addSubtractResultDayOfWeek.value = '';
        break;
      case DateCalculationType.difference:
        fromDate.value = DateTime.now();
        toDate.value = DateTime.now().add(const Duration(days: 1));
        diffYears.value = 0;
        diffMonths.value = 0;
        diffDays.value = 0;
        diffTotalWeeks.value = 0;
        diffTotalDays.value = 0;
        checkDateConflict();
        break;
      case DateCalculationType.age:
        birthDate.value = DateTime(1990, 1, 1);
        currentAge.value = '';
        nextBirthday.value = '';
        daysUntilBirthday.value = 0;
        totalDaysLived.value = 0;
        break;
      case DateCalculationType.dateInfo:
        selectedDate.value = DateTime.now();
        dayOfWeek.value = '';
        dayInMonth.value = 0;
        dayInYear.value = 0;
        weekInMonth.value = 0;
        weekInYear.value = 0;
        monthOfYear.value = '';
        yearValue.value = 0;
        quarterOfYear.value = 0;
        isLeapYear.value = false;
        daysInMonth.value = 0;
        daysInYear.value = 0;
        break;
    }
    calculate();
  }
}
