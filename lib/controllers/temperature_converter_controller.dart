import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/temperature_converter_service.dart';
import 'package:setpocket/services/converter_services/temperature_state_adapter.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';

class TemperatureConverterController extends ConverterController {
  TemperatureConverterController()
      : super(
          converterService: TemperatureConverterService(),
          stateService: TemperatureStateAdapter(),
        ) {
    logInfo(
        'TemperatureConverterController: Initialized with TemperatureConverterService and TemperatureStateAdapter');
  }

  // Generic Preset functionality using new GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('temperature');
    } catch (e) {
      logError('Error loading temperature presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'temperature',
        name: name,
        units: units,
      );
      logInfo('Saved temperature preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving temperature preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('temperature', id);
      logInfo('Deleted temperature preset: $id');
    } catch (e) {
      logError('Error deleting temperature preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('temperature', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('temperature', id, newName);
      logInfo('Renamed temperature preset: $id to $newName');
    } catch (e) {
      logError('Error renaming temperature preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied temperature preset: ${preset.name}');
    } catch (e) {
      logError('Error applying temperature preset: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value with optimization
  String getFormattedValue(double value, String unitId) {
    try {
      final temperatureService =
          converterService as TemperatureConverterService;
      return temperatureService.getFormattedValue(value, unitId);
    } catch (e) {
      logError(
          'TemperatureConverterController: Error getting formatted value: $e');
      final unit = converterService.getUnit(unitId);
      if (unit != null) {
        return unit.formatValue(value);
      }
      return value.toStringAsFixed(2);
    }
  }

  /// Get temperature-specific unit categories for customization
  Map<String, List<String>> getTemperatureUnitCategories() {
    return {
      'common': ['celsius', 'fahrenheit'],
      'scientific': ['kelvin'],
      'historical': ['rankine', 'reaumur', 'delisle'],
    };
  }

  /// Get conversion factor between two units (using 0°C as base)
  double getConversionFactor(String fromUnitId, String toUnitId) {
    try {
      return converterService.convert(0.0, fromUnitId, toUnitId);
    } catch (e) {
      logError(
          'TemperatureConverterController: Error getting conversion factor: $e');
      return 0.0; // Note: Temperature conversions don't have simple multiplication factors
    }
  }

  /// Convert temperature with proper validation
  double convertTemperature(double value, String fromUnitId, String toUnitId) {
    try {
      return converterService.convert(value, fromUnitId, toUnitId);
    } catch (e) {
      logError(
          'TemperatureConverterController: Error converting temperature: $e');
      return value;
    }
  }

  // Performance monitoring methods
  Map<String, dynamic> getCacheStats() {
    return TemperatureConverterService.getCacheStats();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return TemperatureConverterService.getPerformanceMetrics();
  }

  void clearCacheStats() {
    TemperatureConverterService.clearCacheStats();
  }

  void clearPerformanceCaches() {
    TemperatureConverterService.clearCaches();
  }

  Map<String, dynamic> getMemoryStats() {
    return TemperatureConverterService.getMemoryStats();
  }

  /// Get performance summary for logging/debugging
  String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final conversionHitRate = metrics['conversionHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Temperature Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB';
  }

  /// Log performance metrics for monitoring
  void logPerformanceMetrics() {
    try {
      final summary = getPerformanceSummary();
      logInfo('TemperatureConverterController: $summary');

      final metrics = getPerformanceMetrics();
      logInfo('TemperatureConverterController: Detailed metrics: $metrics');
    } catch (e) {
      logError(
          'TemperatureConverterController: Error logging performance metrics: $e');
    }
  }
}
