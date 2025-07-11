enum DiscountCalculationType {
  discount,
  tip,
  tax,
  markup,
}

class DiscountCalculationResult {
  final double originalAmount;
  final double discountPercent;
  final double discountAmount;
  final double finalAmount;
  final double savedAmount;

  DiscountCalculationResult({
    required this.originalAmount,
    required this.discountPercent,
    required this.discountAmount,
    required this.finalAmount,
    required this.savedAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'originalAmount': originalAmount,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'savedAmount': savedAmount,
    };
  }

  static DiscountCalculationResult fromMap(Map<String, dynamic> map) {
    return DiscountCalculationResult(
      originalAmount: map['originalAmount']?.toDouble() ?? 0.0,
      discountPercent: map['discountPercent']?.toDouble() ?? 0.0,
      discountAmount: map['discountAmount']?.toDouble() ?? 0.0,
      finalAmount: map['finalAmount']?.toDouble() ?? 0.0,
      savedAmount: map['savedAmount']?.toDouble() ?? 0.0,
    );
  }
}

class TipCalculationResult {
  final double billAmount;
  final double tipPercent;
  final int numberOfPeople;
  final double tipAmount;
  final double totalBill;
  final double perPersonAmount;

  TipCalculationResult({
    required this.billAmount,
    required this.tipPercent,
    required this.numberOfPeople,
    required this.tipAmount,
    required this.totalBill,
    required this.perPersonAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'billAmount': billAmount,
      'tipPercent': tipPercent,
      'numberOfPeople': numberOfPeople,
      'tipAmount': tipAmount,
      'totalBill': totalBill,
      'perPersonAmount': perPersonAmount,
    };
  }

  static TipCalculationResult fromMap(Map<String, dynamic> map) {
    return TipCalculationResult(
      billAmount: map['billAmount']?.toDouble() ?? 0.0,
      tipPercent: map['tipPercent']?.toDouble() ?? 0.0,
      numberOfPeople: map['numberOfPeople']?.toInt() ?? 1,
      tipAmount: map['tipAmount']?.toDouble() ?? 0.0,
      totalBill: map['totalBill']?.toDouble() ?? 0.0,
      perPersonAmount: map['perPersonAmount']?.toDouble() ?? 0.0,
    );
  }
}

class TaxCalculationResult {
  final double priceBeforeTax;
  final double taxRate;
  final double taxAmount;
  final double priceAfterTax;

  TaxCalculationResult({
    required this.priceBeforeTax,
    required this.taxRate,
    required this.taxAmount,
    required this.priceAfterTax,
  });

  Map<String, dynamic> toMap() {
    return {
      'priceBeforeTax': priceBeforeTax,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'priceAfterTax': priceAfterTax,
    };
  }

  static TaxCalculationResult fromMap(Map<String, dynamic> map) {
    return TaxCalculationResult(
      priceBeforeTax: map['priceBeforeTax']?.toDouble() ?? 0.0,
      taxRate: map['taxRate']?.toDouble() ?? 0.0,
      taxAmount: map['taxAmount']?.toDouble() ?? 0.0,
      priceAfterTax: map['priceAfterTax']?.toDouble() ?? 0.0,
    );
  }
}

class MarkupCalculationResult {
  final double costPrice;
  final double markupPercent;
  final double markupAmount;
  final double sellingPrice;
  final double profitMargin;

  MarkupCalculationResult({
    required this.costPrice,
    required this.markupPercent,
    required this.markupAmount,
    required this.sellingPrice,
    required this.profitMargin,
  });

  Map<String, dynamic> toMap() {
    return {
      'costPrice': costPrice,
      'markupPercent': markupPercent,
      'markupAmount': markupAmount,
      'sellingPrice': sellingPrice,
      'profitMargin': profitMargin,
    };
  }

  static MarkupCalculationResult fromMap(Map<String, dynamic> map) {
    return MarkupCalculationResult(
      costPrice: map['costPrice']?.toDouble() ?? 0.0,
      markupPercent: map['markupPercent']?.toDouble() ?? 0.0,
      markupAmount: map['markupAmount']?.toDouble() ?? 0.0,
      sellingPrice: map['sellingPrice']?.toDouble() ?? 0.0,
      profitMargin: map['profitMargin']?.toDouble() ?? 0.0,
    );
  }
}

class DiscountCalculationHistory {
  final String id;
  final DiscountCalculationType type;
  final Map<String, String> inputs;
  final Map<String, dynamic> results;
  final DateTime timestamp;
  final String displayTitle;

  DiscountCalculationHistory({
    String? id,
    required this.type,
    required this.inputs,
    required this.results,
    DateTime? timestamp,
    required this.displayTitle,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'inputs': inputs,
      'results': results,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'displayTitle': displayTitle,
    };
  }

  static DiscountCalculationHistory fromMap(Map<String, dynamic> map) {
    return DiscountCalculationHistory(
      id: map['id'] ?? '',
      type: DiscountCalculationType.values[map['type'] ?? 0],
      inputs: Map<String, String>.from(map['inputs'] ?? {}),
      results: Map<String, dynamic>.from(map['results'] ?? {}),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      displayTitle: map['displayTitle'] ?? '',
    );
  }
}

class DiscountCalculatorState {
  final int activeTabIndex;
  final Map<String, String> discountInputs;
  final Map<String, String> tipInputs;
  final Map<String, String> taxInputs;
  final Map<String, String> markupInputs;
  final Map<String, dynamic>? discountResults;
  final Map<String, dynamic>? tipResults;
  final Map<String, dynamic>? taxResults;
  final Map<String, dynamic>? markupResults;
  final DateTime lastModified;

  DiscountCalculatorState({
    required this.activeTabIndex,
    required this.discountInputs,
    required this.tipInputs,
    required this.taxInputs,
    required this.markupInputs,
    this.discountResults,
    this.tipResults,
    this.taxResults,
    this.markupResults,
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'activeTabIndex': activeTabIndex,
      'discountInputs': discountInputs,
      'tipInputs': tipInputs,
      'taxInputs': taxInputs,
      'markupInputs': markupInputs,
      'discountResults': discountResults,
      'tipResults': tipResults,
      'taxResults': taxResults,
      'markupResults': markupResults,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }

  static DiscountCalculatorState fromMap(Map<String, dynamic> map) {
    return DiscountCalculatorState(
      activeTabIndex: map['activeTabIndex'] ?? 0,
      discountInputs: Map<String, String>.from(map['discountInputs'] ?? {}),
      tipInputs: Map<String, String>.from(map['tipInputs'] ?? {}),
      taxInputs: Map<String, String>.from(map['taxInputs'] ?? {}),
      markupInputs: Map<String, String>.from(map['markupInputs'] ?? {}),
      discountResults: map['discountResults'],
      tipResults: map['tipResults'],
      taxResults: map['taxResults'],
      markupResults: map['markupResults'],
      lastModified:
          DateTime.fromMillisecondsSinceEpoch(map['lastModified'] ?? 0),
    );
  }
}
