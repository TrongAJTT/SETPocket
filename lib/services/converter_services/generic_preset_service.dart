// import 'package:hive/hive.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/converter_services/generic_preset_service_isar.dart';

export 'package:setpocket/services/converter_services/generic_preset_service_isar.dart' show PresetSortOrder;

class GenericPresetService {
  // Initialize service for specific preset type - no longer needed for Isar
  static Future<void> initialize(String presetType) async {
    logInfo('GenericPresetService: Initialize called for $presetType - using Isar backend');
  }

  // Get all presets for a specific type
  static Future<List<GenericPresetModel>> getAllPresets(String presetType) async {
    try {
      return await GenericPresetServiceIsar.getAllPresets(presetType);
    } catch (e) {
      logError('GenericPresetService: Error getting all presets for $presetType: $e');
      return [];
    }
  }

  // Save a preset with model
  static Future<void> savePresetModel(GenericPresetModel preset) async {
    try {
      await GenericPresetServiceIsar.savePreset(preset);
      logInfo('GenericPresetService: Preset saved successfully via Isar');
    } catch (e) {
      logError('GenericPresetService: Error saving preset: $e');
      rethrow;
    }
  }

  // Save a preset with named parameters (for controller compatibility)
  static Future<void> savePreset({
    required String presetType,
    required String name,
    required List<String> units,
  }) async {
    try {
      final preset = GenericPresetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        presetType: presetType,
        name: name,
        units: units,
        createdAt: DateTime.now(),
      );
      await savePresetModel(preset);
    } catch (e) {
      logError('GenericPresetService: Error saving preset: $e');
      rethrow;
    }
  }



  // Delete a preset
  static Future<void> deletePreset(String presetType, String presetId) async {
    try {
      await GenericPresetServiceIsar.deletePreset(presetId);
      logInfo('GenericPresetService: Preset deleted successfully via Isar');
    } catch (e) {
      logError('GenericPresetService: Error deleting preset: $e');
      rethrow;
    }
  }

  // Get a specific preset by ID
  static Future<GenericPresetModel?> getPreset(String presetType, String presetId) async {
    try {
      return await GenericPresetServiceIsar.getPreset(presetId);
    } catch (e) {
      logError('GenericPresetService: Error getting preset: $e');
      return null;
    }
  }

  // Update a preset
  static Future<void> updatePreset(String presetType, GenericPresetModel preset) async {
    try {
      await GenericPresetServiceIsar.updatePreset(preset);
      logInfo('GenericPresetService: Preset updated successfully via Isar');
    } catch (e) {
      logError('GenericPresetService: Error updating preset: $e');
      rethrow;
    }
  }

  // Get presets count for a specific type
  static Future<int> getPresetsCount(String presetType) async {
    try {
      return await GenericPresetServiceIsar.getPresetsCount(presetType);
    } catch (e) {
      logError('GenericPresetService: Error getting presets count: $e');
      return 0;
    }
  }

  // Clear all presets for a specific type
  static Future<void> clearPresets(String presetType) async {
    try {
      await GenericPresetServiceIsar.clearPresets(presetType);
      logInfo('GenericPresetService: Presets cleared successfully via Isar');
    } catch (e) {
      logError('GenericPresetService: Error clearing presets: $e');
      rethrow;
    }
  }

  // Clear all presets for all types - for compatibility
  static Future<void> clearAllPresets() async {
    try {
      // Clear common preset types
      final presetTypes = ['currency', 'length', 'weight', 'volume', 'area', 'mass', 'time', 'temperature', 'speed'];
      for (String presetType in presetTypes) {
        await clearPresets(presetType);
      }
      logInfo('GenericPresetService: All presets cleared successfully via Isar');
    } catch (e) {
      logError('GenericPresetService: Error clearing all presets: $e');
      rethrow;
    }
  }

  // Get sorted presets
  static Future<List<GenericPresetModel>> getSortedPresets(
      String presetType, PresetSortOrder sortOrder) async {
    try {
      return await GenericPresetServiceIsar.getSortedPresets(presetType, sortOrder);
    } catch (e) {
      logError('GenericPresetService: Error getting sorted presets: $e');
      return [];
    }
  }

  // Check if a preset name already exists for a type
  static Future<bool> presetNameExists(String presetType, String name, {String? excludeId}) async {
    try {
      return await GenericPresetServiceIsar.presetNameExists(presetType, name, excludeId: excludeId);
    } catch (e) {
      logError('GenericPresetService: Error checking preset name existence: $e');
      return false;
    }
  }

  // Close service - no longer needed for Isar
  static Future<void> close(String presetType) async {
    logInfo('GenericPresetService: Close called for $presetType - using Isar backend');
  }

  // Close all services - no longer needed for Isar
  static Future<void> closeAll() async {
    logInfo('GenericPresetService: CloseAll called - using Isar backend');
  }

  // Load presets for a specific type (alias for getAllPresets)
  static Future<List<GenericPresetModel>> loadPresets(String presetType) async {
    return await getAllPresets(presetType);
  }

  // Rename a preset
  static Future<void> renamePreset(String presetType, String presetId, String newName) async {
    try {
      final preset = await getPreset(presetType, presetId);
      if (preset != null) {
        final updatedPreset = preset.copyWith(name: newName);
        await updatePreset(presetType, updatedPreset);
        logInfo('GenericPresetService: Preset renamed successfully via Isar');
      } else {
        throw Exception('Preset not found');
      }
    } catch (e) {
      logError('GenericPresetService: Error renaming preset: $e');
      rethrow;
    }
  }
}
