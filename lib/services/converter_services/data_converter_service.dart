import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/app_logger.dart';

class DataUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor;

  DataUnit({
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

class DataConverterService extends ConverterServiceBase {
  static final DataConverterService _instance =
      DataConverterService._internal();
  factory DataConverterService() => _instance;
  DataConverterService._internal();

  // Performance optimization: Static caches for singleton pattern
  static final Map<String, DataUnit> _unitsCache = <String, DataUnit>{};
  static final Map<String, double> _conversionCache = <String, double>{};
  static final Map<String, String> _formattingCache = <String, String>{};
  static bool _cacheInitialized = false;

  // Performance monitoring
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _formattingCacheHits = 0;
  static int _formattingCacheMisses = 0;

  // Initialize cache with all data storage units for O(1) lookup
  static void _initializeCache() {
    if (_cacheInitialized) return;

    _unitsCache.clear();
    final allUnits = [
      // Base units (bytes)
      DataUnit(id: 'byte', name: 'Byte', symbol: 'B', factor: 1.0),
      DataUnit(id: 'kilobyte', name: 'Kilobyte', symbol: 'KB', factor: 1024.0),
      DataUnit(
          id: 'megabyte',
          name: 'Megabyte',
          symbol: 'MB',
          factor: 1048576.0), // 1024^2
      DataUnit(
          id: 'gigabyte',
          name: 'Gigabyte',
          symbol: 'GB',
          factor: 1073741824.0), // 1024^3
      DataUnit(
          id: 'terabyte',
          name: 'Terabyte',
          symbol: 'TB',
          factor: 1099511627776.0), // 1024^4
      DataUnit(
          id: 'petabyte',
          name: 'Petabyte',
          symbol: 'PB',
          factor: 1125899906842624.0), // 1024^5

      // Bit units (base unit is byte, so bit = 1/8 byte)
      DataUnit(
          id: 'bit', name: 'Bit', symbol: 'bit', factor: 0.125), // 1/8 byte
      DataUnit(
          id: 'kilobit',
          name: 'Kilobit',
          symbol: 'Kbit',
          factor: 128.0), // 1024 bits = 128 bytes
      DataUnit(
          id: 'megabit',
          name: 'Megabit',
          symbol: 'Mbit',
          factor: 131072.0), // 1024^2 bits = 131072 bytes
      DataUnit(
          id: 'gigabit',
          name: 'Gigabit',
          symbol: 'Gbit',
          factor: 134217728.0), // 1024^3 bits = 134217728 bytes
    ];

    for (final unit in allUnits) {
      _unitsCache[unit.id] = unit;
    }
    _cacheInitialized = true;

    logInfo(
        'DataConverterService: Initialized cache with ${_unitsCache.length} data storage units');
  }

  @override
  String get converterType => 'data_storage';

  @override
  String get displayName => 'Data Storage Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'kilobyte',
        'megabyte',
        'gigabyte',
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
            'DataConverterService: Unknown unit in conversion: $fromUnitId -> $toUnitId');
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
          'DataConverterService: Converted $value ${fromUnit.symbol} = $result ${toUnit.symbol}');
      return result;
    } catch (e) {
      logError(
          'DataConverterService: Error converting $fromUnitId to $toUnitId: $e');
      return value;
    }
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  DataUnit? _getUnitById(String unitId) {
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
    // Data storage conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for data storage converter as it doesn't need real-time data
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
    logInfo('DataConverterService: All caches cleared');
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

    return 'Data Storage Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB, '
        'Units Cached: ${_unitsCache.length}';
  }
}
