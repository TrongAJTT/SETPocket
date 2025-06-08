import 'package:hive/hive.dart';
import 'currency_cache_model.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 12)
class SettingsModel extends HiveObject {
  @HiveField(0)
  CurrencyFetchMode currencyFetchMode;

  SettingsModel({
    this.currencyFetchMode = CurrencyFetchMode.onceADay,
  });

  SettingsModel copyWith({
    CurrencyFetchMode? currencyFetchMode,
  }) {
    return SettingsModel(
      currencyFetchMode: currencyFetchMode ?? this.currencyFetchMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyFetchMode': currencyFetchMode.index,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currencyFetchMode:
          CurrencyFetchMode.values[json['currencyFetchMode'] ?? 1],
    );
  }
}
