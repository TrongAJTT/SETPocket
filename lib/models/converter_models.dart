import '../services/currency_service.dart';
import 'package:decimal/decimal.dart';

/// Base class for all conversion units
abstract class ConversionUnit {
  final String id;
  final String name;
  final String symbol;
  final String? description;

  const ConversionUnit({
    required this.id,
    required this.name,
    required this.symbol,
    this.description,
  });
}

/// Base class for all converters
abstract class BaseConverter {
  String get name;
  String get description;
  List<ConversionUnit> get units;

  /// Convert from one unit to another
  double convert(double value, String fromUnit, String toUnit);

  /// Get the base unit (used as reference for conversions)
  ConversionUnit get baseUnit;
}

/// Length units and converter
class LengthUnit extends ConversionUnit {
  final Decimal toMeters;

  const LengthUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.toMeters,
    super.description,
  });
}

class LengthConverter extends BaseConverter {
  @override
  String get name => 'Length';

  @override
  String get description => 'Convert between different length units';

  @override
  LengthUnit get baseUnit => meters;

  static final angstroms = LengthUnit(
    id: 'angstroms',
    name: 'Angstroms',
    symbol: 'Å',
    toMeters: Decimal.parse('0.0000000001'),
  );

  static final nanometers = LengthUnit(
    id: 'nanometers',
    name: 'Nanometers',
    symbol: 'nm',
    toMeters: Decimal.parse('0.000000001'),
  );

  static final microns = LengthUnit(
    id: 'microns',
    name: 'Microns',
    symbol: 'μm',
    toMeters: Decimal.parse('0.000001'),
  );

  static final millimeters = LengthUnit(
    id: 'millimeters',
    name: 'Millimeters',
    symbol: 'mm',
    toMeters: Decimal.parse('0.001'),
  );

  static final centimeters = LengthUnit(
    id: 'centimeters',
    name: 'Centimeters',
    symbol: 'cm',
    toMeters: Decimal.parse('0.01'),
  );

  static final meters = LengthUnit(
    id: 'meters',
    name: 'Meters',
    symbol: 'm',
    toMeters: Decimal.parse('1.0'),
  );

  static final kilometers = LengthUnit(
    id: 'kilometers',
    name: 'Kilometers',
    symbol: 'km',
    toMeters: Decimal.parse('1000.0'),
  );

  static final inches = LengthUnit(
    id: 'inches',
    name: 'Inches',
    symbol: 'in',
    toMeters: Decimal.parse('0.0254'),
  );

  static final feet = LengthUnit(
    id: 'feet',
    name: 'Feet',
    symbol: 'ft',
    toMeters: Decimal.parse('0.3048'),
  );

  static final yards = LengthUnit(
    id: 'yards',
    name: 'Yards',
    symbol: 'yd',
    toMeters: Decimal.parse('0.9144'),
  );

  static final miles = LengthUnit(
    id: 'miles',
    name: 'Miles',
    symbol: 'mi',
    toMeters: Decimal.parse('1609.344'),
  );

  static final nauticalMiles = LengthUnit(
    id: 'nautical_miles',
    name: 'Nautical Miles',
    symbol: 'nmi',
    toMeters: Decimal.parse('1852.0'),
  );

  @override
  List<LengthUnit> get units => [
        angstroms,
        nanometers,
        microns,
        millimeters,
        centimeters,
        meters,
        kilometers,
        inches,
        feet,
        yards,
        miles,
        nauticalMiles,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final from = units.firstWhere((unit) => unit.id == fromUnit);
    final to = units.firstWhere((unit) => unit.id == toUnit);

    // Use Decimal for precise calculations
    final decimalValue = Decimal.parse(value.toString());
    final inMeters = decimalValue * from.toMeters;
    final result = inMeters / to.toMeters;

    return result.toDouble();
  }
}

/// Weight units and converter
class WeightUnit extends ConversionUnit {
  final Decimal toGrams;

  const WeightUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.toGrams,
    super.description,
  });
}

