import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/length_converter_service.dart';
import 'package:setpocket/services/converter_services/unified_state_adapter.dart';
import 'package:setpocket/services/converter_services/length_unified_service.dart';
import 'package:setpocket/services/app_logger.dart';

class LengthConverterController extends ConverterController {
  LengthConverterController()
      : super(
          converterService: LengthConverterService(),
          stateService: UnifiedStateAdapter('length'),
        );

  Future<List<Map<String, dynamic>>> getPresets() async {
    try {
      return await LengthUnifiedService.loadPresets();
    } catch (e) {
      logError('Error loading length presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await LengthUnifiedService.savePreset(name: name, units: units);
      logInfo('Saved length preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving length preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await LengthUnifiedService.deletePreset(id);
      logInfo('Deleted length preset: $id');
    } catch (e) {
      logError('Error deleting length preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await LengthUnifiedService.presetNameExists(name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await LengthUnifiedService.renamePreset(id, newName);
      logInfo('Renamed length preset: $id to $newName');
    } catch (e) {
      logError('Error renaming length preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(Map<String, dynamic> preset) async {
    try {
      logInfo('Applied length preset: ${preset['name']}');
    } catch (e) {
      logError('Error applying length preset: $e');
      rethrow;
    }
  }

  final Map<String, String> _formattedValueCache = {};

  String getFormattedValue(double value, String unitId) {
    final roundedValue = (value * 1000).round() / 1000;
    final cacheKey = '${roundedValue}_$unitId';

    if (_formattedValueCache.containsKey(cacheKey)) {
      return _formattedValueCache[cacheKey]!;
    }

    final unit = converterService.getUnit(unitId);
    final formatted = unit?.formatValue(value) ?? value.toStringAsFixed(2);

    if (_formattedValueCache.length > 1000) {
      _formattedValueCache.clear();
    }
    _formattedValueCache[cacheKey] = formatted;

    return formatted;
  }

  void clearFormattingCache() {
    _formattedValueCache.clear();
  }
}
