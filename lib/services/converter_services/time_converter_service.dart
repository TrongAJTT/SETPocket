import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/converter_services/converter_service_base.dart';
import 'package:setpocket/services/converter_services/time_units_service.dart';

class TimeConverterService implements ConverterServiceBase {
  @override
  String get converterType => 'time';

  @override
  String get displayName => 'Time Converter';

  @override
  Set<String> get defaultVisibleUnits =>
      {'seconds', 'minutes', 'hours', 'days'};

  @override
  List<ConverterUnit> get units {
    return TimeUnitsService.allUnits
        .map((timeUnit) => TimeConverterUnit(
              id: timeUnit.id,
              name: timeUnit.name,
              symbol: timeUnit.symbol,
              timeUnit: timeUnit,
            ))
        .toList();
  }

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    return TimeUnitsService.convert(value, fromUnitId, toUnitId);
  }

  @override
  ConverterUnit? getUnit(String unitId) {
    final timeUnit = TimeUnitsService.getUnitById(unitId);
    if (timeUnit == null) return null;

    return TimeConverterUnit(
      id: timeUnit.id,
      name: timeUnit.name,
      symbol: timeUnit.symbol,
      timeUnit: timeUnit,
    );
  }

  @override
  ConversionStatus getUnitStatus(String unitId) => ConversionStatus.success;

  @override
  bool get requiresRealTimeData => false;

  @override
  Future<void> refreshData() async {
    // Time conversion doesn't require real-time data
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;
}

class TimeConverterUnit extends ConverterUnit {
  final TimeUnit timeUnit;

  TimeConverterUnit({
    required String id,
    required String name,
    required String symbol,
    required this.timeUnit,
  })  : _id = id,
        _name = name,
        _symbol = symbol;

  final String _id;
  final String _name;
  final String _symbol;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get symbol => _symbol;

  @override
  String formatValue(double value) {
    return timeUnit.formatValue(value);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
    };
  }
}
