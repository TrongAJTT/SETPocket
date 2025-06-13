import 'package:hive/hive.dart';
import 'package:setpocket/services/app_logger.dart';
import '../../models/converter_models/generic_preset_model.dart';
import '../../models/converter_models/currency_preset_model.dart';
import '../../models/converter_models/length_preset_model.dart';

enum PresetSortOrder { name, date }

class GenericPresetService {
  static final Map<String, Box<GenericPresetModel>?> _boxes = {};
  static bool _migrationCompleted = false;

  // Get box name for specific preset type
  static String _getBoxName(String presetType) =>
      'generic_${presetType}_presets';

  // Initialize service for specific preset type
  static Future<void> initialize(String presetType) async {
    try {
      final boxName = _getBoxName(presetType);
      if (_boxes[presetType] == null ||
          !(_boxes[presetType]?.isOpen ?? false)) {
        _boxes[presetType] = await Hive.openBox<GenericPresetModel>(boxName);
        logInfo(
            'GenericPresetService: Box opened successfully for type: $presetType');

        // Perform migration if not completed
        if (!_migrationCompleted) {
          await _migrateOldPresets(presetType);
        }
      }
    } catch (e) {
      logError('GenericPresetService: Error opening box for $presetType: $e');
      rethrow;
    }
  }

  // Migration logic from old preset services
  static Future<void> _migrateOldPresets(String presetType) async {
    try {
      if (presetType == 'currency') {
        await _migrateCurrencyPresets();
      } else if (presetType == 'length') {
        await _migrateLengthPresets();
      }

      _migrationCompleted = true;
      logInfo('GenericPresetService: Migration completed for $presetType');
    } catch (e) {
      logError('GenericPresetService: Migration error for $presetType: $e');
      // Continue operation even if migration fails
    }
  }

  // Migrate currency presets
  static Future<void> _migrateCurrencyPresets() async {
    try {
      if (Hive.isBoxOpen('currency_presets')) {
        final oldBox = Hive.box('currency_presets');
        final newBox = _getBox('currency');

        // Check if already migrated
        if (newBox.isNotEmpty) {
          logInfo('GenericPresetService: Currency presets already migrated');
          return;
        }

        for (var key in oldBox.keys) {
          try {
            final oldPreset = oldBox.get(key);
            if (oldPreset is CurrencyPresetModel) {
              final newPreset = GenericPresetModel(
                id: oldPreset.id,
                name: oldPreset.name,
                units: List<String>.from(oldPreset.currencies),
                createdAt: oldPreset.createdAt,
                presetType: 'currency',
              );

              await newBox.put(newPreset.id, newPreset);
              logInfo(
                  'GenericPresetService: Migrated currency preset: ${newPreset.name}');
            }
          } catch (e) {
            logError(
                'GenericPresetService: Error migrating currency preset $key: $e');
          }
        }

        logInfo('GenericPresetService: Currency migration completed');
      }
    } catch (e) {
      logError('GenericPresetService: Currency migration error: $e');
    }
  }

  // Migrate length presets
  static Future<void> _migrateLengthPresets() async {
    try {
      if (Hive.isBoxOpen('length_presets')) {
        final oldBox = Hive.box('length_presets');
        final newBox = _getBox('length');

        // Check if already migrated
        if (newBox.isNotEmpty) {
          logInfo('GenericPresetService: Length presets already migrated');
          return;
        }

        for (var key in oldBox.keys) {
          try {
            final oldPreset = oldBox.get(key);
            if (oldPreset is LengthPresetModel) {
              final newPreset = GenericPresetModel(
                id: oldPreset.id,
                name: oldPreset.name,
                units: List<String>.from(oldPreset.units),
                createdAt: oldPreset.createdAt,
                presetType: 'length',
              );

              await newBox.put(newPreset.id, newPreset);
              logInfo(
                  'GenericPresetService: Migrated length preset: ${newPreset.name}');
            }
          } catch (e) {
            logError(
                'GenericPresetService: Error migrating length preset $key: $e');
          }
        }

        logInfo('GenericPresetService: Length migration completed');
      }
    } catch (e) {
      logError('GenericPresetService: Length migration error: $e');
    }
  }

  // Get box for specific preset type
  static Box<GenericPresetModel> _getBox(String presetType) {
    final box = _boxes[presetType];
    if (box == null || !box.isOpen) {
      throw Exception('Box not initialized for preset type: $presetType');
    }
    return box;
  }

