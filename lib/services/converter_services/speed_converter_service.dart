import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/app_logger.dart';

class SpeedUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor;

  SpeedUnit({
    required String id,
    required String name,
    required String symbol,
    required double factor,
  })  : _id = id,
        _name = name,
        _symbol = symbol,
        _factor = factor;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get symbol => _symbol;

  double get factor => _factor;

  @override
  String formatValue(double value) {
    return NumberFormatService.formatUnit(value);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
        'factor': factor,
      };
}

class SpeedConverterService extends ConverterServiceBase {
  static final SpeedConverterService _instance =
      SpeedConverterService._internal();
  factory SpeedConverterService() => _instance;
  SpeedConverterService._internal();

  // Performance optimization: Static caches for singleton pattern
  static final Map<String, SpeedUnit> _unitsCache = <String, SpeedUnit>{};
  static final Map<String, double> _conversionCache = <String, double>{};
  static final Map<String, String> _formattingCache = <String, String>{};
  static bool _cacheInitialized = false;

  // Performance monitoring
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _formattingCacheHits = 0;
  static int _formattingCacheMisses = 0;

  // Initialize cache with all speed units for O(1) lookup
  static void _initializeCache() {
    if (_cacheInitialized) return;

    _unitsCache.clear();
    final allUnits = [
      SpeedUnit(
          id: 'meters_per_second',
          name: 'Meters per Second',
          symbol: 'm/s',
          factor: 1.0), // Base unit
      SpeedUnit(
          id: 'kilometers_per_hour',
          name: 'Kilometers per Hour',
          symbol: 'km/h',
          factor: 0.277778), // 1 km/h = 0.277778 m/s
      SpeedUnit(
          id: 'miles_per_hour',
          name: 'Miles per Hour',
          symbol: 'mph',
          factor: 0.44704), // 1 mph = 0.44704 m/s
      SpeedUnit(
          id: 'knots',
          name: 'Knots',
          symbol: 'kn',
          factor: 0.514444), // 1 knot = 0.514444 m/s
      SpeedUnit(
          id: 'feet_per_second',
          name: 'Feet per Second',
          symbol: 'ft/s',
          factor: 0.3048), // 1 ft/s = 0.3048 m/s
      SpeedUnit(
          id: 'mach',
          name: 'Mach',
          symbol: 'M',
          factor: 343.0), // 1 Mach ≈ 343 m/s (at sea level, 20°C)
    ];

    for (final unit in allUnits) {
      _unitsCache[unit.id] = unit;
    }
    _cacheInitialized = true;

    logInfo(
        'SpeedConverterService: Initialized cache with ${_unitsCache.length} speed units');
  }

  @override
  String get converterType => 'speed';

  @override
  String get displayName => 'Speed Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'kilometers_per_hour',
        'meters_per_second',
        'miles_per_hour',
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

      // Performance optimization: Use conversion cache for conversion factors
      final cacheKey = '${fromUnitId}_$toUnitId';
      if (_conversionCache.containsKey(cacheKey)) {
        _cacheHits++;
        return value * _conversionCache[cacheKey]!;
      }

      _cacheMisses++;
      _initializeCache(); // Ensure cache is initialized

      final fromUnit = _unitsCache[fromUnitId];
      final toUnit = _unitsCache[toUnitId];

      if (fromUnit == null || toUnit == null) {
        logError(
            'SpeedConverterService: Unknown unit in conversion: $fromUnitId -> $toUnitId');
        throw Exception('Unit not found: $fromUnitId or $toUnitId');
      }

      // Calculate conversion factor: fromUnit.factor / toUnit.factor
      final conversionFactor = fromUnit.factor / toUnit.factor;
      _conversionCache[cacheKey] = conversionFactor;

      // Limit cache size to prevent memory issues
      if (_conversionCache.length > 500) {
        _conversionCache.clear();
      }

      final result = value * conversionFactor;
      logInfo(
          'SpeedConverterService: Converted $value ${fromUnit.symbol} = $result ${toUnit.symbol}');
      return result;
    } catch (e) {
      logError(
          'SpeedConverterService: Error converting $fromUnitId to $toUnitId: $e');
      return value;
    }
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  SpeedUnit? _getUnitById(String unitId) {
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
    // Speed conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for speed converter as it doesn't need real-time data
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
    logInfo('SpeedConverterService: All caches cleared');
  }

  // Get memory usage estimation
  static Map<String, dynamic> getMemoryStats() {
    final conversionMemory =
        _conversionCache.length * 40; // Estimated bytes per entry
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

    return 'Speed Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB, '
        'Units Cached: ${_unitsCache.length}';
  }
}
