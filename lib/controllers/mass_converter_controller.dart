import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/mass_converter_service.dart';
import 'package:setpocket/services/converter_services/mass_state_adapter.dart';
import 'package:setpocket/services/converter_services/mass_state_service.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class MassConverterController extends ConverterController {
  MassConverterController()
      : super(
          converterService: MassConverterService(),
          stateService: MassStateAdapter(),
        );

  // Generic Preset functionality using GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('mass');
    } catch (e) {
      logError('Error loading mass presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'mass',
        name: name,
        units: units,
      );
      logInfo('Saved mass preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving mass preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('mass', id);
      logInfo('Deleted mass preset: $id');
    } catch (e) {
      logError('Error deleting mass preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('mass', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('mass', id, newName);
      logInfo('Renamed mass preset: $id to $newName');
    } catch (e) {
      logError('Error renaming mass preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied mass preset: ${preset.name}');
    } catch (e) {
      logError('Error applying mass preset: $e');
      rethrow;
    }
  }

  /// Force clear all cached state data (for recovery from data corruption)
  Future<void> forceClearCache() async {
    try {
      logInfo('MassConverterController: Force clearing all cache data');

      // Clear state service cache
      await MassStateService.forceClearAllCache();

      // Clear controller state through state service adapter
      final adapter = MassStateAdapter();
      await adapter.clearState('mass');

      // Clear performance caches from service
      MassConverterService.clearCaches();

      logInfo('MassConverterController: All cache data cleared successfully');
    } catch (e) {
      logError('MassConverterController: Error force clearing cache: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value using optimized service method
  String getFormattedValue(double value, String unitId) {
    try {
      final service = converterService as MassConverterService;
      return service.getFormattedValue(value, unitId);
    } catch (e) {
      logError('MassConverterController: Error formatting value: $e');
      return value.toStringAsFixed(2);
    }
  }

  /// Get mass-specific unit categories for customization
  Map<String, List<String>> getMassUnitCategories() {
    return {
      'metric': [
        'kilograms',
        'grams',
        'milligrams',
        'tonnes',
        'micrograms',
        'nanograms'
      ],
      'imperial': ['pounds', 'ounces', 'stones', 'grains', 'drams', 'quarters'],
      'troy': ['troy_ounces', 'troy_pounds', 'pennyweights', 'troy_grains'],
      'apothecaries': [
        'apothecaries_ounces',
        'apothecaries_drams',
        'scruples',
        'apothecaries_pounds'
      ],
      'special': [
        'carats',
        'slugs',
        'atomic_mass_units',
        'short_tons',
        'long_tons'
      ],
    };
  }

  /// Check if a unit is metric
  bool isMetricUnit(String unitCode) {
    final metricUnits = {
      'nanograms',
      'micrograms',
      'milligrams',
      'grams',
      'kilograms',
      'tonnes'
    };
    return metricUnits.contains(unitCode);
  }

  /// Check if a unit is imperial
  bool isImperialUnit(String unitCode) {
    final imperialUnits = {
      'grains',
      'drams',
      'ounces',
      'pounds',
      'stones',
      'quarters',
      'short_hundredweight',
      'long_hundredweight',
      'short_tons',
      'long_tons'
    };
    return imperialUnits.contains(unitCode);
  }

  /// Get the most precise unit for calculations
  String getMostPreciseUnit() {
    // Grams is the base unit and most precise for calculations
    return 'grams';
  }

  /// Get recommended units for beginners
  List<String> getBeginnerUnits() {
    return ['kilograms', 'grams', 'pounds', 'ounces'];
  }

  /// Get advanced units for professionals
  List<String> getAdvancedUnits() {
    return [
      'tonnes',
      'stones',
      'troy_ounces',
      'apothecaries_ounces',
      'carats',
      'slugs',
      'grains',
      'pennyweights'
    ];
  }

  /// Get conversion factor between two units
  double getConversionFactor(String fromUnitId, String toUnitId) {
    try {
      return converterService.convert(1.0, fromUnitId, toUnitId);
    } catch (e) {
      logError('MassConverterController: Error getting conversion factor: $e');
      return 1.0;
    }
  }

  // Performance monitoring methods
  Map<String, dynamic> getCacheStats() {
    return MassConverterService.getCacheStats();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return MassConverterService.getPerformanceMetrics();
  }

  void clearCacheStats() {
    MassConverterService.clearCacheStats();
  }

  void clearPerformanceCaches() {
    MassConverterService.clearCaches();
  }

  Map<String, dynamic> getMemoryStats() {
    return MassConverterService.getMemoryStats();
  }

  /// Get performance summary for logging/debugging
  String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final conversionHitRate = metrics['conversionHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Mass Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB';
  }

  /// Log performance metrics for monitoring
  void logPerformanceMetrics() {
    try {
      final summary = getPerformanceSummary();
      logInfo('MassConverterController: $summary');

      final metrics = getPerformanceMetrics();
      logInfo('MassConverterController: Detailed metrics: $metrics');
    } catch (e) {
      logError(
          'MassConverterController: Error logging performance metrics: $e');
    }
  }
}
