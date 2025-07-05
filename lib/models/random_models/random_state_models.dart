import 'package:isar/isar.dart';

part 'random_state_models.g.dart';

// Simple JSON-based state models for random generators
@Collection()
class NumberGeneratorState {
  Id id = Isar.autoIncrement;

  bool isInteger = true;
  double minValue = 1.0;
  double maxValue = 100.0;
  int quantity = 5;
  bool allowDuplicates = true;
  DateTime? lastUpdated;

  NumberGeneratorState();

  static NumberGeneratorState createDefault() {
    return NumberGeneratorState()
      ..isInteger = true
      ..minValue = 1.0
      ..maxValue = 100.0
      ..quantity = 5
      ..allowDuplicates = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'isInteger': isInteger,
      'minValue': minValue,
      'maxValue': maxValue,
      'quantity': quantity,
      'allowDuplicates': allowDuplicates,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory NumberGeneratorState.fromJson(Map<String, dynamic> json) {
    return NumberGeneratorState()
      ..isInteger = json['isInteger'] ?? true
      ..minValue = (json['minValue'] as num?)?.toDouble() ?? 1.0
      ..maxValue = (json['maxValue'] as num?)?.toDouble() ?? 100.0
      ..quantity = json['quantity'] ?? 5
      ..allowDuplicates = json['allowDuplicates'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  NumberGeneratorState copyWith({
    bool? isInteger,
    double? minValue,
    double? maxValue,
    int? quantity,
    bool? allowDuplicates,
  }) {
    return NumberGeneratorState()
      ..isInteger = isInteger ?? this.isInteger
      ..minValue = minValue ?? this.minValue
      ..maxValue = maxValue ?? this.maxValue
      ..quantity = quantity ?? this.quantity
      ..allowDuplicates = allowDuplicates ?? this.allowDuplicates
      ..lastUpdated = DateTime.now();
  }
}

@Collection()
class PasswordGeneratorState {
  Id id = Isar.autoIncrement;

  int passwordLength = 12;
  bool includeLowercase = true;
  bool includeUppercase = true;
  bool includeNumbers = true;
  bool includeSpecial = true;
  DateTime? lastUpdated;

  PasswordGeneratorState();

  static PasswordGeneratorState createDefault() {
    return PasswordGeneratorState()
      ..passwordLength = 12
      ..includeLowercase = true
      ..includeUppercase = true
      ..includeNumbers = true
      ..includeSpecial = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'passwordLength': passwordLength,
      'includeLowercase': includeLowercase,
      'includeUppercase': includeUppercase,
      'includeNumbers': includeNumbers,
      'includeSpecial': includeSpecial,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory PasswordGeneratorState.fromJson(Map<String, dynamic> json) {
    return PasswordGeneratorState()
      ..passwordLength = json['passwordLength'] ?? 12
      ..includeLowercase = json['includeLowercase'] ?? true
      ..includeUppercase = json['includeUppercase'] ?? true
      ..includeNumbers = json['includeNumbers'] ?? true
      ..includeSpecial = json['includeSpecial'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  PasswordGeneratorState copyWith({
    int? passwordLength,
    bool? includeLowercase,
    bool? includeUppercase,
    bool? includeNumbers,
    bool? includeSpecial,
  }) {
    return PasswordGeneratorState()
      ..passwordLength = passwordLength ?? this.passwordLength
      ..includeLowercase = includeLowercase ?? this.includeLowercase
      ..includeUppercase = includeUppercase ?? this.includeUppercase
      ..includeNumbers = includeNumbers ?? this.includeNumbers
      ..includeSpecial = includeSpecial ?? this.includeSpecial
      ..lastUpdated = DateTime.now();
  }
}

@Collection()
class DateGeneratorState {
  Id id = Isar.autoIncrement;

  DateTime? startDate;
  DateTime? endDate;
  int dateCount = 5;
  bool allowDuplicates = true;
  DateTime? lastUpdated;

  DateGeneratorState();

  static DateGeneratorState createDefault() {
    final now = DateTime.now();
    return DateGeneratorState()
      ..startDate = now.subtract(const Duration(days: 365))
      ..endDate = now.add(const Duration(days: 365))
      ..dateCount = 5
      ..allowDuplicates = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'dateCount': dateCount,
      'allowDuplicates': allowDuplicates,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory DateGeneratorState.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return DateGeneratorState()
      ..startDate = json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : now.subtract(const Duration(days: 365))
      ..endDate = json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : now.add(const Duration(days: 365))
      ..dateCount = json['dateCount'] ?? 5
      ..allowDuplicates = json['allowDuplicates'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  DateGeneratorState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? dateCount,
    bool? allowDuplicates,
  }) {
    return DateGeneratorState()
      ..startDate = startDate ?? this.startDate
      ..endDate = endDate ?? this.endDate
      ..dateCount = dateCount ?? this.dateCount
      ..allowDuplicates = allowDuplicates ?? this.allowDuplicates
      ..lastUpdated = DateTime.now();
  }
}

@Collection()
class ColorGeneratorState {
  Id id = Isar.autoIncrement;

  bool withAlpha = false;
  DateTime? lastUpdated;

  ColorGeneratorState();

  static ColorGeneratorState createDefault() {
    return ColorGeneratorState()
      ..withAlpha = false
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'withAlpha': withAlpha,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory ColorGeneratorState.fromJson(Map<String, dynamic> json) {
    return ColorGeneratorState()
      ..withAlpha = json['withAlpha'] ?? false
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  ColorGeneratorState copyWith({
    bool? withAlpha,
  }) {
    return ColorGeneratorState()
      ..withAlpha = withAlpha ?? this.withAlpha
      ..lastUpdated = DateTime.now();
  }
}

// Date Time Generator State
@Collection()
class DateTimeGeneratorState {
  Id id = Isar.autoIncrement;

  DateTime? startDateTime;
  DateTime? endDateTime;
  int dateTimeCount = 5;
  bool allowDuplicates = true;
  DateTime? lastUpdated;

  DateTimeGeneratorState();

  static DateTimeGeneratorState createDefault() {
    final now = DateTime.now();
    return DateTimeGeneratorState()
      ..startDateTime = now.subtract(const Duration(days: 365))
      ..endDateTime = now.add(const Duration(days: 365))
      ..dateTimeCount = 5
      ..allowDuplicates = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'startDateTime': startDateTime?.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'dateTimeCount': dateTimeCount,
      'allowDuplicates': allowDuplicates,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory DateTimeGeneratorState.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return DateTimeGeneratorState()
      ..startDateTime = json['startDateTime'] != null
          ? DateTime.parse(json['startDateTime'])
          : now.subtract(const Duration(days: 365))
      ..endDateTime = json['endDateTime'] != null
          ? DateTime.parse(json['endDateTime'])
          : now.add(const Duration(days: 365))
      ..dateTimeCount = json['dateTimeCount'] ?? 5
      ..allowDuplicates = json['allowDuplicates'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  DateTimeGeneratorState copyWith({
    DateTime? startDateTime,
    DateTime? endDateTime,
    int? dateTimeCount,
    bool? allowDuplicates,
  }) {
    return DateTimeGeneratorState()
      ..startDateTime = startDateTime ?? this.startDateTime
      ..endDateTime = endDateTime ?? this.endDateTime
      ..dateTimeCount = dateTimeCount ?? this.dateTimeCount
      ..allowDuplicates = allowDuplicates ?? this.allowDuplicates
      ..lastUpdated = DateTime.now();
  }
}

// Time Generator State
@Collection()
class TimeGeneratorState {
  Id id = Isar.autoIncrement;

  int startHour = 0;
  int startMinute = 0;
  int endHour = 23;
  int endMinute = 59;
  int timeCount = 5;
  bool allowDuplicates = true;
  DateTime? lastUpdated;

  TimeGeneratorState();

  static TimeGeneratorState createDefault() {
    return TimeGeneratorState()
      ..startHour = 0
      ..startMinute = 0
      ..endHour = 23
      ..endMinute = 59
      ..timeCount = 5
      ..allowDuplicates = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'timeCount': timeCount,
      'allowDuplicates': allowDuplicates,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory TimeGeneratorState.fromJson(Map<String, dynamic> json) {
    return TimeGeneratorState()
      ..startHour = json['startHour'] ?? 0
      ..startMinute = json['startMinute'] ?? 0
      ..endHour = json['endHour'] ?? 23
      ..endMinute = json['endMinute'] ?? 59
      ..timeCount = json['timeCount'] ?? 5
      ..allowDuplicates = json['allowDuplicates'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  TimeGeneratorState copyWith({
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    int? timeCount,
    bool? allowDuplicates,
  }) {
    return TimeGeneratorState()
      ..startHour = startHour ?? this.startHour
      ..startMinute = startMinute ?? this.startMinute
      ..endHour = endHour ?? this.endHour
      ..endMinute = endMinute ?? this.endMinute
      ..timeCount = timeCount ?? this.timeCount
      ..allowDuplicates = allowDuplicates ?? this.allowDuplicates
      ..lastUpdated = DateTime.now();
  }
}

// Simple Generator State (for coin flip, dice, etc.)
@Collection()
class SimpleGeneratorState {
  Id id = Isar.autoIncrement;

  bool skipAnimation = false;
  DateTime? lastUpdated;

  SimpleGeneratorState();

  static SimpleGeneratorState createDefault() {
    return SimpleGeneratorState()
      ..skipAnimation = false
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'skipAnimation': skipAnimation,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory SimpleGeneratorState.fromJson(Map<String, dynamic> json) {
    return SimpleGeneratorState()
      ..skipAnimation = json['skipAnimation'] ?? false
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  SimpleGeneratorState copyWith({
    bool? skipAnimation,
  }) {
    return SimpleGeneratorState()
      ..skipAnimation = skipAnimation ?? this.skipAnimation
      ..lastUpdated = DateTime.now();
  }
}

// UUID Generator State
@Collection()
class UuidGeneratorState {
  Id id = Isar.autoIncrement;

  bool uppercase = false;
  bool withHyphens = true;
  int quantity = 5;
  DateTime? lastUpdated;

  UuidGeneratorState();

  static UuidGeneratorState createDefault() {
    return UuidGeneratorState()
      ..uppercase = false
      ..withHyphens = true
      ..quantity = 5
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'uppercase': uppercase,
      'withHyphens': withHyphens,
      'quantity': quantity,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory UuidGeneratorState.fromJson(Map<String, dynamic> json) {
    return UuidGeneratorState()
      ..uppercase = json['uppercase'] ?? false
      ..withHyphens = json['withHyphens'] ?? true
      ..quantity = json['quantity'] ?? 5
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  UuidGeneratorState copyWith({
    bool? uppercase,
    bool? withHyphens,
    int? quantity,
  }) {
    return UuidGeneratorState()
      ..uppercase = uppercase ?? this.uppercase
      ..withHyphens = withHyphens ?? this.withHyphens
      ..quantity = quantity ?? this.quantity
      ..lastUpdated = DateTime.now();
  }
}

// String Generator State
@Collection()
class StringGeneratorState {
  Id id = Isar.autoIncrement;

  int stringLength = 10;
  bool includeLowercase = true;
  bool includeUppercase = true;
  bool includeNumbers = true;
  bool includeSpecial = false;
  int quantity = 5;
  DateTime? lastUpdated;

  StringGeneratorState();

  static StringGeneratorState createDefault() {
    return StringGeneratorState()
      ..stringLength = 10
      ..includeLowercase = true
      ..includeUppercase = true
      ..includeNumbers = true
      ..includeSpecial = false
      ..quantity = 5
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'stringLength': stringLength,
      'includeLowercase': includeLowercase,
      'includeUppercase': includeUppercase,
      'includeNumbers': includeNumbers,
      'includeSpecial': includeSpecial,
      'quantity': quantity,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory StringGeneratorState.fromJson(Map<String, dynamic> json) {
    return StringGeneratorState()
      ..stringLength = json['stringLength'] ?? 10
      ..includeLowercase = json['includeLowercase'] ?? true
      ..includeUppercase = json['includeUppercase'] ?? true
      ..includeNumbers = json['includeNumbers'] ?? true
      ..includeSpecial = json['includeSpecial'] ?? false
      ..quantity = json['quantity'] ?? 5
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  StringGeneratorState copyWith({
    int? stringLength,
    bool? includeLowercase,
    bool? includeUppercase,
    bool? includeNumbers,
    bool? includeSpecial,
    int? quantity,
  }) {
    return StringGeneratorState()
      ..stringLength = stringLength ?? this.stringLength
      ..includeLowercase = includeLowercase ?? this.includeLowercase
      ..includeUppercase = includeUppercase ?? this.includeUppercase
      ..includeNumbers = includeNumbers ?? this.includeNumbers
      ..includeSpecial = includeSpecial ?? this.includeSpecial
      ..quantity = quantity ?? this.quantity
      ..lastUpdated = DateTime.now();
  }
}

// List Generator State
@Collection()
class ListGeneratorState {
  Id id = Isar.autoIncrement;

  String items = '';
  bool shuffleResults = true;
  int quantity = 5;
  bool allowDuplicates = true;
  DateTime? lastUpdated;

  ListGeneratorState();

  static ListGeneratorState createDefault() {
    return ListGeneratorState()
      ..items = ''
      ..shuffleResults = true
      ..quantity = 5
      ..allowDuplicates = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'shuffleResults': shuffleResults,
      'quantity': quantity,
      'allowDuplicates': allowDuplicates,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory ListGeneratorState.fromJson(Map<String, dynamic> json) {
    return ListGeneratorState()
      ..items = json['items'] ?? ''
      ..shuffleResults = json['shuffleResults'] ?? true
      ..quantity = json['quantity'] ?? 5
      ..allowDuplicates = json['allowDuplicates'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  ListGeneratorState copyWith({
    String? items,
    bool? shuffleResults,
    int? quantity,
    bool? allowDuplicates,
  }) {
    return ListGeneratorState()
      ..items = items ?? this.items
      ..shuffleResults = shuffleResults ?? this.shuffleResults
      ..quantity = quantity ?? this.quantity
      ..allowDuplicates = allowDuplicates ?? this.allowDuplicates
      ..lastUpdated = DateTime.now();
  }
}

// Dice Roll Generator State
@Collection()
class DiceRollGeneratorState {
  Id id = Isar.autoIncrement;

  int diceCount = 2;
  int diceSides = 6;
  bool showSum = true;
  DateTime? lastUpdated;

  DiceRollGeneratorState();

  static DiceRollGeneratorState createDefault() {
    return DiceRollGeneratorState()
      ..diceCount = 2
      ..diceSides = 6
      ..showSum = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'diceCount': diceCount,
      'diceSides': diceSides,
      'showSum': showSum,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory DiceRollGeneratorState.fromJson(Map<String, dynamic> json) {
    return DiceRollGeneratorState()
      ..diceCount = json['diceCount'] ?? 2
      ..diceSides = json['diceSides'] ?? 6
      ..showSum = json['showSum'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  DiceRollGeneratorState copyWith({
    int? diceCount,
    int? diceSides,
    bool? showSum,
  }) {
    return DiceRollGeneratorState()
      ..diceCount = diceCount ?? this.diceCount
      ..diceSides = diceSides ?? this.diceSides
      ..showSum = showSum ?? this.showSum
      ..lastUpdated = DateTime.now();
  }
}

// Latin Letter Generator State
@Collection()
class LatinLetterGeneratorState {
  Id id = Isar.autoIncrement;

  bool uppercase = false;
  int quantity = 5;
  bool allowDuplicates = true;
  DateTime? lastUpdated;

  LatinLetterGeneratorState();

  static LatinLetterGeneratorState createDefault() {
    return LatinLetterGeneratorState()
      ..uppercase = false
      ..quantity = 5
      ..allowDuplicates = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'uppercase': uppercase,
      'quantity': quantity,
      'allowDuplicates': allowDuplicates,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory LatinLetterGeneratorState.fromJson(Map<String, dynamic> json) {
    return LatinLetterGeneratorState()
      ..uppercase = json['uppercase'] ?? false
      ..quantity = json['quantity'] ?? 5
      ..allowDuplicates = json['allowDuplicates'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  LatinLetterGeneratorState copyWith({
    bool? uppercase,
    int? quantity,
    bool? allowDuplicates,
  }) {
    return LatinLetterGeneratorState()
      ..uppercase = uppercase ?? this.uppercase
      ..quantity = quantity ?? this.quantity
      ..allowDuplicates = allowDuplicates ?? this.allowDuplicates
      ..lastUpdated = DateTime.now();
  }
}

// Playing Card Generator State
@Collection()
class PlayingCardGeneratorState {
  Id id = Isar.autoIncrement;

  bool includeJokers = false;
  int quantity = 5;
  bool allowDuplicates = true;
  DateTime? lastUpdated;

  PlayingCardGeneratorState();

  static PlayingCardGeneratorState createDefault() {
    return PlayingCardGeneratorState()
      ..includeJokers = false
      ..quantity = 5
      ..allowDuplicates = true
      ..lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'includeJokers': includeJokers,
      'quantity': quantity,
      'allowDuplicates': allowDuplicates,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory PlayingCardGeneratorState.fromJson(Map<String, dynamic> json) {
    return PlayingCardGeneratorState()
      ..includeJokers = json['includeJokers'] ?? false
      ..quantity = json['quantity'] ?? 5
      ..allowDuplicates = json['allowDuplicates'] ?? true
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }

  PlayingCardGeneratorState copyWith({
    bool? includeJokers,
    int? quantity,
    bool? allowDuplicates,
  }) {
    return PlayingCardGeneratorState()
      ..includeJokers = includeJokers ?? this.includeJokers
      ..quantity = quantity ?? this.quantity
      ..allowDuplicates = allowDuplicates ?? this.allowDuplicates
      ..lastUpdated = DateTime.now();
  }
}
