import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/services/settings_models_service.dart';
import 'package:setpocket/services/isar_service.dart';

/// Script to update settings schema and ensure all fields are present using new ExtensibleSettings
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExtensibleSettings Schema Update', () {
    test('Update extensible settings with all fields', () async {
      // Initialize Isar
      await IsarService.init();

      // Initialize ExtensibleSettingsService (will migrate if needed)
      await ExtensibleSettingsService.initialize();

      // Get current settings
      final globalSettings =
          await ExtensibleSettingsService.getGlobalSettings();
      final converterSettings =
          await ExtensibleSettingsService.getConverterToolsSettings();
      final randomSettings =
          await ExtensibleSettingsService.getRandomToolsSettings();

      print('Current settings:');
      print(
          'Global - featureStateSavingEnabled: ${globalSettings.featureStateSavingEnabled}');
      print('Global - logRetentionDays: ${globalSettings.logRetentionDays}');
      print(
          'Converter - saveConverterToolsState: ${converterSettings.saveConverterToolsState}');
      print(
          'Random - saveRandomToolsState: ${randomSettings.saveRandomToolsState}');

      // Force update fields to ensure they exist in database
      await ExtensibleSettingsService.updateRandomToolsSettings(
        randomSettings.copyWith(saveRandomToolsState: true),
      );
      await ExtensibleSettingsService.updateConverterToolsSettings(
        converterSettings.copyWith(saveConverterToolsState: true),
      );

      // Verify the update
      final verifyRandomSettings =
          await ExtensibleSettingsService.getRandomToolsSettings();
      final verifyConverterSettings =
          await ExtensibleSettingsService.getConverterToolsSettings();

      print('\nAfter update:');
      print(
          'Random - saveRandomToolsState: ${verifyRandomSettings.saveRandomToolsState}');
      print(
          'Converter - saveConverterToolsState: ${verifyConverterSettings.saveConverterToolsState}');

      expect(verifyRandomSettings.saveRandomToolsState, isTrue);
      expect(verifyConverterSettings.saveConverterToolsState, isTrue);

      print('\n✅ ExtensibleSettings schema updated successfully!');
    });
  });
}
