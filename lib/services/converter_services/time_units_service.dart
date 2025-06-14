import 'package:setpocket/services/number_format_service.dart';

class TimeUnit {
  final String id;
  final String name;
  final String symbol;
  final double toSeconds; // Conversion factor to seconds (base unit)
  final String category;

  const TimeUnit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.toSeconds,
    required this.category,
  });

  String formatValue(double value) {
    return NumberFormatService.formatNumber(value);
  }
}

class TimeUnitsService {
  // Base unit: Second (s)
  static const List<TimeUnit> _units = [
    // Common units
    TimeUnit(
      id: 'seconds',
      name: 'Second',
      symbol: 's',
      toSeconds: 1.0, // Base unit
      category: 'common',
    ),
    TimeUnit(
      id: 'minutes',
      name: 'Minute',
      symbol: 'min',
      toSeconds: 60.0, // 1 min = 60 s
      category: 'common',
    ),
    TimeUnit(
      id: 'hours',
      name: 'Hour',
      symbol: 'h',
      toSeconds: 3600.0, // 1 h = 3600 s
      category: 'common',
    ),

    // Less common units
    TimeUnit(
      id: 'days',
      name: 'Day',
      symbol: 'd',
      toSeconds: 86400.0, // 1 d = 86400 s
      category: 'less_common',
    ),
    TimeUnit(
      id: 'weeks',
      name: 'Week',
      symbol: 'wk',
      toSeconds: 604800.0, // 1 wk = 604800 s
      category: 'less_common',
    ),
    TimeUnit(
      id: 'months',
      name: 'Month',
      symbol: 'mo',
      toSeconds: 2629746.0, // Average month = 30.44 days
      category: 'less_common',
    ),
    TimeUnit(
      id: 'years',
      name: 'Year',
      symbol: 'yr',
      toSeconds: 31556952.0, // Average year = 365.2425 days
      category: 'less_common',
    ),

    // Uncommon units
    TimeUnit(
      id: 'milliseconds',
      name: 'Millisecond',
      symbol: 'ms',
      toSeconds: 0.001, // 1 ms = 0.001 s
      category: 'uncommon',
    ),
    TimeUnit(
      id: 'microseconds',
      name: 'Microsecond',
      symbol: 'μs',
      toSeconds: 0.000001, // 1 μs = 0.000001 s
      category: 'uncommon',
    ),
    TimeUnit(
      id: 'nanoseconds',
      name: 'Nanosecond',
      symbol: 'ns',
      toSeconds: 0.000000001, // 1 ns = 0.000000001 s
      category: 'uncommon',
    ),
    TimeUnit(
      id: 'decades',
      name: 'Decade',
      symbol: 'dec',
      toSeconds: 315569520.0, // 10 years
      category: 'uncommon',
    ),
    TimeUnit(
      id: 'centuries',
      name: 'Century',
      symbol: 'c',
      toSeconds: 3155695200.0, // 100 years
      category: 'uncommon',
    ),
    TimeUnit(
      id: 'millennia',
      name: 'Millennium',
      symbol: 'mil',
      toSeconds: 31556952000.0, // 1000 years
      category: 'uncommon',
    ),
  ];

  /// Get all available time units
  static List<TimeUnit> get allUnits => _units;

  /// Get unit by ID
  static TimeUnit? getUnitById(String id) {
    try {
      return _units.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Convert between time units
  static double convert(double value, String fromUnitId, String toUnitId) {
    if (fromUnitId == toUnitId) return value;

    final fromUnit = getUnitById(fromUnitId);
    final toUnit = getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) {
      throw ArgumentError('Invalid unit ID: $fromUnitId or $toUnitId');
    }

    // Convert to seconds first, then to target unit
    final seconds = value * fromUnit.toSeconds;
    return seconds / toUnit.toSeconds;
  }

  /// Get units by category
  static List<TimeUnit> getUnitsByCategory(String category) {
    return _units.where((unit) => unit.category == category).toList();
  }

  /// Get all categories
  static List<String> get categories => ['common', 'less_common', 'uncommon'];

  /// Get default visible units
  static Set<String> get defaultVisibleUnits =>
      {'seconds', 'minutes', 'hours', 'days'};

  /// Check if unit exists
  static bool hasUnit(String unitId) {
    return _units.any((unit) => unit.id == unitId);
  }

  /// Get unit display name with symbol
  static String getUnitDisplayName(String unitId) {
    final unit = getUnitById(unitId);
    if (unit == null) return unitId;
    return '${unit.name} (${unit.symbol})';
  }

  /// Get conversion factor between two units
  static double getConversionFactor(String fromUnitId, String toUnitId) {
    if (fromUnitId == toUnitId) return 1.0;

    final fromUnit = getUnitById(fromUnitId);
    final toUnit = getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) return 1.0;

    return fromUnit.toSeconds / toUnit.toSeconds;
  }

  /// Format time value with appropriate precision
  static String formatTimeValue(double value, String unitId) {
    final unit = getUnitById(unitId);
    if (unit == null) return NumberFormatService.formatNumber(value);

    // Use higher precision for very small or very large values
    if (value.abs() < 0.001 || value.abs() > 1000000) {
      return value.toStringAsExponential(6);
    }

    return unit.formatValue(value);
  }
}
