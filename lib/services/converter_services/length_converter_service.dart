import '../../models/converter_models/converter_base.dart';
import 'converter_service_base.dart';
import '../number_format_service.dart';

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

  @override
  String get converterType => 'length';

  @override
  String get displayName => 'Length Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'kilometer',
        'mile',
        'meter',
        'centimeter',
        'millimeter',
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

    final fromUnit = _getUnitById(fromUnitId);
    final toUnit = _getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) {
      throw Exception('Unit not found: $fromUnitId or $toUnitId');
    }

    // Convert to base unit (meter) first, then to target unit
    final baseValue = value * fromUnit.factor;
    return baseValue / toUnit.factor;
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  LengthUnit? _getUnitById(String unitId) {
    try {
      return units.firstWhere((unit) => unit.id == unitId) as LengthUnit;
    } catch (e) {
      return null;
    }
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
}
