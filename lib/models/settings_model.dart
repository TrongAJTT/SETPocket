import 'package:hive/hive.dart';
import 'converter_models/currency_cache_model.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 12)
class SettingsModel extends HiveObject {
  @HiveField(0)
  CurrencyFetchMode currencyFetchMode;

  @HiveField(1)
  int fetchTimeoutSeconds;

  @HiveField(2)
  bool featureStateSavingEnabled;

  @HiveField(3)
  int logRetentionDays;

  @HiveField(4)
  int fetchRetryTimes;

  SettingsModel({
    this.currencyFetchMode = CurrencyFetchMode.onceADay,
    this.fetchTimeoutSeconds = 10,
    this.featureStateSavingEnabled = true, // Always enabled by default
    this.logRetentionDays = 5, // Default to 5 days (minimum in new range)
    this.fetchRetryTimes = 1, // Default to 1 retry
  });

  SettingsModel copyWith({
    CurrencyFetchMode? currencyFetchMode,
    int? fetchTimeoutSeconds,
    bool? featureStateSavingEnabled,
    int? logRetentionDays,
    int? fetchRetryTimes,
  }) {
    return SettingsModel(
      currencyFetchMode: currencyFetchMode ?? this.currencyFetchMode,
      fetchTimeoutSeconds: fetchTimeoutSeconds ?? this.fetchTimeoutSeconds,
      featureStateSavingEnabled:
          featureStateSavingEnabled ?? this.featureStateSavingEnabled,
      logRetentionDays: logRetentionDays ?? this.logRetentionDays,
      fetchRetryTimes: fetchRetryTimes ?? this.fetchRetryTimes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyFetchMode': currencyFetchMode.index,
      'fetchTimeoutSeconds': fetchTimeoutSeconds,
      'featureStateSavingEnabled': featureStateSavingEnabled,
      'logRetentionDays': logRetentionDays,
      'fetchRetryTimes': fetchRetryTimes,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currencyFetchMode:
          CurrencyFetchMode.values[json['currencyFetchMode'] ?? 1],
      fetchTimeoutSeconds: json['fetchTimeoutSeconds'] ?? 10,
      featureStateSavingEnabled: json['featureStateSavingEnabled'] ?? true,
      logRetentionDays: json['logRetentionDays'] ?? 5,
      fetchRetryTimes: json['fetchRetryTimes'] ?? 1,
    );
  }
}
