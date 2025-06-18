import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/app_logger.dart';

class VolumeUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor;

  VolumeUnit({
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

class VolumeConverterService extends ConverterServiceBase {
  static final VolumeConverterService _instance =
      VolumeConverterService._internal();
  factory VolumeConverterService() => _instance;
  VolumeConverterService._internal();

  // Performance optimization: Static caches for singleton pattern
  static final Map<String, VolumeUnit> _unitsCache = <String, VolumeUnit>{};
  static final Map<String, double> _conversionCache = <String, double>{};
  static final Map<String, String> _formattingCache = <String, String>{};
  static bool _cacheInitialized = false;

  // Performance monitoring
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _formattingCacheHits = 0;
  static int _formattingCacheMisses = 0;

  // Initialize cache with all volume units for O(1) lookup
  static void _initializeCache() {
    if (_cacheInitialized) return;

    _unitsCache.clear();
    final allUnits = [
      // Metric units (base: cubic meter)
      VolumeUnit(
          id: 'cubic_meter',
          name: 'Cubic Meter',
          symbol: 'm³',
          factor: 1.0), // Base unit

      // Liter family
      VolumeUnit(id: 'liter', name: 'Liter', symbol: 'L', factor: 0.001),
      VolumeUnit(
          id: 'milliliter', name: 'Milliliter', symbol: 'mL', factor: 0.000001),
      VolumeUnit(
          id: 'cubic_centimeter',
          name: 'Cubic Centimeter',
          symbol: 'cm³',
          factor: 0.000001),
      VolumeUnit(
          id: 'hectoliter', name: 'Hectoliter', symbol: 'hL', factor: 0.1),

      // Imperial/US units
      VolumeUnit(
          id: 'gallon_us',
          name: 'Gallon (US)',
          symbol: 'gal',
          factor: 0.003785411784),
      VolumeUnit(
          id: 'gallon_uk',
          name: 'Gallon (UK)',
          symbol: 'gal',
          factor: 0.00454609),
      VolumeUnit(
          id: 'quart_us',
          name: 'Quart (US)',
          symbol: 'qt',
          factor: 0.000946352946),
      VolumeUnit(
          id: 'pint_us',
          name: 'Pint (US)',
          symbol: 'pt',
          factor: 0.000473176473),
      VolumeUnit(
          id: 'cup', name: 'Cup', symbol: 'cup', factor: 0.0002365882365),
      VolumeUnit(
          id: 'fluid_ounce_us',
          name: 'Fluid Ounce (US)',
          symbol: 'fl oz',
          factor: 0.00002957352956),

      // Cubic measurements
      VolumeUnit(
          id: 'cubic_inch',
          name: 'Cubic Inch',
          symbol: 'in³',
          factor: 0.000016387064),
      VolumeUnit(
          id: 'cubic_foot',
          name: 'Cubic Foot',
          symbol: 'ft³',
          factor: 0.028316846592),
      VolumeUnit(
          id: 'cubic_yard',
          name: 'Cubic Yard',
          symbol: 'yd³',
          factor: 0.764554857984),

      // Special units
      VolumeUnit(
          id: 'barrel',
          name: 'Barrel (Oil)',
          symbol: 'bbl',
          factor: 0.158987294928),
    ];

    for (final unit in allUnits) {
      _unitsCache[unit.id] = unit;
    }
    _cacheInitialized = true;

    logInfo(
        'VolumeConverterService: Initialized cache with ${_unitsCache.length} volume units');
  }

  @override
  String get converterType => 'volume';

  @override
  String get displayName => 'Volume Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'cubic_meter',
        'liter',
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
            'VolumeConverterService: Unknown unit in conversion: $fromUnitId -> $toUnitId');
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
          'VolumeConverterService: Converted $value ${fromUnit.symbol} = $result ${toUnit.symbol}');
      return result;
    } catch (e) {
      logError(
          'VolumeConverterService: Error converting $fromUnitId to $toUnitId: $e');
      return value;
    }
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  VolumeUnit? _getUnitById(String unitId) {
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
    // Volume conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for volume converter as it doesn't need real-time data
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
    logInfo('VolumeConverterService: All caches cleared');
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

    return 'Volume Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB, '
        'Units Cached: ${_unitsCache.length}';
  }
}
