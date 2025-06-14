import 'package:setpocket/services/app_logger.dart';

class WeightUnitsService {
  // Base unit: Newton (N)
  static const String baseUnit = 'newtons';

  // Conversion factors to Newton (most precise unit)
  static const Map<String, double> _conversionFactors = {
    // Common units
    'newtons': 1.0, // Base unit (N)
    'kilogram_force': 9.80665, // kgf to N (exact)
    'pound_force': 4.4482216152605, // lbf to N (exact)

    // Less common units
    'dyne': 0.00001, // dyne to N (exact: 10^-5)
    'kilopond': 9.80665, // kp to N (same as kgf)
    'ton_force': 8896.443230521, // ton-force (US) to N

    // Special units
    'gram_force': 0.00980665, // gf to N (exact)
    'troy_pound': 3.6287389, // troy pound-force to N (approximate)
  };

  // Unit display names and symbols
  static const Map<String, Map<String, String>> _unitInfo = {
    'newtons': {
      'name_en': 'Newton',
      'name_vi': 'Newton',
      'symbol': 'N',
      'category': 'common',
    },
    'kilogram_force': {
      'name_en': 'Kilogram-force',
      'name_vi': 'Kilôgam lực',
      'symbol': 'kgf',
      'category': 'common',
    },
    'pound_force': {
      'name_en': 'Pound-force',
      'name_vi': 'Pound lực',
      'symbol': 'lbf',
      'category': 'common',
    },
    'dyne': {
      'name_en': 'Dyne',
      'name_vi': 'Dyne',
      'symbol': 'dyn',
      'category': 'less_common',
    },
    'kilopond': {
      'name_en': 'Kilopond',
      'name_vi': 'Kilopond',
      'symbol': 'kp',
      'category': 'less_common',
    },
    'ton_force': {
      'name_en': 'Ton-force',
      'name_vi': 'Tấn lực',
      'symbol': 'tf',
      'category': 'uncommon',
    },
    'gram_force': {
      'name_en': 'Gram-force',
      'name_vi': 'Gam lực',
      'symbol': 'gf',
      'category': 'special',
    },
    'troy_pound': {
      'name_en': 'Troy pound-force',
      'name_vi': 'Troy pound lực',
      'symbol': 'tlbf',
      'category': 'special',
    },
  };

  // Get default visible units
  static Set<String> get defaultVisibleUnits =>
      {'newtons', 'kilogram_force', 'pound_force'};

  // All available units
  static List<String> get allUnits => _conversionFactors.keys.toList();

  // Get unit categories
  static Map<String, List<String>> getUnitsByCategory() {
    final Map<String, List<String>> categories = {
      'common': [],
      'less_common': [],
      'uncommon': [],
      'special': [],
    };

    for (final unit in allUnits) {
      final category = _unitInfo[unit]?['category'] ?? 'common';
      categories[category]?.add(unit);
    }

    return categories;
  }

  // Convert between units
  static double convert(double value, String fromUnit, String toUnit) {
    try {
      if (fromUnit == toUnit) return value;

      final fromFactor = _conversionFactors[fromUnit];
      final toFactor = _conversionFactors[toUnit];

      if (fromFactor == null || toFactor == null) {
        logError(
            'WeightUnitsService: Unknown unit conversion: $fromUnit -> $toUnit');
        return value;
      }

      // Convert to base unit (Newton) then to target unit
      final baseValue = value * fromFactor;
      final result = baseValue / toFactor;

      logInfo(
          'WeightUnitsService: Converted $value $fromUnit = $result $toUnit');
      return result;
    } catch (e) {
      logError('WeightUnitsService: Error converting $fromUnit to $toUnit: $e');
      return value;
    }
  }

  // Get unit display name
  static String getUnitName(String unitCode, String locale) {
    final info = _unitInfo[unitCode];
    if (info == null) return unitCode;

    final nameKey = locale == 'vi' ? 'name_vi' : 'name_en';
    return info[nameKey] ?? info['name_en'] ?? unitCode;
  }

  // Get unit symbol
  static String getUnitSymbol(String unitCode) {
    return _unitInfo[unitCode]?['symbol'] ?? unitCode;
  }

  // Get unit category
  static String getUnitCategory(String unitCode) {
    return _unitInfo[unitCode]?['category'] ?? 'common';
  }

  // Check if unit exists
  static bool isValidUnit(String unitCode) {
    return _conversionFactors.containsKey(unitCode);
  }

  // Get conversion factor to base unit
  static double? getConversionFactor(String unitCode) {
    return _conversionFactors[unitCode];
  }

  // Get formatted unit display (name + symbol)
  static String getFormattedUnitDisplay(String unitCode, String locale) {
    final name = getUnitName(unitCode, locale);
    final symbol = getUnitSymbol(unitCode);
    return '$name ($symbol)';
  }

  // Get units for customization dialog
  static List<Map<String, dynamic>> getUnitsForCustomization(String locale) {
    return allUnits.map((unit) {
      return {
        'code': unit,
        'name': getUnitName(unit, locale),
        'symbol': getUnitSymbol(unit),
        'category': getUnitCategory(unit),
        'display': getFormattedUnitDisplay(unit, locale),
      };
    }).toList();
  }

  // Validate unit list
  static List<String> validateUnits(List<String> units) {
    return units.where((unit) => isValidUnit(unit)).toList();
  }

  // Get default card units
  static List<String> getDefaultCardUnits() {
    return ['newtons', 'kilogram_force', 'pound_force'];
  }

  // Get precision for unit (decimal places)
  static int getPrecisionForUnit(String unitCode) {
    switch (unitCode) {
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
}
