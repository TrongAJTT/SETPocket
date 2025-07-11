import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

import 'converter_tools_data_service.dart';

/// Service for managing length converter state, cache, and presets using unified data structure
class LengthUnifiedService {
  static const String _toolCode = 'length';
  static const _uuid = Uuid();

  // ===== STATE MANAGEMENT =====

  /// Load length converter states
  static Future<List<Map<String, dynamic>>> loadState() async {
    try {
      final stateData = await ConverterToolsDataService.getStates(_toolCode);
      if (stateData == null) return [];

      // Handle both list and map formats for backward compatibility
      if (stateData['states'] is List) {
        return List<Map<String, dynamic>>.from(stateData['states']);
      }

      return [stateData]; // Single state object
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to load state: $e');
      return [];
    }
  }

  /// Save length converter states
  static Future<void> saveState(List<Map<String, dynamic>> states) async {
    try {
      await ConverterToolsDataService.saveStates(_toolCode, {'states': states});
      developer.log('LengthUnifiedService: Saved ${states.length} states');
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to save state: $e');
      rethrow;
    }
  }

  /// Clear length converter states
  static Future<void> clearState() async {
    try {
      await ConverterToolsDataService.clearStates(_toolCode);
      developer.log('LengthUnifiedService: Cleared states');
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to clear state: $e');
      rethrow;
    }
  }

  // ===== PRESET MANAGEMENT =====

  /// Load all presets
  static Future<List<Map<String, dynamic>>> loadPresets() async {
    try {
      return await ConverterToolsDataService.getPresets(_toolCode);
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to load presets: $e');
      return [];
    }
  }

  /// Save a new preset
  static Future<String> savePreset({
    required String name,
    required List<String> units,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final id = _uuid.v4();
      final preset = {
        'id': id,
        'name': name.trim(),
        'units': units,
        'createdAt': DateTime.now().toIso8601String(),
        'lastModified': DateTime.now().toIso8601String(),
        'toolType': 'length',
        ...?metadata,
      };

      await ConverterToolsDataService.savePreset(_toolCode, preset);
      developer.log('LengthUnifiedService: Saved preset: $name');
      return id;
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to save preset: $e');
      rethrow;
    }
  }

  /// Get specific preset
  static Future<Map<String, dynamic>?> getPreset(String id) async {
    try {
      return await ConverterToolsDataService.getPreset(_toolCode, id);
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to get preset: $e');
      return null;
    }
  }

  /// Delete preset
  static Future<void> deletePreset(String id) async {
    try {
      await ConverterToolsDataService.deletePreset(_toolCode, id);
      developer.log('LengthUnifiedService: Deleted preset $id');
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to delete preset: $e');
      rethrow;
    }
  }

  /// Update preset
  static Future<void> updatePreset(
    String id, {
    String? name,
    List<String>? units,
  }) async {
    try {
      final existingPreset = await getPreset(id);
      if (existingPreset == null) {
        throw Exception('Preset not found');
      }

      final updatedData = Map<String, dynamic>.from(existingPreset);
      if (name != null) updatedData['name'] = name;
      if (units != null) updatedData['units'] = units;
      updatedData['lastModified'] = DateTime.now().toIso8601String();

      await ConverterToolsDataService.savePreset(_toolCode, updatedData);
      developer.log('LengthUnifiedService: Updated preset $id');
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to update preset: $e');
      rethrow;
    }
  }

  /// Rename preset
  static Future<void> renamePreset(String id, String newName) async {
    try {
      await updatePreset(id, name: newName);
      developer.log('LengthUnifiedService: Renamed preset $id to $newName');
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to rename preset: $e');
      rethrow;
    }
  }

  /// Check if preset name exists
  static Future<bool> presetNameExists(String name) async {
    try {
      final presets = await loadPresets();
      final normalizedName = name.trim().toLowerCase();
      return presets.any((preset) =>
          (preset['name'] ?? '').toString().toLowerCase() == normalizedName);
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to check preset name: $e');
      return false;
    }
  }

  /// Get preset count
  static Future<int> getPresetCount() async {
    try {
      final presets = await loadPresets();
      return presets.length;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all presets
  static Future<void> clearAllPresets() async {
    try {
      await ConverterToolsDataService.clearPresets(_toolCode);
      developer.log('LengthUnifiedService: Cleared all presets');
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to clear presets: $e');
      rethrow;
    }
  }

  /// Export presets
  static Future<List<Map<String, dynamic>>> exportPresets() async {
    try {
      return await loadPresets();
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to export presets: $e');
      return [];
    }
  }

  // ===== UTILITY METHODS =====

  /// Get all length data (state + presets)
  static Future<Map<String, dynamic>> getAllData() async {
    try {
      return {
        'states': await loadState(),
        'presets': await loadPresets(),
      };
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to get all data: $e');
      return {
        'states': <Map<String, dynamic>>[],
        'presets': <Map<String, dynamic>>[],
      };
    }
  }

  /// Clear all length data
  static Future<void> clearAllData() async {
    try {
      await clearState();
      await clearAllPresets();
      developer.log('LengthUnifiedService: Cleared all length data');
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to clear all data: $e');
      rethrow;
    }
  }

  /// Check if length state exists
  static Future<bool> hasState() async {
    try {
      final state = await loadState();
      return state.isNotEmpty;
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to check state: $e');
      return false;
    }
  }

  /// Get length state size
  static Future<int> getStateSize() async {
    try {
      final state = await loadState();
      return state.toString().length;
    } catch (e) {
      developer.log('LengthUnifiedService: Failed to get state size: $e');
      return 0;
    }
  }
}
