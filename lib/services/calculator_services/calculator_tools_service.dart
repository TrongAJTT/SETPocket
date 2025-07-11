import 'package:isar/isar.dart';
import 'package:setpocket/models/calculator_models/calculator_tools_data.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/settings_models_service.dart';

/// Service for managing calculator tools data with efficient storage pattern
class CalculatorToolsService {
  /// Get state data for a specific calculator tool
  static Future<Map<String, dynamic>?> getToolState(String toolCode) async {
    final isar = IsarService.isar;
    final entry = await isar.calculatorToolsDatas
        .filter()
        .toolCodeEqualTo(toolCode)
        .and()
        .dataTypeEqualTo(CalculatorDataTypes.state)
        .findFirst();

    return entry?.getParsedData();
  }

  /// Save state data for a specific calculator tool
  static Future<void> saveToolState(
    String toolCode,
    Map<String, dynamic> stateData, {
    Map<String, dynamic>? metadata,
  }) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      // Try to find existing entry
      var entry = await isar.calculatorToolsDatas
          .filter()
          .toolCodeEqualTo(toolCode)
          .and()
          .dataTypeEqualTo(CalculatorDataTypes.state)
          .findFirst();

      if (entry == null) {
        // Create new entry
        entry = CalculatorToolsData.create(
          toolCode: toolCode,
          dataType: CalculatorDataTypes.state,
          data: stateData,
          meta: metadata,
        );
      } else {
        // Update existing entry
        entry.updateData(stateData);
        if (metadata != null) {
          entry.updateMetadata(metadata);
        }
      }

      await isar.calculatorToolsDatas.put(entry);
    });
  }

  /// Clear state data for a specific calculator tool
  static Future<void> clearToolState(String toolCode) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      await isar.calculatorToolsDatas
          .filter()
          .toolCodeEqualTo(toolCode)
          .and()
          .dataTypeEqualTo(CalculatorDataTypes.state)
          .deleteAll();
    });
  }

  /// Get cache data for a specific calculator tool
  static Future<Map<String, dynamic>?> getToolCache(String toolCode) async {
    final isar = IsarService.isar;
    final entry = await isar.calculatorToolsDatas
        .filter()
        .toolCodeEqualTo(toolCode)
        .and()
        .dataTypeEqualTo(CalculatorDataTypes.cache)
        .findFirst();

    return entry?.getParsedData();
  }

  /// Save cache data for a specific calculator tool
  static Future<void> saveToolCache(
    String toolCode,
    Map<String, dynamic> cacheData, {
    Map<String, dynamic>? metadata,
  }) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      // Try to find existing entry
      var entry = await isar.calculatorToolsDatas
          .filter()
          .toolCodeEqualTo(toolCode)
          .and()
          .dataTypeEqualTo(CalculatorDataTypes.cache)
          .findFirst();

      if (entry == null) {
        // Create new entry
        entry = CalculatorToolsData.create(
          toolCode: toolCode,
          dataType: CalculatorDataTypes.cache,
          data: cacheData,
          meta: metadata,
        );
      } else {
        // Update existing entry
        entry.updateData(cacheData);
        if (metadata != null) {
          entry.updateMetadata(metadata);
        }
      }

      await isar.calculatorToolsDatas.put(entry);
    });
  }

  /// Clear cache data for a specific calculator tool
  static Future<void> clearToolCache(String toolCode) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      await isar.calculatorToolsDatas
          .filter()
          .toolCodeEqualTo(toolCode)
          .and()
          .dataTypeEqualTo(CalculatorDataTypes.cache)
          .deleteAll();
    });
  }

  /// Clear all data for a specific calculator tool
  static Future<void> clearAllToolData(String toolCode) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      await isar.calculatorToolsDatas
          .filter()
          .toolCodeEqualTo(toolCode)
          .deleteAll();
    });
  }

  /// Get all tool codes that have data
  static Future<List<String>> getAllToolCodes() async {
    final isar = IsarService.isar;
    final entries = await isar.calculatorToolsDatas.where().findAll();
    final toolCodes = entries.map((e) => e.toolCode).toSet().toList();
    return toolCodes;
  }

  /// Get data size for a specific tool
  static Future<int> getToolDataSize(String toolCode) async {
    final isar = IsarService.isar;
    final entries = await isar.calculatorToolsDatas
        .filter()
        .toolCodeEqualTo(toolCode)
        .findAll();

    int totalSize = 0;
    for (final entry in entries) {
      totalSize += entry.jsonData.length;
      totalSize += (entry.metadata?.length ?? 0);
    }
    return totalSize;
  }

  /// Get presets data for a specific calculator tool
  static Future<Map<String, dynamic>?> getToolPresets(String toolCode) async {
    final isar = IsarService.isar;
    final entry = await isar.calculatorToolsDatas
        .filter()
        .toolCodeEqualTo(toolCode)
        .and()
        .dataTypeEqualTo(CalculatorDataTypes.presets)
        .findFirst();

    return entry?.getParsedData();
  }

  /// Save presets data for a specific calculator tool
  static Future<void> saveToolPresets(
    String toolCode,
    Map<String, dynamic> presetsData, {
    Map<String, dynamic>? metadata,
  }) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      // Try to find existing entry
      var entry = await isar.calculatorToolsDatas
          .filter()
          .toolCodeEqualTo(toolCode)
          .and()
          .dataTypeEqualTo(CalculatorDataTypes.presets)
          .findFirst();

      if (entry == null) {
        // Create new entry
        entry = CalculatorToolsData.create(
          toolCode: toolCode,
          dataType: CalculatorDataTypes.presets,
          data: presetsData,
          meta: metadata,
        );
      } else {
        // Update existing entry
        entry.updateData(presetsData);
        if (metadata != null) {
          entry.updateMetadata(metadata);
        }
      }

      await isar.calculatorToolsDatas.put(entry);
    });
  }

  /// Get cache information for all calculator tools (for backward compatibility)
  static Future<Map<String, int>> getCacheInfo() async {
    final isar = IsarService.isar;
    final entries = await isar.calculatorToolsDatas.where().findAll();

    int totalSize = 0;
    for (final entry in entries) {
      totalSize += entry.jsonData.length;
      totalSize += (entry.metadata?.length ?? 0);
    }

    return {
      'size': totalSize,
      'items': entries.length,
    };
  }

  /// Clear all calculator tools data (for backward compatibility)
  static Future<void> clearAllData() async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      await isar.calculatorToolsDatas.clear();
    });
  }

  // === Backward compatibility methods for specific calculator tools ===

  /// Get graphing calculator state (backward compatibility)
  static Future<Map<String, dynamic>?> getGraphingCalculatorState() async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return null;

    return await getToolState(CalculatorToolCodes.graphing);
  }

  /// Save graphing calculator state (backward compatibility)
  static Future<void> saveGraphingCalculatorState(
      Map<String, dynamic> state) async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return;

    await saveToolState(CalculatorToolCodes.graphing, state);
  }

  /// Get scientific calculator state (backward compatibility)
  static Future<Map<String, dynamic>?> getScientificCalculatorState() async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return null;

    return await getToolState(CalculatorToolCodes.scientific);
  }

  /// Save scientific calculator state (backward compatibility)
  static Future<void> saveScientificCalculatorState(
      Map<String, dynamic> state) async {
    // Check if feature state saving is enabled
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    if (!settings.saveFeatureState) return;

    await saveToolState(CalculatorToolCodes.scientific, state);
  }
}
