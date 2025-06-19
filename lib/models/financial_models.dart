enum FinancialCalculationType {
  loan,
  investment,
  compoundInterest,
}

class FinancialCalculationHistory {
  final String id;
  final FinancialCalculationType type;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> results;
  final DateTime timestamp;
  final String displayTitle;

  FinancialCalculationHistory({
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

  factory FinancialCalculationHistory.fromJson(Map<String, dynamic> json) {
    return FinancialCalculationHistory(
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

class FinancialCalculatorState {
  final int activeTabIndex;
  final Map<String, String> loanInputs;
  final Map<String, String> investmentInputs;
  final Map<String, String> compoundInputs;
  final Map<String, dynamic>? loanResults;
  final Map<String, dynamic>? investmentResults;
  final Map<String, dynamic>? compoundResults;
  final DateTime lastModified;

  FinancialCalculatorState({
    required this.activeTabIndex,
    required this.loanInputs,
    required this.investmentInputs,
    required this.compoundInputs,
    this.loanResults,
    this.investmentResults,
    this.compoundResults,
    required this.lastModified,
  });

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
    return FinancialCalculatorState(
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
    return FinancialCalculatorState(
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      loanInputs: loanInputs ?? this.loanInputs,
      investmentInputs: investmentInputs ?? this.investmentInputs,
      compoundInputs: compoundInputs ?? this.compoundInputs,
      loanResults: loanResults ?? this.loanResults,
      investmentResults: investmentResults ?? this.investmentResults,
      compoundResults: compoundResults ?? this.compoundResults,
      lastModified: DateTime.now(),
    );
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
