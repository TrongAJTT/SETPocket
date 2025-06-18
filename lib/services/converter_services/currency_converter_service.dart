import 'package:setpocket/models/converter_models/converter_base.dart';
import 'converter_service_base.dart';
import 'currency_service.dart';
import 'currency_cache_service.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/number_format_service.dart';

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
  // Performance optimization: Static caches for singleton pattern
  static final Map<String, CurrencyUnit> _unitsCache = <String, CurrencyUnit>{};
  static final Map<String, String> _formattingCache = <String, String>{};
  static bool _cacheInitialized = false;

  // Performance monitoring
  static int _unitsCacheHits = 0;
  static int _unitsCacheMisses = 0;
  static int _formattingCacheHits = 0;
  static int _formattingCacheMisses = 0;
  static int _conversionCount = 0;

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

  // Initialize cache with all currency units for O(1) lookup
  static void _initializeCache() {
    if (_cacheInitialized) return;

    _unitsCache.clear();

    final currencies = CurrencyService.getSupportedCurrencies();
    for (final currency in currencies) {
      final unit = CurrencyUnit(
        id: currency.code,
        name: currency.name,
        symbol: currency.symbol,
      );
      _unitsCache[currency.code] = unit;
    }

    _cacheInitialized = true;
    logInfo(
        'CurrencyConverterService: Initialized cache with ${_unitsCache.length} currency units');
  }

  @override
  List<ConverterUnit> get units {
    _initializeCache(); // Ensure cache is initialized
    return _unitsCache.values.toList();
  }

  @override
  Set<String> get defaultVisibleUnits =>
      {'USD', 'EUR', 'GBP', 'JPY', 'VND', 'CNY', 'THB', 'SGD'};

  @override
  ConverterUnit? getUnit(String id) => _getUnitById(id);

  CurrencyUnit? _getUnitById(String unitId) {
    _initializeCache(); // Ensure cache is initialized

    if (_unitsCache.containsKey(unitId)) {
      _unitsCacheHits++;
      return _unitsCache[unitId];
    }

    _unitsCacheMisses++;
    return null;
  }

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    try {
      _conversionCount++;
      _initializeCache(); // Ensure cache is initialized

      // Verify units exist in cache
      final fromCurrencyUnit = _unitsCache[fromUnit];
      final toCurrencyUnit = _unitsCache[toUnit];

      if (fromCurrencyUnit == null || toCurrencyUnit == null) {
        logError(
            'CurrencyConverterService: Unknown currency in conversion: $fromUnit -> $toUnit');
        return 0.0;
      }

      // Use existing CurrencyService for conversion logic (which has its own exchange rate caching)
      final rate = CurrencyService.getExchangeRate(fromUnit, toUnit);
      final result = value * rate;

      logInfo(
          'CurrencyConverterService: Converted $value $fromUnit = $result $toUnit (rate: $rate)');
      return result;
    } catch (e) {
      logError(
          'CurrencyConverterService: Error converting $fromUnit to $toUnit: $e');
      return 0.0;
    }
  }

  // Optimized formatting with cache
  String getFormattedValue(double value, String unitId) {
    // Round to 2 decimal places for cache key consistency (currency precision)
    final roundedValue = (value * 100).round() / 100;
    final cacheKey = '${roundedValue}_$unitId';

    if (_formattingCache.containsKey(cacheKey)) {
      _formattingCacheHits++;
      return _formattingCache[cacheKey]!;
    }

    _formattingCacheMisses++;
    final unit = getUnit(unitId);
    final formatted = unit?.formatValue(value) ?? value.toStringAsFixed(2);

    // Cache the result
    _formattingCache[cacheKey] = formatted;

    // Limit formatting cache size
    if (_formattingCache.length > 1000) {
      _formattingCache.clear();
    }

    return formatted;
  }

  @override
  Future<void> refreshData() async {
    try {
      logInfo('CurrencyConverterService: Refreshing currency data');

      // Use existing currency cache service
      final rates = await CurrencyCacheService.forceRefresh();
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

      // Update CurrencyService with fresh rates
      CurrencyService.updateCurrentRates(rates);

      _lastUpdated = cacheInfo?.lastUpdated;
      _isUsingLiveData = cacheInfo != null && cacheInfo.isValid;

      logInfo('CurrencyConverterService: Currency data refreshed successfully');
    } catch (e) {
      logError('CurrencyConverterService: Error refreshing currency data: $e');
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
      logInfo(
          'CurrencyConverterService: Initializing currency converter service');

      // Initialize cache first
      _initializeCache();

      // Initialize existing currency services
      final rates = await CurrencyCacheService.getRates();
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

      CurrencyService.updateCurrentRates(rates);

      _lastUpdated = cacheInfo?.lastUpdated;
      _isUsingLiveData = cacheInfo != null && cacheInfo.isValid;

      logInfo(
          'CurrencyConverterService: Currency converter service initialized');
    } catch (e) {
      logError(
          'CurrencyConverterService: Error initializing currency converter service: $e');
      _isUsingLiveData = false;
    }
  }

  void dispose() {
    // Clean up any resources if needed
    logInfo('CurrencyConverterService: Currency converter service disposed');
  }

  // Performance monitoring methods
  static Map<String, dynamic> getCacheStats() {
    final unitsTotal = _unitsCacheHits + _unitsCacheMisses;
    final unitsHitRate =
        unitsTotal > 0 ? (_unitsCacheHits / unitsTotal * 100) : 0.0;

    final formattingTotal = _formattingCacheHits + _formattingCacheMisses;
    final formattingHitRate = formattingTotal > 0
        ? (_formattingCacheHits / formattingTotal * 100)
        : 0.0;

    // Also include CurrencyService cache stats
    final currencyServiceStats = CurrencyService.getCacheStats();

    return {
      'unitsCacheHits': _unitsCacheHits,
      'unitsCacheMisses': _unitsCacheMisses,
      'unitsHitRate': unitsHitRate.toStringAsFixed(1),
      'formattingCacheHits': _formattingCacheHits,
      'formattingCacheMisses': _formattingCacheMisses,
      'formattingHitRate': formattingHitRate.toStringAsFixed(1),
      'formattingCacheSize': _formattingCache.length,
      'unitsCacheSize': _unitsCache.length,
      'totalConversions': _conversionCount,
      'currencyServiceStats': currencyServiceStats,
    };
  }

  // Get performance metrics
  static Map<String, dynamic> getPerformanceMetrics() {
    final cacheStats = getCacheStats();
    final memoryStats = getMemoryStats();

    return {
      ...cacheStats,
      ...memoryStats,
      'totalUnitCacheOperations': _unitsCacheHits + _unitsCacheMisses,
      'totalFormattingOperations':
          _formattingCacheHits + _formattingCacheMisses,
    };
  }

  // Clear performance stats
  static void clearCacheStats() {
    _unitsCacheHits = 0;
    _unitsCacheMisses = 0;
    _formattingCacheHits = 0;
    _formattingCacheMisses = 0;
    _conversionCount = 0;

    // Also clear CurrencyService stats
    CurrencyService.clearCacheStats();
  }

  // Clear all caches (for memory management)
  static void clearCaches() {
    _formattingCache.clear();
    _unitsCache.clear();
    _cacheInitialized = false;
    clearCacheStats();
    logInfo('CurrencyConverterService: All caches cleared');
  }

  // Get memory usage estimation
  static Map<String, dynamic> getMemoryStats() {
    final formattingMemory =
        _formattingCache.length * 50; // Estimated bytes per entry
    final unitsMemory =
        _unitsCache.length * 200; // Estimated bytes per unit object
    final totalMemory = formattingMemory + unitsMemory;

    return {
      'formattingCacheMemoryBytes': formattingMemory,
      'unitsCacheMemoryBytes': unitsMemory,
      'totalMemoryBytes': totalMemory,
      'totalMemoryKB': (totalMemory / 1024).toStringAsFixed(2),
    };
  }

  // Get performance summary for logging
  static String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final unitsHitRate = metrics['unitsHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Currency Converter Performance: '
        'Units Cache Hit Rate: $unitsHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB, '
        'Total Conversions: $_conversionCount, '
        'Units Cached: ${_unitsCache.length}';
  }
}
