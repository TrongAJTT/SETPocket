import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  try {
    // Get application documents directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String hivePath = '${appDocDir.path}/hive_data';

    print('Hive path: $hivePath');

    // Initialize Hive
    Hive.init(hivePath);

    // Try to clear time converter boxes
    try {
      final timeStateBox = await Hive.openBox('time_state');
      await timeStateBox.clear();
      await timeStateBox.close();
      print('✅ Cleared time_state box');
    } catch (e) {
      print('⚠️ Could not clear time_state box: $e');
    }

    try {
      final timePresetsBox = await Hive.openBox('time_presets');
      await timePresetsBox.clear();
      await timePresetsBox.close();
      print('✅ Cleared time_presets box');
    } catch (e) {
      print('⚠️ Could not clear time_presets box: $e');
    }

    print('🎉 Time Converter cache cleared successfully!');
    print('Please restart the app to register adapters properly.');
  } catch (e) {
    print('❌ Error clearing cache: $e');
  }
}
