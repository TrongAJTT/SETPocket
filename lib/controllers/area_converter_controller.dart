import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/area_converter_service.dart';
import 'package:setpocket/services/converter_services/area_state_adapter.dart';
import 'package:setpocket/services/converter_services/area_state_service.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class AreaConverterController extends ConverterController {
  AreaConverterController()
      : super(
          converterService: AreaConverterService(),
          stateService: AreaStateAdapter(),
        );

  // Generic Preset functionality using GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('area');
    } catch (e) {
      logError('Error loading area presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'area',
        name: name,
        units: units,
      );
      logInfo('Saved area preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving area preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('area', id);
      logInfo('Deleted area preset: $id');
    } catch (e) {
      logError('Error deleting area preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('area', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('area', id, newName);
      logInfo('Renamed area preset: $id to $newName');
    } catch (e) {
      logError('Error renaming area preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied area preset: ${preset.name}');
    } catch (e) {
      logError('Error applying area preset: $e');
      rethrow;
    }
  }

  /// Force clear all cached state data (for recovery from data corruption)
  Future<void> forceClearCache() async {
    try {
      logInfo('AreaConverterController: Force clearing all cache data');

      // Clear state service cache
      await AreaStateService.forceClearAllCache();

      // Clear controller state through state service adapter
      final adapter = AreaStateAdapter();
      await adapter.clearState('area');

      logInfo('AreaConverterController: All cache data cleared successfully');
    } catch (e) {
      logError('AreaConverterController: Error force clearing cache: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value
  String getFormattedValue(double value, String unitId) {
    final unit = converterService.getUnit(unitId);
    if (unit != null) {
      return unit.formatValue(value);
    }
    return value.toStringAsFixed(6); // Higher precision for area units
  }

  /// Get area-specific unit categories for customization
  Map<String, List<String>> getAreaUnitCategories() {
    return {
      'common': ['square_meters', 'square_kilometers', 'square_centimeters'],
      'less_common': ['hectares', 'acres', 'square_feet', 'square_inches'],
      'uncommon': ['square_yards', 'square_miles', 'roods'],
    };
  }

  /// Check if a unit is metric
  bool isMetricUnit(String unitCode) {
    final service = converterService as AreaConverterService;
    return service.isMetricUnit(unitCode);
  }

  /// Check if a unit is imperial
  bool isImperialUnit(String unitCode) {
    final service = converterService as AreaConverterService;
    return service.isImperialUnit(unitCode);
  }

  /// Get the most precise unit for calculations
  String getMostPreciseUnit() {
    // Square meter is the base unit and most precise for calculations
    return 'square_meters';
  }

  /// Get recommended units for beginners
  List<String> getBeginnerUnits() {
    return ['square_meters', 'square_kilometers', 'square_centimeters'];
  }

  /// Get advanced units for professionals
  List<String> getAdvancedUnits() {
    return [
      'hectares',
      'acres',
      'square_feet',
      'square_inches',
      'square_yards',
      'square_miles',
      'roods'
    ];
  }

  /// Get conversion factor between two units
  double getConversionFactor(String fromUnitId, String toUnitId) {
    final service = converterService as AreaConverterService;
    return service.getConversionFactor(fromUnitId, toUnitId);
  }

  /// Get units categorized for customization dialog
  Map<String, List<String>> getCategorizedUnits() {
    final service = converterService as AreaConverterService;
    final categorized = service.getUnitsByCategory();

    final result = <String, List<String>>{};
    for (final entry in categorized.entries) {
      result[entry.key] = entry.value.map((unit) => unit.id).toList();
    }

    return result;
  }
}
