class UnitCategory {
  final String id;
  final String name;
  final String description;
  final List<Unit> units;

  UnitCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.units,
  });

  factory UnitCategory.fromJson(Map<String, dynamic> json) {
    return UnitCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      units: (json['units'] as List).map((u) => Unit.fromJson(u)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'units': units.map((u) => u.toJson()).toList(),
    };
  }
}

class Unit {
  final String id;
  final String name;
  final String symbol;
  final double factor; // Conversion factor to base unit
  final double offset; // Offset for temperature conversions

  Unit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.factor,
    this.offset = 0.0,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      factor: json['factor'].toDouble(),
      offset: json['offset']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'factor': factor,
      'offset': offset,
    };
  }
}

class ConversionResult {
  final double value;
  final Unit fromUnit;
  final Unit toUnit;
  final DateTime timestamp;

  ConversionResult({
    required this.value,
    required this.fromUnit,
    required this.toUnit,
    required this.timestamp,
  });

  String get formattedValue {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else if (value.abs() >= 1000000 || value.abs() < 0.001) {
      return value.toStringAsExponential(4);
    } else {
      return value
          .toStringAsFixed(6)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'fromUnit': fromUnit.toJson(),
      'toUnit': toUnit.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ConversionResult.fromJson(Map<String, dynamic> json) {
    return ConversionResult(
      value: json['value'].toDouble(),
      fromUnit: Unit.fromJson(json['fromUnit']),
      toUnit: Unit.fromJson(json['toUnit']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
