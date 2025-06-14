import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';

class VolumeUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor;

  VolumeUnit({
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

class VolumeConverterService extends ConverterServiceBase {
  static final VolumeConverterService _instance =
      VolumeConverterService._internal();
  factory VolumeConverterService() => _instance;
  VolumeConverterService._internal();

  @override
  String get converterType => 'volume';

  @override
  String get displayName => 'Volume Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'cubic_meter',
        'liter',
        'milliliter',
      };

  @override
  List<ConverterUnit> get units => [
        // Metric units (base: cubic meter)
        VolumeUnit(
            id: 'cubic_meter',
            name: 'Cubic Meter',
            symbol: 'm³',
            factor: 1.0), // Base unit

        // Liter family
        VolumeUnit(id: 'liter', name: 'Liter', symbol: 'L', factor: 0.001),
        VolumeUnit(
            id: 'milliliter',
            name: 'Milliliter',
            symbol: 'mL',
            factor: 0.000001),
        VolumeUnit(
            id: 'cubic_centimeter',
            name: 'Cubic Centimeter',
            symbol: 'cm³',
            factor: 0.000001),
        VolumeUnit(
            id: 'hectoliter', name: 'Hectoliter', symbol: 'hL', factor: 0.1),

        // Imperial/US units
        VolumeUnit(
            id: 'gallon_us',
            name: 'Gallon (US)',
            symbol: 'gal',
            factor: 0.003785411784),
        VolumeUnit(
            id: 'gallon_uk',
            name: 'Gallon (UK)',
            symbol: 'gal',
            factor: 0.00454609),
        VolumeUnit(
            id: 'quart_us',
            name: 'Quart (US)',
            symbol: 'qt',
            factor: 0.000946352946),
        VolumeUnit(
            id: 'pint_us',
            name: 'Pint (US)',
            symbol: 'pt',
            factor: 0.000473176473),
        VolumeUnit(
            id: 'cup', name: 'Cup', symbol: 'cup', factor: 0.0002365882365),
        VolumeUnit(
            id: 'fluid_ounce_us',
            name: 'Fluid Ounce (US)',
            symbol: 'fl oz',
            factor: 0.00002957352956),

        // Cubic measurements
        VolumeUnit(
            id: 'cubic_inch',
            name: 'Cubic Inch',
            symbol: 'in³',
            factor: 0.000016387064),
        VolumeUnit(
            id: 'cubic_foot',
            name: 'Cubic Foot',
            symbol: 'ft³',
            factor: 0.028316846592),
        VolumeUnit(
            id: 'cubic_yard',
            name: 'Cubic Yard',
            symbol: 'yd³',
            factor: 0.764554857984),

        // Special units
        VolumeUnit(
            id: 'barrel',
            name: 'Barrel (Oil)',
            symbol: 'bbl',
            factor: 0.158987294928),
      ];

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    if (fromUnitId == toUnitId) return value;

    final fromUnit = _getUnitById(fromUnitId);
    final toUnit = _getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) {
      throw Exception('Unit not found: $fromUnitId or $toUnitId');
    }

    // Convert to base unit (cubic meter) first, then to target unit
    final baseValue = value * fromUnit.factor;
    return baseValue / toUnit.factor;
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  VolumeUnit? _getUnitById(String unitId) {
    try {
      return units.firstWhere((unit) => unit.id == unitId) as VolumeUnit;
    } catch (e) {
      return null;
    }
  }

  @override
  ConversionStatus getUnitStatus(String unitId) {
    // Volume conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for volume converter as it doesn't need real-time data
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;
}
