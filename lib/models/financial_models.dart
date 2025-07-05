import 'dart:convert';
import 'package:isar/isar.dart';

part 'financial_models.g.dart';

enum FinancialCalculationType {
  loan,
  investment,
  compoundInterest,
}

@collection
class FinancialCalculationHistory {
  Id isarId = Isar.autoIncrement;

  @Index()
  late String id;

  @Enumerated(EnumType.name)
  late FinancialCalculationType type;

  String? _inputs;
  String? _results;

  @Index()
  late DateTime timestamp;
  late String displayTitle;

  @ignore
  Map<String, dynamic> get inputs {
    if (_inputs == null) return {};
    return json.decode(_inputs!) as Map<String, dynamic>;
  }

  set inputs(Map<String, dynamic> value) {
    _inputs = json.encode(value);
  }

  @ignore
  Map<String, dynamic> get results {
    if (_results == null) return {};
    return json.decode(_results!) as Map<String, dynamic>;
  }

  set results(Map<String, dynamic> value) {
    _results = json.encode(value);
  }

  FinancialCalculationHistory();

  FinancialCalculationHistory.fromData({
    required this.id,
    required this.type,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> results,
    required this.timestamp,
    required this.displayTitle,
  }) {
    this.inputs = inputs;
    this.results = results;
  }

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

  factory FinancialCalculationHistory.fromJson(Map<String, dynamic> json) {
    return FinancialCalculationHistory.fromData(
      id: json['id'] ?? '',
      type: FinancialCalculationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FinancialCalculationType.loan,
      ),
      inputs: Map<String, dynamic>.from(json['inputs'] ?? {}),
      results: Map<String, dynamic>.from(json['results'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      displayTitle: json['displayTitle'] ?? '',
    );
  }
}

@collection
class FinancialCalculatorState {
  Id id = Isar.autoIncrement;

  late int activeTabIndex;

  String? _loanInputs;
  String? _investmentInputs;
  String? _compoundInputs;
  String? _loanResults;
  String? _investmentResults;
  String? _compoundResults;

  late DateTime lastModified;

  @ignore
  Map<String, String> get loanInputs => _loanInputs == null
      ? {}
      : Map<String, String>.from(json.decode(_loanInputs!));
  set loanInputs(Map<String, String> value) => _loanInputs = json.encode(value);

  @ignore
  Map<String, String> get investmentInputs => _investmentInputs == null
      ? {}
      : Map<String, String>.from(json.decode(_investmentInputs!));
  set investmentInputs(Map<String, String> value) =>
      _investmentInputs = json.encode(value);

  @ignore
  Map<String, String> get compoundInputs => _compoundInputs == null
      ? {}
      : Map<String, String>.from(json.decode(_compoundInputs!));
  set compoundInputs(Map<String, String> value) =>
      _compoundInputs = json.encode(value);

  @ignore
  Map<String, dynamic>? get loanResults => _loanResults == null
      ? null
      : Map<String, dynamic>.from(json.decode(_loanResults!));
  set loanResults(Map<String, dynamic>? value) =>
      _loanResults = value == null ? null : json.encode(value);

  @ignore
  Map<String, dynamic>? get investmentResults => _investmentResults == null
      ? null
      : Map<String, dynamic>.from(json.decode(_investmentResults!));
  set investmentResults(Map<String, dynamic>? value) =>
      _investmentResults = value == null ? null : json.encode(value);

  @ignore
  Map<String, dynamic>? get compoundResults => _compoundResults == null
      ? null
      : Map<String, dynamic>.from(json.decode(_compoundResults!));
  set compoundResults(Map<String, dynamic>? value) =>
      _compoundResults = value == null ? null : json.encode(value);

  FinancialCalculatorState();

  FinancialCalculatorState.fromData({
    required this.activeTabIndex,
    required Map<String, String> loanInputs,
    required Map<String, String> investmentInputs,
    required Map<String, String> compoundInputs,
    Map<String, dynamic>? loanResults,
    Map<String, dynamic>? investmentResults,
    Map<String, dynamic>? compoundResults,
    required this.lastModified,
  }) {
    this.loanInputs = loanInputs;
    this.investmentInputs = investmentInputs;
    this.compoundInputs = compoundInputs;
    this.loanResults = loanResults;
    this.investmentResults = investmentResults;
    this.compoundResults = compoundResults;
  }

