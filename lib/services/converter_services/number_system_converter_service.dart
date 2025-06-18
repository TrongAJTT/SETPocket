import 'package:setpocket/models/converter_models/converter_base.dart';
import 'converter_service_base.dart';
import 'package:setpocket/services/app_logger.dart';

class NumberSystemUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final int _base;

  NumberSystemUnit({
    required String id,
    required String name,
    required String symbol,
    required int base,
  })  : _id = id,
        _name = name,
        _symbol = symbol,
        _base = base;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get symbol => _symbol;

  int get base => _base;

  @override
  String formatValue(double value) {
    // For number systems, we work with integers
    final intValue = value.round();

    if (intValue < 0) return '0';

    try {
      switch (_base) {
        case 2:
          return intValue.toRadixString(2);
        case 8:
          return intValue.toRadixString(8);
        case 10:
          return intValue.toString();
        case 16:
          return intValue.toRadixString(16).toUpperCase();
        case 32:
          return _toBase32(intValue);
        case 64:
          return _toBase64(intValue);
        case 128:
          return _toBaseN(intValue, 128);
        case 256:
          return _toBaseN(intValue, 256);
        default:
          return intValue.toRadixString(_base);
      }
    } catch (e) {
      return '0';
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'symbol': _symbol,
      'base': _base,
    };
  }

  // Convert decimal to base 32 using standard alphabet
  String _toBase32(int value) {
    if (value == 0) return '0';

    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
    String result = '';
    int temp = value;

    while (temp > 0) {
      result = alphabet[temp % 32] + result;
      temp ~/= 32;
    }

    return result;
  }

  // Convert decimal to base 64 using standard alphabet
  String _toBase64(int value) {
    if (value == 0) return '0';

    const alphabet =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
    String result = '';
    int temp = value;

    while (temp > 0) {
      result = alphabet[temp % 64] + result;
      temp ~/= 64;
    }

    return result;
  }

  // Convert decimal to arbitrary base N
  String _toBaseN(int value, int base) {
    if (value == 0) return '0';

    String result = '';
    int temp = value;

    while (temp > 0) {
      int remainder = temp % base;
      if (remainder < 10) {
        result = remainder.toString() + result;
      } else {
        // Use ASCII values for bases > 10
        result = String.fromCharCode(65 + remainder - 10) + result;
      }
      temp ~/= base;
    }

    return result;
  }

  // Convert from this base to decimal
  double parseValue(String input) {
    if (input.isEmpty) return 0.0;

    try {
      switch (_base) {
        case 2:
        case 8:
        case 16:
          return int.parse(input, radix: _base).toDouble();
        case 10:
          return double.parse(input);
        case 32:
          return _fromBase32(input).toDouble();
        case 64:
          return _fromBase64(input).toDouble();
        case 128:
          return _fromBaseN(input, 128).toDouble();
        case 256:
          return _fromBaseN(input, 256).toDouble();
        default:
          return int.parse(input, radix: _base).toDouble();
      }
    } catch (e) {
      return 0.0;
    }
  }

  int _fromBase32(String input) {
    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
    int result = 0;

    for (int i = 0; i < input.length; i++) {
      final char = input[i].toUpperCase();
      final value = alphabet.indexOf(char);
      if (value == -1) return 0;
      result = result * 32 + value;
    }

    return result;
  }

  int _fromBase64(String input) {
    const alphabet =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
    int result = 0;

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final value = alphabet.indexOf(char);
      if (value == -1) return 0;
      result = result * 64 + value;
    }

    return result;
  }

  int _fromBaseN(String input, int base) {
    int result = 0;

    for (int i = 0; i < input.length; i++) {
      final char = input[i].toUpperCase();
      int value;

      if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        // 0-9
        value = char.codeUnitAt(0) - 48;
      } else if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        // A-Z
        value = char.codeUnitAt(0) - 65 + 10;
      } else {
        return 0;
      }

      if (value >= base) return 0;
      result = result * base + value;
    }

    return result;
  }
}

class NumberSystemConverterService extends ConverterServiceBase {
  static final NumberSystemConverterService _instance =
      NumberSystemConverterService._internal();
  factory NumberSystemConverterService() => _instance;
  NumberSystemConverterService._internal();

  // Performance optimization: Static caches for singleton pattern
  static final Map<String, NumberSystemUnit> _unitsCache =
      <String, NumberSystemUnit>{};
  static final Map<String, String> _formattingCache = <String, String>{};
  static bool _cacheInitialized = false;

  // Performance monitoring
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _formattingCacheHits = 0;
  static int _formattingCacheMisses = 0;
  static int _conversionCount = 0;

  @override
  String get converterType => 'number_system';

