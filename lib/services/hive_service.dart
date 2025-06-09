import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/currency_cache_model.dart';
import '../models/currency_preset_model.dart';
import '../models/currency_state_model.dart';
import '../models/settings_model.dart';
import '../models/unit_template_model.dart';
import '../models/length_state_model.dart';
import '../models/weight_state_model.dart';

class HiveService {
  static final Logger _logger = Logger();

  // Box names
  static const String templatesBoxName = 'templates';
  static const String historyBoxName = 'history';
  static const String currencyCacheBoxName = 'currency_cache';
  static const String settingsBoxName = 'settings';

  // Box instances
  static Box? _templatesBox;
  static Box? _historyBox;

  /// Initialize Hive database
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register type adapters
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(CurrencyCacheModelAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(CurrencyFetchModeAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
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
        Hive.registerAdapter(WeightCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(9)) {
        Hive.registerAdapter(WeightStateModelAdapter());
      }

      // Open boxes
      _templatesBox = await Hive.openBox(templatesBoxName);
      _historyBox = await Hive.openBox(historyBoxName);

      _logger.i('Hive initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Hive: $e');
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
      _logger.i('All Hive boxes closed');
    } catch (e) {
      _logger.e('Error closing Hive boxes: $e');
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
      _logger.i('Cleared box: $boxName');
    } catch (e) {
      _logger.e('Error clearing box $boxName: $e');
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
      _logger.e('Error calculating box size for $boxName: $e');
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
      _logger.e('Error getting item count for $boxName: $e');
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
      _logger.e('Error opening box $boxName: $e');
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
}
