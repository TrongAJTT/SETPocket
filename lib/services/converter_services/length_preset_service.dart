import 'package:setpocket/models/converter_models/length_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';

export 'package:setpocket/services/converter_services/generic_preset_service.dart' show PresetSortOrder;

class LengthPresetService {
  /// Initialize service
  static Future<void> initialize() async {
    logInfo('LengthPresetService: Using GenericPresetService for length presets');
    // Migration is handled by GenericPresetService
  }

  /// Save preset
  static Future<void> savePreset({
    required String name,
    required List<String> units,
  }) async {
    logInfo('LengthPresetService: Saving via GenericPresetService');
    return await GenericPresetService.savePreset(
      presetType: 'length',
      name: name,
      units: units,
    );
  }

  /// Update preset
  static Future<void> updatePreset({
    required String id,
    required String name,
    required List<String> units,
  }) async {
    logInfo('LengthPresetService: Updating via GenericPresetService');
    final preset = await GenericPresetService.getPreset('length', id);
    if (preset != null) {
      final updatedPreset = preset.copyWith(name: name, units: units);
      return await GenericPresetService.updatePreset('length', updatedPreset);
    }
  }

  /// Delete preset
  static Future<bool> deletePreset(String id) async {
    logInfo('LengthPresetService: Deleting via GenericPresetService');
    try {
      await GenericPresetService.deletePreset('length', id);
      return true;
    } catch (e) {
      logError('LengthPresetService: Error deleting preset: $e');
      return false;
    }
  }

  /// Get all presets
  static Future<List<LengthPresetModel>> getAllPresets({
    PresetSortOrder sortOrder = PresetSortOrder.date,
  }) async {
    final genericPresets = await GenericPresetService.getSortedPresets('length', sortOrder);
    return genericPresets.map((preset) => LengthPresetModel(
      presetId: preset.id,
      name: preset.name,
      units: preset.units,
      createdAt: preset.createdAt,
      updatedAt: preset.createdAt, // Use createdAt as fallback
    )).toList();
  }

  /// Get preset by ID
  static Future<LengthPresetModel?> getPresetById(String id) async {
    final genericPreset = await GenericPresetService.getPreset('length', id);
    if (genericPreset != null) {
      return LengthPresetModel(
        presetId: genericPreset.id,
        name: genericPreset.name,
        units: genericPreset.units,
        createdAt: genericPreset.createdAt,
        updatedAt: genericPreset.createdAt, // Use createdAt as fallback
      );
    }
    return null;
  }

  /// Check if preset name already exists
  static Future<bool> presetNameExists(String name, {String? excludeId}) async {
    return await GenericPresetService.presetNameExists('length', name, excludeId: excludeId);
  }

  /// Clear all presets
  static Future<void> clearAllPresets() async {
    logInfo('LengthPresetService: Clearing via GenericPresetService');
    return await GenericPresetService.clearPresets('length');
  }

  /// Get presets data size
  static Future<int> getPresetsDataSize() async {
    final presets = await GenericPresetService.getAllPresets('length');
    return presets.length * 50; // rough estimate
  }
}
