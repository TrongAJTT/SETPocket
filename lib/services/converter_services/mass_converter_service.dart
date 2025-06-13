import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/number_format_service.dart';

class MassUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor; // Factor to convert to grams (base unit)

  MassUnit({
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

class MassConverterService extends ConverterServiceBase {
  static final MassConverterService _instance =
      MassConverterService._internal();
  factory MassConverterService() => _instance;
  MassConverterService._internal();

  @override
  String get converterType => 'mass';

  @override
  String get displayName => 'Mass Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'kilograms',
        'pounds',
        'ounces',
      };

  @override
  List<ConverterUnit> get units => [
        // SI/Metric Units (most precise first for highest accuracy)
        MassUnit(
            id: 'nanograms',
            name: 'Nanograms',
            symbol: 'ng',
            factor: 0.000000001),
        MassUnit(
            id: 'micrograms',
            name: 'Micrograms',
            symbol: 'µg',
            factor: 0.000001),
        MassUnit(
            id: 'milligrams', name: 'Milligrams', symbol: 'mg', factor: 0.001),
        MassUnit(id: 'grams', name: 'Grams', symbol: 'g', factor: 1.0),
        MassUnit(
            id: 'kilograms', name: 'Kilograms', symbol: 'kg', factor: 1000.0),
        MassUnit(id: 'tonnes', name: 'Tonnes', symbol: 't', factor: 1000000.0),

        // Imperial/US Avoirdupois System (high precision factors)
        MassUnit(
            id: 'grains', name: 'Grains', symbol: 'gr', factor: 0.06479891),
        MassUnit(
            id: 'drams', name: 'Drams', symbol: 'dr', factor: 1.7718451953125),
        MassUnit(
            id: 'ounces', name: 'Ounces', symbol: 'oz', factor: 28.349523125),
        MassUnit(id: 'pounds', name: 'Pounds', symbol: 'lb', factor: 453.59237),
        MassUnit(
            id: 'stones', name: 'Stones', symbol: 'st', factor: 6350.29318),
        MassUnit(
            id: 'quarters',
            name: 'Quarters',
            symbol: 'qr',
            factor: 12700.58636),
        MassUnit(
            id: 'short_hundredweight',
            name: 'Short Hundredweight',
            symbol: 'cwt (US)',
            factor: 45359.237),
        MassUnit(
            id: 'long_hundredweight',
            name: 'Long Hundredweight',
            symbol: 'cwt (UK)',
            factor: 50802.34544),
        MassUnit(
            id: 'short_tons',
            name: 'Short Tons',
            symbol: 'ton (US)',
            factor: 907184.74),
        MassUnit(
            id: 'long_tons',
            name: 'Long Tons',
            symbol: 'ton (UK)',
            factor: 1016046.9088),

        // Troy System (precious metals)
        MassUnit(
            id: 'troy_grains',
            name: 'Troy Grains',
            symbol: 'gr t',
            factor: 0.06479891),
        MassUnit(
            id: 'pennyweights',
            name: 'Pennyweights',
            symbol: 'dwt',
            factor: 1.55517384),
        MassUnit(
            id: 'troy_ounces',
            name: 'Troy Ounces',
            symbol: 'oz t',
            factor: 31.1034768),
        MassUnit(
            id: 'troy_pounds',
            name: 'Troy Pounds',
            symbol: 'lb t',
            factor: 373.2417216),

        // Apothecaries System (pharmacy/medicine)
        MassUnit(
            id: 'scruples',
            name: 'Scruples',
            symbol: 's ap',
            factor: 1.2959782),
        MassUnit(
            id: 'apothecaries_drams',
            name: 'Apothecaries Drams',
            symbol: 'dr ap',
            factor: 3.8879346),
        MassUnit(
            id: 'apothecaries_ounces',
            name: 'Apothecaries Ounces',
            symbol: 'oz ap',
            factor: 31.1034768),
        MassUnit(
            id: 'apothecaries_pounds',
            name: 'Apothecaries Pounds',
            symbol: 'lb ap',
            factor: 373.2417216),

        // Other Special Units
        MassUnit(id: 'carats', name: 'Carats', symbol: 'ct', factor: 0.2),
        MassUnit(id: 'slugs', name: 'Slugs', symbol: 'slug', factor: 14593.903),
        MassUnit(
            id: 'atomic_mass_units',
            name: 'Atomic Mass Units',
            symbol: 'u',
            factor: 0.00000000000000000000001660539066),
      ];

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    if (fromUnitId == toUnitId) return value;

    final fromUnit = _getUnitById(fromUnitId);
    final toUnit = _getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) {
      throw Exception('Unit not found: $fromUnitId or $toUnitId');
    }

    // Convert to base unit (grams) first, then to target unit
    final baseValue = value * fromUnit.factor;
    return baseValue / toUnit.factor;
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  MassUnit? _getUnitById(String unitId) {
    try {
      return units.firstWhere((unit) => unit.id == unitId) as MassUnit;
    } catch (e) {
      return null;
    }
  }
}
