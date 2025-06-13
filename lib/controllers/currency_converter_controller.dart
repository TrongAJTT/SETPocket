import '../controllers/converter_controller.dart';
import '../services/converter_services/currency_converter_service.dart';
import '../services/converter_services/currency_state_adapter.dart';
import '../services/converter_services/generic_preset_service.dart';
import '../models/converter_models/generic_preset_model.dart';
import '../services/app_logger.dart';

class CurrencyConverterController extends ConverterController {
  CurrencyConverterController()
      : super(
          converterService: CurrencyConverterService(),
          stateService: CurrencyStateAdapter(),
        );

  // Override initialize to initialize currency service
  @override
  Future<void> initialize() async {
    try {
      // Initialize the currency converter service
      final currencyService = converterService as CurrencyConverterService;
      await currencyService.initialize();

      // Call parent initialize to setup state
      await super.initialize();

      logInfo('Currency converter controller initialized');
    } catch (e) {
      logError('Error initializing currency converter controller: $e');
      rethrow;
    }
  }

  // Override dispose to clean up currency service
  @override
  void dispose() {
    try {
      final currencyService = converterService as CurrencyConverterService;
      currencyService.dispose();

      super.dispose();

      logInfo('Currency converter controller disposed');
    } catch (e) {
      logError('Error disposing currency converter controller: $e');
    }
  }

  // Generic Preset functionality using GenericPresetService
  Future<List<GenericPresetModel>> getPresets() async {
    try {
      return await GenericPresetService.loadPresets('currency');
    } catch (e) {
      logError('Error loading currency presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await GenericPresetService.savePreset(
        presetType: 'currency',
        name: name,
        units: units,
      );
      logInfo('Saved currency preset: $name with ${units.length} units');
    } catch (e) {
      logError('Error saving currency preset: $e');
      rethrow;
    }
  }

  Future<void> deletePreset(String id) async {
    try {
      await GenericPresetService.deletePreset('currency', id);
      logInfo('Deleted currency preset: $id');
    } catch (e) {
      logError('Error deleting currency preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await GenericPresetService.presetNameExists('currency', name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await GenericPresetService.renamePreset('currency', id, newName);
      logInfo('Renamed currency preset: $id to $newName');
    } catch (e) {
      logError('Error renaming currency preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(GenericPresetModel preset) async {
    try {
      // Use inherited method to update global visible units
      await updateGlobalVisibleUnits(preset.units.toSet());

      logInfo('Applied currency preset: ${preset.name}');
    } catch (e) {
      logError('Error applying currency preset: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value
  String getFormattedValue(double value, String unitId) {
    final unit = converterService.getUnit(unitId);
    if (unit != null) {
      return unit.formatValue(value);
    }
    return value.toStringAsFixed(2);
  }

  // Override refresh to use currency-specific refresh
  @override
  Future<void> refreshData() async {
    try {
      logInfo('Refreshing currency data');

      final currencyService = converterService as CurrencyConverterService;
      await currencyService.refreshData();

      // Trigger UI update
      notifyListeners();

      logInfo('Currency data refreshed successfully');
    } catch (e) {
      logError('Error refreshing currency data: $e');
      rethrow;
    }
  }
}
