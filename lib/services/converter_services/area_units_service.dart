import 'package:setpocket/services/number_format_service.dart';

class AreaUnit {
  final String id;
  final String name;
  final String symbol;
  final double toSquareMeters; // Conversion factor to square meters
  final String category;

  const AreaUnit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.toSquareMeters,
    required this.category,
  });

  String formatValue(double value) {
    return NumberFormatService.formatNumber(value);
  }
}

class AreaUnitsService {
  // Base unit: Square Meter (m²)
  static const List<AreaUnit> _units = [
    // Common units
    AreaUnit(
      id: 'square_meters',
      name: 'Square Meter',
      symbol: 'm²',
      toSquareMeters: 1.0, // Base unit
      category: 'common',
    ),
    AreaUnit(
      id: 'square_kilometers',
      name: 'Square Kilometer',
      symbol: 'km²',
      toSquareMeters: 1000000.0, // 1 km² = 1,000,000 m²
      category: 'common',
    ),
    AreaUnit(
      id: 'square_centimeters',
      name: 'Square Centimeter',
      symbol: 'cm²',
      toSquareMeters: 0.0001, // 1 cm² = 0.0001 m²
      category: 'common',
    ),

    // Less common units
    AreaUnit(
      id: 'hectares',
      name: 'Hectare',
      symbol: 'ha',
      toSquareMeters: 10000.0, // 1 ha = 10,000 m²
      category: 'less_common',
    ),
    AreaUnit(
      id: 'acres',
      name: 'Acre',
      symbol: 'ac',
      toSquareMeters: 4046.8564224, // 1 acre = 4046.8564224 m² (exact)
      category: 'less_common',
    ),
    AreaUnit(
      id: 'square_feet',
      name: 'Square Foot',
      symbol: 'ft²',
      toSquareMeters: 0.09290304, // 1 ft² = 0.09290304 m² (exact)
      category: 'less_common',
    ),
    AreaUnit(
      id: 'square_inches',
      name: 'Square Inch',
      symbol: 'in²',
      toSquareMeters: 0.00064516, // 1 in² = 0.00064516 m² (exact)
      category: 'less_common',
    ),

    // Uncommon units
    AreaUnit(
      id: 'square_yards',
      name: 'Square Yard',
      symbol: 'yd²',
      toSquareMeters: 0.83612736, // 1 yd² = 0.83612736 m² (exact)
      category: 'uncommon',
    ),
    AreaUnit(
      id: 'square_miles',
      name: 'Square Mile',
      symbol: 'mi²',
      toSquareMeters: 2589988.110336, // 1 mi² = 2,589,988.110336 m² (exact)
      category: 'uncommon',
    ),
    AreaUnit(
      id: 'roods',
      name: 'Rood',
      symbol: 'rood',
      toSquareMeters: 1011.7141056, // 1 rood = 1/4 acre = 1011.7141056 m²
      category: 'uncommon',
    ),
  ];

  /// Get all available area units
  static List<AreaUnit> get allUnits => _units;

  /// Get unit by ID
  static AreaUnit? getUnitById(String id) {
    try {
      return _units.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Convert between area units
  static double convert(double value, String fromUnitId, String toUnitId) {
    if (fromUnitId == toUnitId) return value;

    final fromUnit = getUnitById(fromUnitId);
    final toUnit = getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) {
      throw ArgumentError('Invalid unit ID: $fromUnitId or $toUnitId');
    }

    // Convert to square meters first, then to target unit
    final squareMeters = value * fromUnit.toSquareMeters;
    return squareMeters / toUnit.toSquareMeters;
  }

  /// Get units by category
  static List<AreaUnit> getUnitsByCategory(String category) {
    return _units.where((unit) => unit.category == category).toList();
  }

  /// Get all categories
  static List<String> get categories => ['common', 'less_common', 'uncommon'];

  /// Get default visible units
  static Set<String> get defaultVisibleUnits =>
      {'square_meters', 'square_feet', 'square_inches'};

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

    return fromUnit.toSquareMeters / toUnit.toSquareMeters;
  }

  /// Format area value with appropriate precision
  static String formatAreaValue(double value, String unitId) {
    final unit = getUnitById(unitId);
    if (unit == null) return NumberFormatService.formatNumber(value);

    // Use higher precision for very small or very large values
    if (value.abs() < 0.001 || value.abs() > 1000000) {
      return value.toStringAsExponential(6);
    }

    return unit.formatValue(value);
  }
}