class WeightConverter extends BaseConverter {
  @override
  String get name => 'Weight';

  @override
  String get description => 'Convert between different weight units';

  @override
  WeightUnit get baseUnit => kilograms;

  // SI/Metric Units with highest precision decimal values
  static final nanograms = WeightUnit(
    id: 'nanograms',
    name: 'Nanograms',
    symbol: 'ng',
    toGrams: Decimal.parse('0.000000001'),
  );

  static final micrograms = WeightUnit(
    id: 'micrograms',
    name: 'Micrograms',
    symbol: 'µg',
    toGrams: Decimal.parse('0.000001'),
  );

  static final milligrams = WeightUnit(
    id: 'milligrams',
    name: 'Milligrams',
    symbol: 'mg',
    toGrams: Decimal.parse('0.001'),
  );

  static final grams = WeightUnit(
    id: 'grams',
    name: 'Grams',
    symbol: 'g',
    toGrams: Decimal.parse('1.0'),
  );

  static final kilograms = WeightUnit(
    id: 'kilograms',
    name: 'Kilograms',
    symbol: 'kg',
    toGrams: Decimal.parse('1000.0'),
  );

  static final tonnes = WeightUnit(
    id: 'tonnes',
    name: 'Tonnes',
    symbol: 't',
    toGrams: Decimal.parse('1000000.0'),
  );

  // Imperial/US Avoirdupois System with precise conversion factors
  static final grains = WeightUnit(
    id: 'grains',
    name: 'Grains',
    symbol: 'gr',
    toGrams: Decimal.parse('0.06479891'),
  );

  static final drams = WeightUnit(
    id: 'drams',
    name: 'Drams',
    symbol: 'dr',
    toGrams: Decimal.parse('1.7718451953125'),
  );

  static final ounces = WeightUnit(
    id: 'ounces',
    name: 'Ounces',
    symbol: 'oz',
    toGrams: Decimal.parse('28.349523125'),
  );

  static final pounds = WeightUnit(
    id: 'pounds',
    name: 'Pounds',
    symbol: 'lb',
    toGrams: Decimal.parse('453.59237'),
  );

  static final stones = WeightUnit(
    id: 'stones',
    name: 'Stones',
    symbol: 'st',
    toGrams: Decimal.parse('6350.29318'),
  );

  static final quarters = WeightUnit(
    id: 'quarters',
    name: 'Quarters',
    symbol: 'qr',
    toGrams: Decimal.parse('12700.58636'),
  );

  static final shortHundredweight = WeightUnit(
    id: 'short_hundredweight',
    name: 'Short Hundredweight',
    symbol: 'cwt (US)',
    toGrams: Decimal.parse('45359.237'),
  );

  static final longHundredweight = WeightUnit(
    id: 'long_hundredweight',
    name: 'Long Hundredweight',
    symbol: 'cwt (UK)',
    toGrams: Decimal.parse('50802.34544'),
  );

  static final shortTons = WeightUnit(
    id: 'short_tons',
    name: 'Short Tons',
    symbol: 'ton (US)',
    toGrams: Decimal.parse('907184.74'),
  );

  static final longTons = WeightUnit(
    id: 'long_tons',
    name: 'Long Tons',
    symbol: 'ton (UK)',
    toGrams: Decimal.parse('1016046.9088'),
  );

  // Troy System with precise values
  static final troyGrains = WeightUnit(
    id: 'troy_grains',
    name: 'Troy Grains',
    symbol: 'gr t',
    toGrams: Decimal.parse('0.06479891'),
  );

  static final pennyweights = WeightUnit(
    id: 'pennyweights',
    name: 'Pennyweights',
    symbol: 'dwt',
    toGrams: Decimal.parse('1.55517384'),
  );

  static final troyOunces = WeightUnit(
    id: 'troy_ounces',
    name: 'Troy Ounces',
    symbol: 'oz t',
    toGrams: Decimal.parse('31.1034768'),
  );

