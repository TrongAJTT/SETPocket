import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/volume_converter_service.dart';
import 'package:setpocket/services/converter_services/unified_state_adapter.dart';
import 'package:setpocket/services/converter_services/volume_unified_service.dart';
import 'package:setpocket/services/app_logger.dart';

class VolumeConverterController extends ConverterController {
  VolumeConverterController()
      : super(
          converterService: VolumeConverterService(),
          stateService: UnifiedStateAdapter('volume'),
        );

  // Volume Preset functionality using VolumeUnifiedService
  Future<List<Map<String, dynamic>>> getPresets() async {
    try {
      return await VolumeUnifiedService.loadPresets();
    } catch (e) {
      logError('Error loading volume presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await VolumeUnifiedService.savePreset(
        name: name,
        units: units,
      );
      logInfo('Saved volume preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving volume preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await VolumeUnifiedService.deletePreset(id);
      logInfo('Deleted volume preset: $id');
    } catch (e) {
      logError('Error deleting volume preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await VolumeUnifiedService.presetNameExists(name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await VolumeUnifiedService.renamePreset(id, newName);
      logInfo('Renamed volume preset: $id to $newName');
    } catch (e) {
      logError('Error renaming volume preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(Map<String, dynamic> preset) async {
    try {
      // Units are handled by the preset system itself
      logInfo('Applied volume preset: ${preset['name']}');
    } catch (e) {
      logError('Error applying volume preset: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value using optimized service method
  String getFormattedValue(double value, String unitId) {
    try {
      // Cast to VolumeConverterService to access optimized formatting
      final volumeService = converterService as VolumeConverterService;
      return volumeService.getFormattedValue(value, unitId);
    } catch (e) {
      logError('VolumeConverterController: Error formatting value: $e');
      final unit = converterService.getUnit(unitId);
      if (unit != null) {
        return unit.formatValue(value);
      }
      return value.toStringAsFixed(2);
    }
  }

  /// Get volume-specific unit categories for customization
  Map<String, List<String>> getVolumeUnitCategories() {
    return {
      'metric': [
        'cubic_meter',
        'liter',
        'milliliter',
        'cubic_centimeter',
        'hectoliter'
      ],
      'imperial_us': [
        'gallon_us',
        'quart_us',
        'pint_us',
        'cup',
        'fluid_ounce_us'
      ],
      'imperial_uk': ['gallon_uk'],
      'cubic': ['cubic_inch', 'cubic_foot', 'cubic_yard'],
      'special': ['barrel'],
    };
  }

  /// Get conversion factor between two units
  double getConversionFactor(String fromUnitId, String toUnitId) {
    try {
      return converterService.convert(1.0, fromUnitId, toUnitId);
    } catch (e) {
      logError(
          'VolumeConverterController: Error getting conversion factor: $e');
      return 1.0;
    }
  }

  // Performance monitoring methods
  Map<String, dynamic> getCacheStats() {
    return VolumeConverterService.getCacheStats();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return VolumeConverterService.getPerformanceMetrics();
  }

  void clearCacheStats() {
    VolumeConverterService.clearCacheStats();
  }

  void clearPerformanceCaches() {
    VolumeConverterService.clearCaches();
  }

  Map<String, dynamic> getMemoryStats() {
    return VolumeConverterService.getMemoryStats();
  }

  /// Get performance summary for logging/debugging
  String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final conversionHitRate = metrics['conversionHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Volume Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB';
  }

  /// Log performance metrics for monitoring
  void logPerformanceMetrics() {
    try {
      final summary = getPerformanceSummary();
      logInfo('VolumeConverterController: $summary');

      final metrics = getPerformanceMetrics();
      logInfo('VolumeConverterController: Detailed metrics: $metrics');
    } catch (e) {
      logError(
          'VolumeConverterController: Error logging performance metrics: $e');
    }
  }
}
