import 'package:isar/isar.dart';

part 'currency_state_model.g.dart';

@embedded
class CurrencyCardState {
  String? currencyCode;
  double? amount;
  String? name;
  List<String>? currencies;

  CurrencyCardState({
    this.currencyCode,
    this.amount,
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

@Collection()
class CurrencyStateModel {
  Id id = Isar.autoIncrement;

  List<CurrencyCardState> cards = [];
  List<String> visibleCurrencies = [];
  DateTime? lastUpdated;
  bool isFocusMode = false;
  String viewMode = 'cards'; // Store as string for compatibility

  CurrencyStateModel();

  // Default state
  static CurrencyStateModel getDefault() {
    final model = CurrencyStateModel()
      ..cards = [
        CurrencyCardState(
          currencyCode: 'USD',
          amount: 1.0,
          name: 'Converter 1',
          currencies: ['USD', 'EUR', 'JPY', 'AUD', 'CNY', 'VND'],
        ),
      ]
      ..visibleCurrencies = ['USD', 'EUR', 'JPY', 'AUD', 'CNY', 'VND']
      ..lastUpdated = DateTime.now()
      ..isFocusMode = false
      ..viewMode = 'cards';
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((c) => c.toJson()).toList(),
      'visibleCurrencies': visibleCurrencies,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isFocusMode': isFocusMode,
      'viewMode': viewMode,
    };
  }

  factory CurrencyStateModel.fromJson(Map<String, dynamic> json) {
    final model = CurrencyStateModel()
      ..cards = (json['cards'] as List<dynamic>?)
              ?.map(
                  (e) => CurrencyCardState.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..visibleCurrencies = (json['visibleCurrencies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now()
      ..isFocusMode = json['isFocusMode'] as bool? ?? false
      ..viewMode = json['viewMode'] as String? ?? 'cards';
    return model;
  }
}
