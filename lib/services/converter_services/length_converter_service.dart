import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/number_format_service.dart';

class LengthUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor;

  LengthUnit({
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

class LengthConverterService extends ConverterServiceBase {
  static final LengthConverterService _instance =
      LengthConverterService._internal();
  factory LengthConverterService() => _instance;
  LengthConverterService._internal();

  // Performance optimization: Cache for units lookup
  static final Map<String, LengthUnit> _unitsCache = {};
  static final Map<String, double> _conversionCache = {};
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static bool _cacheInitialized = false;

  // Initialize units cache on first access
  void _initializeCache() {
    if (_cacheInitialized) return;

    for (final unit in units) {
      _unitsCache[unit.id] = unit as LengthUnit;
    }
    _cacheInitialized = true;
  }

  @override
  String get converterType => 'length';

  @override
  String get displayName => 'Length Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'meter',
        'inch',
        'foot',
        'yard',
      };

  @override
  List<ConverterUnit> get units => [
        LengthUnit(id: 'meter', name: 'Meter', symbol: 'm', factor: 1.0),
        LengthUnit(
            id: 'kilometer', name: 'Kilometer', symbol: 'km', factor: 1000.0),
        LengthUnit(
            id: 'centimeter', name: 'Centimeter', symbol: 'cm', factor: 0.01),
        LengthUnit(
            id: 'millimeter', name: 'Millimeter', symbol: 'mm', factor: 0.001),
        LengthUnit(id: 'inch', name: 'Inch', symbol: 'in', factor: 0.0254),
        LengthUnit(id: 'foot', name: 'Foot', symbol: 'ft', factor: 0.3048),
        LengthUnit(id: 'yard', name: 'Yard', symbol: 'yd', factor: 0.9144),
        LengthUnit(id: 'mile', name: 'Mile', symbol: 'mi', factor: 1609.344),
        LengthUnit(
            id: 'nautical_mile',
            name: 'Nautical Mile',
            symbol: 'nmi',
            factor: 1852.0),
        LengthUnit(
            id: 'angstrom', name: 'Angstrom', symbol: 'Å', factor: 1e-10),
        LengthUnit(
            id: 'nanometer', name: 'Nanometer', symbol: 'nm', factor: 1e-9),
        LengthUnit(
            id: 'micrometer', name: 'Micrometer', symbol: 'μm', factor: 1e-6),
      ];

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
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
      throw Exception('Unit not found: $fromUnitId or $toUnitId');
    }

    // Calculate conversion factor and cache it
    final conversionFactor = fromUnit.factor / toUnit.factor;
    _conversionCache[cacheKey] = conversionFactor;

    // Limit cache size to prevent memory issues
    if (_conversionCache.length > 500) {
      _conversionCache.clear();
    }

    return value * conversionFactor;
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  LengthUnit? _getUnitById(String unitId) {
    _initializeCache(); // Ensure cache is initialized
    return _unitsCache[unitId];
  }

  @override
  ConversionStatus getUnitStatus(String unitId) {
    // Length conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for length converter as it doesn't need real-time data
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;

  // Performance monitoring methods
  static Map<String, dynamic> getCacheStats() {
    final total = _cacheHits + _cacheMisses;
    final hitRate = total > 0 ? (_cacheHits / total * 100) : 0.0;
    return {
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRate': hitRate.toStringAsFixed(1),
      'conversionCacheSize': _conversionCache.length,
      'unitsCacheSize': _unitsCache.length,
    };
  }

  // Clear performance stats
  static void clearCacheStats() {
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  // Clear all caches (for memory management)
  static void clearCaches() {
    _conversionCache.clear();
    _unitsCache.clear();
    _cacheInitialized = false;
    clearCacheStats();
  }
}
