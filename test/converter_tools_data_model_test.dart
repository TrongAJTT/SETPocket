import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/models/converter_models/converter_tools_data.dart';

void main() {
  group('ConverterToolsData Model Tests', () {
    test('should create ConverterToolsData with create constructor', () {
      final data = ConverterToolsData.create(
        toolCode: 'test_tool',
        dataType: 'state',
        data: {'key': 'value', 'number': 42},
        meta: {'version': '1.0'},
      );

      expect(data.toolCode, 'test_tool');
      expect(data.dataType, 'state');
      expect(data.getParsedData(), {'key': 'value', 'number': 42});
      expect(data.getParsedMetadata(), {'version': '1.0'});
    });

    test('should parse JSON data correctly', () {
      final data = ConverterToolsData.create(
        toolCode: 'area',
        dataType: 'state',
        data: {
          'fromAreaType': 'Square meter',
          'toAreaType': 'Square feet',
          'areaValue': 10.0,
        },
      );

      final parsed = data.getParsedData();
      expect(parsed['fromAreaType'], 'Square meter');
      expect(parsed['toAreaType'], 'Square feet');
      expect(parsed['areaValue'], 10.0);
    });

    test('should update data and timestamp', () {
      final data = ConverterToolsData.create(
        toolCode: 'currency',
        dataType: 'cache',
        data: {'rates': {}},
      );

      final originalTimestamp = data.lastUpdated;

      // Wait a tiny bit to ensure timestamp changes
      Future.delayed(Duration(milliseconds: 1), () {
        data.updateData({
          'rates': {'USD': 1.0, 'EUR': 0.85}
        });

        expect(data.getParsedData(), {
          'rates': {'USD': 1.0, 'EUR': 0.85}
        });
        expect(data.lastUpdated.isAfter(originalTimestamp), true);
      });
    });

    test('should handle invalid JSON gracefully', () {
      final data = ConverterToolsData();
      data.jsonData = 'invalid json';

      expect(data.getParsedData(), {});

      data.metadata = 'invalid metadata json';
      expect(data.getParsedMetadata(), null);
    });

    test('should generate unique key correctly', () {
      final data = ConverterToolsData.create(
        toolCode: 'length',
        dataType: 'presets',
        data: {},
      );

      expect(data.uniqueKey, 'length_presets');
    });

    test('should create toString representation', () {
      final data = ConverterToolsData.create(
        toolCode: 'mass',
        dataType: 'state',
        data: {},
      );

      final stringRep = data.toString();
      expect(stringRep, contains('mass'));
      expect(stringRep, contains('state'));
      expect(stringRep, contains('ConverterToolsData'));
    });
  });

  group('Tool Code Constants Tests', () {
    test('should have all expected tool codes', () {
      expect(ConverterToolCodes.area, 'area');
      expect(ConverterToolCodes.currency, 'currency');
      expect(ConverterToolCodes.length, 'length');
      expect(ConverterToolCodes.weight, 'weight');
      expect(ConverterToolCodes.volume, 'volume');
      expect(ConverterToolCodes.temperature, 'temperature');
      expect(ConverterToolCodes.mass, 'mass');
      expect(ConverterToolCodes.numberSystem, 'number_system');
      expect(ConverterToolCodes.time, 'time');
      expect(ConverterToolCodes.data, 'data');
      expect(ConverterToolCodes.speed, 'speed');
    });
  });

  group('Data Type Constants Tests', () {
    test('should have all expected data types', () {
      expect(ConverterDataTypes.state, 'state');
      expect(ConverterDataTypes.cache, 'cache');
      expect(ConverterDataTypes.presets, 'presets');
    });
  });
}