  static final troyPounds = WeightUnit(
    id: 'troy_pounds',
    name: 'Troy Pounds',
    symbol: 'lb t',
    toGrams: Decimal.parse('373.2417216'),
  );

  // Apothecaries System with precise values
  static final scruples = WeightUnit(
    id: 'scruples',
    name: 'Scruples',
    symbol: 's ap',
    toGrams: Decimal.parse('1.2959782'),
  );

  static final apothecariesDrams = WeightUnit(
    id: 'apothecaries_drams',
    name: 'Apothecaries Drams',
    symbol: 'dr ap',
    toGrams: Decimal.parse('3.8879346'),
  );

  static final apothecariesOunces = WeightUnit(
    id: 'apothecaries_ounces',
    name: 'Apothecaries Ounces',
    symbol: 'oz ap',
    toGrams: Decimal.parse('31.1034768'),
  );

  static final apothecariesPounds = WeightUnit(
    id: 'apothecaries_pounds',
    name: 'Apothecaries Pounds',
    symbol: 'lb ap',
    toGrams: Decimal.parse('373.2417216'),
  );

  // Other Units with precise values
  static final carats = WeightUnit(
    id: 'carats',
    name: 'Carats',
    symbol: 'ct',
    toGrams: Decimal.parse('0.2'),
  );

  static final slugs = WeightUnit(
    id: 'slugs',
    name: 'Slugs',
    symbol: 'slug',
    toGrams: Decimal.parse('14593.903'),
  );

  static final atomicMassUnits = WeightUnit(
    id: 'atomic_mass_units',
    name: 'Atomic Mass Units',
    symbol: 'u',
    toGrams: Decimal.parse('0.00000000000000000000001660539066'),
  );

  @override
  List<WeightUnit> get units => [
        // SI/Metric - most common first
        kilograms,
        grams,
        milligrams,
        tonnes,
        micrograms,
        nanograms,

        // Imperial/US - most common first
        pounds,
        ounces,
        stones,
        grains,
        drams,
        quarters,
        shortHundredweight,
        longHundredweight,
        shortTons,
        longTons,

        // Troy System
        troyOunces,
        pennyweights,
        troyPounds,
        troyGrains,

        // Apothecaries System
        apothecariesOunces,
        apothecariesDrams,
        scruples,
        apothecariesPounds,

        // Other
        carats,
        slugs,
        atomicMassUnits,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final from = units.firstWhere((unit) => unit.id == fromUnit);
    final to = units.firstWhere((unit) => unit.id == toUnit);

    // Use Decimal for precise calculations
    final decimalValue = Decimal.parse(value.toString());
    final inGrams = decimalValue * from.toGrams;
    final result = inGrams / to.toGrams;

    return result.toDouble();
  }
}

/// Temperature units and converter
class TemperatureUnit extends ConversionUnit {
  const TemperatureUnit({
    required super.id,
    required super.name,
    required super.symbol,
    super.description,
  });
}

class TemperatureConverter extends BaseConverter {
  @override
  String get name => 'Temperature';

  @override
  String get description => 'Convert between different temperature units';

  @override
  TemperatureUnit get baseUnit => celsius;

  static const celsius = TemperatureUnit(
    id: 'celsius',
    name: 'Celsius',
    symbol: '°C',
  );

  static const fahrenheit = TemperatureUnit(
    id: 'fahrenheit',
    name: 'Fahrenheit',
    symbol: '°F',
  );

  static const kelvin = TemperatureUnit(
    id: 'kelvin',
    name: 'Kelvin',
    symbol: 'K',
  );

  @override
  List<TemperatureUnit> get units => [
        celsius,
        fahrenheit,
        kelvin,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    // Convert to Celsius first
    double celsius;
    switch (fromUnit) {
      case 'celsius':
        celsius = value;
        break;
      case 'fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'kelvin':
        celsius = value - 273.15;
        break;
      default:
        throw ArgumentError('Unknown temperature unit: $fromUnit');
    }

    // Convert from Celsius to target unit
    switch (toUnit) {
      case 'celsius':
        return celsius;
      case 'fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'kelvin':
        return celsius + 273.15;
      default:
        throw ArgumentError('Unknown temperature unit: $toUnit');
    }
  }
}

