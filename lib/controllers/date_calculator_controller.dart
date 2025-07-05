import 'package:flutter/material.dart';
import 'package:setpocket/models/date_calculator_models.dart';
import 'package:setpocket/services/date_calculator_service.dart';
import 'dart:math' as math;

class DateCalculatorController with ChangeNotifier {
  final DateCalculatorService _dateCalculatorService;
  DateCalculationType activeTab = DateCalculationType.dateInfo;

  // Tab states
  late DateDifferenceState _dateDifferenceState;
  late AddSubtractState _addSubtractState;
  late AgeCalculatorState _ageState;
  late WorkingDaysState _workingDaysState;
  late TimezoneState _timezoneState;
  late RecurringDatesState _recurringState;
  late CountdownState _countdownState;
  late TimeUnitState _timeUnitState;
  late DateInfoState _dateInfoState;

  // Additional states for simpler tabs
  int _nthWeekdayYear = DateTime.now().year;
  int _nthWeekdayMonth = DateTime.now().month;
  int _nthWeekdayWeekday = 1; // Monday
  int _nthWeekdayOccurrence = 1; // First

  // Results
  Map<String, dynamic>? _currentResult;
  Map<String, dynamic>? get currentResult => _currentResult;

  // History
  List<DateCalculationHistory> _history = [];
  List<DateCalculationHistory> get history => _history;

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCalculating = false;
  bool get isCalculating => _isCalculating;

  bool _isDataConstraintEnabled = false;

  // State getters
  DateDifferenceState get dateDifferenceState => _dateDifferenceState;
  AddSubtractState get addSubtractState => _addSubtractState;
  AgeCalculatorState get ageState => _ageState;
  WorkingDaysState get workingDaysState => _workingDaysState;
  TimezoneState get timezoneState => _timezoneState;
  RecurringDatesState get recurringState => _recurringState;
  CountdownState get countdownState => _countdownState;
  TimeUnitState get timeUnitState => _timeUnitState;
  DateInfoState get dateInfoState => _dateInfoState;
  int get nthWeekdayYear => _nthWeekdayYear;
  int get nthWeekdayMonth => _nthWeekdayMonth;
  int get nthWeekdayWeekday => _nthWeekdayWeekday;
  int get nthWeekdayOccurrence => _nthWeekdayOccurrence;
  bool get isDataConstraintEnabled => _isDataConstraintEnabled;

  DateCalculatorController(
      {required DateCalculatorService dateCalculatorService})
      : _dateCalculatorService = dateCalculatorService {
    _initializeStates();
    _loadState();
    _loadHistory();
  }

  void _initializeStates() {
    final now = DateTime.now();

    _dateDifferenceState = DateDifferenceState(
      startDate: now,
      endDate: now.add(const Duration(days: 30)),
    );

    _addSubtractState = AddSubtractState(
      baseDate: now,
      years: 0,
      months: 0,
      days: 0,
    );

    _ageState = AgeCalculatorState(
      birthDate: now.subtract(const Duration(days: 365 * 25)),
    );

    _workingDaysState = WorkingDaysState(
      startDate: now,
      endDate: now.add(const Duration(days: 30)),
    );

    _timezoneState = TimezoneState(
      dateTime: now,
      fromTimezone: 'UTC',
      toTimezone: 'UTC',
    );

    _recurringState = RecurringDatesState(
      startDate: now,
      pattern: RecurringPattern.weekly,
    );

    _countdownState = CountdownState(
      targetDate: now.add(const Duration(days: 365)),
      eventName: 'New Year',
    );

    _timeUnitState = TimeUnitState(
      value: 1.0,
      fromUnit: TimeUnit.hours,
      toUnit: TimeUnit.minutes,
    );

    _dateInfoState = DateInfoState(
      selectedDate: now,
    );
  }

