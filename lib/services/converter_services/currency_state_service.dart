import 'package:hive/hive.dart';
import '../../models/converter_models/currency_state_model.dart';
import '../settings_service.dart';

class CurrencyStateService {
  static const String _stateBoxName = 'currency_state';
  static const String _stateKey = 'converter_state';

  static Box<CurrencyStateModel>? _stateBox;

  // Initialize the state service
  static Future<void> initialize() async {
    try {
      if (_stateBox == null || !_stateBox!.isOpen) {
        _stateBox = await Hive.openBox<CurrencyStateModel>(_stateBoxName);
        print('CurrencyStateService: Box opened successfully');
      }
    } catch (e) {
      print('CurrencyStateService: Error opening box: $e');
      rethrow;
    }
  }

  // Check if state saving is enabled
  static Future<bool> isStateSavingEnabled() async {
    final settings = await SettingsService.getSettings();
    return settings.featureStateSavingEnabled;
  }

  // Save currency converter state
  static Future<void> saveState(CurrencyStateModel state) async {
    try {
      final enabled = await isStateSavingEnabled();
      if (!enabled) {
        print('CurrencyStateService: State saving is disabled');
        return;
      }

      await initialize();

      print(
          'CurrencyStateService: Saving converter state with ${state.cards.length} cards');
      await _stateBox!.put(_stateKey, state);
      await _stateBox!.flush();
      print('CurrencyStateService: State saved successfully');
    } catch (e) {
      print('CurrencyStateService: Error saving state: $e');
    }
  }

  // Load currency converter state
  static Future<CurrencyStateModel> loadState() async {
    try {
      final enabled = await isStateSavingEnabled();
      if (!enabled) {
        print(
            'CurrencyStateService: State saving is disabled, returning default');
        return CurrencyStateModel.getDefault();
      }

      await initialize();

      final state = _stateBox!.get(_stateKey);
      if (state != null) {
        print(
            'CurrencyStateService: Loaded state with ${state.cards.length} cards');
        return state;
      } else {
        print('CurrencyStateService: No saved state, returning default');
        return CurrencyStateModel.getDefault();
      }
    } catch (e) {
      print('CurrencyStateService: Error loading state: $e');
      return CurrencyStateModel.getDefault();
    }
  }

  // Clear saved state
  static Future<void> clearState() async {
    try {
      await initialize();
      await _stateBox!.delete(_stateKey);
      await _stateBox!.flush();
      print('CurrencyStateService: State cleared');
    } catch (e) {
      print('CurrencyStateService: Error clearing state: $e');
    }
  }

  // Check if state exists
  static Future<bool> hasState() async {
    try {
      await initialize();
      return _stateBox!.containsKey(_stateKey);
    } catch (e) {
      print('CurrencyStateService: Error checking state: $e');
      return false;
    }
  }

  // Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      await initialize();
      final state = _stateBox!.get(_stateKey);
      if (state != null) {
        final json = state.toJson();
        final jsonString = json.toString();
        return jsonString.length;
      }
      return 0;
    } catch (e) {
      print('CurrencyStateService: Error getting state size: $e');
      return 0;
    }
  }

  // Debug method
  static Future<void> debugState() async {
    try {
      await initialize();
      final state = _stateBox!.get(_stateKey);
      print('=== CURRENCY STATE DEBUG ===');
      print('State exists: ${state != null}');
      if (state != null) {
        print('Cards count: ${state.cards.length}');
        print('Visible currencies: ${state.visibleCurrencies}');
        print('Last updated: ${state.lastUpdated}');
        for (int i = 0; i < state.cards.length; i++) {
          final card = state.cards[i];
          print('Card $i: ${card.currencyCode} = ${card.amount}');
        }
      }
      print('=== END STATE DEBUG ===');
    } catch (e) {
      print('CurrencyStateService: Error in debug: $e');
    }
  }
}