/// Volume units and converter
class VolumeUnit extends ConversionUnit {
  final double toLiters;

  const VolumeUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.toLiters,
    super.description,
  });
}

class VolumeConverter extends BaseConverter {
  @override
  String get name => 'Volume';

  @override
  String get description => 'Convert between different volume units';

  @override
  VolumeUnit get baseUnit => liters;

  static const liters = VolumeUnit(
    id: 'liters',
    name: 'Liters',
    symbol: 'L',
    toLiters: 1.0,
  );

  static const milliliters = VolumeUnit(
    id: 'milliliters',
    name: 'Milliliters',
    symbol: 'ml',
    toLiters: 0.001,
  );

  static const gallons = VolumeUnit(
    id: 'gallons',
    name: 'Gallons (US)',
    symbol: 'gal',
    toLiters: 3.78541,
  );

  static const quarts = VolumeUnit(
    id: 'quarts',
    name: 'Quarts',
    symbol: 'qt',
    toLiters: 0.946353,
  );

  static const pints = VolumeUnit(
    id: 'pints',
    name: 'Pints',
    symbol: 'pt',
    toLiters: 0.473176,
  );

  static const cups = VolumeUnit(
    id: 'cups',
    name: 'Cups',
    symbol: 'cup',
    toLiters: 0.236588,
  );

  @override
  List<VolumeUnit> get units => [
        liters,
        milliliters,
        gallons,
        quarts,
        pints,
        cups,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final from = units.firstWhere((unit) => unit.id == fromUnit);
    final to = units.firstWhere((unit) => unit.id == toUnit);

    final inLiters = value * from.toLiters;
    return inLiters / to.toLiters;
  }
}

/// Area units and converter
class AreaUnit extends ConversionUnit {
  final double toSquareMeters;

  const AreaUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.toSquareMeters,
    super.description,
  });
}

class AreaConverter extends BaseConverter {
  @override
  String get name => 'Area';

  @override
  String get description => 'Convert between different area units';

  @override
  AreaUnit get baseUnit => squareMeters;

  static const squareMeters = AreaUnit(
    id: 'square_meters',
    name: 'Square Meters',
    symbol: 'm²',
    toSquareMeters: 1.0,
  );

  static const squareKilometers = AreaUnit(
    id: 'square_kilometers',
    name: 'Square Kilometers',
    symbol: 'km²',
    toSquareMeters: 1000000.0,
  );

  static const squareFeet = AreaUnit(
    id: 'square_feet',
    name: 'Square Feet',
    symbol: 'ft²',
    toSquareMeters: 0.092903,
  );

  static const squareInches = AreaUnit(
    id: 'square_inches',
    name: 'Square Inches',
    symbol: 'in²',
    toSquareMeters: 0.00064516,
  );

  static const acres = AreaUnit(
    id: 'acres',
    name: 'Acres',
    symbol: 'ac',
    toSquareMeters: 4046.86,
  );

  static const hectares = AreaUnit(
    id: 'hectares',
    name: 'Hectares',
    symbol: 'ha',
    toSquareMeters: 10000.0,
  );

  @override
  List<AreaUnit> get units => [
        squareMeters,
        squareKilometers,
        squareFeet,
        squareInches,
        acres,
        hectares,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final from = units.firstWhere((unit) => unit.id == fromUnit);
    final to = units.firstWhere((unit) => unit.id == toUnit);

    final inSquareMeters = value * from.toSquareMeters;
    return inSquareMeters / to.toSquareMeters;
  }
}

/// Speed units and converter
class SpeedUnit extends ConversionUnit {
  final double toMetersPerSecond;

  const SpeedUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.toMetersPerSecond,
    super.description,
  });
}

class SpeedConverter extends BaseConverter {
  @override
  String get name => 'Speed';