  void _loadState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final state = await _dateCalculatorService.getCurrentState();
      if (state != null) {
        activeTab = state.activeTab;

        // Load individual tab states
        if (state.tabStates.containsKey('dateDifference')) {
          _dateDifferenceState = DateDifferenceState.fromJson(
              Map<String, dynamic>.from(state.tabStates['dateDifference']));
        }

        if (state.tabStates.containsKey('addSubtract')) {
          _addSubtractState = AddSubtractState.fromJson(
              Map<String, dynamic>.from(state.tabStates['addSubtract']));
        }

        if (state.tabStates.containsKey('age')) {
          _ageState = AgeCalculatorState.fromJson(
              Map<String, dynamic>.from(state.tabStates['age']));
        }

        if (state.tabStates.containsKey('workingDays')) {
          _workingDaysState = WorkingDaysState.fromJson(
              Map<String, dynamic>.from(state.tabStates['workingDays']));
        }

        if (state.tabStates.containsKey('timezone')) {
          _timezoneState = TimezoneState.fromJson(
              Map<String, dynamic>.from(state.tabStates['timezone']));
        }

        if (state.tabStates.containsKey('recurring')) {
          _recurringState = RecurringDatesState.fromJson(
              Map<String, dynamic>.from(state.tabStates['recurring']));
        }

        if (state.tabStates.containsKey('countdown')) {
          _countdownState = CountdownState.fromJson(
              Map<String, dynamic>.from(state.tabStates['countdown']));
        }

        if (state.tabStates.containsKey('timeUnit')) {
          _timeUnitState = TimeUnitState.fromJson(
              Map<String, dynamic>.from(state.tabStates['timeUnit']));
        }

        // Load simple states
        if (state.tabStates.containsKey('dateInfo')) {
          _dateInfoState = DateInfoState.fromJson(
              Map<String, dynamic>.from(state.tabStates['dateInfo']));
        }

        if (state.tabStates.containsKey('nthWeekday')) {
          final nthData =
              Map<String, dynamic>.from(state.tabStates['nthWeekday']);
          _nthWeekdayYear = nthData['year'] ?? DateTime.now().year;
          _nthWeekdayMonth = nthData['month'] ?? DateTime.now().month;
          _nthWeekdayWeekday = nthData['weekday'] ?? 1;
          _nthWeekdayOccurrence = nthData['occurrence'] ?? 1;
        }

        _isDataConstraintEnabled = state.isDataConstraintEnabled;
      }
    } catch (e) {
      // Handle error silently
    }

    _isLoading = false;
    notifyListeners();

    // Calculate initial result for current tab
    await calculate();
  }

  void _loadHistory() async {
    try {
      _history = await _dateCalculatorService.getHistory();
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  // Tab management
  void setActiveTab(DateCalculationType tab) {
    if (activeTab != tab) {
      activeTab = tab;
      notifyListeners();
      _saveState();
      calculate();
    }
  }

  // State setters
  void updateDateDifferenceState({DateTime? startDate, DateTime? endDate}) {
    _dateDifferenceState = DateDifferenceState(
      startDate: startDate ?? _dateDifferenceState.startDate,
      endDate: endDate ?? _dateDifferenceState.endDate,
    );
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.dateDifference) {
      calculate();
    }
  }

  void updateAddSubtractState({
    DateTime? baseDate,
    int? years,
    int? months,
    int? days,
  }) {
    _addSubtractState = AddSubtractState(
      baseDate: baseDate ?? _addSubtractState.baseDate,
      years: years ?? _addSubtractState.years,
      months: months ?? _addSubtractState.months,
      days: days ?? _addSubtractState.days,
    );

    if (_isDataConstraintEnabled) {
      _normalizeAddSubtractState();
    }

    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.addSubtract) {
      calculate();
    }
  }

  void updateAgeState({DateTime? birthDate}) {
    _ageState = AgeCalculatorState(
      birthDate: birthDate ?? _ageState.birthDate,
    );
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.age) {
      calculate();
    }
  }

  void updateWorkingDaysState({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? excludedWeekdays,
    List<DateTime>? excludedDates,
  }) {
    _workingDaysState = WorkingDaysState(
      startDate: startDate ?? _workingDaysState.startDate,
      endDate: endDate ?? _workingDaysState.endDate,
      excludedWeekdays: excludedWeekdays ?? _workingDaysState.excludedWeekdays,
      excludedDates: excludedDates ?? _workingDaysState.excludedDates,
    );
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.workingDays) {
      calculate();
    }
  }

  void updateTimezoneState({
    DateTime? dateTime,
    String? fromTimezone,
    String? toTimezone,
  }) {
    _timezoneState = TimezoneState(
      dateTime: dateTime ?? _timezoneState.dateTime,
      fromTimezone: fromTimezone ?? _timezoneState.fromTimezone,
      toTimezone: toTimezone ?? _timezoneState.toTimezone,
    );
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.timezone) {
      calculate();
    }
  }

  void updateRecurringState({
    DateTime? startDate,
    RecurringPattern? pattern,
    int? interval,
    int? occurrences,
  }) {
    _recurringState = RecurringDatesState(
      startDate: startDate ?? _recurringState.startDate,
      pattern: pattern ?? _recurringState.pattern,
      interval: interval ?? _recurringState.interval,
      occurrences: occurrences ?? _recurringState.occurrences,
    );
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.recurring) {
      calculate();
    }
  }

  void updateCountdownState({
    DateTime? targetDate,
    String? eventName,
  }) {
    _countdownState = CountdownState(
      targetDate: targetDate ?? _countdownState.targetDate,
      eventName: eventName ?? _countdownState.eventName,
    );
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.countdown) {
      calculate();
    }
  }

  void updateTimeUnitState({
    double? value,
    TimeUnit? fromUnit,
    TimeUnit? toUnit,
  }) {
    _timeUnitState = TimeUnitState(
      value: value ?? _timeUnitState.value,
      fromUnit: fromUnit ?? _timeUnitState.fromUnit,
      toUnit: toUnit ?? _timeUnitState.toUnit,
    );
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.timeUnit) {
      calculate();
    }
  }

  void updateDateInfo(DateTime date) {
    _dateInfoState = DateInfoState(selectedDate: date);
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.dateInfo) {
      calculate();
    }
  }

  void updateNthWeekdayState({
    int? year,
    int? month,
    int? weekday,
    int? occurrence,
  }) {
    _nthWeekdayYear = year ?? _nthWeekdayYear;
    _nthWeekdayMonth = month ?? _nthWeekdayMonth;
    _nthWeekdayWeekday = weekday ?? _nthWeekdayWeekday;
    _nthWeekdayOccurrence = occurrence ?? _nthWeekdayOccurrence;
    notifyListeners();
    _saveState();
    if (activeTab == DateCalculationType.nthWeekday) {
      calculate();
    }
  }

  void setDataConstraint(bool enabled) {
    if (_isDataConstraintEnabled != enabled) {
      _isDataConstraintEnabled = enabled;
      if (enabled) {
        _normalizeAddSubtractState();
      }
      notifyListeners();
      _saveState();
    }
  }

  void _normalizeAddSubtractState() {
    if (!_isDataConstraintEnabled) return;

    int y = _addSubtractState.years;
    int m = _addSubtractState.months;
    int d = _addSubtractState.days;

    // Normalize for increment (carry over)
    if (d > 30) {
      m += (d / 31).floor();
      d %= 31;
    }
    if (m > 11) {
      y += (m / 12).floor();
      m %= 12;
    }

    // Normalize for decrement (borrow)
    if (d < 0) {
      int monthsToBorrow = ((-d - 1) / 31).floor() + 1;
      m -= monthsToBorrow;
      d += monthsToBorrow * 31;
    }
    if (m < 0) {
      int yearsToBorrow = ((-m - 1) / 12).floor() + 1;
      y -= yearsToBorrow;
      m += yearsToBorrow * 12;
    }

    // Recursively normalize in case borrowing from months made it negative
    if (m < 0) {
      _normalizeAddSubtractState();
    }

    if (y != _addSubtractState.years ||
        m != _addSubtractState.months ||
        d != _addSubtractState.days) {
      _addSubtractState = AddSubtractState(
        baseDate: _addSubtractState.baseDate,
        years: y,
        months: m,
        days: d,
      );
    }
  }

  // Calculation
  Future<void> calculate() async {
    if (_isCalculating) return;

    _isCalculating = true;
    notifyListeners();

    try {
      switch (activeTab) {
        case DateCalculationType.dateDifference:
          _currentResult = _dateCalculatorService.calculateDateDifference(
            _dateDifferenceState.startDate,
            _dateDifferenceState.endDate,
          );
          break;

        case DateCalculationType.addSubtract:
          _currentResult = _dateCalculatorService.calculateAddSubtractDate(
            _addSubtractState.baseDate,
            _addSubtractState.years,
            _addSubtractState.months,
            _addSubtractState.days,
          );
          break;

        case DateCalculationType.age:
          final ageResult =
              _dateCalculatorService.calculateAge(_ageState.birthDate);
          _currentResult = ageResult;
          break;

        case DateCalculationType.workingDays:
          final workingDays = _dateCalculatorService.calculateWorkingDays(
            _workingDaysState.startDate,
            _workingDaysState.endDate,
            excludedWeekdays: _workingDaysState.excludedWeekdays,
            excludedDates: _workingDaysState.excludedDates,
          );
          _currentResult = {'workingDays': workingDays};
          break;

        case DateCalculationType.timezone:
          // For now, just return the same time (would need timezone library for real conversion)
          _currentResult = {
            'convertedDateTime': _timezoneState.dateTime.toIso8601String(),
          };
          break;

        case DateCalculationType.recurring:
          final dates = _dateCalculatorService.generateRecurringDates(
            _recurringState.startDate,
            _recurringState.pattern,
            _recurringState.interval,
            _recurringState.occurrences,
          );
          _currentResult = {
            'dates': dates.map((d) => d.toIso8601String()).toList(),
          };
          break;

        case DateCalculationType.countdown:
          _currentResult = _dateCalculatorService
              .calculateCountdown(_countdownState.targetDate);
          break;

        case DateCalculationType.dateInfo:
          _currentResult = _dateCalculatorService
              .calculateDateInfo(_dateInfoState.selectedDate);
          break;

        case DateCalculationType.timeUnit:
          final converted = _dateCalculatorService.convertTimeUnit(
            _timeUnitState.value,
            _timeUnitState.fromUnit,
            _timeUnitState.toUnit,
          );
          _currentResult = {'convertedValue': converted};
          break;

        case DateCalculationType.nthWeekday:
          final date = _dateCalculatorService.findNthWeekdayInMonth(
            _nthWeekdayYear,
            _nthWeekdayMonth,
            _nthWeekdayWeekday,
            _nthWeekdayOccurrence,
          );
          _currentResult = {
            'date': date?.toIso8601String(),
            'found': date != null,
          };
          break;
      }
    } catch (e) {
      _currentResult = {'error': e.toString()};
    }

    _isCalculating = false;
    notifyListeners();

    _saveState();
  }

  void _saveState() {
    final state = DateCalculatorState.fromData(
      activeTab: activeTab,
      tabStates: {
        'dateDifference': _dateDifferenceState.toJson(),
        'addSubtract': _addSubtractState.toJson(),
        'age': _ageState.toJson(),
        'workingDays': _workingDaysState.toJson(),
        'timezone': _timezoneState.toJson(),
        'recurring': _recurringState.toJson(),
        'countdown': _countdownState.toJson(),
        'timeUnit': _timeUnitState.toJson(),
        'dateInfo': _dateInfoState.toJson(),
        'nthWeekday': {
          'year': _nthWeekdayYear,
          'month': _nthWeekdayMonth,
          'weekday': _nthWeekdayWeekday,
          'occurrence': _nthWeekdayOccurrence,
        },
      },
      lastUpdated: DateTime.now(),
      isDataConstraintEnabled: _isDataConstraintEnabled,
    );
    _dateCalculatorService.saveCurrentState(state);
  }

  String _generateId() {
    // Simple ID generation
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(1000);
    return '${timestamp}_$random';
  }

  Map<String, dynamic> _getInputsForCurrentTab() {
    switch (activeTab) {
      case DateCalculationType.dateDifference:
        return {
          'startDate': _dateDifferenceState.startDate.toIso8601String(),
          'endDate': _dateDifferenceState.endDate.toIso8601String(),
        };
      case DateCalculationType.addSubtract:
        return {
          'baseDate': _addSubtractState.baseDate.toIso8601String(),
          'years': _addSubtractState.years,
          'months': _addSubtractState.months,
          'days': _addSubtractState.days,
        };
      case DateCalculationType.age:
        return {
          'birthDate': _ageState.birthDate.toIso8601String(),
        };
      case DateCalculationType.workingDays:
        return {
          'startDate': _workingDaysState.startDate.toIso8601String(),
          'endDate': _workingDaysState.endDate.toIso8601String(),
          'excludedWeekdays': _workingDaysState.excludedWeekdays,
          'excludedDates': _workingDaysState.excludedDates
              .map((d) => d.toIso8601String())
              .toList(),
        };
      case DateCalculationType.timezone:
        return {
          'dateTime': _timezoneState.dateTime.toIso8601String(),
          'fromTimezone': _timezoneState.fromTimezone,
          'toTimezone': _timezoneState.toTimezone,
        };
      case DateCalculationType.recurring:
        return {
          'startDate': _recurringState.startDate.toIso8601String(),
          'pattern': _recurringState.pattern.name,
          'interval': _recurringState.interval,
          'occurrences': _recurringState.occurrences,
        };
      case DateCalculationType.countdown:
        return {
          'targetDate': _countdownState.targetDate.toIso8601String(),
          'eventName': _countdownState.eventName,
        };
      case DateCalculationType.dateInfo:
        return {
          'selectedDate': _dateInfoState.selectedDate.toIso8601String(),
        };
      case DateCalculationType.timeUnit:
        return {
          'value': _timeUnitState.value,
          'fromUnit': _timeUnitState.fromUnit.name,
          'toUnit': _timeUnitState.toUnit.name,
        };
      case DateCalculationType.nthWeekday:
        return {
          'year': _nthWeekdayYear,
          'month': _nthWeekdayMonth,
          'weekday': _nthWeekdayWeekday,
          'occurrence': _nthWeekdayOccurrence,
        };
    }
  }

  String _getDisplayTitleForCurrentTab() {
    String formatDate(DateTime date) =>
        '${date.day}/${date.month}/${date.year}';

    switch (activeTab) {
      case DateCalculationType.dateDifference:
        final startDate = _dateDifferenceState.startDate;
        final endDate = _dateDifferenceState.endDate;
        return 'Diff: ${formatDate(startDate)} → ${formatDate(endDate)}';

      case DateCalculationType.addSubtract:
        final state = _addSubtractState;
        String operation = '';
        if (state.years != 0) {
          operation += '${state.years > 0 ? "+" : ""}${state.years}Y ';
        }
        if (state.months != 0) {
          operation += '${state.months > 0 ? "+" : ""}${state.months}M ';
        }
        if (state.days != 0) {
          operation += '${state.days > 0 ? "+" : ""}${state.days}D';
        }
        operation = operation.trim();
        if (operation.startsWith('+')) operation = operation.substring(1);
        if (operation.isEmpty) operation = 'No change';

        return 'From ${formatDate(state.baseDate)}: $operation';

      case DateCalculationType.age:
        return 'Age since ${formatDate(_ageState.birthDate)}';

      case DateCalculationType.dateInfo:
        return 'Info for ${formatDate(_dateInfoState.selectedDate)}';

      // Other cases can be simple strings
      case DateCalculationType.workingDays:
        return 'Working Days';
      case DateCalculationType.timezone:
        return 'Timezone Conversion';
      case DateCalculationType.recurring:
        return 'Recurring Dates';
      case DateCalculationType.countdown:
        return 'Countdown';
      case DateCalculationType.timeUnit:
        return 'Time Unit Conversion';
      case DateCalculationType.nthWeekday:
        return 'Nth Weekday';
    }
  }

  Future<void> removeFromHistory(String id) async {
    await _dateCalculatorService.removeFromHistory(id);
    _loadHistory();
  }

  Future<void> clearHistory() async {
    await _dateCalculatorService.clearHistory();
    _loadHistory();
  }

  Future<void> clearCurrentTabData() async {
    switch (activeTab) {
      case DateCalculationType.dateDifference:
        _dateDifferenceState = DateDifferenceState(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        );
        break;
      case DateCalculationType.addSubtract:
        _addSubtractState = AddSubtractState(
          baseDate: DateTime.now(),
          years: 0,
          months: 0,
          days: 0,
        );
        break;
      case DateCalculationType.age:
        _ageState = AgeCalculatorState(
          birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
        );
        break;
      case DateCalculationType.workingDays:
        _workingDaysState = WorkingDaysState(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        );
        break;
      case DateCalculationType.timezone:
        _timezoneState = TimezoneState(
          dateTime: DateTime.now(),
          fromTimezone: 'UTC',
          toTimezone: 'UTC',
        );
        break;
      case DateCalculationType.recurring:
        _recurringState = RecurringDatesState(
          startDate: DateTime.now(),
          pattern: RecurringPattern.weekly,
        );
        break;
      case DateCalculationType.countdown:
        _countdownState = CountdownState(
          targetDate: DateTime.now().add(const Duration(days: 365)),
          eventName: 'New Year',
        );
        break;
      case DateCalculationType.dateInfo:
        _dateInfoState = DateInfoState(selectedDate: DateTime.now());
        break;
      case DateCalculationType.timeUnit:
        _timeUnitState = TimeUnitState(
          value: 1.0,
          fromUnit: TimeUnit.hours,
          toUnit: TimeUnit.minutes,
        );
        break;
      case DateCalculationType.nthWeekday:
        final now = DateTime.now();
        _nthWeekdayYear = now.year;
        _nthWeekdayMonth = now.month;
        _nthWeekdayWeekday = 1;
        _nthWeekdayOccurrence = 1;
        break;
    }

    _currentResult = null;
    notifyListeners();
    _saveState();
    await calculate();
  }

  void loadFromHistory(DateCalculationHistory item) {
    // Set active tab first
    setActiveTab(item.type);

    // Load the inputs based on type
    final inputs = item.inputs;

    switch (item.type) {
      case DateCalculationType.dateInfo:
        if (inputs.containsKey('selectedDate')) {
          final selectedDate = DateTime.parse(inputs['selectedDate']);
          updateDateInfo(selectedDate);
        }
        break;
      case DateCalculationType.dateDifference:
        if (inputs.containsKey('startDate') && inputs.containsKey('endDate')) {
          final startDate = DateTime.parse(inputs['startDate']);
          final endDate = DateTime.parse(inputs['endDate']);
          updateDateDifferenceState(startDate: startDate, endDate: endDate);
        }
        break;
      case DateCalculationType.addSubtract:
        if (inputs.containsKey('baseDate')) {
          final baseDate = DateTime.parse(inputs['baseDate']);
          final years = inputs['years'] ?? 0;
          final months = inputs['months'] ?? 0;
          final days = inputs['days'] ?? 0;
          updateAddSubtractState(
            baseDate: baseDate,
            years: years,
            months: months,
            days: days,
          );
        }
        break;
      case DateCalculationType.age:
        if (inputs.containsKey('birthDate')) {
          final birthDate = DateTime.parse(inputs['birthDate']);
          updateAgeState(birthDate: birthDate);
        }
        break;
      // Add other cases as needed
      default:
        break;
    }
  }

  Future<void> saveToHistory() async {
    if (_currentResult == null || _currentResult!.containsKey('error')) return;

    final historyItem = DateCalculationHistory.fromData(
      id: _generateId(),
      type: activeTab,
      timestamp: DateTime.now(),
      inputs: _getInputsForCurrentTab(),
      results: _currentResult!,
      displayTitle: _getDisplayTitleForCurrentTab(),
    );

    await _dateCalculatorService.saveToHistory(historyItem);
    _loadHistory();
  }
}
