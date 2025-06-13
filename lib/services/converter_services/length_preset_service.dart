import 'package:hive/hive.dart';
import 'package:setpocket/services/app_logger.dart';
import '../../models/converter_models/length_preset_model.dart';

enum PresetSortOrder { name, date }

class LengthPresetService {
  static const String _boxName = 'length_presets';
  static Box<LengthPresetModel>? _box;

  // Initialize service
  static Future<void> initialize() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<LengthPresetModel>(_boxName);
        logInfo('LengthPresetService: Box opened successfully');
      }
    } catch (e) {
      logError('LengthPresetService: Error opening box: $e');
      rethrow;
    }
  }

  // Save preset
  static Future<void> savePreset({
    required String name,
    required List<String> units,
  }) async {
    await initialize();

    if (name.trim().isEmpty) {
      throw Exception('Preset name cannot be empty');
    }

    if (units.isEmpty || units.length > 10) {
      throw Exception('Preset must contain 1-10 units');
    }

    final preset = LengthPresetModel.create(
      name: name.trim(),
      units: units,
    );

    await _box!.put(preset.id, preset);
    await _box!.flush();

    logInfo(
        'LengthPresetService: Saved preset "${preset.name}" with ${preset.units.length} units');
  }

  // Load all presets
  static Future<List<LengthPresetModel>> loadPresets({
    PresetSortOrder sortOrder = PresetSortOrder.date,
  }) async {
    await initialize();

    final presets = _box!.values.toList();

    // Sort presets
    switch (sortOrder) {
      case PresetSortOrder.name:
        presets.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case PresetSortOrder.date:
        presets
            .sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
        break;
    }

    logInfo(
        'LengthPresetService: Loaded ${presets.length} presets, sorted by $sortOrder');
    return presets;
  }

  // Get preset by ID
  static Future<LengthPresetModel?> getPreset(String id) async {
    await initialize();
    return _box!.get(id);
  }

  // Delete preset
  static Future<void> deletePreset(String id) async {
    await initialize();

    final preset = _box!.get(id);
    if (preset != null) {
      await _box!.delete(id);
      await _box!.flush();
      logInfo('LengthPresetService: Deleted preset "${preset.name}"');
    }
  }

  // Check if preset name exists
  static Future<bool> presetNameExists(String name) async {
    await initialize();

    final normalizedName = name.trim().toLowerCase();
    return _box!.values
        .any((preset) => preset.name.toLowerCase() == normalizedName);
  }

  // Get preset count
  static Future<int> getPresetCount() async {
    await initialize();
    return _box!.length;
  }

  // Clear all presets (for debugging/testing)
  static Future<void> clearAllPresets() async {
    await initialize();
    await _box!.clear();
    await _box!.flush();
    logInfo('LengthPresetService: Cleared all presets');
  }

  // Update preset
  static Future<void> updatePreset(
    String id, {
    String? name,
    List<String>? units,
  }) async {
    await initialize();

    final existingPreset = _box!.get(id);
    if (existingPreset == null) {
      throw Exception('Preset not found');
    }

    final updatedPreset = existingPreset.copyWith(
      name: name,
      units: units,
    );

    await _box!.put(id, updatedPreset);
    await _box!.flush();

    logInfo('LengthPresetService: Updated preset "${updatedPreset.name}"');
  }

  // Export presets (returns JSON-like structure)
  static Future<List<Map<String, dynamic>>> exportPresets() async {
    await initialize();

    return _box!.values
        .map((preset) => {
              'id': preset.id,
              'name': preset.name,
              'units': preset.units,
              'createdAt': preset.createdAt.toIso8601String(),
            })
        .toList();
  }
}
