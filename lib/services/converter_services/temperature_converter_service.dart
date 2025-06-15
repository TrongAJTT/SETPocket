import 'package:setpocket/models/converter_models/converter_base.dart';
import 'converter_service_base.dart';
import 'package:setpocket/services/number_format_service.dart';

class TemperatureUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;

  TemperatureUnit({
    required String id,
    required String name,
    required String symbol,
  })  : _id = id,
        _name = name,
        _symbol = symbol;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get symbol => _symbol;

  @override
  String formatValue(double value) {
    return NumberFormatService.formatUnit(value);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
      };
}

class TemperatureConverterService extends ConverterServiceBase {
  static final TemperatureConverterService _instance =
      TemperatureConverterService._internal();
  factory TemperatureConverterService() => _instance;
  TemperatureConverterService._internal();

  @override
  String get converterType => 'temperature';

  @override
  String get displayName => 'Temperature Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'celsius',
        'fahrenheit',
      };

  @override
  List<ConverterUnit> get units => [
        // Common units
        TemperatureUnit(id: 'celsius', name: 'Celsius', symbol: '°C'),
        TemperatureUnit(id: 'fahrenheit', name: 'Fahrenheit', symbol: '°F'),
        // Less common
        TemperatureUnit(id: 'kelvin', name: 'Kelvin', symbol: 'K'),
        // Rare units
        TemperatureUnit(id: 'rankine', name: 'Rankine', symbol: '°R'),
        TemperatureUnit(id: 'reaumur', name: 'Réaumur', symbol: '°Ré'),
        TemperatureUnit(id: 'delisle', name: 'Delisle', symbol: '°De'),
      ];

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    if (fromUnitId == toUnitId) return value;

    // First convert from source unit to Celsius
    double celsius = _toCelsius(value, fromUnitId);

    // Then convert from Celsius to target unit
    return _fromCelsius(celsius, toUnitId);
  }

  // Convert any temperature unit to Celsius
  double _toCelsius(double value, String unitId) {
    switch (unitId) {
      case 'celsius':
        return value;
      case 'fahrenheit':
        return (value - 32) * 5 / 9;
      case 'kelvin':
        return value - 273.15;
      case 'rankine':
        return (value - 491.67) * 5 / 9;
      case 'reaumur':
        return value * 5 / 4;
      case 'delisle':
        return 100 - value * 2 / 3;
      default:
        throw Exception('Unknown temperature unit: $unitId');
    }
  }

  // Convert Celsius to any temperature unit
  double _fromCelsius(double celsius, String unitId) {
    switch (unitId) {
      case 'celsius':
        return celsius;
      case 'fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'kelvin':
        return celsius + 273.15;
      case 'rankine':
        return (celsius + 273.15) * 9 / 5;
      case 'reaumur':
        return celsius * 4 / 5;
      case 'delisle':
        return (100 - celsius) * 3 / 2;
      default:
        throw Exception('Unknown temperature unit: $unitId');
    }
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  TemperatureUnit? _getUnitById(String unitId) {
    try {
      return units.firstWhere((unit) => unit.id == unitId) as TemperatureUnit;
    } catch (e) {
      return null;
    }
  }

  @override
  ConversionStatus getUnitStatus(String unitId) {
    // Temperature conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for temperature converter as it doesn't need real-time data
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;
}
