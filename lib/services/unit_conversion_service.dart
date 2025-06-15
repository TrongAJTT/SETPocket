import 'package:setpocket/models/converter_models/unit_models.dart';

class UnitConversionService {
  static final Map<String, UnitCategory> _categories = {
    'length': UnitCategory(
      id: 'length',
      name: 'Length',
      description: 'Distance and length measurements',
      units: [
        Unit(id: 'meter', name: 'Meter', symbol: 'm', factor: 1.0),
        Unit(id: 'kilometer', name: 'Kilometer', symbol: 'km', factor: 1000.0),
        Unit(id: 'centimeter', name: 'Centimeter', symbol: 'cm', factor: 0.01),
        Unit(id: 'millimeter', name: 'Millimeter', symbol: 'mm', factor: 0.001),
        Unit(id: 'inch', name: 'Inch', symbol: 'in', factor: 0.0254),
        Unit(id: 'foot', name: 'Foot', symbol: 'ft', factor: 0.3048),
        Unit(id: 'yard', name: 'Yard', symbol: 'yd', factor: 0.9144),
        Unit(id: 'mile', name: 'Mile', symbol: 'mi', factor: 1609.344),
        Unit(
            id: 'nautical_mile',
            name: 'Nautical Mile',
            symbol: 'nmi',
            factor: 1852.0),
      ],
    ),
    'weight': UnitCategory(
      id: 'weight',
      name: 'Weight',
      description: 'Mass and weight measurements',
      units: [
        Unit(id: 'kilogram', name: 'Kilogram', symbol: 'kg', factor: 1.0),
        Unit(id: 'gram', name: 'Gram', symbol: 'g', factor: 0.001),
        Unit(id: 'pound', name: 'Pound', symbol: 'lb', factor: 0.453592),
        Unit(id: 'ounce', name: 'Ounce', symbol: 'oz', factor: 0.0283495),
        Unit(id: 'ton', name: 'Ton', symbol: 't', factor: 1000.0),
        Unit(id: 'stone', name: 'Stone', symbol: 'st', factor: 6.35029),
      ],
    ),
    'area': UnitCategory(
      id: 'area',
      name: 'Area',
      description: 'Surface area measurements',
      units: [
        Unit(
            id: 'square_meter',
            name: 'Square Meter',
            symbol: 'm²',
            factor: 1.0),
        Unit(
            id: 'square_kilometer',
            name: 'Square Kilometer',
            symbol: 'km²',
            factor: 1000000.0),
        Unit(
            id: 'square_centimeter',
            name: 'Square Centimeter',
            symbol: 'cm²',
            factor: 0.0001),
        Unit(
            id: 'square_foot',
            name: 'Square Foot',
            symbol: 'ft²',
            factor: 0.092903),
        Unit(
            id: 'square_inch',
            name: 'Square Inch',
            symbol: 'in²',
            factor: 0.00064516),
        Unit(id: 'acre', name: 'Acre', symbol: 'ac', factor: 4046.86),
        Unit(id: 'hectare', name: 'Hectare', symbol: 'ha', factor: 10000.0),
      ],
    ),
    'volume': UnitCategory(
      id: 'volume',
      name: 'Volume',
      description: 'Volume and capacity measurements',
      units: [
        Unit(id: 'liter', name: 'Liter', symbol: 'L', factor: 1.0),
        Unit(id: 'milliliter', name: 'Milliliter', symbol: 'mL', factor: 0.001),
        Unit(
            id: 'gallon_us',
            name: 'Gallon (US)',
            symbol: 'gal',
            factor: 3.78541),
        Unit(
            id: 'gallon_uk',
            name: 'Gallon (UK)',
            symbol: 'gal',
            factor: 4.54609),
        Unit(id: 'quart', name: 'Quart', symbol: 'qt', factor: 0.946353),
        Unit(id: 'pint', name: 'Pint', symbol: 'pt', factor: 0.473176),
        Unit(id: 'cup', name: 'Cup', symbol: 'cup', factor: 0.236588),
        Unit(
            id: 'fluid_ounce',
            name: 'Fluid Ounce',
            symbol: 'fl oz',
            factor: 0.0295735),
        Unit(
            id: 'cubic_meter',
            name: 'Cubic Meter',
            symbol: 'm³',
            factor: 1000.0),
      ],
    ),
    'temperature': UnitCategory(
      id: 'temperature',
      name: 'Temperature',
      description: 'Temperature measurements',
      units: [
        Unit(
            id: 'celsius',
            name: 'Celsius',
            symbol: '°C',
            factor: 1.0,
            offset: 0.0),
        Unit(
            id: 'fahrenheit',
            name: 'Fahrenheit',
            symbol: '°F',
            factor: 5 / 9,
            offset: 32.0),
        Unit(
            id: 'kelvin',
            name: 'Kelvin',
            symbol: 'K',
            factor: 1.0,
            offset: -273.15),
      ],
    ),
    'speed': UnitCategory(
      id: 'speed',
      name: 'Speed',
      description: 'Speed and velocity measurements',
      units: [
        Unit(
            id: 'meter_per_second',
            name: 'Meter per Second',
            symbol: 'm/s',
            factor: 1.0),
        Unit(
            id: 'kilometer_per_hour',
            name: 'Kilometer per Hour',
            symbol: 'km/h',
            factor: 0.277778),
        Unit(
            id: 'mile_per_hour',
            name: 'Mile per Hour',
            symbol: 'mph',
            factor: 0.44704),
        Unit(id: 'knot', name: 'Knot', symbol: 'kn', factor: 0.514444),
        Unit(
            id: 'foot_per_second',
            name: 'Foot per Second',
            symbol: 'ft/s',
            factor: 0.3048),
      ],
    ),
    'time': UnitCategory(
      id: 'time',
      name: 'Time',
      description: 'Time duration measurements',
      units: [
        Unit(id: 'second', name: 'Second', symbol: 's', factor: 1.0),
        Unit(id: 'minute', name: 'Minute', symbol: 'min', factor: 60.0),
        Unit(id: 'hour', name: 'Hour', symbol: 'h', factor: 3600.0),
        Unit(id: 'day', name: 'Day', symbol: 'd', factor: 86400.0),
        Unit(id: 'week', name: 'Week', symbol: 'wk', factor: 604800.0),
        Unit(
            id: 'month',
            name: 'Month',
            symbol: 'mo',
            factor: 2628000.0), // 30.42 days
        Unit(
            id: 'year',
            name: 'Year',
            symbol: 'yr',
            factor: 31536000.0), // 365 days
      ],
    ),
    'data_storage': UnitCategory(
      id: 'data_storage',
      name: 'Data Storage',
      description: 'Digital storage measurements',
      units: [
        Unit(id: 'byte', name: 'Byte', symbol: 'B', factor: 1.0),
        Unit(id: 'kilobyte', name: 'Kilobyte', symbol: 'KB', factor: 1024.0),
        Unit(id: 'megabyte', name: 'Megabyte', symbol: 'MB', factor: 1048576.0),
        Unit(
            id: 'gigabyte',
            name: 'Gigabyte',
            symbol: 'GB',
            factor: 1073741824.0),
        Unit(
            id: 'terabyte',
            name: 'Terabyte',
            symbol: 'TB',
            factor: 1099511627776.0),
        Unit(
            id: 'petabyte',
            name: 'Petabyte',
            symbol: 'PB',
            factor: 1125899906842624.0),
        Unit(id: 'bit', name: 'Bit', symbol: 'bit', factor: 0.125),
        Unit(id: 'kilobit', name: 'Kilobit', symbol: 'Kbit', factor: 128.0),
        Unit(id: 'megabit', name: 'Megabit', symbol: 'Mbit', factor: 131072.0),
        Unit(
            id: 'gigabit',
            name: 'Gigabit',
            symbol: 'Gbit',
            factor: 134217728.0),
      ],
    ),
    'number_systems': UnitCategory(
      id: 'number_systems',
      name: 'Number Systems',
      description: 'Number base conversions',
      units: [
        Unit(
            id: 'decimal',
            name: 'Decimal (Base 10)',
            symbol: 'Dec',
            factor: 1.0),
        Unit(id: 'binary', name: 'Binary (Base 2)', symbol: 'Bin', factor: 1.0),
        Unit(id: 'octal', name: 'Octal (Base 8)', symbol: 'Oct', factor: 1.0),
        Unit(
            id: 'hexadecimal',
            name: 'Hexadecimal (Base 16)',
            symbol: 'Hex',
            factor: 1.0),
      ],
    ),
  };