  Map<String, dynamic> toJson() {
    return {
      'activeTabIndex': activeTabIndex,
      'loanInputs': loanInputs,
      'investmentInputs': investmentInputs,
      'compoundInputs': compoundInputs,
      'loanResults': loanResults,
      'investmentResults': investmentResults,
      'compoundResults': compoundResults,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory FinancialCalculatorState.fromJson(Map<String, dynamic> json) {
    return FinancialCalculatorState.fromData(
      activeTabIndex: json['activeTabIndex'] ?? 0,
      loanInputs: Map<String, String>.from(json['loanInputs'] ?? {}),
      investmentInputs:
          Map<String, String>.from(json['investmentInputs'] ?? {}),
      compoundInputs: Map<String, String>.from(json['compoundInputs'] ?? {}),
      loanResults: json['loanResults'] != null
          ? Map<String, dynamic>.from(json['loanResults'])
          : null,
      investmentResults: json['investmentResults'] != null
          ? Map<String, dynamic>.from(json['investmentResults'])
          : null,
      compoundResults: json['compoundResults'] != null
          ? Map<String, dynamic>.from(json['compoundResults'])
          : null,
      lastModified: DateTime.parse(json['lastModified']),
    );
  }

  FinancialCalculatorState copyWith({
    int? activeTabIndex,
    Map<String, String>? loanInputs,
    Map<String, String>? investmentInputs,
    Map<String, String>? compoundInputs,
    Map<String, dynamic>? loanResults,
    Map<String, dynamic>? investmentResults,
    Map<String, dynamic>? compoundResults,
  }) {
    final state = FinancialCalculatorState()
      ..activeTabIndex = activeTabIndex ?? this.activeTabIndex
      ..loanInputs = loanInputs ?? this.loanInputs
      ..investmentInputs = investmentInputs ?? this.investmentInputs
      ..compoundInputs = compoundInputs ?? this.compoundInputs
      ..loanResults = loanResults ?? this.loanResults
      ..investmentResults = investmentResults ?? this.investmentResults
      ..compoundResults = compoundResults ?? this.compoundResults
      ..lastModified = DateTime.now();
    return state;
  }
}

class LoanCalculationResult {
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;

  LoanCalculationResult({
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
  });

  Map<String, dynamic> toMap() {
    return {
      'monthlyPayment': monthlyPayment,
      'totalPayment': totalPayment,
      'totalInterest': totalInterest,
    };
  }

  factory LoanCalculationResult.fromMap(Map<String, dynamic> map) {
    return LoanCalculationResult(
      monthlyPayment: map['monthlyPayment']?.toDouble() ?? 0.0,
      totalPayment: map['totalPayment']?.toDouble() ?? 0.0,
      totalInterest: map['totalInterest']?.toDouble() ?? 0.0,
    );
  }
}

class InvestmentCalculationResult {
  final double futureValue;
  final double totalContributions;
  final double totalEarnings;

  InvestmentCalculationResult({
    required this.futureValue,
    required this.totalContributions,
    required this.totalEarnings,
  });

  Map<String, dynamic> toMap() {
    return {
      'futureValue': futureValue,
      'totalContributions': totalContributions,
      'totalEarnings': totalEarnings,
    };
  }

  factory InvestmentCalculationResult.fromMap(Map<String, dynamic> map) {
    return InvestmentCalculationResult(
      futureValue: map['futureValue']?.toDouble() ?? 0.0,
      totalContributions: map['totalContributions']?.toDouble() ?? 0.0,
      totalEarnings: map['totalEarnings']?.toDouble() ?? 0.0,
    );
  }
}

class CompoundInterestCalculationResult {
  final double compoundAmount;
  final double compoundInterestEarned;

  CompoundInterestCalculationResult({
    required this.compoundAmount,
    required this.compoundInterestEarned,
  });

  Map<String, dynamic> toMap() {
    return {
      'compoundAmount': compoundAmount,
      'compoundInterestEarned': compoundInterestEarned,
    };
  }

  factory CompoundInterestCalculationResult.fromMap(Map<String, dynamic> map) {
    return CompoundInterestCalculationResult(
      compoundAmount: map['compoundAmount']?.toDouble() ?? 0.0,
      compoundInterestEarned: map['compoundInterestEarned']?.toDouble() ?? 0.0,
    );
  }
}
