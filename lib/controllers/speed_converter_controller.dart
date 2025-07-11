import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/speed_converter_service.dart';
import 'package:setpocket/services/converter_services/unified_state_adapter.dart';
import 'package:setpocket/services/converter_services/speed_unified_service.dart';
import 'package:setpocket/services/app_logger.dart';

class SpeedConverterController extends ConverterController {
  SpeedConverterController()
      : super(
          converterService: SpeedConverterService(),
          stateService: UnifiedStateAdapter('speed'),
        );

  // Speed Preset functionality using SpeedUnifiedService
  Future<List<Map<String, dynamic>>> getPresets() async {
    try {
      return await SpeedUnifiedService.loadPresets();
    } catch (e) {
      logError('Error loading speed presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await SpeedUnifiedService.savePreset(
        name: name,
        units: units,
      );
      logInfo('Saved speed preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving speed preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await SpeedUnifiedService.deletePreset(id);
      logInfo('Deleted speed preset: $id');
    } catch (e) {
      logError('Error deleting speed preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await SpeedUnifiedService.presetNameExists(name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await SpeedUnifiedService.renamePreset(id, newName);
      logInfo('Renamed speed preset: $id to $newName');
    } catch (e) {
      logError('Error renaming speed preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(Map<String, dynamic> preset) async {
    try {
      // Use inherited method to update global visible units
      final units = List<String>.from(preset['units'] ?? []);
      await updateGlobalVisibleUnits(units.toSet());

      logInfo('Applied speed preset: ${preset['name']}');
    } catch (e) {
      logError('Error applying speed preset: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value using optimized service method
  String getFormattedValue(double value, String unitId) {
    try {
      // Cast to SpeedConverterService to access optimized formatting
      final speedService = converterService as SpeedConverterService;
      return speedService.getFormattedValue(value, unitId);
    } catch (e) {
      logError('SpeedConverterController: Error formatting value: $e');
      final unit = converterService.getUnit(unitId);
      if (unit != null) {
        return unit.formatValue(value);
      }
      return value.toStringAsFixed(2);
    }
  }

  /// Get speed-specific unit categories for customization
  Map<String, List<String>> getSpeedUnitCategories() {
    return {
      'common': ['kilometers_per_hour', 'meters_per_second', 'miles_per_hour'],
      'nautical': ['knots'],
      'imperial': ['feet_per_second'],
      'specialized': ['mach'],
    };
  }

  /// Get conversion factor between two units
  double getConversionFactor(String fromUnitId, String toUnitId) {
    try {
      return converterService.convert(1.0, fromUnitId, toUnitId);
    } catch (e) {
      logError('SpeedConverterController: Error getting conversion factor: $e');
      return 1.0;
    }
  }

  // Performance monitoring methods
  Map<String, dynamic> getCacheStats() {
    return SpeedConverterService.getCacheStats();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return SpeedConverterService.getPerformanceMetrics();
  }

  void clearCacheStats() {
    SpeedConverterService.clearCacheStats();
  }

  void clearPerformanceCaches() {
    SpeedConverterService.clearCaches();
  }

  Map<String, dynamic> getMemoryStats() {
    return SpeedConverterService.getMemoryStats();
  }

  /// Get performance summary for logging/debugging
  String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final conversionHitRate = metrics['conversionHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Speed Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB';
  }

  /// Log performance metrics for monitoring
  void logPerformanceMetrics() {
    try {
      final summary = getPerformanceSummary();
      logInfo('SpeedConverterController: $summary');

      final metrics = getPerformanceMetrics();
      logInfo('SpeedConverterController: Detailed metrics: $metrics');
    } catch (e) {
      logError(
          'SpeedConverterController: Error logging performance metrics: $e');
    }
  }
}
