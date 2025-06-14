import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';

class SpeedUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor;

  SpeedUnit({
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

class SpeedConverterService extends ConverterServiceBase {
  static final SpeedConverterService _instance =
      SpeedConverterService._internal();
  factory SpeedConverterService() => _instance;
  SpeedConverterService._internal();

  @override
  String get converterType => 'speed';

  @override
  String get displayName => 'Speed Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'kilometers_per_hour',
        'meters_per_second',
        'miles_per_hour',
      };

  @override
  List<ConverterUnit> get units => [
        SpeedUnit(
            id: 'meters_per_second',
            name: 'Meters per Second',
            symbol: 'm/s',
            factor: 1.0), // Base unit
        SpeedUnit(
            id: 'kilometers_per_hour',
            name: 'Kilometers per Hour',
            symbol: 'km/h',
            factor: 0.277778), // 1 km/h = 0.277778 m/s
        SpeedUnit(
            id: 'miles_per_hour',
            name: 'Miles per Hour',
            symbol: 'mph',
            factor: 0.44704), // 1 mph = 0.44704 m/s
        SpeedUnit(
            id: 'knots',
            name: 'Knots',
            symbol: 'kn',
            factor: 0.514444), // 1 knot = 0.514444 m/s
        SpeedUnit(
            id: 'feet_per_second',
            name: 'Feet per Second',
            symbol: 'ft/s',
            factor: 0.3048), // 1 ft/s = 0.3048 m/s
        SpeedUnit(
            id: 'mach',
            name: 'Mach',
            symbol: 'M',
            factor: 343.0), // 1 Mach ≈ 343 m/s (at sea level, 20°C)
      ];

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    if (fromUnitId == toUnitId) return value;

    final fromUnit = _getUnitById(fromUnitId);
    final toUnit = _getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) {
      throw Exception('Unit not found: $fromUnitId or $toUnitId');
    }

    // Convert to base unit (meters per second) first, then to target unit
    final baseValue = value * fromUnit.factor;
    return baseValue / toUnit.factor;
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  SpeedUnit? _getUnitById(String unitId) {
    try {
      return units.firstWhere((unit) => unit.id == unitId) as SpeedUnit;
    } catch (e) {
      return null;
    }
  }

  @override
  ConversionStatus getUnitStatus(String unitId) {
    // Speed conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for speed converter as it doesn't need real-time data
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;
}
