import 'package:isar/isar.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/isar_service.dart';

enum PresetSortOrder { name, date }

class GenericPresetServiceIsar {
  // Get all presets for a specific type
  static Future<List<GenericPresetModel>> getAllPresets(String presetType) async {
    try {
      final isar = IsarService.isar;
      
      final presets = await isar.genericPresetModels
          .filter()
          .presetTypeEqualTo(presetType)
          .findAll();
      
      logInfo('GenericPresetServiceIsar: Retrieved ${presets.length} presets for type: $presetType');
      return presets;
    } catch (e) {
      logError('GenericPresetServiceIsar: Error getting all presets for type $presetType: $e');
      return [];
    }
  }

  // Save a preset
  static Future<void> savePreset(GenericPresetModel preset) async {
    try {
      final isar = IsarService.isar;
      
      await isar.writeTxn(() async {
        await isar.genericPresetModels.put(preset);
      });
      
      logInfo('GenericPresetServiceIsar: Preset saved successfully: ${preset.name} (${preset.presetType})');
    } catch (e) {
      logError('GenericPresetServiceIsar: Error saving preset: $e');
      rethrow;
    }
  }

  // Delete a preset
  static Future<void> deletePreset(String presetId) async {
    try {
      final isar = IsarService.isar;
      
      await isar.writeTxn(() async {
        final success = await isar.genericPresetModels
            .filter()
            .idEqualTo(presetId)
            .deleteAll();
        
        if (success == 0) {
          logWarning('GenericPresetServiceIsar: No preset found with id: $presetId');
        }
      });
      
      logInfo('GenericPresetServiceIsar: Preset deleted successfully: $presetId');
    } catch (e) {
      logError('GenericPresetServiceIsar: Error deleting preset: $e');
      rethrow;
    }
  }

  // Get a specific preset by ID
  static Future<GenericPresetModel?> getPreset(String presetId) async {
    try {
      final isar = IsarService.isar;
      
      final preset = await isar.genericPresetModels
          .filter()
          .idEqualTo(presetId)
          .findFirst();
      
      if (preset != null) {
        logInfo('GenericPresetServiceIsar: Retrieved preset: ${preset.name}');
      }
      
      return preset;
    } catch (e) {
      logError('GenericPresetServiceIsar: Error getting preset $presetId: $e');
      return null;
    }
  }

  // Update a preset
  static Future<void> updatePreset(GenericPresetModel preset) async {
    try {
      final isar = IsarService.isar;
      
      await isar.writeTxn(() async {
        await isar.genericPresetModels.put(preset);
      });
      
      logInfo('GenericPresetServiceIsar: Preset updated successfully: ${preset.name}');
    } catch (e) {
      logError('GenericPresetServiceIsar: Error updating preset: $e');
      rethrow;
    }
  }

  // Get presets count for a specific type
  static Future<int> getPresetsCount(String presetType) async {
    try {
      final isar = IsarService.isar;
      
      final count = await isar.genericPresetModels
          .filter()
          .presetTypeEqualTo(presetType)
          .count();
      
      return count;
    } catch (e) {
      logError('GenericPresetServiceIsar: Error getting presets count for type $presetType: $e');
      return 0;
    }
  }

  // Clear all presets for a specific type
  static Future<void> clearPresets(String presetType) async {
    try {
      final isar = IsarService.isar;
      
      await isar.writeTxn(() async {
        await isar.genericPresetModels
            .filter()
            .presetTypeEqualTo(presetType)
            .deleteAll();
      });
      
      logInfo('GenericPresetServiceIsar: All presets cleared for type: $presetType');
    } catch (e) {
      logError('GenericPresetServiceIsar: Error clearing presets for type $presetType: $e');
      rethrow;
    }
  }

  // Get sorted presets
  static Future<List<GenericPresetModel>> getSortedPresets(
      String presetType, PresetSortOrder sortOrder) async {
    try {
      final presets = await getAllPresets(presetType);
      
      switch (sortOrder) {
        case PresetSortOrder.name:
          presets.sort((a, b) => a.name.compareTo(b.name));
          break;
        case PresetSortOrder.date:
          presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
      
      return presets;
    } catch (e) {
      logError('GenericPresetServiceIsar: Error getting sorted presets: $e');
      return [];
    }
  }

  // Check if a preset name already exists for a type
  static Future<bool> presetNameExists(String presetType, String name, {String? excludeId}) async {
    try {
      final isar = IsarService.isar;
      
      var query = isar.genericPresetModels
          .filter()
          .presetTypeEqualTo(presetType)
          .nameEqualTo(name);
      
      if (excludeId != null) {
        query = query.not().idEqualTo(excludeId);
      }
      
      final existingPreset = await query.findFirst();
      return existingPreset != null;
    } catch (e) {
      logError('GenericPresetServiceIsar: Error checking preset name existence: $e');
      return false;
    }
  }
}
