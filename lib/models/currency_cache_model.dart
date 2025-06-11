import 'package:hive/hive.dart';
import '../services/converter_services/currency_service.dart';

part 'currency_cache_model.g.dart';

@HiveType(typeId: 10)
class CurrencyCacheModel extends HiveObject {
  @HiveField(0)
  Map<String, double> rates;

  @HiveField(1)
  DateTime lastUpdated;

  @HiveField(2)
  bool isValid;

  @HiveField(3)
  Map<String, int>? currencyStatuses; // Store status as int (enum index)

  @HiveField(4)
  Map<String, int>?
      currencyFetchTimes; // Store last fetch timestamp for each currency

  CurrencyCacheModel({
    required this.rates,
    required this.lastUpdated,
    this.isValid = true,
    this.currencyStatuses,
    this.currencyFetchTimes,
  });

  // Helper to get currency status
  CurrencyStatus getCurrencyStatus(String currencyCode) {
    final statusIndex = currencyStatuses?[currencyCode];
    if (statusIndex != null) {
      return CurrencyStatus.values[statusIndex];
    }
    return CurrencyStatus.staticRate;
  }

  // Helper to set currency statuses
  void setCurrencyStatuses(Map<String, CurrencyStatus> statuses) {
    currencyStatuses = statuses.map((key, value) => MapEntry(key, value.index));
  }

  // Helper to get all currency statuses
  Map<String, CurrencyStatus> getCurrencyStatuses() {
    if (currencyStatuses == null) return {};

    return currencyStatuses!.map((key, value) {
      return MapEntry(key, CurrencyStatus.values[value]);
    });
  }

  // Helper to set currency fetch times
  void setCurrencyFetchTimes(Map<String, DateTime> fetchTimes) {
    currencyFetchTimes = fetchTimes
        .map((key, value) => MapEntry(key, value.millisecondsSinceEpoch));
  }

  // Helper to get currency fetch time
  DateTime? getCurrencyFetchTime(String currencyCode) {
    final timestamp = currencyFetchTimes?[currencyCode];
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  // Check if currency needs refresh (older than 1 hour)
  bool currencyNeedsRefresh(String currencyCode) {
    final fetchTime = getCurrencyFetchTime(currencyCode);
    if (fetchTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(fetchTime);
    return difference.inHours >= 1;
  }

  // Check if cache is expired (older than 24 hours)
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inHours >= 24;
  }

  // Check if cache should be refreshed based on settings
  bool shouldRefresh(CurrencyFetchMode fetchMode) {
    switch (fetchMode) {
      case CurrencyFetchMode.manual:
        return false; // Only refresh when manually requested
      case CurrencyFetchMode.onceADay:
        return isExpired;
      case CurrencyFetchMode.everytime:
        return true; // Always refresh
    }
  }
}

@HiveType(typeId: 11)
enum CurrencyFetchMode {
  @HiveField(0)
  manual,

  @HiveField(1)
  onceADay,

  @HiveField(2)
  everytime,
}

extension CurrencyFetchModeExtension on CurrencyFetchMode {
  String displayName(dynamic loc) {
    switch (this) {
      case CurrencyFetchMode.manual:
        return loc?.fetchModeManual ?? 'Manual';
      case CurrencyFetchMode.onceADay:
        return loc?.fetchModeOnceADay ?? 'Once a day';
      case CurrencyFetchMode.everytime:
        return loc?.fetchModeEverytime ?? 'Every time';
    }
  }

  String description(dynamic loc) {
    switch (this) {
      case CurrencyFetchMode.manual:
        return loc?.fetchModeManualDesc ??
            'Fetch rates only when manually requested';
      case CurrencyFetchMode.onceADay:
        return loc?.fetchModeOnceADayDesc ??
            'Automatically fetch rates once per day';
      case CurrencyFetchMode.everytime:
        return loc?.fetchModeEverytimeDesc ??
            'Fetch fresh rates every time you use the converter';
    }
  }
}
