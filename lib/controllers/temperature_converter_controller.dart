import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/temperature_converter_service.dart';
import 'package:setpocket/services/converter_services/unified_state_adapter.dart';
import 'package:setpocket/services/converter_services/temperature_unified_service.dart';
import 'package:setpocket/services/app_logger.dart';

class TemperatureConverterController extends ConverterController {
  TemperatureConverterController()
      : super(
          converterService: TemperatureConverterService(),
          stateService: UnifiedStateAdapter('temperature'),
        );

  // Temperature Preset functionality using TemperatureUnifiedService
  Future<List<Map<String, dynamic>>> getPresets() async {
    try {
      return await TemperatureUnifiedService.loadPresets();
    } catch (e) {
      logError('Error loading temperature presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await TemperatureUnifiedService.savePreset(
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
      await TemperatureUnifiedService.deletePreset(id);
      logInfo('Deleted temperature preset: $id');
    } catch (e) {
      logError('Error deleting temperature preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await TemperatureUnifiedService.presetNameExists(name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await TemperatureUnifiedService.renamePreset(id, newName);
      logInfo('Renamed temperature preset: $id to $newName');
    } catch (e) {
      logError('Error renaming temperature preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(Map<String, dynamic> preset) async {
    try {
      // Units are handled by the preset system itself
      logInfo('Applied temperature preset: ${preset['name']}');
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
