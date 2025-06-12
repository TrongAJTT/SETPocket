import '../../models/converter_base.dart';
import 'converter_service_base.dart';
import 'currency_service.dart';
import 'currency_cache_service.dart';
import '../app_logger.dart';

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
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
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
  List<ConverterUnit> get units => _supportedCurrencies;

  static final List<CurrencyUnit> _supportedCurrencies = [
    CurrencyUnit(id: 'USD', name: 'US Dollar', symbol: '\$'),
    CurrencyUnit(id: 'EUR', name: 'Euro', symbol: '€'),
    CurrencyUnit(id: 'GBP', name: 'British Pound', symbol: '£'),
    CurrencyUnit(id: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    CurrencyUnit(id: 'VND', name: 'Vietnamese Dong', symbol: '₫'),
    CurrencyUnit(id: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    CurrencyUnit(id: 'THB', name: 'Thai Baht', symbol: '฿'),
    CurrencyUnit(id: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    CurrencyUnit(id: 'KRW', name: 'South Korean Won', symbol: '₩'),
    CurrencyUnit(id: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    CurrencyUnit(id: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    CurrencyUnit(id: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
  ];

  @override
  Set<String> get defaultVisibleUnits =>
      {'USD', 'EUR', 'GBP', 'JPY', 'VND', 'CNY', 'THB', 'SGD'};

  @override
  ConverterUnit? getUnit(String id) {
    try {
      return _supportedCurrencies.firstWhere((unit) => unit.id == id);
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
