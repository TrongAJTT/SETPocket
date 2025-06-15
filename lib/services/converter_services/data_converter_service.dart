import '../../models/converter_models/converter_base.dart';
import 'converter_service_base.dart';
import '../number_format_service.dart';

class DataUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final double _factor;

  DataUnit({
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

class DataConverterService extends ConverterServiceBase {
  static final DataConverterService _instance =
      DataConverterService._internal();
  factory DataConverterService() => _instance;
  DataConverterService._internal();

  @override
  String get converterType => 'data_storage';

  @override
  String get displayName => 'Data Storage Converter';

  @override
  Set<String> get defaultVisibleUnits => {
        'kilobyte',
        'megabyte',
        'gigabyte',
      };

  @override
  List<ConverterUnit> get units => [
        // Base units (bytes)
        DataUnit(id: 'byte', name: 'Byte', symbol: 'B', factor: 1.0),
        DataUnit(
            id: 'kilobyte', name: 'Kilobyte', symbol: 'KB', factor: 1024.0),
        DataUnit(
            id: 'megabyte',
            name: 'Megabyte',
            symbol: 'MB',
            factor: 1048576.0), // 1024^2
        DataUnit(
            id: 'gigabyte',
            name: 'Gigabyte',
            symbol: 'GB',
            factor: 1073741824.0), // 1024^3
        DataUnit(
            id: 'terabyte',
            name: 'Terabyte',
            symbol: 'TB',
            factor: 1099511627776.0), // 1024^4
        DataUnit(
            id: 'petabyte',
            name: 'Petabyte',
            symbol: 'PB',
            factor: 1125899906842624.0), // 1024^5

        // Bit units (base unit is byte, so bit = 1/8 byte)
        DataUnit(
            id: 'bit', name: 'Bit', symbol: 'bit', factor: 0.125), // 1/8 byte
        DataUnit(
            id: 'kilobit',
            name: 'Kilobit',
            symbol: 'Kbit',
            factor: 128.0), // 1024 bits = 128 bytes
        DataUnit(
            id: 'megabit',
            name: 'Megabit',
            symbol: 'Mbit',
            factor: 131072.0), // 1024^2 bits = 131072 bytes
        DataUnit(
            id: 'gigabit',
            name: 'Gigabit',
            symbol: 'Gbit',
            factor: 134217728.0), // 1024^3 bits = 134217728 bytes
      ];

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    if (fromUnitId == toUnitId) return value;

    final fromUnit = _getUnitById(fromUnitId);
    final toUnit = _getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) {
      throw Exception('Unit not found: $fromUnitId or $toUnitId');
    }

    // Convert to base unit (byte) first, then to target unit
    final baseValue = value * fromUnit.factor;
    return baseValue / toUnit.factor;
  }

  @override
  ConverterUnit? getUnit(String unitId) => _getUnitById(unitId);

  DataUnit? _getUnitById(String unitId) {
    try {
      return units.firstWhere((unit) => unit.id == unitId) as DataUnit;
    } catch (e) {
      return null;
    }
  }

  @override
  ConversionStatus getUnitStatus(String unitId) {
    // Data storage conversions are always successful as they're mathematical
    return ConversionStatus.success;
  }

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // No-op for data storage converter as it doesn't need real-time data
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;
}
