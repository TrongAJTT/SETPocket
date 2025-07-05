import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/models/converter_models/currency_preset_model.dart';
import 'currency_preset_service_isar.dart';

class CurrencyPresetService {
  // Delegate all calls to Isar implementation

  // Initialize service (for backward compatibility)
  static Future<void> initialize() async {
    // No longer needed with Isar, but keep for compatibility
    logInfo('CurrencyPresetService: Initialization delegated to Isar');
  }

  // Save preset
  static Future<void> savePreset({
    required String name,
    required List<String> currencies,
  }) async {
    return CurrencyPresetServiceIsar.savePreset(
      name: name,
      currencies: currencies,
    );
  }

  // Load all presets
  static Future<List<CurrencyPresetModel>> loadPresets({
    PresetSortOrder sortOrder = PresetSortOrder.date,
  }) async {
    return CurrencyPresetServiceIsar.loadPresets(sortOrder: sortOrder);
  }

  // Get preset by ID
  static Future<CurrencyPresetModel?> getPreset(String id) async {
    return CurrencyPresetServiceIsar.getPreset(id);
  }

  // Delete preset
  static Future<void> deletePreset(String id) async {
    return CurrencyPresetServiceIsar.deletePreset(id);
  }

  // Check if preset name exists
  static Future<bool> presetNameExists(String name) async {
    return CurrencyPresetServiceIsar.presetNameExists(name);
  }

  // Get preset count
  static Future<int> getPresetCount() async {
    return CurrencyPresetServiceIsar.getPresetCount();
  }

  // Clear all presets (for debugging/testing)
  static Future<void> clearAllPresets() async {
    return CurrencyPresetServiceIsar.clearAllPresets();
  }

  // Update preset
  static Future<void> updatePreset(
    String id, {
    String? name,
    List<String>? currencies,
  }) async {
    return CurrencyPresetServiceIsar.updatePreset(
      id,
      name: name,
      currencies: currencies,
    );
  }

  // Export presets (returns JSON-like structure)
  static Future<List<Map<String, dynamic>>> exportPresets() async {
    return CurrencyPresetServiceIsar.exportPresets();
  }
}
