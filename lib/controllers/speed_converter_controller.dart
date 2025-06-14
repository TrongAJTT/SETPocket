import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/speed_converter_service.dart';
import 'package:setpocket/services/converter_services/speed_state_adapter.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class SpeedConverterController extends ConverterController {
  SpeedConverterController()
      : super(
          converterService: SpeedConverterService(),
          stateService: SpeedStateAdapter(),
        );

  // Generic Preset functionality using new GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('speed');
    } catch (e) {
      logError('Error loading speed presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'speed',
        name: name,
        units: units,
      );
      logInfo('Saved speed preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving speed preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('speed', id);
      logInfo('Deleted speed preset: $id');
    } catch (e) {
      logError('Error deleting speed preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('speed', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('speed', id, newName);
      logInfo('Renamed speed preset: $id to $newName');
    } catch (e) {
      logError('Error renaming speed preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied speed preset: ${preset.name}');
    } catch (e) {
      logError('Error applying speed preset: $e');
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
