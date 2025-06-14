import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/volume_converter_service.dart';
import 'package:setpocket/services/converter_services/volume_state_adapter.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class VolumeConverterController extends ConverterController {
  VolumeConverterController()
      : super(
          converterService: VolumeConverterService(),
          stateService: VolumeStateAdapter(),
        ) {
    logInfo(
        'VolumeConverterController: Initialized with VolumeConverterService and VolumeStateAdapter');
  }

  // Generic Preset functionality using new GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('volume');
    } catch (e) {
      logError('Error loading volume presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'volume',
        name: name,
        units: units,
      );
      logInfo('Saved volume preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving volume preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('volume', id);
      logInfo('Deleted volume preset: $id');
    } catch (e) {
      logError('Error deleting volume preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('volume', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('volume', id, newName);
      logInfo('Renamed volume preset: $id to $newName');
    } catch (e) {
      logError('Error renaming volume preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied volume preset: ${preset.name}');
    } catch (e) {
      logError('Error applying volume preset: $e');
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
