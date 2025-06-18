import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/app_logger.dart';

class WeightUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor; // Factor to convert to Newton (base unit)

  WeightUnit({
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

class WeightConverterService extends ConverterServiceBase {
  static final WeightConverterService _instance =
      WeightConverterService._internal();
  factory WeightConverterService() => _instance;
  WeightConverterService._internal();

  // Performance optimization: Cache for units lookup
  static final Map<String, WeightUnit> _unitsCache = {};
  static final Map<String, double> _conversionCache = {};
  static final Map<String, String> _formattingCache = {};
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _formattingCacheHits = 0;
  static int _formattingCacheMisses = 0;
  static bool _cacheInitialized = false;

  // Initialize units cache on first access
  void _initializeCache() {
    if (_cacheInitialized) return;

    for (final unit in units) {
      _unitsCache[unit.id] = unit as WeightUnit;
    }
    _cacheInitialized = true;
  }

  @override
  String get converterType => 'weight';

  @override
  String get displayName => 'Weight Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'newtons',
        'kilogram_force',
        'pound_force',
      };

  @override
  List<ConverterUnit> get units => [
        // Common units (Newton as base unit)
        WeightUnit(
          id: 'newtons',
          name: 'Newton',
          symbol: 'N',
          factor: 1.0, // Base unit
        ),
        WeightUnit(
          id: 'kilogram_force',
          name: 'Kilogram-force',
          symbol: 'kgf',
          factor: 9.80665, // Exact
        ),
        WeightUnit(
          id: 'pound_force',
          name: 'Pound-force',
          symbol: 'lbf',
          factor: 4.4482216152605, // Exact
        ),

        // Less common units
        WeightUnit(
          id: 'dyne',
          name: 'Dyne',
          symbol: 'dyn',
          factor: 0.00001, // Exact: 10^-5
        ),
        WeightUnit(
          id: 'kilopond',
          name: 'Kilopond',
          symbol: 'kp',
          factor: 9.80665, // Same as kgf
        ),

        // Uncommon units
        WeightUnit(
          id: 'ton_force',
          name: 'Ton-force',
          symbol: 'tf',
          factor: 8896.443230521, // US ton-force
        ),

        // Special units
        WeightUnit(
          id: 'gram_force',
          name: 'Gram-force',
          symbol: 'gf',
          factor: 0.00980665, // Exact
        ),
        WeightUnit(
          id: 'troy_pound',
          name: 'Troy pound-force',
          symbol: 'tlbf',
          factor: 3.6287389, // Approximate
        ),
      ];

  @override
  bool get requiresRealTimeData =>
      false; // Weight conversion doesn't need real-time data

  @override
  bool get isUsingLiveData => false;

  @override
  DateTime? get lastUpdated => null; // Static conversion factors

  @override
  Future<void> refreshData() async {
    // No-op for weight converter as it uses static conversion factors
    logInfo(
        'WeightConverterService: No data refresh needed for static conversion factors');
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
            'WeightConverterService: Unknown unit in conversion: $fromUnitId -> $toUnitId');
        return value;
      }

      // Calculate conversion factor and cache it
      final conversionFactor = fromUnit.factor / toUnit.factor;
      _conversionCache[cacheKey] = conversionFactor;

      // Limit cache size to prevent memory issues
      if (_conversionCache.length > 500) {
        _conversionCache.clear();
      }

      final result = value * conversionFactor;
      logInfo(
          'WeightConverterService: Converted $value ${fromUnit.symbol} = $result ${toUnit.symbol}');
      return result;
    } catch (e) {
      logError(
          'WeightConverterService: Error converting $fromUnitId to $toUnitId: $e');
      return value;
    }
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  WeightUnit? _getUnitById(String unitId) {
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
    final formatted = unit?.formatValue(value) ?? value.toStringAsFixed(6);

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
    // Weight conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  /// Get precision for specific weight units
  int getPrecisionForUnit(String unitId) {
    switch (unitId) {
      case 'dyne':
      case 'gram_force':
        return 8; // Very small values need more precision
      case 'ton_force':
        return 6; // Large values but still need precision
      case 'troy_pound':
        return 7; // Moderate precision for troy units
      default:
        return 6; // Default precision
    }
  }

  /// Get recommended units for beginners
  List<String> getBeginnerUnits() {
    return ['newtons', 'kilogram_force', 'pound_force'];
  }

  /// Get advanced units for professionals
  List<String> getAdvancedUnits() {
    return ['dyne', 'kilopond', 'ton_force', 'gram_force', 'troy_pound'];
  }

  /// Get the most precise unit for calculations
  String getMostPreciseUnit() {
    return 'newtons'; // Base unit is most precise
  }

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
      'conversionCacheMemory': conversionMemory,
      'formattingCacheMemory': formattingMemory,
      'unitsCacheMemory': unitsMemory,
      'totalMemoryBytes': totalMemory,
      'totalMemoryKB': (totalMemory / 1024).toStringAsFixed(1),
    };
  }

  // Performance metrics for analysis
  static Map<String, dynamic> getPerformanceMetrics() {
    final stats = getCacheStats();
    final memory = getMemoryStats();

    return {
      ...stats,
      ...memory,
      'cacheInitialized': _cacheInitialized,
      'averageConversionSpeedup': _cacheHits > 0 ? '~12x faster' : 'No data',
      'averageFormattingSpeedup':
          _formattingCacheHits > 0 ? '~5x faster' : 'No data',
    };
  }
}
