enum DateCalculationType {
  dateDifference,
  addSubtract,
  age,
  workingDays,
  timezone,
  recurring,
  countdown,
  dateInfo,
  timeUnit,
  nthWeekday,
}

enum TimeUnit {
  seconds,
  minutes,
  hours,
  days,
  weeks,
  months,
  years,
}

enum RecurringPattern {
  daily,
  weekly,
  monthly,
  yearly,
}

class DateCalculationHistory {
  final String id;
  final DateCalculationType type;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> results;
  final DateTime timestamp;
  final String displayTitle;

  DateCalculationHistory({
    required this.id,
    required this.type,
    required this.inputs,
    required this.results,
    required this.timestamp,
    required this.displayTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'inputs': inputs,
      'results': results,
      'timestamp': timestamp.toIso8601String(),
      'displayTitle': displayTitle,
    };
  }

  factory DateCalculationHistory.fromJson(Map<String, dynamic> json) {
    return DateCalculationHistory(
      id: json['id'] ?? '',
      type: DateCalculationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DateCalculationType.dateDifference,
      ),
      inputs: Map<String, dynamic>.from(json['inputs'] ?? {}),
      results: Map<String, dynamic>.from(json['results'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      displayTitle: json['displayTitle'] ?? '',
    );
  }
}

class DateCalculatorState {
  final DateCalculationType activeTab;
  final Map<String, dynamic> tabStates;
  final DateTime lastUpdated;
  final bool isDataConstraintEnabled;

  DateCalculatorState({
    required this.activeTab,
    required this.tabStates,
    required this.lastUpdated,
    this.isDataConstraintEnabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'activeTab': activeTab.name,
      'tabStates': tabStates,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isDataConstraintEnabled': isDataConstraintEnabled,
    };
  }

  factory DateCalculatorState.fromJson(Map<String, dynamic> json) {
    return DateCalculatorState(
      activeTab: DateCalculationType.values.firstWhere(
        (e) => e.name == json['activeTab'],
        orElse: () => DateCalculationType.dateInfo,
      ),
      tabStates: Map<String, dynamic>.from(json['tabStates'] ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isDataConstraintEnabled: json['isDataConstraintEnabled'] ?? false,
    );
  }
}

// Specific state models for each tab
class DateDifferenceState {
  final DateTime startDate;
  final DateTime endDate;

  DateDifferenceState({
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory DateDifferenceState.fromJson(Map<String, dynamic> json) {
    return DateDifferenceState(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

class AddSubtractState {
  final DateTime baseDate;
  final int years;
  final int months;
  final int days;

  AddSubtractState({
    required this.baseDate,
    required this.years,
    required this.months,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'baseDate': baseDate.toIso8601String(),
      'years': years,
      'months': months,
      'days': days,
    };
  }

  factory AddSubtractState.fromJson(Map<String, dynamic> json) {
    return AddSubtractState(
      baseDate: DateTime.parse(json['baseDate']),
      years: json['years'] ?? 0,
      months: json['months'] ?? 0,
      days: json['days'] ?? 0,
    );
  }
}

class AgeCalculatorState {
  final DateTime birthDate;

  AgeCalculatorState({
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'birthDate': birthDate.toIso8601String(),
    };
  }

  factory AgeCalculatorState.fromJson(Map<String, dynamic> json) {
    return AgeCalculatorState(
      birthDate: DateTime.parse(json['birthDate']),
    );
  }
}

class WorkingDaysState {
  final DateTime startDate;
  final DateTime endDate;
  final List<int> excludedWeekdays; // 1=Monday, 7=Sunday
  final List<DateTime> excludedDates; // Custom holidays

  WorkingDaysState({
    required this.startDate,
    required this.endDate,
    this.excludedWeekdays = const [6, 7], // Saturday, Sunday by default
    this.excludedDates = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'excludedWeekdays': excludedWeekdays,
      'excludedDates': excludedDates.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory WorkingDaysState.fromJson(Map<String, dynamic> json) {
    return WorkingDaysState(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      excludedWeekdays: List<int>.from(json['excludedWeekdays'] ?? [6, 7]),
      excludedDates: (json['excludedDates'] as List<dynamic>? ?? [])
          .map((d) => DateTime.parse(d))
          .toList(),
    );
  }
}

class TimezoneState {
  final DateTime dateTime;
  final String fromTimezone;
  final String toTimezone;

  TimezoneState({
    required this.dateTime,
    required this.fromTimezone,
    required this.toTimezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'fromTimezone': fromTimezone,
      'toTimezone': toTimezone,
    };
  }

  factory TimezoneState.fromJson(Map<String, dynamic> json) {
    return TimezoneState(
      dateTime: DateTime.parse(json['dateTime']),
      fromTimezone: json['fromTimezone'] ?? 'UTC',
      toTimezone: json['toTimezone'] ?? 'UTC',
    );
  }
}

class RecurringDatesState {
  final DateTime startDate;
  final RecurringPattern pattern;
  final int interval;
  final int occurrences;

  RecurringDatesState({
    required this.startDate,
    required this.pattern,
    this.interval = 1,
    this.occurrences = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'pattern': pattern.name,
      'interval': interval,
      'occurrences': occurrences,
    };
  }

  factory RecurringDatesState.fromJson(Map<String, dynamic> json) {
    return RecurringDatesState(
      startDate: DateTime.parse(json['startDate']),
      pattern: RecurringPattern.values.firstWhere(
        (e) => e.name == json['pattern'],
        orElse: () => RecurringPattern.daily,
      ),
      interval: json['interval'] ?? 1,
      occurrences: json['occurrences'] ?? 10,
    );
  }
}

class CountdownState {
  final DateTime targetDate;
  final String eventName;

  CountdownState({
    required this.targetDate,
    required this.eventName,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetDate': targetDate.toIso8601String(),
      'eventName': eventName,
    };
  }

  factory CountdownState.fromJson(Map<String, dynamic> json) {
    return CountdownState(
      targetDate: DateTime.parse(json['targetDate']),
      eventName: json['eventName'] ?? '',
    );
  }
}

class TimeUnitState {
  final double value;
  final TimeUnit fromUnit;
  final TimeUnit toUnit;

  TimeUnitState({
    required this.value,
    required this.fromUnit,
    required this.toUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'fromUnit': fromUnit.name,
      'toUnit': toUnit.name,
    };
  }

  factory TimeUnitState.fromJson(Map<String, dynamic> json) {
    return TimeUnitState(
      value: json['value']?.toDouble() ?? 0.0,
      fromUnit: TimeUnit.values.firstWhere(
        (e) => e.name == json['fromUnit'],
        orElse: () => TimeUnit.hours,
      ),
      toUnit: TimeUnit.values.firstWhere(
        (e) => e.name == json['toUnit'],
        orElse: () => TimeUnit.days,
      ),
    );
  }
}

class DateInfoState {
  final DateTime selectedDate;

  DateInfoState({
    required this.selectedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'selectedDate': selectedDate.toIso8601String(),
    };
  }

  factory DateInfoState.fromJson(Map<String, dynamic> json) {
    return DateInfoState(
      selectedDate: DateTime.parse(json['selectedDate']),
    );
  }
}
