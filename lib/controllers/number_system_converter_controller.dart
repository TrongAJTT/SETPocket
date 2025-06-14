import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/number_system_converter_service.dart';
import 'package:setpocket/services/converter_services/number_system_state_adapter.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class NumberSystemConverterController extends ConverterController {
  NumberSystemConverterController()
      : super(
          converterService: NumberSystemConverterService(),
          stateService: NumberSystemStateAdapter(),
        ) {
    logInfo(
        'NumberSystemConverterController: Initialized with NumberSystemConverterService and NumberSystemStateAdapter');
  }

  // Generic Preset functionality using new GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('number_system');
    } catch (e) {
      logError('Error loading number system presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'number_system',
        name: name,
        units: units,
      );
      logInfo('Saved number system preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving number system preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('number_system', id);
      logInfo('Deleted number system preset: $id');
    } catch (e) {
      logError('Error deleting number system preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('number_system', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('number_system', id, newName);
      logInfo('Renamed number system preset: $id to $newName');
    } catch (e) {
      logError('Error renaming number system preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied number system preset: ${preset.name}');
    } catch (e) {
      logError('Error applying number system preset: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value
  String getFormattedValue(double value, String unitId) {
    final unit = converterService.getUnit(unitId);
    if (unit != null) {
      return unit.formatValue(value);
    }
    return value.toStringAsFixed(0); // For integers
  }
}
