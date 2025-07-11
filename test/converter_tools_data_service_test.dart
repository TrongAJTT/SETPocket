import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/services/converter_services/converter_tools_data_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:isar/isar.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConverterToolsDataService Tests', () {
    late ConverterToolsDataService service;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
      await IsarService.init();
      service = ConverterToolsDataService();
    });

    tearDownAll(() async {
      await IsarService.close();
    });

    setUp(() async {
      // Clear all data before each test
      await service.clearAllData();
    });

    test('should save and retrieve data', () async {
      final testData = {'key': 'value', 'number': 42};

      await service.saveData(
        toolCode: 'test_tool',
        dataType: 'state',
        data: testData,
      );

      final retrievedData = await service.getData(
        toolCode: 'test_tool',
        dataType: 'state',
      );

      expect(retrievedData, equals(testData));
    });

    test('should save and retrieve state using convenience methods', () async {
      final testState = {'fromUnit': 'meter', 'toUnit': 'feet', 'value': 10.0};

      await ConverterToolsDataService.saveState('test_converter', testState);
      final retrievedState =
          await ConverterToolsDataService.getState('test_converter');

      expect(retrievedState, equals(testState));
    });

    test('should check if data exists', () async {
      final testData = {'test': 'data'};

      // Initially no data
      bool hasData = await ConverterToolsDataService.hasData(
        toolCode: 'test_tool',
        dataType: 'cache',
      );
      expect(hasData, false);

      // Save data
      await service.saveData(
        toolCode: 'test_tool',
        dataType: 'cache',
        data: testData,
      );

      // Now should have data
      hasData = await ConverterToolsDataService.hasData(
        toolCode: 'test_tool',
        dataType: 'cache',
      );
      expect(hasData, true);
    });

    test('should delete data', () async {
      final testData = {'test': 'data'};

      await service.saveData(
        toolCode: 'test_tool',
        dataType: 'state',
        data: testData,
      );

      // Verify data exists
      var retrievedData = await service.getData(
        toolCode: 'test_tool',
        dataType: 'state',
      );
      expect(retrievedData, isNotNull);

      // Delete data
      await service.deleteData(
        toolCode: 'test_tool',
        dataType: 'state',
      );

      // Verify data is gone
      retrievedData = await service.getData(
        toolCode: 'test_tool',
        dataType: 'state',
      );
      expect(retrievedData, isNull);
    });

    test('should get tool data count', () async {
      expect(await service.getToolDataCount('test_tool'), 0);

      await service.saveData(
        toolCode: 'test_tool',
        dataType: 'state',
        data: {'test': 'data1'},
      );
      await service.saveData(
        toolCode: 'test_tool',
        dataType: 'cache',
        data: {'test': 'data2'},
      );

      expect(await service.getToolDataCount('test_tool'), 2);
    });

    test('should estimate data size', () async {
      final testData = {'key': 'value'};

      await service.saveData(
        toolCode: 'test_tool',
        dataType: 'state',
        data: testData,
      );

      final size = await ConverterToolsDataService.getDataSize(
        toolCode: 'test_tool',
        dataType: 'state',
      );

      expect(size, greaterThan(0));
    });
  });
}
