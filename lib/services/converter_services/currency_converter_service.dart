import '../../models/converter_models/converter_base.dart';
import 'converter_service_base.dart';
import 'currency_service.dart';
import 'currency_cache_service.dart';
import '../app_logger.dart';
import '../number_format_service.dart';

class CurrencyUnit extends ConverterUnit {
  @override
  final String id;
  @override
  final String name;
  @override
  final String symbol;

  CurrencyUnit({
    required this.id,
    required this.name,
    required this.symbol,
  });

  @override
  String formatValue(double value) {
    return NumberFormatService.formatCurrency(value);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
      };

  factory CurrencyUnit.fromJson(Map<String, dynamic> json) => CurrencyUnit(
        id: json['id'],
        name: json['name'],
        symbol: json['symbol'],
      );
}

class CurrencyConverterService implements ConverterServiceBase {
  @override
  String get converterType => 'currency';

  @override
  String get displayName => 'Currency Converter';

  @override
  bool get requiresRealTimeData => true;

  @override
  DateTime? get lastUpdated => _lastUpdated;

  @override
  bool get isUsingLiveData => _isUsingLiveData;

  DateTime? _lastUpdated;
  bool _isUsingLiveData = false;

  @override
  List<ConverterUnit> get units {
    // Use CurrencyService to get all 83 supported currencies
    return CurrencyService.getSupportedCurrencies()
        .map((currency) => CurrencyUnit(
              id: currency.code,
              name: currency.name,
              symbol: currency.symbol,
            ))
        .toList();
  }

  @override
  Set<String> get defaultVisibleUnits =>
      {'USD', 'EUR', 'GBP', 'JPY', 'VND', 'CNY', 'THB', 'SGD'};

  @override
  ConverterUnit? getUnit(String id) {
    try {
      final currency = CurrencyService.getSupportedCurrencies()
          .firstWhere((currency) => currency.code == id);
      return CurrencyUnit(
        id: currency.code,
        name: currency.name,
        symbol: currency.symbol,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    try {
      // Use existing CurrencyService for conversion logic
      // final fromCurrency =
      CurrencyService.getSupportedCurrencies()
          .firstWhere((c) => c.code == fromUnit);
      // final toCurrency =
      CurrencyService.getSupportedCurrencies()
          .firstWhere((c) => c.code == toUnit);

      // Get conversion rate
      final rate = CurrencyService.getExchangeRate(fromUnit, toUnit);
      return value * rate;
    } catch (e) {
      AppLogger.instance.error('Error converting $fromUnit to $toUnit: $e');
      return 0.0;
    }
  }

  @override
  Future<void> refreshData() async {
    try {
      logError('Refreshing currency data');

      // Use existing currency cache service
      final rates = await CurrencyCacheService.forceRefresh();
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

      // Update CurrencyService with fresh rates
      CurrencyService.updateCurrentRates(rates);

      _lastUpdated = cacheInfo?.lastUpdated;
      _isUsingLiveData = cacheInfo != null && cacheInfo.isValid;

      logInfo('Currency data refreshed successfully');
    } catch (e) {
      logError('Error refreshing currency data: $e');
      _isUsingLiveData = false;
      rethrow;
    }
  }

  @override
  ConversionStatus getUnitStatus(String unitId) {
    final status = CurrencyService.getCurrencyStatus(unitId);

    switch (status) {
      case CurrencyStatus.success:
        return ConversionStatus.success;
      case CurrencyStatus.failed:
        return ConversionStatus.failed;
      case CurrencyStatus.timeout:
        return ConversionStatus.timeout;
      case CurrencyStatus.staticRate:
        return ConversionStatus.success;
      case CurrencyStatus.notSupported:
        return ConversionStatus.notAvailable;
      case CurrencyStatus.fetchedRecently:
        return ConversionStatus.success;
      case CurrencyStatus.fetching:
        return ConversionStatus.loading;
    }
  }

  Future<void> initialize() async {
    try {
      logInfo('Initializing currency converter service');

      // Initialize existing currency services
      final rates = await CurrencyCacheService.getRates();
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

      CurrencyService.updateCurrentRates(rates);

      _lastUpdated = cacheInfo?.lastUpdated;
      _isUsingLiveData = cacheInfo != null && cacheInfo.isValid;

      logInfo('Currency converter service initialized');
    } catch (e) {
      logError('Error initializing currency converter service: $e');
      _isUsingLiveData = false;
    }
  }

  void dispose() {
    // Clean up any resources if needed
    logInfo('Currency converter service disposed');
  }
}
