import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/models/converter_models/currency_cache_model.dart';
import 'package:setpocket/models/converter_models/currency_preset_model.dart';
import 'package:setpocket/models/converter_models/currency_state_model.dart';
import 'package:setpocket/models/settings_model.dart';
import 'package:setpocket/models/converter_models/unit_template_model.dart';
import 'package:setpocket/models/converter_models/length_state_model.dart';
import 'package:setpocket/models/converter_models/mass_state_model.dart';
import 'package:setpocket/models/converter_models/length_preset_model.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/models/converter_models/weight_state_model.dart';
import 'package:setpocket/models/converter_models/area_state_model.dart';
import 'package:setpocket/models/converter_models/time_state_model.dart';
import 'package:setpocket/models/converter_models/volume_state_model.dart';
import 'package:setpocket/models/converter_models/number_system_state_model.dart';
import 'package:setpocket/models/converter_models/speed_state_model.dart';
import 'package:setpocket/models/converter_models/temperature_state_model.dart';
import 'package:setpocket/models/converter_models/data_state_model.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/app_installation_service.dart';

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

      // TEMPORARY FIX: Clear the file transfer requests box to resolve a data migration issue.
      // This error (type 'bool' is not a subtype of type 'String?') occurs when the
      // structure of a stored object changes in an incompatible way.
      try {
        await Hive.deleteBoxFromDisk('file_transfer_requests');
        logInfo(
            "HiveService: Cleared 'file_transfer_requests' box to fix migration error.");
      } catch (e) {
        logWarning(
            "HiveService: Could not clear 'file_transfer_requests' box: $e");
      }

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
      if (!Hive.isAdapterRegistered(20)) {
        Hive.registerAdapter(WeightCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(21)) {
        Hive.registerAdapter(WeightStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(AreaCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(AreaStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(TimeCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(TimeStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(26)) {
        Hive.registerAdapter(VolumeCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(27)) {
        Hive.registerAdapter(VolumeStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(28)) {
        Hive.registerAdapter(NumberSystemCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(29)) {
        Hive.registerAdapter(NumberSystemStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(30)) {
        Hive.registerAdapter(SpeedCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(31)) {
        Hive.registerAdapter(SpeedStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(32)) {
        Hive.registerAdapter(TemperatureCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(33)) {
        Hive.registerAdapter(TemperatureStateModelAdapter());
      }
      if (!Hive.isAdapterRegistered(34)) {
        Hive.registerAdapter(DataCardStateAdapter());
      }
      if (!Hive.isAdapterRegistered(35)) {
        Hive.registerAdapter(DataStateModelAdapter());
      }

      // P2P adapters (with correct and consistent TypeIds)
      if (!Hive.isAdapterRegistered(58)) {
        Hive.registerAdapter(P2PDataTransferSettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(50)) {
        Hive.registerAdapter(P2PUserAdapter());
      }
      if (!Hive.isAdapterRegistered(51)) {
        Hive.registerAdapter(PairingRequestAdapter());
      }
      if (!Hive.isAdapterRegistered(49)) {
        Hive.registerAdapter(DataTransferTaskAdapter());
      }
      if (!Hive.isAdapterRegistered(54)) {
        Hive.registerAdapter(FileTransferRequestAdapter());
      }

      // Open boxes
      _templatesBox = await Hive.openBox(templatesBoxName);
      _historyBox = await Hive.openBox(historyBoxName);

      // Initialize AppInstallationService to generate stable app installation ID
      await AppInstallationService.instance.initialize();

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
