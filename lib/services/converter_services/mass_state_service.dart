import 'package:hive_flutter/hive_flutter.dart';
import '../../models/mass_state_model.dart';

class MassStateService {
  static const String _boxName = 'mass_state';

  /// Get the mass state box
  static Future<Box<MassStateModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<MassStateModel>(_boxName);
    }
    return Hive.box<MassStateModel>(_boxName);
  }

  /// Load mass state from storage
  static Future<MassStateModel> loadState() async {
    try {
      final box = await _getBox();
      final state = box.get('current_state');

      if (state == null) {
        print('MassStateService: No saved state found, creating default');
        return MassStateModel.createDefault();
      }

      print('MassStateService: Loaded state with ${state.cards.length} cards');
      return state;
    } catch (e) {
      print('MassStateService: Error loading state: $e');
      return MassStateModel.createDefault();
    }
  }

  /// Save mass state to storage
  static Future<void> saveState(MassStateModel state) async {
    try {
      final box = await _getBox();
      await box.put('current_state', state);
      print('MassStateService: Saved state with ${state.cards.length} cards');
    } catch (e) {
      print('MassStateService: Error saving state: $e');
    }
  }

  /// Clear saved mass state
  static Future<void> clearState() async {
    try {
      final box = await _getBox();
      await box.delete('current_state');
      print('MassStateService: Cleared saved state');
    } catch (e) {
      print('MassStateService: Error clearing state: $e');
    }
  }

  /// Check if saved state exists
  static Future<bool> hasState() async {
    try {
      final box = await _getBox();
      return box.containsKey('current_state');
    } catch (e) {
      print('MassStateService: Error checking state: $e');
      return false;
    }
  }

  /// Get state size for cache management
  static Future<int> getStateSize() async {
    try {
      final box = await _getBox();
      final state = box.get('current_state');
      if (state == null) return 0;

      // Rough estimation: each card = ~100 bytes, each visible unit = ~20 bytes
      int size = state.cards.length * 100;
      size += state.visibleUnits.length * 20;
      size += 50; // metadata overhead

      return size;
    } catch (e) {
      print('MassStateService: Error calculating state size: $e');
      return 0;
    }
  }

  /// Debug: Print current state info
  static Future<void> debugPrintState() async {
    try {
      final box = await _getBox();
      final state = box.get('current_state');

      if (state == null) {
        print('MassStateService: No state found');
        return;
      }

      print('=== Mass State Debug Info ===');
      print('Cards: ${state.cards.length}');
      print('Visible units: ${state.visibleUnits}');
      print('Last updated: ${state.lastUpdated}');
      print('============================');
    } catch (e) {
      print('MassStateService: Error printing debug info: $e');
    }
  }
}
