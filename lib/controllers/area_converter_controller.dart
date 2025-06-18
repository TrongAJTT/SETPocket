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

      // Clear performance caches from service
      AreaConverterService.clearCaches();

      logInfo('AreaConverterController: All cache data cleared successfully');
    } catch (e) {
      logError('AreaConverterController: Error force clearing cache: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value using optimized service method
  String getFormattedValue(double value, String unitId) {
    try {
      final service = converterService as AreaConverterService;
      return service.getFormattedValue(value, unitId);
    } catch (e) {
      logError('AreaConverterController: Error formatting value: $e');
      return value.toStringAsFixed(6); // Higher precision for area units
    }
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
    try {
      return converterService.convert(1.0, fromUnitId, toUnitId);
    } catch (e) {
      logError('AreaConverterController: Error getting conversion factor: $e');
      return 1.0;
    }
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

  // Performance monitoring methods
  Map<String, dynamic> getCacheStats() {
    return AreaConverterService.getCacheStats();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return AreaConverterService.getPerformanceMetrics();
  }

  void clearCacheStats() {
    AreaConverterService.clearCacheStats();
  }

  void clearPerformanceCaches() {
    AreaConverterService.clearCaches();
  }

  Map<String, dynamic> getMemoryStats() {
    return AreaConverterService.getMemoryStats();
  }

  /// Get performance summary for logging/debugging
  String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final conversionHitRate = metrics['conversionHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Area Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB';
  }

  /// Log performance metrics for monitoring
  void logPerformanceMetrics() {
    try {
      final summary = getPerformanceSummary();
      logInfo('AreaConverterController: $summary');

      final metrics = getPerformanceMetrics();
      logInfo('AreaConverterController: Detailed metrics: $metrics');
    } catch (e) {
      logError(
          'AreaConverterController: Error logging performance metrics: $e');
    }
  }
}
