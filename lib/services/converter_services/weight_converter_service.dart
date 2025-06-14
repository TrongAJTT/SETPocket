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

      final fromUnit = _getUnitById(fromUnitId);
      final toUnit = _getUnitById(toUnitId);

      if (fromUnit == null || toUnit == null) {
        logError(
            'WeightConverterService: Unknown unit in conversion: $fromUnitId -> $toUnitId');
        return value;
      }

      // Convert to base unit (Newton) then to target unit
      final baseValue = value * fromUnit.factor;
      final result = baseValue / toUnit.factor;

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
    try {
      return units.firstWhere((unit) => unit.id == unitId) as WeightUnit;
    } catch (e) {
      logError('WeightConverterService: Unit not found: $unitId');
      return null;
    }
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
}
