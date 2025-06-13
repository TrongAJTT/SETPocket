import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/mass_converter_service.dart';
import 'package:setpocket/services/converter_services/mass_state_adapter.dart';
import 'package:setpocket/services/converter_services/mass_state_service.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class MassConverterController extends ConverterController {
  MassConverterController()
      : super(
          converterService: MassConverterService(),
          stateService: MassStateAdapter(),
        );

  // Generic Preset functionality using GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('mass');
    } catch (e) {
      logError('Error loading mass presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'mass',
        name: name,
        units: units,
      );
      logInfo('Saved mass preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving mass preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('mass', id);
      logInfo('Deleted mass preset: $id');
    } catch (e) {
      logError('Error deleting mass preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('mass', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('mass', id, newName);
      logInfo('Renamed mass preset: $id to $newName');
    } catch (e) {
      logError('Error renaming mass preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied mass preset: ${preset.name}');
    } catch (e) {
      logError('Error applying mass preset: $e');
      rethrow;
    }
  }

  /// Force clear all cached state data (for recovery from data corruption)
  Future<void> forceClearCache() async {
    try {
      logInfo('MassConverterController: Force clearing all cache data');

      // Clear state service cache
      await MassStateService.forceClearAllCache();

      // Clear controller state through state service adapter
      final adapter = MassStateAdapter();
      await adapter.clearState('mass');

      logInfo('MassConverterController: All cache data cleared successfully');
    } catch (e) {
      logError('MassConverterController: Error force clearing cache: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value
  String getFormattedValue(double value, String unitId) {
    final unit = converterService.getUnit(unitId);
    if (unit != null) {
      return unit.formatValue(value);
    }
    return value.toStringAsFixed(2);
  }
}