  @override
  String get description => 'Convert between different speed units';

  @override
  SpeedUnit get baseUnit => metersPerSecond;

  static const metersPerSecond = SpeedUnit(
    id: 'meters_per_second',
    name: 'Meters per Second',
    symbol: 'm/s',
    toMetersPerSecond: 1.0,
  );

  static const kilometersPerHour = SpeedUnit(
    id: 'kilometers_per_hour',
    name: 'Kilometers per Hour',
    symbol: 'km/h',
    toMetersPerSecond: 0.277778,
  );

  static const milesPerHour = SpeedUnit(
    id: 'miles_per_hour',
    name: 'Miles per Hour',
    symbol: 'mph',
    toMetersPerSecond: 0.44704,
  );

  static const knots = SpeedUnit(
    id: 'knots',
    name: 'Knots',
    symbol: 'kn',
    toMetersPerSecond: 0.514444,
  );

  @override
  List<SpeedUnit> get units => [
        metersPerSecond,
        kilometersPerHour,
        milesPerHour,
        knots,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final from = units.firstWhere((unit) => unit.id == fromUnit);
    final to = units.firstWhere((unit) => unit.id == toUnit);

    final inMetersPerSecond = value * from.toMetersPerSecond;
    return inMetersPerSecond / to.toMetersPerSecond;
  }
}

/// Time units and converter
class TimeUnit extends ConversionUnit {
  final double toSeconds;

  const TimeUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.toSeconds,
    super.description,
  });
}

class TimeConverter extends BaseConverter {
  @override
  String get name => 'Time';

  @override
  String get description => 'Convert between different time units';

  @override
  TimeUnit get baseUnit => seconds;

  static const seconds = TimeUnit(
    id: 'seconds',
    name: 'Seconds',
    symbol: 's',
    toSeconds: 1.0,
  );

  static const minutes = TimeUnit(
    id: 'minutes',
    name: 'Minutes',
    symbol: 'min',
    toSeconds: 60.0,
  );

  static const hours = TimeUnit(
    id: 'hours',
    name: 'Hours',
    symbol: 'h',
    toSeconds: 3600.0,
  );

  static const days = TimeUnit(
    id: 'days',
    name: 'Days',
    symbol: 'd',
    toSeconds: 86400.0,
  );

  static const weeks = TimeUnit(
    id: 'weeks',
    name: 'Weeks',
    symbol: 'w',
    toSeconds: 604800.0,
  );

  static const months = TimeUnit(
    id: 'months',
    name: 'Months',
    symbol: 'mo',
    toSeconds: 2629746.0, // Average month
  );

  static const years = TimeUnit(
    id: 'years',
    name: 'Years',
    symbol: 'y',
    toSeconds: 31556952.0, // Average year
  );

  @override
  List<TimeUnit> get units => [
        seconds,
        minutes,
        hours,
        days,
        weeks,
        months,
        years,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final from = units.firstWhere((unit) => unit.id == fromUnit);
    final to = units.firstWhere((unit) => unit.id == toUnit);

    final inSeconds = value * from.toSeconds;
    return inSeconds / to.toSeconds;
  }
}

/// Data units and converter
class DataUnit extends ConversionUnit {
  final double toBytes;

  const DataUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.toBytes,
    super.description,
  });
}

class DataConverter extends BaseConverter {
  @override
  String get name => 'Data Storage';

  @override
  String get description => 'Convert between different data storage units';

  @override
  DataUnit get baseUnit => bytes;

  static const bytes = DataUnit(
    id: 'bytes',
    name: 'Bytes',
    symbol: 'B',
    toBytes: 1.0,
  );

  static const kilobytes = DataUnit(
    id: 'kilobytes',
    name: 'Kilobytes',
    symbol: 'KB',
    toBytes: 1024.0,
  );

  static const megabytes = DataUnit(
    id: 'megabytes',
    name: 'Megabytes',
    symbol: 'MB',
    toBytes: 1048576.0,
  );

