import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:setpocket/services/app_logger.dart';
import '../models/converter_models/currency_cache_model.dart';
import '../models/converter_models/currency_preset_model.dart';
import '../models/converter_models/currency_state_model.dart';
import '../models/settings_model.dart';
import '../models/converter_models/unit_template_model.dart';
import '../models/converter_models/length_state_model.dart';
import '../models/converter_models/mass_state_model.dart';
import '../models/converter_models/length_preset_model.dart';
import '../models/converter_models/generic_preset_model.dart';

class HiveService {
  // Box names
  static const String templatesBoxName = 'templates';
  static const String historyBoxName = 'history';
  static const String currencyCacheBoxName = 'currency_cache';
  static const String settingsBoxName = 'settings';

  // Box instances
  static Box? _templatesBox;
  static Box? _historyBox;

  /// Initialize Hive database with custom path
  static Future<void> initialize() async {
    try {
      // Get application documents directory for storing Hive data
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String hivePath = '${appDocDir.path}/hive_data';

      // Create directory if it doesn't exist
      final Directory hiveDir = Directory(hivePath);
      if (!await hiveDir.exists()) {
        await hiveDir.create(recursive: true);
        logInfo('HiveService: Created Hive data directory at $hivePath');
      }

      // Initialize Hive with custom path
      Hive.init(hivePath);
      logInfo('HiveService: Initialized Hive with path: $hivePath');

      // Register type adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CurrencyCacheModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CurrencyFetchModeAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(SettingsModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(CurrencyPresetModelAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(CurrencyStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(CurrencyCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(15)) {
        Hive.registerAdapter(UnitTemplateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(16)) {
        Hive.registerAdapter(TemplateSortOrderAdapter());
      }
      if (!Hive.isAdapterRegistered(17)) {
        Hive.registerAdapter(LengthCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(18)) {
        Hive.registerAdapter(LengthStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(MassCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(9)) {
        Hive.registerAdapter(MassStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(LengthPresetModelAdapter());
      }
      if (!Hive.isAdapterRegistered(19)) {
        Hive.registerAdapter(GenericPresetModelAdapter());
      }

      // Open boxes
      _templatesBox = await Hive.openBox(templatesBoxName);
      _historyBox = await Hive.openBox(historyBoxName);

      logInfo('HiveService: Initialized successfully with custom path');
    } catch (e) {
      logFatal('HiveService: Failed to initialize: $e');
      rethrow;
    }
  }

  /// Get templates box
  static Box get templatesBox {
    if (_templatesBox == null || !_templatesBox!.isOpen) {
      throw Exception(
          'Templates box is not initialized. Call HiveService.initialize() first.');
    }
    return _templatesBox!;
  }

  /// Get history box
  static Box get historyBox {
    if (_historyBox == null || !_historyBox!.isOpen) {
      throw Exception(
          'History box is not initialized. Call HiveService.initialize() first.');
    }
    return _historyBox!;
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    try {
      await _templatesBox?.close();
      await _historyBox?.close();
      logInfo('All Hive boxes closed');
    } catch (e) {
      logError('Error closing Hive boxes: $e');
    }
  }

  /// Clear all data from a specific box
  static Future<void> clearBox(String boxName) async {
    try {
      Box box;
      switch (boxName) {
        case templatesBoxName:
          box = templatesBox;
          break;
        case historyBoxName:
          box = historyBox;
          break;
        default:
          throw Exception('Unknown box name: $boxName');
      }

      await box.clear();
      logInfo('Cleared box: $boxName');
    } catch (e) {
      logError('Error clearing box $boxName: $e');
      rethrow;
    }
  }

  /// Get the size of a box in bytes (estimated)
  static int getBoxSize(String boxName) {
    try {
      Box box;
      switch (boxName) {
        case templatesBoxName:
          box = templatesBox;
          break;
        case historyBoxName:
          box = historyBox;
          break;
        default:
          return 0;
      }

      int totalSize = 0;
      for (var key in box.keys) {
        final value = box.get(key);
        if (value is String) {
          totalSize += value.length * 2; // UTF-16 encoding estimate
        } else if (value is Map || value is List) {
          // Rough estimate for complex objects
          totalSize += value.toString().length * 2;
        }
      }

      return totalSize;
    } catch (e) {
      logError('Error calculating box size for $boxName: $e');
      return 0;
    }
  }

  /// Get the number of items in a box
  static int getBoxItemCount(String boxName) {
    try {
      Box box;
      switch (boxName) {
        case templatesBoxName:
          box = templatesBox;
          break;
        case historyBoxName:
          box = historyBox;
          break;
        default:
          return 0;
      }

      return box.length;
    } catch (e) {
      logError('Error getting item count for $boxName: $e');
      return 0;
    }
  }

  /// Get a generic box for typed models
  static Future<Box<T>> getBox<T>(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        return await Hive.openBox<T>(boxName);
      }
      return Hive.box<T>(boxName);
    } catch (e) {
      logError('Error opening box $boxName: $e');
      rethrow;
    }
  }

  /// Check if Hive is initialized
  static bool get isInitialized {
    return _templatesBox != null &&
        _historyBox != null &&
        _templatesBox!.isOpen &&
        _historyBox!.isOpen;
  }

  /// Get current Hive storage path
  static Future<String> getHivePath() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      return '${appDocDir.path}/hive_data';
    } catch (e) {
      logError('HiveService: Error getting Hive path: $e');
      return 'Unknown';
    }
  }

  /// Get storage info for debugging
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final hivePath = await getHivePath();
      final hiveDir = Directory(hivePath);

      Map<String, dynamic> info = {
        'path': hivePath,
        'exists': await hiveDir.exists(),
        'files': <String>[],
        'totalSize': 0,
      };

      if (await hiveDir.exists()) {
        final files = await hiveDir.list().toList();
        info['files'] = files.map((f) => f.path.split('/').last).toList();

        int totalSize = 0;
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
        info['totalSize'] = totalSize;
      }

      return info;
    } catch (e) {
      logError('HiveService: Error getting storage info: $e');
      return {'error': e.toString()};
    }
  }
}
