import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/length_converter_service.dart';
import 'package:setpocket/services/converter_services/length_state_adapter.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class LengthConverterController extends ConverterController {
  LengthConverterController()
      : super(
          converterService: LengthConverterService(),
          stateService: LengthStateAdapter(),
        );

  // Generic Preset functionality using new GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('length');
    } catch (e) {
      logError('Error loading length presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'length',
        name: name,
        units: units,
      );
      logInfo('Saved length preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving length preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('length', id);
      logInfo('Deleted length preset: $id');
    } catch (e) {
      logError('Error deleting length preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('length', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('length', id, newName);
      logInfo('Renamed length preset: $id to $newName');
    } catch (e) {
      logError('Error renaming length preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied length preset: ${preset.name}');
    } catch (e) {
      logError('Error applying length preset: $e');
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
