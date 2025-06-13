import 'package:hive/hive.dart';

part 'currency_state_model.g.dart';

@HiveType(typeId: 5)
class CurrencyStateModel extends HiveObject {
  @HiveField(0)
  List<CurrencyCardState> cards;

  @HiveField(1)
  List<String> visibleCurrencies;

  @HiveField(2)
  DateTime lastUpdated;

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
  String viewMode; // Store as string for Hive compatibility

  CurrencyStateModel({
    required this.cards,
    required this.visibleCurrencies,
    required this.lastUpdated,
    this.isFocusMode = false,
    this.viewMode = 'cards',
  });

  // Default state
  static CurrencyStateModel getDefault() {
    return CurrencyStateModel(
      cards: [
        CurrencyCardState(
          currencyCode: 'USD',
          amount: 1.0,
          name: 'Converter 1',
          currencies: ['USD', 'EUR', 'JPY', 'AUD', 'CNY', 'VND'],
        ),
      ],
      visibleCurrencies: ['USD', 'EUR', 'JPY', 'AUD', 'CNY', 'VND'],
      lastUpdated: DateTime.now(),
      isFocusMode: false,
      viewMode: 'cards',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((c) => c.toJson()).toList(),
      'visibleCurrencies': visibleCurrencies,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isFocusMode': isFocusMode,
      'viewMode': viewMode,
    };
  }

  factory CurrencyStateModel.fromJson(Map<String, dynamic> json) {
    return CurrencyStateModel(
      cards: (json['cards'] as List<dynamic>?)
              ?.map(
                  (e) => CurrencyCardState.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      visibleCurrencies: (json['visibleCurrencies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      isFocusMode: json['isFocusMode'] as bool? ?? false,
      viewMode: json['viewMode'] as String? ?? 'cards',
    );
  }
}

@HiveType(typeId: 6)
class CurrencyCardState extends HiveObject {
  @HiveField(0)
  String currencyCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<String>? currencies;

  CurrencyCardState({
    required this.currencyCode,
    required this.amount,
    this.name,
    this.currencies,
  });

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'amount': amount,
      'name': name ?? 'Converter 1',
      'currencies': currencies ?? ['USD', 'EUR', 'JPY'],
    };
  }

  static CurrencyCardState fromJson(Map<String, dynamic> json) {
    return CurrencyCardState(
      currencyCode: json['currencyCode'],
      amount: json['amount'],
      name: json['name'],
      currencies: json['currencies'] != null
          ? List<String>.from(json['currencies'])
          : null,
    );
  }
}
