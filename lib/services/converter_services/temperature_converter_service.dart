import 'package:setpocket/models/converter_models/converter_base.dart';
import 'converter_service_base.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/app_logger.dart';

class TemperatureUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;

  TemperatureUnit({
    required String id,
    required String name,
    required String symbol,
  })  : _id = id,
        _name = name,
        _symbol = symbol;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get symbol => _symbol;

  @override
  String formatValue(double value) {
    return NumberFormatService.formatUnit(value);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
      };
}

class TemperatureConverterService extends ConverterServiceBase {
  static final TemperatureConverterService _instance =
      TemperatureConverterService._internal();
  factory TemperatureConverterService() => _instance;
  TemperatureConverterService._internal();

  // Performance optimization: Static caches for singleton pattern
  static final Map<String, TemperatureUnit> _unitsCache =
      <String, TemperatureUnit>{};
  static final Map<String, double> _conversionCache = <String, double>{};
  static final Map<String, String> _formattingCache = <String, String>{};
  static bool _cacheInitialized = false;

  // Performance monitoring
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _formattingCacheHits = 0;
  static int _formattingCacheMisses = 0;

  // Initialize cache with all temperature units for O(1) lookup
  static void _initializeCache() {
    if (_cacheInitialized) return;

    _unitsCache.clear();
    final allUnits = [
      // Common units
      TemperatureUnit(id: 'celsius', name: 'Celsius', symbol: '°C'),
      TemperatureUnit(id: 'fahrenheit', name: 'Fahrenheit', symbol: '°F'),
      // Less common
      TemperatureUnit(id: 'kelvin', name: 'Kelvin', symbol: 'K'),
      // Rare units
      TemperatureUnit(id: 'rankine', name: 'Rankine', symbol: '°R'),
      TemperatureUnit(id: 'reaumur', name: 'Réaumur', symbol: '°Ré'),
      TemperatureUnit(id: 'delisle', name: 'Delisle', symbol: '°De'),
    ];

    for (final unit in allUnits) {
      _unitsCache[unit.id] = unit;
    }
    _cacheInitialized = true;

    logInfo(
        'TemperatureConverterService: Initialized cache with ${_unitsCache.length} temperature units');
  }

  @override
  String get converterType => 'temperature';

