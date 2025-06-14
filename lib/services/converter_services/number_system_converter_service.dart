import 'package:setpocket/models/converter_models/converter_base.dart';
import 'converter_service_base.dart';

class NumberSystemUnit extends ConverterUnit {
  final String _id;
  final String _name;
  final String _symbol;
  final int _base;

  NumberSystemUnit({
    required String id,
    required String name,
    required String symbol,
    required int base,
  })  : _id = id,
        _name = name,
        _symbol = symbol,
        _base = base;

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  String get symbol => _symbol;

  int get base => _base;

  @override
  String formatValue(double value) {
    // For number systems, we work with integers
    final intValue = value.round();

    if (intValue < 0) return '0';

    try {
      switch (_base) {
        case 2:
          return intValue.toRadixString(2);
        case 8:
          return intValue.toRadixString(8);
        case 10:
          return intValue.toString();
        case 16:
          return intValue.toRadixString(16).toUpperCase();
        case 32:
          return _toBase32(intValue);
        case 64:
          return _toBase64(intValue);
        case 128:
          return _toBaseN(intValue, 128);
        case 256:
          return _toBaseN(intValue, 256);
        default:
          return intValue.toRadixString(_base);
      }
    } catch (e) {
      return '0';
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'symbol': _symbol,
      'base': _base,
    };
  }

  // Convert decimal to base 32 using standard alphabet
  String _toBase32(int value) {
    if (value == 0) return '0';

    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
    String result = '';
    int temp = value;

    while (temp > 0) {
      result = alphabet[temp % 32] + result;
      temp ~/= 32;
    }

    return result;
  }

  // Convert decimal to base 64 using standard alphabet
  String _toBase64(int value) {
    if (value == 0) return '0';

    const alphabet =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
    String result = '';
    int temp = value;

    while (temp > 0) {
      result = alphabet[temp % 64] + result;
      temp ~/= 64;
    }

    return result;
  }

  // Convert decimal to arbitrary base N
  String _toBaseN(int value, int base) {
    if (value == 0) return '0';

    String result = '';
    int temp = value;

    while (temp > 0) {
      int remainder = temp % base;
      if (remainder < 10) {
        result = remainder.toString() + result;
      } else {
        // Use ASCII values for bases > 10
        result = String.fromCharCode(65 + remainder - 10) + result;
      }
      temp ~/= base;
    }

    return result;
  }

  // Convert from this base to decimal
  double parseValue(String input) {
    if (input.isEmpty) return 0.0;

    try {
      switch (_base) {
        case 2:
        case 8:
        case 16:
          return int.parse(input, radix: _base).toDouble();
        case 10:
          return double.parse(input);
        case 32:
          return _fromBase32(input).toDouble();
        case 64:
          return _fromBase64(input).toDouble();
        case 128:
          return _fromBaseN(input, 128).toDouble();
        case 256:
          return _fromBaseN(input, 256).toDouble();
        default:
          return int.parse(input, radix: _base).toDouble();
      }
    } catch (e) {
      return 0.0;
    }
  }

  int _fromBase32(String input) {
    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
    int result = 0;

    for (int i = 0; i < input.length; i++) {
      final char = input[i].toUpperCase();
      final value = alphabet.indexOf(char);
      if (value == -1) return 0;
      result = result * 32 + value;
    }

    return result;
  }

  int _fromBase64(String input) {
    const alphabet =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
    int result = 0;

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final value = alphabet.indexOf(char);
      if (value == -1) return 0;
      result = result * 64 + value;
    }

    return result;
  }

  int _fromBaseN(String input, int base) {
    int result = 0;

    for (int i = 0; i < input.length; i++) {
      final char = input[i].toUpperCase();
      int value;

      if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        // 0-9
        value = char.codeUnitAt(0) - 48;
      } else if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        // A-Z
        value = char.codeUnitAt(0) - 65 + 10;
      } else {
        return 0;
      }

      if (value >= base) return 0;
      result = result * base + value;
    }

    return result;
  }
}

class NumberSystemConverterService extends ConverterServiceBase {
  static final NumberSystemConverterService _instance =
      NumberSystemConverterService._internal();
  factory NumberSystemConverterService() => _instance;
  NumberSystemConverterService._internal();

  @override
  String get converterType => 'number_system';

  @override
  String get displayName => 'Number System Converter';

  @override
  bool get requiresRealTimeData => false;

  // Define all number system units
  static final _binaryUnit = NumberSystemUnit(
    id: 'binary',
    name: 'Binary',
    symbol: 'bin',
    base: 2,
  );

  static final _octalUnit = NumberSystemUnit(
    id: 'octal',
    name: 'Octal',
    symbol: 'oct',
    base: 8,
  );

  static final _decimalUnit = NumberSystemUnit(
    id: 'decimal',
    name: 'Decimal',
    symbol: 'dec',
    base: 10,
  );

  static final _hexadecimalUnit = NumberSystemUnit(
    id: 'hexadecimal',
    name: 'Hexadecimal',
    symbol: 'hex',
    base: 16,
  );

  static final _base32Unit = NumberSystemUnit(
    id: 'base32',
    name: 'Base 32',
    symbol: 'b32',
    base: 32,
  );

  static final _base64Unit = NumberSystemUnit(
    id: 'base64',
    name: 'Base 64',
    symbol: 'b64',
    base: 64,
  );

  static final _base128Unit = NumberSystemUnit(
    id: 'base128',
    name: 'Base 128',
    symbol: 'b128',
    base: 128,
  );

  static final _base256Unit = NumberSystemUnit(
    id: 'base256',
    name: 'Base 256',
    symbol: 'b256',
    base: 256,
  );

  @override
  List<ConverterUnit> get units => [
        _binaryUnit,
        _octalUnit,
        _decimalUnit,
        _hexadecimalUnit,
        _base32Unit,
        _base64Unit,
        _base128Unit,
        _base256Unit,
      ];

  @override
  Set<String> get defaultVisibleUnits => {
        'binary',
        'decimal',
        'hexadecimal',
        'octal',
        'base32',
        'base64',
      };

  @override
  ConverterUnit? getUnit(String id) {
    try {
      return units.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  // @override
  // Map<String, double> convertToAll(
  //     String fromUnitId, double value, Set<String> visibleUnits) {
  //   final fromUnit = getUnit(fromUnitId) as NumberSystemUnit?;
  //   if (fromUnit == null) return {};

  //   final results = <String, double>{};

  //   // First convert to decimal (base 10) if not already
  //   double decimalValue;
  //   if (fromUnit.base == 10) {
  //     decimalValue = value;
  //   } else {
  //     // Convert from the input base to decimal
  //     decimalValue = value; // Already converted by parseValue
  //   }

  //   // Convert decimal to all visible units
  //   for (String unitId in visibleUnits) {
  //     final toUnit = getUnit(unitId) as NumberSystemUnit?;
  //     if (toUnit != null) {
  //       results[unitId] = decimalValue;
  //     }
  //   }

  //   return results;
  // }

  // @override
  // double parseValue(String input, String unitId) {
  //   final unit = getUnit(unitId) as NumberSystemUnit?;
  //   if (unit == null) return 0.0;

  //   return unit.parseValue(input);
  // }

  @override
  double convert(double value, String fromUnitId, String toUnitId) {
    // For number systems, all conversions go through decimal
    return value; // Value is already in decimal after parseValue
  }

  @override
  Future<void> refreshData() async {
    // Number system converter doesn't need real-time data
    return;
  }

  @override
  DateTime? get lastUpdated => null;

  @override
  bool get isUsingLiveData => false;
}
