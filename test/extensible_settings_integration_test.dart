import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/services/settings_models_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/models/settings_models.dart';

/// Integration test for ExtensibleSettings migration and end-to-end functionality
void main() {
  group('ExtensibleSettings Integration Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await IsarService.init();
    });

    tearDownAll(() async {
      try {
        await IsarService.close();
      } catch (e) {
        // Ignore errors
      }
    });

    test('End-to-end settings management lifecycle', () async {
      // Clear all settings to start fresh
      await ExtensibleSettingsService.clearAllSettingsModels();

      // Initialize service (should create defaults)
      await ExtensibleSettingsService.initialize();

      // Test getting default global settings
      final defaultGlobal = await ExtensibleSettingsService.getGlobalSettings();
      expect(defaultGlobal.featureStateSavingEnabled, isTrue);
      expect(defaultGlobal.logRetentionDays, equals(5));
      expect(defaultGlobal.focusModeEnabled, isFalse);

      // Test updating global settings
      final modifiedGlobal = defaultGlobal.copyWith(
        featureStateSavingEnabled: false,
        logRetentionDays: 10,
        focusModeEnabled: true,
      );
      await ExtensibleSettingsService.updateGlobalSettings(modifiedGlobal);

      // Verify the changes persisted
      final updatedGlobal = await ExtensibleSettingsService.getGlobalSettings();
      expect(updatedGlobal.featureStateSavingEnabled, isFalse);
      expect(updatedGlobal.logRetentionDays, equals(10));
      expect(updatedGlobal.focusModeEnabled, isTrue);

      // Test getting default converter settings
      final defaultConverter =
          await ExtensibleSettingsService.getConverterToolsSettings();
      expect(defaultConverter.fetchTimeoutSeconds, equals(10));
      expect(defaultConverter.fetchRetryTimes, equals(1));
      expect(defaultConverter.saveConverterToolsState, isTrue);

      // Test updating converter settings
      final modifiedConverter = defaultConverter.copyWith(
        fetchTimeoutSeconds: 20,
        fetchRetryTimes: 3,
        saveConverterToolsState: false,
      );
      await ExtensibleSettingsService.updateConverterToolsSettings(
          modifiedConverter);

      // Verify converter changes persisted
      final updatedConverter =
          await ExtensibleSettingsService.getConverterToolsSettings();
      expect(updatedConverter.fetchTimeoutSeconds, equals(20));
      expect(updatedConverter.fetchRetryTimes, equals(3));
      expect(updatedConverter.saveConverterToolsState, isFalse);

      // Test getting default random tools settings
      final defaultRandom =
          await ExtensibleSettingsService.getRandomToolsSettings();
      expect(defaultRandom.saveRandomToolsState, isTrue);

      // Test updating random tools settings
      final modifiedRandom = defaultRandom.copyWith(
        saveRandomToolsState: false,
      );
      await ExtensibleSettingsService.updateRandomToolsSettings(modifiedRandom);

      // Verify random tools changes persisted
      final updatedRandom =
          await ExtensibleSettingsService.getRandomToolsSettings();
      expect(updatedRandom.saveRandomToolsState, isFalse);

      // Test getting all settings models
      final allModels = await ExtensibleSettingsService.getAllSettingsModels();
      expect(allModels.length,
          greaterThanOrEqualTo(3)); // At least global, converter, random

      // Verify each model type exists
      final modelCodes = allModels.map((m) => m.modelCode).toList();
      expect(
          modelCodes, contains(ExtensibleSettingsService.globalSettingsCode));
      expect(modelCodes,
          contains(ExtensibleSettingsService.converterToolsSettingsCode));
      expect(modelCodes,
          contains(ExtensibleSettingsService.randomToolsSettingsCode));

      // Test deleting a specific settings model
      await ExtensibleSettingsService.deleteSettingsModel(
          ExtensibleSettingsService.randomToolsSettingsCode);

      final afterDelete = await ExtensibleSettingsService.getSettingsModel(
          ExtensibleSettingsService.randomToolsSettingsCode);
      expect(afterDelete, isNull);

      // Test that getting the deleted settings recreates defaults
      final recreatedRandom =
          await ExtensibleSettingsService.getRandomToolsSettings();
      expect(recreatedRandom.saveRandomToolsState,
          isTrue); // Should be default again

      print('✅ End-to-end settings lifecycle test completed successfully!');
    });

    test('Settings JSON serialization integrity', () async {
      // Test that complex settings data can be serialized and deserialized correctly
      final complexGlobal = GlobalSettingsData(
        featureStateSavingEnabled: true,
        logRetentionDays: 15,
        focusModeEnabled: false,
      );

      // Save complex settings
      await ExtensibleSettingsService.updateGlobalSettings(complexGlobal);

      // Retrieve and verify
      final retrieved = await ExtensibleSettingsService.getGlobalSettings();
      expect(retrieved.featureStateSavingEnabled,
          equals(complexGlobal.featureStateSavingEnabled));
      expect(
          retrieved.logRetentionDays, equals(complexGlobal.logRetentionDays));
      expect(
          retrieved.focusModeEnabled, equals(complexGlobal.focusModeEnabled));

      // Test that the underlying JSON is correct
      final model = await ExtensibleSettingsService.getSettingsModel(
          ExtensibleSettingsService.globalSettingsCode);
      expect(model, isNotNull);

      final parsedJson = model!.getSettingsAsMap();
      expect(parsedJson['featureStateSavingEnabled'], equals(true));
      expect(parsedJson['logRetentionDays'], equals(15));
      expect(parsedJson['focusModeEnabled'], equals(false));

      print('✅ JSON serialization integrity test completed successfully!');
    });
  });
}