  static List<UnitCategory> getAllCategories() {
    return _categories.values.toList();
  }

  static UnitCategory? getCategory(String categoryId) {
    return _categories[categoryId];
  }

  static double convert(
      double value, Unit fromUnit, Unit toUnit, String categoryId) {
    if (fromUnit.id == toUnit.id) return value;

    switch (categoryId) {
      case 'temperature':
        return _convertTemperature(value, fromUnit, toUnit);
      case 'number_systems':
        return _convertNumberSystem(value, fromUnit, toUnit);
      default:
        return _convertStandard(value, fromUnit, toUnit);
    }
  }

  static double _convertStandard(double value, Unit fromUnit, Unit toUnit) {
    // Convert to base unit first, then to target unit
    double baseValue = value * fromUnit.factor;
    return baseValue / toUnit.factor;
  }

  static double _convertTemperature(double value, Unit fromUnit, Unit toUnit) {
    // Convert to Celsius first
    double celsius;
    switch (fromUnit.id) {
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
        celsius = value;
    }

    // Convert from Celsius to target
    switch (toUnit.id) {
      case 'celsius':
        return celsius;
      case 'fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  static double _convertNumberSystem(double value, Unit fromUnit, Unit toUnit) {
    // For number systems, we need to handle as integers
    int intValue = value.toInt();

    // Convert from source base to decimal
    int decimalValue;
    switch (fromUnit.id) {
      case 'decimal':
        decimalValue = intValue;
        break;
      case 'binary':
        decimalValue = int.parse(intValue.toString(), radix: 2);
        break;
      case 'octal':
        decimalValue = int.parse(intValue.toString(), radix: 8);
        break;
      case 'hexadecimal':
        decimalValue = int.parse(intValue.toString(), radix: 16);
        break;
      default:
        decimalValue = intValue;
    }

    // Convert from decimal to target base
    switch (toUnit.id) {
      case 'decimal':
        return decimalValue.toDouble();
      case 'binary':
        return double.parse(decimalValue.toRadixString(2));
      case 'octal':
        return double.parse(decimalValue.toRadixString(8));
      case 'hexadecimal':
        return double.parse(decimalValue.toRadixString(16));
      default:
        return decimalValue.toDouble();
    }
  }

  static List<ConversionResult> convertToAllUnits(
    double value,
    Unit fromUnit,
    String categoryId,
  ) {
    final category = getCategory(categoryId);
    if (category == null) return [];

    return category.units
        .where((unit) => unit.id != fromUnit.id)
        .map((unit) => ConversionResult(
              value: convert(value, fromUnit, unit, categoryId),
              fromUnit: fromUnit,
              toUnit: unit,
              timestamp: DateTime.now(),
            ))
        .toList();
  }
}