  @override
  String get displayName => 'Number System Converter';

  @override
  bool get requiresRealTimeData => false;

  // Initialize cache with all number system units for O(1) lookup
  static void _initializeCache() {
    if (_cacheInitialized) return;

    _unitsCache.clear();

    // Define all number system units
    final units = [
      NumberSystemUnit(id: 'binary', name: 'Binary', symbol: 'bin', base: 2),
      NumberSystemUnit(id: 'octal', name: 'Octal', symbol: 'oct', base: 8),
      NumberSystemUnit(id: 'decimal', name: 'Decimal', symbol: 'dec', base: 10),
      NumberSystemUnit(
          id: 'hexadecimal', name: 'Hexadecimal', symbol: 'hex', base: 16),
      NumberSystemUnit(id: 'base32', name: 'Base 32', symbol: 'b32', base: 32),
      NumberSystemUnit(id: 'base64', name: 'Base 64', symbol: 'b64', base: 64),
      NumberSystemUnit(
          id: 'base128', name: 'Base 128', symbol: 'b128', base: 128),
      NumberSystemUnit(
          id: 'base256', name: 'Base 256', symbol: 'b256', base: 256),
    ];

    for (final unit in units) {
      _unitsCache[unit.id] = unit;
    }

    _cacheInitialized = true;
    logInfo(
        'NumberSystemConverterService: Initialized cache with ${_unitsCache.length} number system units');
  }

  @override
  List<ConverterUnit> get units {
    _initializeCache(); // Ensure cache is initialized
    return _unitsCache.values.toList();
  }

  @override
  Set<String> get defaultVisibleUnits => {
        'binary',
        'octal',
        'decimal',
        'hexadecimal',
      };

  @override
  ConverterUnit? getUnit(String id) => _getUnitById(id);

  NumberSystemUnit? _getUnitById(String unitId) {
    _initializeCache(); // Ensure cache is initialized

    if (_unitsCache.containsKey(unitId)) {
      _cacheHits++;
      return _unitsCache[unitId];
    }

    _cacheMisses++;
    return null;
  }

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    try {
      if (fromUnitId == toUnitId) return value;

      _conversionCount++;
      _initializeCache(); // Ensure cache is initialized

      final fromUnit = _unitsCache[fromUnitId];
      final toUnit = _unitsCache[toUnitId];

      if (fromUnit == null || toUnit == null) {
        logError(
            'NumberSystemConverterService: Unknown unit in conversion: $fromUnitId -> $toUnitId');
        return value;
      }

      // For number systems, we need to work with integers and convert via decimal
      final intValue = value.round();

      // Value is already decimal from parseValue(), so just return it
      // The UI handles formatting through formatValue()
      final result = value;

      logInfo(
          'NumberSystemConverterService: Converted $intValue ${fromUnit.symbol} = $result ${toUnit.symbol}');
      return result;
    } catch (e) {
      logError(
          'NumberSystemConverterService: Error converting $fromUnitId to $toUnitId: $e');
      return value;
    }
  }

  // Optimized formatting with cache
  String getFormattedValue(double value, String unitId) {
    // Round to integer for cache key consistency (number systems work with integers)
    final intValue = value.round();
    final cacheKey = '${intValue}_$unitId';

    if (_formattingCache.containsKey(cacheKey)) {
      _formattingCacheHits++;
      return _formattingCache[cacheKey]!;
    }

    _formattingCacheMisses++;
    final unit = getUnit(unitId);
    final formatted = unit?.formatValue(value) ?? value.toStringAsFixed(0);

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
    // Number system conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  Future<void> refreshData() async {
    // Number system converter doesn't need real-time data
    return;
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
      'unitsCacheHits': _cacheHits,
      'unitsCacheMisses': _cacheMisses,
      'unitsHitRate': hitRate.toStringAsFixed(1),
      'formattingCacheHits': _formattingCacheHits,
      'formattingCacheMisses': _formattingCacheMisses,
      'formattingHitRate': formattingHitRate.toStringAsFixed(1),
      'formattingCacheSize': _formattingCache.length,
      'unitsCacheSize': _unitsCache.length,
      'totalConversions': _conversionCount,
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
    _conversionCount = 0;
  }

  // Clear all caches (for memory management)
  static void clearCaches() {
    _formattingCache.clear();
    _unitsCache.clear();
    _cacheInitialized = false;
    clearCacheStats();
    logInfo('NumberSystemConverterService: All caches cleared');
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

    return 'Number System Converter Performance: '
        'Units Cache Hit Rate: $unitsHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB, '
        'Total Conversions: $_conversionCount, '
        'Units Cached: ${_unitsCache.length}';
  }
}