  static const gigabytes = DataUnit(
    id: 'gigabytes',
    name: 'Gigabytes',
    symbol: 'GB',
    toBytes: 1073741824.0,
  );

  static const terabytes = DataUnit(
    id: 'terabytes',
    name: 'Terabytes',
    symbol: 'TB',
    toBytes: 1099511627776.0,
  );

  static const bits = DataUnit(
    id: 'bits',
    name: 'Bits',
    symbol: 'bit',
    toBytes: 0.125,
  );

  @override
  List<DataUnit> get units => [
        bytes,
        kilobytes,
        megabytes,
        gigabytes,
        terabytes,
        bits,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final from = units.firstWhere((unit) => unit.id == fromUnit);
    final to = units.firstWhere((unit) => unit.id == toUnit);

    final inBytes = value * from.toBytes;
    return inBytes / to.toBytes;
  }
}

/// Number system units and converter
class NumberSystemUnit extends ConversionUnit {
  final int base;

  const NumberSystemUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.base,
    super.description,
  });
}

class NumberSystemConverter extends BaseConverter {
  @override
  String get name => 'Number Systems';

  @override
  String get description => 'Convert between different number systems';

  @override
  NumberSystemUnit get baseUnit => decimal;

  static const decimal = NumberSystemUnit(
    id: 'decimal',
    name: 'Decimal',
    symbol: 'Dec',
    base: 10,
  );

  static const binary = NumberSystemUnit(
    id: 'binary',
    name: 'Binary',
    symbol: 'Bin',
    base: 2,
  );

  static const octal = NumberSystemUnit(
    id: 'octal',
    name: 'Octal',
    symbol: 'Oct',
    base: 8,
  );

  static const hexadecimal = NumberSystemUnit(
    id: 'hexadecimal',
    name: 'Hexadecimal',
    symbol: 'Hex',
    base: 16,
  );

  @override
  List<NumberSystemUnit> get units => [
        decimal,
        binary,
        octal,
        hexadecimal,
      ];

  @override
  double convert(double value, String fromUnit, String toUnit) {
    // Number system conversion is handled differently
    // This is just for compatibility with the base class
    return value;
  }

  /// Convert between number systems (returns string representation)
  String convertNumberSystem(String value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    final from = units.firstWhere((unit) => unit.id == fromUnit);
    final to = units.firstWhere((unit) => unit.id == toUnit);

    try {
      // Convert to decimal first
      int decimal;
      if (from.base == 10) {
        decimal = int.parse(value);
      } else {
        decimal = int.parse(value, radix: from.base);
      }

      // Convert from decimal to target base
      if (to.base == 10) {
        return decimal.toString();
      } else {
        return decimal.toRadixString(to.base).toUpperCase();
      }
    } catch (e) {
      return 'Invalid input';
    }
  }
}

/// Currency units (for reference, actual rates would come from API)
class CurrencyUnit extends ConversionUnit {
  final String countryCode;

  const CurrencyUnit({
    required super.id,
    required super.name,
    required super.symbol,
    required this.countryCode,
    super.description,
  });
}

class CurrencyConverter extends BaseConverter {
  @override
  String get name => 'Currency';

  @override
  String get description => 'Convert between different currencies';

  @override
  CurrencyUnit get baseUnit => usd;
  static const usd = CurrencyUnit(
    id: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    countryCode: 'US',
  );

  static const eur = CurrencyUnit(
    id: 'EUR',
    name: 'Euro',
    symbol: '€',
    countryCode: 'EU',
  );

  static const gbp = CurrencyUnit(
    id: 'GBP',
    name: 'British Pound',
    symbol: '£',
    countryCode: 'GB',
  );

  static const jpy = CurrencyUnit(
    id: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    countryCode: 'JP',
  );

  static const cad = CurrencyUnit(
    id: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
    countryCode: 'CA',
  );

