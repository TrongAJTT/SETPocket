import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/area_units_service.dart';

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
  static final List<AreaUnit> _units = AreaUnitsService.allUnits
      .map((unit) => AreaUnit(
            id: unit.id,
            name: unit.name,
            symbol: unit.symbol,
            toSquareMeters: unit.toSquareMeters,
          ))
      .toList();

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
    return AreaUnitsService.convert(value, fromUnitId, toUnitId);
  }

  @override
  ConverterUnit? getUnit(String unitId) {
    try {
      return _units.firstWhere((unit) => unit.id == unitId);
    } catch (e) {
      return null;
    }
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
}
