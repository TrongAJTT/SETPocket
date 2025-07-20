import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:setpocket/models/p2p/p2p_chat.dart';
// import 'package:setpocket/models/settings_model.dart'; // REMOVED: Legacy settings for internal beta 0.5.0
import 'package:setpocket/models/settings_models.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/models/p2p/p2p_models.dart';
import 'package:setpocket/models/p2p/p2p_cache_models.dart';
import 'package:setpocket/models/converter_models/unit_template_model.dart';
import 'package:setpocket/models/converter_models/converter_tools_data.dart';
import 'package:setpocket/models/random_models/unified_random_state.dart';
import 'package:setpocket/models/app_installation.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/models/calculator_models/calculator_tools_data.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/p2p_services/p2p_chat_service.dart';

/// Isar database service for SetPocket
/// Internal beta v0.5.0 - Clean architecture without legacy migrations
class IsarService {
  static late Isar isar;
  static P2PChatService? _chatService;
  static P2PChatService get chatService {
    if (_chatService == null) {
      logError('IsarService.chatService accessed before initialization!');
      throw Exception('IsarService.chatService not initialized');
    }
    return _chatService!;
  }

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
      ConverterToolsDataSchema, // Unified converter tools data - ALL converter data goes here
      CalculatorToolsDataSchema, // Unified calculator tools data
      UnifiedRandomStateSchema,
      AppInstallationSchema,
      P2PChatSchema,
      P2PCMessageSchema,
    ];

    if (kDebugMode) {
      isar = await Isar.open(
        schemas,
        directory: dir.path,
        inspector: true,
      );
      logDebug('Isar initialized in debug mode with inspector enabled');
      logDebug('Isar directory: ${dir.path}');
    } else {
      isar = await Isar.open(
        schemas,
        directory: dir.path,
      );
    }
    _chatService = P2PChatService(isar);
  }

  static Future<void> close() async {
    await isar.close();
  }

  // ignore: unnecessary_null_comparison
  static bool get isReady => isar != null;
}
