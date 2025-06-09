import 'package:hive_flutter/hive_flutter.dart';
import '../models/weight_state_model.dart';

class WeightStateService {
  static const String _boxName = 'weight_states';
  static const String _stateKey = 'weight_converter_state';

  static Future<void> init() async {
    try {
      await Hive.openBox<WeightStateModel>(_boxName);
      print('WeightStateService: Box opened successfully');
    } catch (e) {
      print('WeightStateService: Error opening box: $e');
    }
  }

  static Box<WeightStateModel>? _getBox() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box<WeightStateModel>(_boxName);
      }
      return null;
    } catch (e) {
      print('WeightStateService: Error getting box: $e');
      return null;
    }
  }

  static Future<WeightStateModel> loadState() async {
    try {
      final box = _getBox();
      if (box == null) {
        print('WeightStateService: Box not available, returning default state');
        return WeightStateModel.createDefault();
      }

      final state = box.get(_stateKey);
      if (state == null) {
        print('WeightStateService: No saved state found, creating default');
        final defaultState = WeightStateModel.createDefault();
        await saveState(defaultState);
        return defaultState;
      }

      print(
          'WeightStateService: Loaded state: ${state.cards.length} cards, ${state.visibleUnits.length} visible units');
      return state;
    } catch (e) {
      print('WeightStateService: Error loading state: $e');
      return WeightStateModel.createDefault();
    }
  }

  static Future<void> saveState(WeightStateModel state) async {
    try {
      final box = _getBox();
      if (box == null) {
        print('WeightStateService: Box not available for saving');
        return;
      }

      await box.put(_stateKey, state);
      print('WeightStateService: State saved successfully');
    } catch (e) {
      print('WeightStateService: Error saving state: $e');
    }
  }

  static Future<void> clearState() async {
    try {
      final box = _getBox();
      if (box == null) {
        print('WeightStateService: Box not available for clearing');
        return;
      }

      await box.delete(_stateKey);
      print('WeightStateService: State cleared successfully');
    } catch (e) {
      print('WeightStateService: Error clearing state: $e');
    }
  }

  static Future<bool> hasState() async {
    try {
      final box = _getBox();
      if (box == null) return false;
      return box.containsKey(_stateKey);
    } catch (e) {
      print('WeightStateService: Error checking state existence: $e');
      return false;
    }
  }

  static Future<void> close() async {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        await Hive.box<WeightStateModel>(_boxName).close();
        print('WeightStateService: Box closed successfully');
      }
    } catch (e) {
      print('WeightStateService: Error closing box: $e');
    }
  }

  // Debug methods
  static Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final box = _getBox();
      if (box == null) {
        return {
          'status': 'Box not available',
          'hasState': false,
          'stateCount': 0,
        };
      }

      final hasState = box.containsKey(_stateKey);
      final state = hasState ? box.get(_stateKey) : null;

      return {
        'status': 'Available',
        'hasState': hasState,
        'stateCount': state?.cards.length ?? 0,
        'visibleUnits': state?.visibleUnits ?? [],
        'lastUpdated': state?.lastUpdated?.toIso8601String(),
        'boxKeys': box.keys.toList(),
        'boxLength': box.length,
      };
    } catch (e) {
      return {
        'status': 'Error',
        'error': e.toString(),
      };
    }
  }

  static Future<void> printDebugInfo() async {
    final debugInfo = await getDebugInfo();
    print('WeightStateService Debug Info:');
    debugInfo.forEach((key, value) {
      print('  $key: $value');
    });
  }
}
