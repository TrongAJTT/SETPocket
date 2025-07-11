import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/data_converter_service.dart';
import 'package:setpocket/services/converter_services/unified_state_adapter.dart';
import 'package:setpocket/services/converter_services/data_unified_service.dart';
import 'package:setpocket/services/app_logger.dart';

class DataConverterController extends ConverterController {
  DataConverterController()
      : super(
          converterService: DataConverterService(),
          stateService: UnifiedStateAdapter('data'),
        ) {
    logInfo(
        'DataConverterController: Initialized with DataConverterService and UnifiedStateAdapter');
  }

  // Data Preset functionality using DataUnifiedService
  Future<List<Map<String, dynamic>>> getPresets() async {
    try {
      return await DataUnifiedService.loadPresets();
    } catch (e) {
      logError('Error loading data storage presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await DataUnifiedService.savePreset(
        name: name,
        units: units,
      );
      logInfo('Saved data storage preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving data storage preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await DataUnifiedService.deletePreset(id);
      logInfo('Deleted data storage preset: $id');
    } catch (e) {
      logError('Error deleting data storage preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await DataUnifiedService.presetNameExists(name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await DataUnifiedService.renamePreset(id, newName);
      logInfo('Renamed data storage preset: $id to $newName');
    } catch (e) {
      logError('Error renaming data storage preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(Map<String, dynamic> preset) async {
    try {
      // Use inherited method to update global visible units
      final units = List<String>.from(preset['units'] ?? []);
      await updateGlobalVisibleUnits(units.toSet());

      logInfo('Applied data storage preset: ${preset['name']}');
    } catch (e) {
      logError('Error applying data storage preset: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value with optimization
  String getFormattedValue(double value, String unitId) {
    try {
      final dataService = converterService as DataConverterService;
      return dataService.getFormattedValue(value, unitId);
    } catch (e) {
      logError('DataConverterController: Error getting formatted value: $e');
      final unit = converterService.getUnit(unitId);
      if (unit != null) {
        return unit.formatValue(value);
      }
      return value.toStringAsFixed(2);
    }
  }

  /// Get data storage-specific unit categories for customization
  Map<String, List<String>> getDataStorageUnitCategories() {
    return {
      'bytes': [
        'byte',
        'kilobyte',
        'megabyte',
        'gigabyte',
        'terabyte',
        'petabyte'
      ],
      'bits': ['bit', 'kilobit', 'megabit', 'gigabit'],
    };
  }

  /// Get conversion factor between two units
  double getConversionFactor(String fromUnitId, String toUnitId) {
    try {
      return converterService.convert(1.0, fromUnitId, toUnitId);
    } catch (e) {
      logError('DataConverterController: Error getting conversion factor: $e');
      return 1.0;
    }
  }

  // Performance monitoring methods
  Map<String, dynamic> getCacheStats() {
    return DataConverterService.getCacheStats();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return DataConverterService.getPerformanceMetrics();
  }

  void clearCacheStats() {
    DataConverterService.clearCacheStats();
  }

  void clearPerformanceCaches() {
    DataConverterService.clearCaches();
  }

  Map<String, dynamic> getMemoryStats() {
    return DataConverterService.getMemoryStats();
  }

  /// Get performance summary for logging/debugging
  String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final conversionHitRate = metrics['conversionHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Data Storage Converter Performance: '
        'Conversion Cache Hit Rate: $conversionHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB';
  }

  /// Log performance metrics for monitoring
  void logPerformanceMetrics() {
    try {
      final summary = getPerformanceSummary();
      logInfo('DataConverterController: $summary');

      final metrics = getPerformanceMetrics();
      logInfo('DataConverterController: Detailed metrics: $metrics');
    } catch (e) {
      logError(
          'DataConverterController: Error logging performance metrics: $e');
    }
  }
}
