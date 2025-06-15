import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/data_converter_service.dart';
import 'package:setpocket/services/converter_services/data_state_adapter.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class DataConverterController extends ConverterController {
  DataConverterController()
      : super(
          converterService: DataConverterService(),
          stateService: DataStateAdapter(),
        );

  // Generic Preset functionality using new GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('data_storage');
    } catch (e) {
      logError('Error loading data storage presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'data_storage',
        name: name,
        units: units,
      );
      logInfo('Saved data storage preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving data storage preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('data_storage', id);
      logInfo('Deleted data storage preset: $id');
    } catch (e) {
      logError('Error deleting data storage preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('data_storage', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('data_storage', id, newName);
      logInfo('Renamed data storage preset: $id to $newName');
    } catch (e) {
      logError('Error renaming data storage preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied data storage preset: ${preset.name}');
    } catch (e) {
      logError('Error applying data storage preset: $e');
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
