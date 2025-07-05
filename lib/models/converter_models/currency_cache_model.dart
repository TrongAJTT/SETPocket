import 'package:isar/isar.dart';
import 'package:setpocket/services/converter_services/currency_service.dart';

part 'currency_cache_model.g.dart';

@embedded
class RateEntry {
  String? key;
  double? value;
}

@embedded
class StatusEntry {
  String? key;
  int? value;
}

@embedded
class FetchTimeEntry {
  String? key;
  int? value;
}

@Collection()
class CurrencyCacheModel {
  Id id = Isar.autoIncrement;

  List<RateEntry> rates;
  DateTime lastUpdated;
  bool isValid;
  List<StatusEntry> currencyStatuses;
  List<FetchTimeEntry> currencyFetchTimes;

  CurrencyCacheModel({
    required this.rates,
    required this.lastUpdated,
    this.isValid = true,
    this.currencyStatuses = const [],
    this.currencyFetchTimes = const [],
  });

  CurrencyStatus getCurrencyStatus(String currencyCode) {
    final statusIndex = currencyStatuses
        .firstWhere((e) => e.key == currencyCode, orElse: () => StatusEntry())
        .value;
    if (statusIndex != null) {
      return CurrencyStatus.values[statusIndex];
    }
    return CurrencyStatus.staticRate;
  }

  void setCurrencyStatuses(Map<String, CurrencyStatus> statuses) {
    currencyStatuses = statuses.entries
        .map((e) => StatusEntry()
          ..key = e.key
          ..value = e.value.index)
        .toList();
  }

  @ignore
  Map<String, double> get getRatesAsMap {
    return {
      for (var entry in rates)
        if (entry.key != null && entry.value != null) entry.key!: entry.value!
    };
  }

  @ignore
  Map<String, CurrencyStatus> get getCurrencyStatuses {
    return {
      for (var entry in currencyStatuses)
        if (entry.key != null && entry.value != null)
          entry.key!: CurrencyStatus.values[entry.value!]
    };
  }

  void setCurrencyFetchTimes(Map<String, DateTime> fetchTimes) {
    currencyFetchTimes = fetchTimes.entries
        .map((e) => FetchTimeEntry()
          ..key = e.key
          ..value = e.value.millisecondsSinceEpoch)
        .toList();
  }

  DateTime? getCurrencyFetchTime(String currencyCode) {
    final timestamp = currencyFetchTimes
        .firstWhere((e) => e.key == currencyCode,
            orElse: () => FetchTimeEntry())
        .value;
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  bool currencyNeedsRefresh(String currencyCode) {
    final fetchTime = getCurrencyFetchTime(currencyCode);
    if (fetchTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(fetchTime);
    return difference.inHours >= 1;
  }

  @ignore
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inHours >= 24;
  }

  bool shouldRefresh(CurrencyFetchMode fetchMode) {
    switch (fetchMode) {
      case CurrencyFetchMode.manual:
        return false;
      case CurrencyFetchMode.onceADay:
        return isExpired;
    }
  }
}

@embedded
class CurrencyFetchModeProxy {
  @Enumerated(EnumType.ordinal)
  late CurrencyFetchMode mode;
}

enum CurrencyFetchMode {
  manual,
  onceADay,
}

extension CurrencyFetchModeExtension on CurrencyFetchMode {
  String displayName(dynamic loc) {
    switch (this) {
      case CurrencyFetchMode.manual:
        return loc?.fetchModeManual ?? 'Manual';
      case CurrencyFetchMode.onceADay:
        return loc?.fetchModeOnceADay ?? 'Once a day';
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
    }
  }
}
