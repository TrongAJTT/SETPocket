import 'package:hive/hive.dart';
import 'currency_cache_model.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 12)
class SettingsModel extends HiveObject {
  @HiveField(0)
  CurrencyFetchMode currencyFetchMode;

  @HiveField(1)
  int fetchTimeoutSeconds;

  SettingsModel({
    this.currencyFetchMode = CurrencyFetchMode.onceADay,
    this.fetchTimeoutSeconds = 10,
  });

  SettingsModel copyWith({
    CurrencyFetchMode? currencyFetchMode,
    int? fetchTimeoutSeconds,
  }) {
    return SettingsModel(
      currencyFetchMode: currencyFetchMode ?? this.currencyFetchMode,
      fetchTimeoutSeconds: fetchTimeoutSeconds ?? this.fetchTimeoutSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyFetchMode': currencyFetchMode.index,
      'fetchTimeoutSeconds': fetchTimeoutSeconds,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currencyFetchMode:
          CurrencyFetchMode.values[json['currencyFetchMode'] ?? 1],
      fetchTimeoutSeconds: json['fetchTimeoutSeconds'] ?? 10,
    );
  }
}
