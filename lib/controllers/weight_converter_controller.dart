import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/weight_converter_service.dart';
import 'package:setpocket/services/converter_services/weight_state_adapter.dart';
import 'package:setpocket/services/converter_services/weight_state_service.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class WeightConverterController extends ConverterController {
  WeightConverterController()
      : super(
          converterService: WeightConverterService(),
          stateService: WeightStateAdapter(),
        );

  // Generic Preset functionality using GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('weight');
    } catch (e) {
      logError('Error loading weight presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'weight',
        name: name,
        units: units,
      );
      logInfo('Saved weight preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving weight preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('weight', id);
      logInfo('Deleted weight preset: $id');
    } catch (e) {
      logError('Error deleting weight preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('weight', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('weight', id, newName);
      logInfo('Renamed weight preset: $id to $newName');
    } catch (e) {
      logError('Error renaming weight preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied weight preset: ${preset.name}');
    } catch (e) {
      logError('Error applying weight preset: $e');
      rethrow;
    }
  }

  /// Force clear all cached state data (for recovery from data corruption)
  Future<void> forceClearCache() async {
    try {
      logInfo('WeightConverterController: Force clearing all cache data');

      // Clear state service cache
      await WeightStateService.forceClearAllCache();

      // Clear controller state through state service adapter
      final adapter = WeightStateAdapter();
      await adapter.clearState('weight');

      logInfo('WeightConverterController: All cache data cleared successfully');
    } catch (e) {
      logError('WeightConverterController: Error force clearing cache: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value
  String getFormattedValue(double value, String unitId) {
    final unit = converterService.getUnit(unitId);
    if (unit != null) {
      return unit.formatValue(value);
    }
    return value.toStringAsFixed(6); // Higher precision for weight/force units
  }

  /// Get weight-specific unit categories for customization
  Map<String, List<String>> getWeightUnitCategories() {
    // This would be implemented in the converter service
    return {
      'common': ['newtons', 'kilogram_force', 'pound_force'],
      'less_common': ['dyne', 'kilopond'],
      'uncommon': ['ton_force'],
      'special': ['gram_force', 'troy_pound'],
    };
  }

  /// Check if a unit is a force unit (all weight units are force units)
  bool isForceUnit(String unitCode) {
    final unit = converterService.getUnit(unitCode);
    return unit != null;
  }

  /// Get the most precise unit for calculations
  String getMostPreciseUnit() {
    // Newton is the base unit and most precise for calculations
    return 'newtons';
  }

  /// Get recommended units for beginners
  List<String> getBeginnerUnits() {
    return ['newtons', 'kilogram_force', 'pound_force'];
  }

  /// Get advanced units for professionals
  List<String> getAdvancedUnits() {
    return ['dyne', 'kilopond', 'ton_force', 'gram_force', 'troy_pound'];
  }
}
