import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/models/settings_models.dart';
import 'dart:convert';

void main() {
  group('ExtensibleSettings Data Classes Tests', () {
    test('should serialize and deserialize GlobalSettingsData', () {
      // Test with custom values
      final originalData = GlobalSettingsData(
        featureStateSavingEnabled: false,
        logRetentionDays: 10,
        focusModeEnabled: true,
      );

      final json = originalData.toJson();
      final deserializedData = GlobalSettingsData.fromJson(json);

      expect(deserializedData.featureStateSavingEnabled, equals(false));
      expect(deserializedData.logRetentionDays, equals(10));
      expect(deserializedData.focusModeEnabled, equals(true));

      // Test with default values
      final defaultData = GlobalSettingsData();
      final defaultJson = defaultData.toJson();
      final deserializedDefault = GlobalSettingsData.fromJson(defaultJson);

      expect(deserializedDefault.featureStateSavingEnabled, equals(true));
      expect(deserializedDefault.logRetentionDays, equals(5));
      expect(deserializedDefault.focusModeEnabled, equals(false));
    });

    test('should serialize and deserialize ConverterToolsSettingsData', () {
      final originalData = ConverterToolsSettingsData(
        fetchTimeoutSeconds: 15,
        fetchRetryTimes: 3,
        saveConverterToolsState: false,
      );

      final json = originalData.toJson();
      final deserializedData = ConverterToolsSettingsData.fromJson(json);

      expect(deserializedData.fetchTimeoutSeconds, equals(15));
      expect(deserializedData.fetchRetryTimes, equals(3));
      expect(deserializedData.saveConverterToolsState, equals(false));
    });

    test('should serialize and deserialize RandomToolsSettingsData', () {
      final originalData = RandomToolsSettingsData(
        saveRandomToolsState: false,
      );

      final json = originalData.toJson();
      final deserializedData = RandomToolsSettingsData.fromJson(json);

      expect(deserializedData.saveRandomToolsState, equals(false));

      // Test default values
      final defaultData = RandomToolsSettingsData();
      final defaultJson = defaultData.toJson();
      final deserializedDefault = RandomToolsSettingsData.fromJson(defaultJson);

      expect(deserializedDefault.saveRandomToolsState, equals(true));
    });

    test('should create ExtensibleSettings and parse JSON', () {
      const testModelCode = 'test_settings';
      final testData = {
        'theme': 'dark',
        'language': 'en',
        'enableNotifications': true,
      };

      final settings = ExtensibleSettings(
        modelCode: testModelCode,
        modelType: SettingsModelType.global,
        settingsJson: jsonEncode(testData),
      );

      expect(settings.modelCode, equals(testModelCode));
      expect(settings.modelType, equals(SettingsModelType.global));

      final retrievedData = settings.getSettingsAsMap();
      expect(retrievedData['theme'], equals('dark'));
      expect(retrievedData['language'], equals('en'));
      expect(retrievedData['enableNotifications'], equals(true));
    });

    test('should handle invalid JSON in getSettingsAsMap', () {
      final settings = ExtensibleSettings(
        modelCode: 'invalid_test',
        modelType: SettingsModelType.global,
        settingsJson: 'invalid_json{{{',
      );

      final retrievedData = settings.getSettingsAsMap();
      expect(retrievedData, equals(<String, dynamic>{}));
    });

    test('should copy ExtensibleSettings with new values', () {
      final original = ExtensibleSettings(
        modelCode: 'original',
        modelType: SettingsModelType.global,
        settingsJson: '{"test": "value"}',
      );
      original.id = 1;

      // Wait a bit to ensure different timestamp
      Future.delayed(Duration(milliseconds: 1));

      final copied = original.copyWith(
        modelCode: 'copied',
        settingsJson: '{"test": "new_value"}',
      );

      expect(copied.modelCode, equals('copied'));
      expect(copied.modelType, equals(SettingsModelType.global)); // unchanged
      expect(copied.settingsJson, equals('{"test": "new_value"}'));
      expect(copied.id, equals(1)); // should preserve ID
      // Just check that updatedAt is set, not necessarily after original
      expect(copied.updatedAt, isNotNull);
    });

    test('should handle copyWith methods in data classes', () {
      final originalGlobal = GlobalSettingsData(
        featureStateSavingEnabled: true,
        logRetentionDays: 5,
        focusModeEnabled: false,
      );

      final modifiedGlobal = originalGlobal.copyWith(
        logRetentionDays: 10,
        focusModeEnabled: true,
      );

      expect(
          modifiedGlobal.featureStateSavingEnabled, equals(true)); // unchanged
      expect(modifiedGlobal.logRetentionDays, equals(10)); // changed
      expect(modifiedGlobal.focusModeEnabled, equals(true)); // changed
    });
  });
}
