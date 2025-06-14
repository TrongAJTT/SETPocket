import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/time_converter_service.dart';
import 'package:setpocket/services/converter_services/time_state_adapter.dart';
import 'package:setpocket/services/converter_services/time_state_service.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class TimeConverterController extends ConverterController {
  TimeConverterController()
      : super(
          converterService: TimeConverterService(),
          stateService: TimeStateAdapter(),
        );

  // Generic Preset functionality using GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('time');
    } catch (e) {
      logError('Error loading time presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'time',
        name: name,
        units: units,
      );
      logInfo('Saved time preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving time preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('time', id);
      logInfo('Deleted time preset: $id');
    } catch (e) {
      logError('Error deleting time preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('time', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('time', id, newName);
      logInfo('Renamed time preset: $id to $newName');
    } catch (e) {
      logError('Error renaming time preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied time preset: ${preset.name}');
    } catch (e) {
      logError('Error applying time preset: $e');
      rethrow;
    }
  }

  /// Force clear all cached state data (for recovery from data corruption)
  Future<void> forceClearTimeCache() async {
    try {
      logInfo('TimeConverterController: Force clearing all cache data');

      // Clear state service cache
      await TimeStateService.forceClearAllCache();

      // Clear controller state through state service adapter
      final adapter = TimeStateAdapter();
      await adapter.clearState('time');

      logInfo('TimeConverterController: All cache data cleared successfully');
    } catch (e) {
      logError('TimeConverterController: Error force clearing cache: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value
  String getFormattedValue(double value, String unitId) {
    try {
      if (unitId.isEmpty) {
        return value.toStringAsFixed(6);
      }

      final unit = converterService.getUnit(unitId);
      if (unit != null) {
        return unit.formatValue(value);
      }
      return value.toStringAsFixed(6); // Higher precision for time units
    } catch (e) {
      logError('Error formatting value for unit $unitId: $e');
      return value.toStringAsFixed(6);
    }
  }

  /// Get time-specific unit categories for customization
  Map<String, List<String>> getTimeUnitCategories() {
    return {
      'common': ['seconds', 'minutes', 'hours'],
      'less_common': ['days', 'weeks', 'months', 'years'],
      'uncommon': [
        'milliseconds',
        'microseconds',
        'nanoseconds',
        'decades',
        'centuries',
        'millennia'
      ],
    };
  }
}