  static const aud = CurrencyUnit(
    id: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
    countryCode: 'AU',
  );
  static const vnd = CurrencyUnit(
    id: 'VND',
    name: 'Vietnamese Dong',
    symbol: '₫',
    countryCode: 'VN',
  );

  static const cny = CurrencyUnit(
    id: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    countryCode: 'CN',
  );

  static const thb = CurrencyUnit(
    id: 'THB',
    name: 'Thai Baht',
    symbol: '฿',
    countryCode: 'TH',
  );
  static const sgd = CurrencyUnit(
    id: 'SGD',
    name: 'Singapore Dollar',
    symbol: 'S\$',
    countryCode: 'SG',
  );

  @override
  List<CurrencyUnit> get units {
    // Use CurrencyService to get all supported currencies
    return CurrencyService.getSupportedCurrencies()
        .map((currency) => CurrencyUnit(
              id: currency.code,
              name: currency.name,
              symbol: currency.symbol,
              countryCode: _getCountryCode(currency.code),
            ))
        .toList();
  }

  static String _getCountryCode(String currencyCode) {
    const Map<String, String> currencyToCountry = {
      'USD': 'US',
      'EUR': 'EU',
      'GBP': 'GB',
      'JPY': 'JP',
      'CAD': 'CA',
      'AUD': 'AU',
      'CHF': 'CH',
      'VND': 'VN',
      'CNY': 'CN',
      'HKD': 'HK',
      'TWD': 'TW',
      'SGD': 'SG',
      'MYR': 'MY',
      'THB': 'TH',
      'IDR': 'ID',
      'PHP': 'PH',
      'INR': 'IN',
      'KRW': 'KR',
      'BND': 'BN',
      'LAK': 'LA',
      'KHR': 'KH',
      'MMK': 'MM',
      'MOP': 'MO',
      'SEK': 'SE',
      'NOK': 'NO',
      'DKK': 'DK',
      'PLN': 'PL',
      'CZK': 'CZ',
      'HUF': 'HU',
      'RON': 'RO',
      'BGN': 'BG',
      'HRK': 'HR',
      'RUB': 'RU',
      'TRY': 'TR',
      'UAH': 'UA',
      'BYN': 'BY',
      'MDL': 'MD',
      'GEL': 'GE',
      'AMD': 'AM',
      'AZN': 'AZ',
      'ILS': 'IL',
      'SAR': 'SA',
      'AED': 'AE',
      'QAR': 'QA',
      'KWD': 'KW',
      'BHD': 'BH',
      'OMR': 'OM',
      'JOD': 'JO',
      'LBP': 'LB',
      'EGP': 'EG',
      'MAD': 'MA',
      'ZAR': 'ZA',
      'NGN': 'NG',
      'KES': 'KE',
      'GHS': 'GH',
      'UGX': 'UG',
      'TZS': 'TZ',
      'ETB': 'ET',
      'XOF': 'BF',
      'XAF': 'CM',
      'BRL': 'BR',
      'MXN': 'MX',
      'ARS': 'AR',
      'CLP': 'CL',
      'COP': 'CO',
      'PEN': 'PE',
      'UYU': 'UY',
      'KZT': 'KZ',
      'UZS': 'UZ',
      'KGS': 'KG',
      'TJS': 'TJ',
      'TMT': 'TM',
      'AFN': 'AF',
      'PKR': 'PK',
      'BDT': 'BD',
      'LKR': 'LK',
      'NPR': 'NP',
      'BTN': 'BT',
      'MVR': 'MV',
      'NZD': 'NZ',
      'FJD': 'FJ',
      'PGK': 'PG',
      'SBD': 'SB',
      'TOP': 'TO',
      'VUV': 'VU',
      'WST': 'WS',
      'XPF': 'PF',
    };
    return currencyToCountry[currencyCode] ?? currencyCode.substring(0, 2);
  }

  @override
  double convert(double value, String fromUnit, String toUnit) {
    // Use the CurrencyService for conversion
    return CurrencyService.convert(
        value, fromUnit.toUpperCase(), toUnit.toUpperCase());
  }
}
