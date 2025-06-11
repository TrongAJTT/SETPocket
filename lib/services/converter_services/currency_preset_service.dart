import 'package:hive/hive.dart';
import 'package:my_multi_tools/services/app_logger.dart';
import '../../models/currency_preset_model.dart';

enum PresetSortOrder { name, date }

class CurrencyPresetService {
  static const String _boxName = 'currency_presets';
  static Box<CurrencyPresetModel>? _box;

  // Initialize service
  static Future<void> initialize() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<CurrencyPresetModel>(_boxName);
        logInfo('CurrencyPresetService: Box opened successfully');
      }
    } catch (e) {
      logError('CurrencyPresetService: Error opening box: $e');
      rethrow;
    }
  }

  // Save preset
  static Future<void> savePreset({
    required String name,
    required List<String> currencies,
  }) async {
    await initialize();

    if (name.trim().isEmpty) {
      throw Exception('Preset name cannot be empty');
    }

    if (currencies.isEmpty || currencies.length > 10) {
      throw Exception('Preset must contain 1-10 currencies');
    }

    final preset = CurrencyPresetModel.create(
      name: name.trim(),
      currencies: currencies,
    );

    await _box!.put(preset.id, preset);
    await _box!.flush();

    logInfo(
        'CurrencyPresetService: Saved preset "${preset.name}" with ${preset.currencies.length} currencies');
  }

  // Load all presets
  static Future<List<CurrencyPresetModel>> loadPresets({
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
        'CurrencyPresetService: Loaded ${presets.length} presets, sorted by $sortOrder');
    return presets;
  }

  // Get preset by ID
  static Future<CurrencyPresetModel?> getPreset(String id) async {
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
      logInfo('CurrencyPresetService: Deleted preset "${preset.name}"');
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
    logInfo('CurrencyPresetService: Cleared all presets');
  }

  // Update preset
  static Future<void> updatePreset(
    String id, {
    String? name,
    List<String>? currencies,
  }) async {
    await initialize();

    final existingPreset = _box!.get(id);
    if (existingPreset == null) {
      throw Exception('Preset not found');
    }

    final updatedPreset = existingPreset.copyWith(
      name: name,
      currencies: currencies,
    );

    await _box!.put(id, updatedPreset);
    await _box!.flush();

    logInfo('CurrencyPresetService: Updated preset "${updatedPreset.name}"');
  }

  // Export presets (returns JSON-like structure)
  static Future<List<Map<String, dynamic>>> exportPresets() async {
    await initialize();

    return _box!.values
        .map((preset) => {
              'id': preset.id,
              'name': preset.name,
              'currencies': preset.currencies,
              'createdAt': preset.createdAt.toIso8601String(),
            })
        .toList();
  }
}
