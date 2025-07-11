import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:setpocket/models/settings_model.dart'; // REMOVED: Legacy settings for internal beta 0.5.0
import 'package:setpocket/models/settings_models.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/models/p2p_cache_models.dart';
import 'package:setpocket/models/converter_models/unit_template_model.dart';
import 'package:setpocket/models/converter_models/converter_tools_data.dart';
import 'package:setpocket/models/random_models/unified_random_state.dart';
import 'package:setpocket/models/app_installation.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/models/calculator_models/calculator_tools_data.dart';

/// Isar database service for SetPocket
/// Internal beta v0.5.0 - Clean architecture without legacy migrations
class IsarService {
  static late Isar isar;

  IsarService._();

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final schemas = [
      // SettingsModelSchema, // REMOVED: Legacy schema for internal beta v0.5.0
      ExtensibleSettingsSchema, // New extensible settings architecture
      TextTemplatesDataSchema, // NEW: Unified schema for text templates
      UnifiedHistoryDataSchema,
      UnitTemplateModelSchema,
      P2PUserSchema,
      P2PDataCacheSchema, // NEW: Unified P2P data cache schema
      PairingRequestSchema, // DEPRECATED: Will be migrated to P2PDataCache
      DataTransferTaskSchema, // DEPRECATED: Will be migrated to P2PDataCache
      FileTransferRequestSchema, // DEPRECATED: Will be migrated to P2PDataCache
      // P2PDataTransferSettingsSchema, // REMOVED: Merged into ExtensibleSettings
      // P2PFileStorageSettingsSchema, // REMOVED: Merged into ExtensibleSettings
      ConverterToolsDataSchema, // Unified converter tools data - ALL converter data goes here
      CalculatorToolsDataSchema, // Unified calculator tools data
      UnifiedRandomStateSchema,
      AppInstallationSchema,
    ];

    if (kDebugMode) {
      isar = await Isar.open(
        schemas,
        directory: dir.path,
        inspector: true,
      );
      print('Isar initialized in debug mode with inspector enabled');
      print('Isar directory: ${dir.path}');
    } else {
      isar = await Isar.open(
        schemas,
        directory: dir.path,
      );
    }
  }

  static Future<void> close() async {
    await isar.close();
  }

  static bool get isReady => isar != null;
}
