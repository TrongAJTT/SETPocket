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

  CurrencyStateModel({
    required this.cards,
    required this.visibleCurrencies,
    required this.lastUpdated,
  });

  // Default state
  static CurrencyStateModel getDefault() {
    return CurrencyStateModel(
      cards: [
        CurrencyCardState(
          currencyCode: 'USD',
          amount: 1.0,
        ),
      ],
      visibleCurrencies: ['USD', 'EUR', 'JPY', 'AUD', 'CNY', 'VND'],
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((c) => c.toJson()).toList(),
      'visibleCurrencies': visibleCurrencies,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static CurrencyStateModel fromJson(Map<String, dynamic> json) {
    return CurrencyStateModel(
      cards: (json['cards'] as List)
          .map((c) => CurrencyCardState.fromJson(c))
          .toList(),
      visibleCurrencies: List<String>.from(json['visibleCurrencies']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

@HiveType(typeId: 6)
class CurrencyCardState extends HiveObject {
  @HiveField(0)
  String currencyCode;

  @HiveField(1)
  double amount;

  CurrencyCardState({
    required this.currencyCode,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'amount': amount,
    };
  }

  static CurrencyCardState fromJson(Map<String, dynamic> json) {
    return CurrencyCardState(
      currencyCode: json['currencyCode'],
      amount: json['amount'],
    );
  }
}
