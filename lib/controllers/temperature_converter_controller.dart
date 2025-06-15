import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/temperature_converter_service.dart';
import 'package:setpocket/services/converter_services/temperature_state_adapter.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class TemperatureConverterController extends ConverterController {
  TemperatureConverterController()
      : super(
          converterService: TemperatureConverterService(),
          stateService: TemperatureStateAdapter(),
        );

  // Generic Preset functionality using new GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('temperature');
    } catch (e) {
      logError('Error loading temperature presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'temperature',
        name: name,
        units: units,
      );
      logInfo('Saved temperature preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving temperature preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('temperature', id);
      logInfo('Deleted temperature preset: $id');
    } catch (e) {
      logError('Error deleting temperature preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('temperature', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('temperature', id, newName);
      logInfo('Renamed temperature preset: $id to $newName');
    } catch (e) {
      logError('Error renaming temperature preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied temperature preset: ${preset.name}');
    } catch (e) {
      logError('Error applying temperature preset: $e');
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
