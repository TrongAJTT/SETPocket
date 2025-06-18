import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/number_system_converter_service.dart';
import 'package:setpocket/services/converter_services/number_system_state_adapter.dart';
import 'package:setpocket/services/converter_services/generic_preset_service.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:flutter/services.dart';

class NumberSystemConverterController extends ConverterController {
  bool _isInternalUpdate = false;

  NumberSystemConverterController()
      : super(
          converterService: NumberSystemConverterService(),
          stateService: NumberSystemStateAdapter(),
        ) {
    logInfo(
        'NumberSystemConverterController: Initialized with NumberSystemConverterService and NumberSystemStateAdapter');
  }

  // Generic Preset functionality using new GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('number_system');
    } catch (e) {
      logError('Error loading number system presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'number_system',
        name: name,
        units: units,
      );
      logInfo('Saved number system preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving number system preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('number_system', id);
      logInfo('Deleted number system preset: $id');
    } catch (e) {
      logError('Error deleting number system preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('number_system', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('number_system', id, newName);
      logInfo('Renamed number system preset: $id to $newName');
    } catch (e) {
      logError('Error renaming number system preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied number system preset: ${preset.name}');
    } catch (e) {
      logError('Error applying number system preset: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value using optimized service method
  String getFormattedValue(double value, String unitId) {
    final service = converterService as NumberSystemConverterService;
    return service.getFormattedValue(value, unitId);
  }

  /// Get number system specific unit categories for customization
  Map<String, List<String>> getNumberSystemUnitCategories() {
    return {
      'basic': ['binary', 'octal', 'decimal', 'hexadecimal'],
      'extended': ['base32', 'base64'],
      'specialized': ['base128', 'base256'],
    };
  }

  /// Get conversion factor between two units (always 1 for number systems as they represent same value)
  double getConversionFactor(String fromUnitId, String toUnitId) {
    try {
      return converterService.convert(1.0, fromUnitId, toUnitId);
    } catch (e) {
      logError(
          'NumberSystemConverterController: Error getting conversion factor: $e');
      return 1.0;
    }
  }

  // Performance monitoring methods
  Map<String, dynamic> getCacheStats() {
    return NumberSystemConverterService.getCacheStats();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return NumberSystemConverterService.getPerformanceMetrics();
  }

  void clearCacheStats() {
    NumberSystemConverterService.clearCacheStats();
  }

  void clearPerformanceCaches() {
    NumberSystemConverterService.clearCaches();
  }

  Map<String, dynamic> getMemoryStats() {
    return NumberSystemConverterService.getMemoryStats();
  }

  /// Get performance summary for logging/debugging
  String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final unitsHitRate = metrics['unitsHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Number System Converter Performance: '
        'Units Cache Hit Rate: $unitsHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB';
  }

  /// Log performance metrics for monitoring
  void logPerformanceMetrics() {
    try {
      final summary = getPerformanceSummary();
      logInfo('NumberSystemConverterController: $summary');

      final metrics = getPerformanceMetrics();
      logInfo('NumberSystemConverterController: Detailed metrics: $metrics');
    } catch (e) {
      logError(
          'NumberSystemConverterController: Error logging performance metrics: $e');
    }
  }

  /// Parse value from input string for specific number system base
  double parseValueForBase(String input, String unitId) {
    try {
      final service = converterService as NumberSystemConverterService;
      final unit = service.getUnit(unitId) as NumberSystemUnit?;
      if (unit == null) return 0.0;

      return unit.parseValue(input);
    } catch (e) {
      logError(
          'NumberSystemConverterController: Error parsing value "$input" for base $unitId: $e');
      return 0.0;
    }
  }

  /// Validate input for specific number system base
  bool validateInputForBase(String input, String unitId) {
    if (input.isEmpty) return true; // Empty input is valid

    try {
      final service = converterService as NumberSystemConverterService;
      final unit = service.getUnit(unitId) as NumberSystemUnit?;
      if (unit == null) return false;

      // Try to parse the input
      unit.parseValue(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get input formatter for specific number system base
  TextInputFormatter? getInputFormatterForUnit(String unitId) {
    return NumberSystemConverterService.getInputFormatterForUnit(unitId);
  }

  /// Get allowed characters for a specific unit
  String? getAllowedCharactersForUnit(String unitId) {
    final service = converterService as NumberSystemConverterService;
    final unit = service.getUnit(unitId) as NumberSystemUnit?;
    if (unit == null) return null;

    return NumberSystemConverterService.getAllowedCharactersForBase(unit.base);
  }

  /// Check if a unit uses letters (base > 10)
  bool unitUsesLetters(String unitId) {
    final service = converterService as NumberSystemConverterService;
    final unit = service.getUnit(unitId) as NumberSystemUnit?;
    if (unit == null) return false;

    return unit.base > 10;
  }

  /// Override onValueChanged to use proper number system parsing
  @override
  void onValueChanged(int cardIndex, String unitId, String valueText) {
    if (cardIndex >= state.cards.length || _isInternalUpdate) return;

    // Use number system specific parsing instead of double.tryParse
    final value = parseValueForBase(valueText, unitId);

    logInfo('NumberSystemConverter: Parsed "$valueText" ($unitId) = $value');

    // Convert the parsed value to string and call parent method
    // to avoid code duplication
    _isInternalUpdate = true;
    super.onValueChanged(cardIndex, unitId, value.toString());
    _isInternalUpdate = false;
  }
}