  // Save preset
  static Future<void> savePreset({
    required String presetType,
    required String name,
    required List<String> units,
  }) async {
    await initialize(presetType);

    if (name.trim().isEmpty) {
      throw Exception('Preset name cannot be empty');
    }

    if (units.isEmpty || units.length > 10) {
      throw Exception('Preset must contain 1-10 units');
    }

    final preset = GenericPresetModel.create(
      name: name.trim(),
      units: units,
      presetType: presetType,
    );

    final box = _getBox(presetType);
    await box.put(preset.id, preset);
    await box.flush();

    logInfo(
        'GenericPresetService: Saved $presetType preset "${preset.name}" with ${preset.units.length} units');
  }

  // Load all presets for specific type
  static Future<List<GenericPresetModel>> loadPresets(
    String presetType, {
    PresetSortOrder sortOrder = PresetSortOrder.date,
  }) async {
    await initialize(presetType);

    final box = _getBox(presetType);
    final presets =
        box.values.where((preset) => preset.presetType == presetType).toList();

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
        'GenericPresetService: Loaded ${presets.length} $presetType presets, sorted by $sortOrder');
    return presets;
  }

  // Get preset by ID
  static Future<GenericPresetModel?> getPreset(
      String presetType, String id) async {
    await initialize(presetType);
    final box = _getBox(presetType);
    return box.get(id);
  }

  // Delete preset
  static Future<void> deletePreset(String presetType, String id) async {
    await initialize(presetType);

    final box = _getBox(presetType);
    final preset = box.get(id);
    if (preset != null) {
      await box.delete(id);
      await box.flush();
      logInfo(
          'GenericPresetService: Deleted $presetType preset "${preset.name}"');
    }
  }

  // Check if preset name exists
  static Future<bool> presetNameExists(String presetType, String name) async {
    await initialize(presetType);

    final box = _getBox(presetType);
    final normalizedName = name.trim().toLowerCase();
    return box.values
        .where((preset) => preset.presetType == presetType)
        .any((preset) => preset.name.toLowerCase() == normalizedName);
  }

  // Get preset count
  static Future<int> getPresetCount(String presetType) async {
    await initialize(presetType);
    final box = _getBox(presetType);
    return box.values.where((preset) => preset.presetType == presetType).length;
  }

  // Clear all presets for specific type
  static Future<void> clearAllPresets(String presetType) async {
    await initialize(presetType);
    final box = _getBox(presetType);

    // Delete only presets of the specific type
    final keysToDelete = <dynamic>[];
    for (final entry in box.toMap().entries) {
      if (entry.value.presetType == presetType) {
        keysToDelete.add(entry.key);
      }
    }

    await box.deleteAll(keysToDelete);
    await box.flush();
    logInfo('GenericPresetService: Cleared all $presetType presets');
  }

  // Update preset (includes rename functionality)
  static Future<void> updatePreset(
    String presetType,
    String id, {
    String? name,
    List<String>? units,
  }) async {
    await initialize(presetType);

    final box = _getBox(presetType);
    final existingPreset = box.get(id);
    if (existingPreset == null) {
      throw Exception('Preset not found');
    }

    final updatedPreset = existingPreset.copyWith(
      name: name,
      units: units,
    );

    await box.put(id, updatedPreset);
    await box.flush();

    logInfo(
        'GenericPresetService: Updated $presetType preset "${updatedPreset.name}"');
  }

  // Rename preset (dedicated method for clarity)
  static Future<void> renamePreset(
    String presetType,
    String id,
    String newName,
  ) async {
    if (newName.trim().isEmpty) {
      throw Exception('Preset name cannot be empty');
    }

    // Check if new name already exists
    if (await presetNameExists(presetType, newName)) {
      throw Exception('Preset name already exists');
    }

    await updatePreset(presetType, id, name: newName.trim());
    logInfo('GenericPresetService: Renamed $presetType preset to "$newName"');
  }

  // Export presets for specific type
  static Future<List<Map<String, dynamic>>> exportPresets(
      String presetType) async {
    await initialize(presetType);

    final box = _getBox(presetType);
    return box.values
        .where((preset) => preset.presetType == presetType)
        .map((preset) => {
              'id': preset.id,
              'name': preset.name,
              'units': preset.units,
              'presetType': preset.presetType,
              'createdAt': preset.createdAt.toIso8601String(),
            })
        .toList();
  }

  // Force migration (for debugging)
  static Future<void> forceMigration() async {
    _migrationCompleted = false;
    await _migrateCurrencyPresets();
    await _migrateLengthPresets();
    logInfo('GenericPresetService: Force migration completed');
  }
}
