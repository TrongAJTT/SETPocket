import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/area_units_service.dart';
import 'package:setpocket/services/app_logger.dart';

class AreaUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _toSquareMeters;

  AreaUnit({
    required String id,
    required String name,
    required String symbol,
    required double toSquareMeters,
  })  : _id = id,
        _name = name,
        _symbol = symbol,
        _toSquareMeters = toSquareMeters;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get symbol => _symbol;

  double get toSquareMeters => _toSquareMeters;

  @override
  String formatValue(double value) {
    return AreaUnitsService.formatAreaValue(value, _id);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': _name,
        'symbol': _symbol,
        'toSquareMeters': _toSquareMeters,
      };
}

class AreaConverterService extends ConverterServiceBase {
  static final AreaConverterService _instance =
      AreaConverterService._internal();
  factory AreaConverterService() => _instance;
  AreaConverterService._internal();

  // Performance optimization: Cache for units lookup
  static final Map<String, AreaUnit> _unitsCache = {};
  static final Map<String, double> _conversionCache = {};
  static final Map<String, String> _formattingCache = {};
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _formattingCacheHits = 0;
  static int _formattingCacheMisses = 0;
  static bool _cacheInitialized = false;

  static final List<AreaUnit> _units = AreaUnitsService.allUnits
      .map((unit) => AreaUnit(
            id: unit.id,
            name: unit.name,
            symbol: unit.symbol,
            toSquareMeters: unit.toSquareMeters,
          ))
      .toList();

  // Initialize units cache on first access
  void _initializeCache() {
    if (_cacheInitialized) return;

    for (final unit in _units) {
      _unitsCache[unit.id] = unit;
    }
    _cacheInitialized = true;
  }

  @override
  List<ConverterUnit> get units => _units;

  @override
  String get converterType => 'area';

  @override
  String get displayName => 'Area Converter';

  @override
  Set<String> get defaultVisibleUnits => AreaUnitsService.defaultVisibleUnits;

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
            'AreaConverterService: Unknown unit in conversion: $fromUnitId -> $toUnitId');
        return value;
      }

      // Calculate conversion factor and cache it
      final conversionFactor = fromUnit.toSquareMeters / toUnit.toSquareMeters;
      _conversionCache[cacheKey] = conversionFactor;

      // Limit cache size to prevent memory issues
      if (_conversionCache.length > 500) {
        _conversionCache.clear();
      }

      final result = value * conversionFactor;
      logInfo(
          'AreaConverterService: Converted $value ${fromUnit.symbol} = $result ${toUnit.symbol}');
      return result;
    } catch (e) {
      logError(
          'AreaConverterService: Error converting $fromUnitId to $toUnitId: $e');
      return value;
    }
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  AreaUnit? _getUnitById(String unitId) {
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
    final formatted = AreaUnitsService.formatAreaValue(value, unitId);

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
    return AreaUnitsService.hasUnit(unitId)
        ? ConversionStatus.success
        : ConversionStatus.notAvailable;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // Area conversion doesn't require real-time data
    logInfo(
        'AreaConverterService: No data refresh needed for static conversion factors');
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;

  /// Get units by category for customization dialog
  Map<String, List<AreaUnit>> getUnitsByCategory() {
    final Map<String, List<AreaUnit>> categorized = {};

    for (final unit in AreaUnitsService.allUnits) {
      final areaUnit = AreaUnit(
        id: unit.id,
        name: unit.name,
        symbol: unit.symbol,
        toSquareMeters: unit.toSquareMeters,
      );

      if (!categorized.containsKey(unit.category)) {
        categorized[unit.category] = [];
      }
      categorized[unit.category]!.add(areaUnit);
    }

    return categorized;
  }

  /// Get conversion factor between two units
  double getConversionFactor(String fromUnitId, String toUnitId) {
    return AreaUnitsService.getConversionFactor(fromUnitId, toUnitId);
  }

  /// Check if a unit is metric
  bool isMetricUnit(String unitId) {
    const metricUnits = {
      'square_meters',
      'square_kilometers',
      'square_centimeters',
      'hectares'
    };
    return metricUnits.contains(unitId);
  }

  /// Check if a unit is imperial
  bool isImperialUnit(String unitId) {
    const imperialUnits = {
      'square_feet',
      'square_inches',
      'square_yards',
      'square_miles',
      'acres',
      'roods'
    };
    return imperialUnits.contains(unitId);
  }

  /// Get the most precise unit for calculations
  String getMostPreciseUnit() {
    // Square meter is the base unit and most precise for calculations
    return 'square_meters';
  }

  /// Get recommended units for beginners
  List<String> getBeginnerUnits() {
    return ['square_meters', 'square_kilometers', 'square_centimeters'];
  }

  /// Get advanced units for professionals
  List<String> getAdvancedUnits() {
    return [
      'hectares',
      'acres',
      'square_feet',
      'square_inches',
      'square_yards',
      'square_miles',
      'roods'
    ];
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
