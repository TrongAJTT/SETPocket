import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/services/converter_services/currency_converter_service.dart';
import 'package:setpocket/services/converter_services/unified_state_adapter.dart';
import 'package:setpocket/services/converter_services/currency_unified_service.dart';
import 'package:setpocket/services/app_logger.dart';

class CurrencyConverterController extends ConverterController {
  CurrencyConverterController()
      : super(
          converterService: CurrencyConverterService(),
          stateService: UnifiedStateAdapter('currency'),
        );

  // Override initialize to initialize currency service
  @override
  Future<void> initialize() async {
    try {
      // Initialize the currency converter service, which loads rates from cache
      final currencyService = converterService as CurrencyConverterService;
      await currencyService.initialize();

      // Manually call only the necessary parts from the parent's initialize method.
      // We are deliberately skipping the parent's `_refreshData()` call, which
      // would force a network fetch and ignore the cache on startup.

      // Load UI state (cards, view mode, etc.)
      await loadState();

      // If no state was loaded, create a default layout
      if (state.cards.isEmpty) {
        createDefaultState();
      }

      // Initialize text controllers for the UI
      initializeControllers();

      // Perform initial conversions for the loaded state
      for (int i = 0; i < state.cards.length; i++) {
        final card = state.cards[i];
        updateCardConversions(i, card.baseUnitId, card.baseValue);
      }

      notifyListenersDebounced();

      logInfo('Currency converter controller initialized correctly');
    } catch (e) {
      logError('Error initializing currency converter controller: $e');
      // Attempt to create a default state on error to prevent a crash
      createDefaultState();
      initializeControllers();
      notifyListenersDebounced();
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

  // Currency Preset functionality using CurrencyUnifiedService
  Future<List<Map<String, dynamic>>> getPresets() async {
    try {
      return await CurrencyUnifiedService.loadPresets();
    } catch (e) {
      logError('Error loading currency presets: $e');
      return [];
    }
  }

  Future<void> savePreset(String name, List<String> units) async {
    try {
      await CurrencyUnifiedService.savePreset(
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
      await CurrencyUnifiedService.deletePreset(id);
      logInfo('Deleted currency preset: $id');
    } catch (e) {
      logError('Error deleting currency preset: $e');
      rethrow;
    }
  }

  Future<bool> presetNameExists(String name) async {
    try {
      return await CurrencyUnifiedService.presetNameExists(name);
    } catch (e) {
      logError('Error checking preset name existence: $e');
      return false;
    }
  }

  Future<void> renamePreset(String id, String newName) async {
    try {
      await CurrencyUnifiedService.renamePreset(id, newName);
      logInfo('Renamed currency preset: $id to $newName');
    } catch (e) {
      logError('Error renaming currency preset: $e');
      rethrow;
    }
  }

  Future<void> applyPreset(Map<String, dynamic> preset) async {
    try {
      // Get currencies from preset
      final currencies = preset['currencies'] as List?;
      if (currencies != null) {
        // Use inherited method to update global visible units
        await updateGlobalVisibleUnits(currencies.cast<String>().toSet());
      }

      logInfo('Applied currency preset: ${preset['name']}');
    } catch (e) {
      logError('Error applying currency preset: $e');
      rethrow;
    }
  }

  // Helper method to get formatted value using optimized service method
  String getFormattedValue(double value, String unitId) {
    final service = converterService as CurrencyConverterService;
    return service.getFormattedValue(value, unitId);
  }

  /// Get currency specific unit categories for customization
  Map<String, List<String>> getCurrencyUnitCategories() {
    return {
      'major': ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF'],
      'asian': [
        'VND',
        'CNY',
        'HKD',
        'TWD',
        'SGD',
        'MYR',
        'THB',
        'IDR',
        'PHP',
        'INR',
        'KRW'
      ],
      'european': [
        'EUR',
        'GBP',
        'CHF',
        'SEK',
        'NOK',
        'DKK',
        'PLN',
        'CZK',
        'HUF',
        'RON'
      ],
      'americas': ['USD', 'CAD', 'BRL', 'MXN', 'ARS', 'CLP', 'COP', 'PEN'],
      'middle_east_africa': [
        'AED',
        'SAR',
        'QAR',
        'KWD',
        'BHD',
        'OMR',
        'JOD',
        'ZAR',
        'EGP',
        'NGN'
      ],
    };
  }

  /// Get conversion factor between two currencies
  double getConversionFactor(String fromUnitId, String toUnitId) {
    try {
      return converterService.convert(1.0, fromUnitId, toUnitId);
    } catch (e) {
      logError(
          'CurrencyConverterController: Error getting conversion factor: $e');
      return 1.0;
    }
  }

  // Performance monitoring methods
  Map<String, dynamic> getCacheStats() {
    return CurrencyConverterService.getCacheStats();
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return CurrencyConverterService.getPerformanceMetrics();
  }

  void clearCacheStats() {
    CurrencyConverterService.clearCacheStats();
  }

  void clearPerformanceCaches() {
    CurrencyConverterService.clearCaches();
  }

  Map<String, dynamic> getMemoryStats() {
    return CurrencyConverterService.getMemoryStats();
  }

  /// Get performance summary for logging/debugging
  String getPerformanceSummary() {
    final metrics = getPerformanceMetrics();
    final unitsHitRate = metrics['unitsHitRate'] ?? '0.0';
    final formattingHitRate = metrics['formattingHitRate'] ?? '0.0';
    final memoryKB = metrics['totalMemoryKB'] ?? '0.0';

    return 'Currency Converter Performance: '
        'Units Cache Hit Rate: $unitsHitRate%, '
        'Formatting Cache Hit Rate: $formattingHitRate%, '
        'Memory Usage: ${memoryKB}KB';
  }

  /// Log performance metrics for monitoring
  void logPerformanceMetrics() {
    try {
      final summary = getPerformanceSummary();
      logInfo('CurrencyConverterController: $summary');

      final metrics = getPerformanceMetrics();
      logInfo('CurrencyConverterController: Detailed metrics: $metrics');
    } catch (e) {
      logError(
          'CurrencyConverterController: Error logging performance metrics: $e');
    }
  }

  /// Check if currency data is live or static
  @override
  bool get isUsingLiveData {
    final service = converterService as CurrencyConverterService;
    return service.isUsingLiveData;
  }

  /// Get last update time for currency data
  @override
  DateTime? get lastUpdated {
    final service = converterService as CurrencyConverterService;
    return service.lastUpdated;
  }

  /// Force refresh currency data
  Future<void> forceRefreshData() async {
    try {
      logInfo('CurrencyConverterController: Force refreshing currency data');
      await refreshData();
      logInfo('CurrencyConverterController: Force refresh completed');
    } catch (e) {
      logError('CurrencyConverterController: Error in force refresh: $e');
      rethrow;
    }
  }

  // Override refresh to use currency-specific refresh
  @override
  Future<void> refreshData() async {
    try {
      logInfo('CurrencyConverterController: Refreshing currency data');

      final currencyService = converterService as CurrencyConverterService;
      await currencyService.refreshData();

      // Trigger UI update
      notifyListeners();

      logInfo(
          'CurrencyConverterController: Currency data refreshed successfully');
    } catch (e) {
      logError(
          'CurrencyConverterController: Error refreshing currency data: $e');
      rethrow;
    }
  }
}
