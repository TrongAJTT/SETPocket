import 'package:isar/isar.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/models/converter_models/currency_preset_model.dart';
import 'package:setpocket/services/isar_service.dart';

enum PresetSortOrder { name, date }

class CurrencyPresetServiceIsar {
  // Save preset
  static Future<void> savePreset({
    required String name,
    required List<String> currencies,
  }) async {
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

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.currencyPresetModels.put(preset);
    });

    logInfo(
        'CurrencyPresetServiceIsar: Saved preset "${preset.name}" with ${preset.currencies.length} currencies');
  }

  // Load all presets
  static Future<List<CurrencyPresetModel>> loadPresets({
    PresetSortOrder sortOrder = PresetSortOrder.date,
  }) async {
    final List<CurrencyPresetModel> presets;

    switch (sortOrder) {
      case PresetSortOrder.name:
        presets = await IsarService.isar.currencyPresetModels
            .where()
            .sortByName()
            .findAll();
        break;
      case PresetSortOrder.date:
        presets = await IsarService.isar.currencyPresetModels
            .where()
            .sortByCreatedAtDesc()
            .findAll();
        break;
    }

    logInfo(
        'CurrencyPresetServiceIsar: Loaded ${presets.length} presets, sorted by $sortOrder');
    return presets;
  }

  // Get preset by ID
  static Future<CurrencyPresetModel?> getPreset(String id) async {
    return await IsarService.isar.currencyPresetModels
        .filter()
        .idEqualTo(id)
        .findFirst();
  }

  // Delete preset
  static Future<void> deletePreset(String id) async {
    final preset = await getPreset(id);
    if (preset != null) {
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.currencyPresetModels.delete(preset.isarId);
      });
      logInfo('CurrencyPresetServiceIsar: Deleted preset "${preset.name}"');
    }
  }

  // Check if preset name exists
  static Future<bool> presetNameExists(String name) async {
    final normalizedName = name.trim().toLowerCase();
    final count = await IsarService.isar.currencyPresetModels
        .filter()
        .nameEqualTo(normalizedName, caseSensitive: false)
        .count();
    return count > 0;
  }

  // Get preset count
  static Future<int> getPresetCount() async {
    return await IsarService.isar.currencyPresetModels.count();
  }

  // Clear all presets (for debugging/testing)
  static Future<void> clearAllPresets() async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.currencyPresetModels.clear();
    });
    logInfo('CurrencyPresetServiceIsar: Cleared all presets');
  }

  // Update preset
  static Future<void> updatePreset(
    String id, {
    String? name,
    List<String>? currencies,
  }) async {
    final existingPreset = await getPreset(id);
    if (existingPreset == null) {
      throw Exception('Preset not found');
    }

    final updatedPreset = existingPreset.copyWith(
      name: name,
      currencies: currencies,
    );

    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.currencyPresetModels.put(updatedPreset);
    });

    logInfo(
        'CurrencyPresetServiceIsar: Updated preset "${updatedPreset.name}"');
  }

  // Export presets (returns JSON-like structure)
  static Future<List<Map<String, dynamic>>> exportPresets() async {
    final presets =
        await IsarService.isar.currencyPresetModels.where().findAll();

    return presets
        .map((preset) => {
              'id': preset.id,
              'name': preset.name,
              'currencies': preset.currencies,
              'createdAt': preset.createdAt.toIso8601String(),
            })
        .toList();
  }
}