  @override
  String get displayName => 'Temperature Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'celsius',
        'fahrenheit',
      };

  @override
  List<ConverterUnit> get units {
    _initializeCache(); // Ensure cache is initialized
    return _unitsCache.values.toList();
  }

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    try {
      if (fromUnitId == toUnitId) return value;

      // Performance optimization: Use conversion cache for complete conversions
      // Round to 3 decimal places for cache key consistency
      final roundedValue = (value * 1000).round() / 1000;
      final cacheKey = '${roundedValue}_${fromUnitId}_$toUnitId';

      if (_conversionCache.containsKey(cacheKey)) {
        _cacheHits++;
        return _conversionCache[cacheKey]!;
      }

      _cacheMisses++;
      _initializeCache(); // Ensure cache is initialized

      // Verify units exist
      final fromUnit = _unitsCache[fromUnitId];
      final toUnit = _unitsCache[toUnitId];

      if (fromUnit == null || toUnit == null) {
        logError(
            'TemperatureConverterService: Unknown unit in conversion: $fromUnitId -> $toUnitId');
        throw Exception('Unknown temperature unit: $fromUnitId or $toUnitId');
      }

      // First convert from source unit to Celsius
      double celsius = _toCelsius(value, fromUnitId);

      // Then convert from Celsius to target unit
      final result = _fromCelsius(celsius, toUnitId);

      // Cache the result
      _conversionCache[cacheKey] = result;

      // Limit cache size to prevent memory issues
      if (_conversionCache.length > 500) {
        _conversionCache.clear();
      }

      logInfo(
          'TemperatureConverterService: Converted $value ${fromUnit.symbol} = $result ${toUnit.symbol}');
      return result;
    } catch (e) {
      logError(
          'TemperatureConverterService: Error converting $fromUnitId to $toUnitId: $e');
      return value;
    }
  }

  // Convert any temperature unit to Celsius
  double _toCelsius(double value, String unitId) {
    switch (unitId) {
      case 'celsius':
        return value;
      case 'fahrenheit':
        return (value - 32) * 5 / 9;
      case 'kelvin':
        return value - 273.15;
      case 'rankine':
        return (value - 491.67) * 5 / 9;
      case 'reaumur':
        return value * 5 / 4;
      case 'delisle':
        return 100 - value * 2 / 3;
      default:
        throw Exception('Unknown temperature unit: $unitId');
    }
  }

  // Convert Celsius to any temperature unit
  double _fromCelsius(double celsius, String unitId) {
    switch (unitId) {
      case 'celsius':
        return celsius;
      case 'fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'kelvin':
        return celsius + 273.15;
      case 'rankine':
        return (celsius + 273.15) * 9 / 5;
      case 'reaumur':
        return celsius * 4 / 5;
      case 'delisle':
        return (100 - celsius) * 3 / 2;
      default:
        throw Exception('Unknown temperature unit: $unitId');
    }
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  TemperatureUnit? _getUnitById(String unitId) {
    _initializeCache(); // Ensure cache is initialized
    return _unitsCache[unitId];
  }

  // Optimized formatting with cache
  String getFormattedValue(double value, String unitId) {
    // Round to 3 decimal places for cache key consistency
    final roundedValue = (value * 1000).round() / 1000;
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
  ConversionStatus getUnitStatus(String unitId) {
    // Temperature conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for temperature converter as it doesn't need real-time data
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;

  // Performance monitoring methods
  static Map<String, dynamic> getCacheStats() {
    final total = _cacheHits + _cacheMisses;
    final hitRate = total > 0 ? (_cacheHits / total * 100) : 0.0;

    final formattingTotal = _formattingCacheHits + _formattingCacheMisses;
    final formattingHitRate = formattingTotal > 0
        ? (_formattingCacheHits / formattingTotal * 100)
        : 0.0;

    return {
      'conversionCacheHits': _cacheHits,
      'conversionCacheMisses': _cacheMisses,
      'conversionHitRate': hitRate.toStringAsFixed(1),
      'formattingCacheHits': _formattingCacheHits,
      'formattingCacheMisses': _formattingCacheMisses,
      'formattingHitRate': formattingHitRate.toStringAsFixed(1),
      'conversionCacheSize': _conversionCache.length,
      'formattingCacheSize': _formattingCache.length,
      'unitsCacheSize': _unitsCache.length,
    };
  }

  // Get performance metrics
  static Map<String, dynamic> getPerformanceMetrics() {
    final cacheStats = getCacheStats();
    final memoryStats = getMemoryStats();

    return {
      ...cacheStats,
      ...memoryStats,
      'totalCacheOperations': _cacheHits + _cacheMisses,
      'totalFormattingOperations':
          _formattingCacheHits + _formattingCacheMisses,
    };
  }

  // Clear performance stats
  static void clearCacheStats() {
    _cacheHits = 0;
    _cacheMisses = 0;
    _formattingCacheHits = 0;
    _formattingCacheMisses = 0;
  }

  // Clear all caches (for memory management)
  static void clearCaches() {
    _conversionCache.clear();
    _formattingCache.clear();
    _unitsCache.clear();
    _cacheInitialized = false;
    clearCacheStats();
    logInfo('TemperatureConverterService: All caches cleared');
  }

  // Get memory usage estimation
  static Map<String, dynamic> getMemoryStats() {
    final conversionMemory = _conversionCache.length *
        60; // Higher estimate for complete conversion results
    final formattingMemory =
        _formattingCache.length * 50; // Estimated bytes per entry
    final unitsMemory =
        _unitsCache.length * 200; // Estimated bytes per unit object
    final totalMemory = conversionMemory + formattingMemory + unitsMemory;

    return {
      'conversionCacheMemoryBytes': conversionMemory,
      'formattingCacheMemoryBytes': formattingMemory,
      'unitsCacheMemoryBytes': unitsMemory,
      'totalMemoryBytes': totalMemory,
      'totalMemoryKB': (totalMemory / 1024).toStringAsFixed(2),
    };
  }

  // Get performance summary for logging
  static String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final conversionHitRate = metrics['conversionHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Temperature Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB, '
        'Units Cached: ${_unitsCache.length}';
  }
}
