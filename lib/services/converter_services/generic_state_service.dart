import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'converter_service_base.dart';
import '../../models/converter_base.dart';
import '../app_logger.dart';

class GenericStateService implements ConverterStateService {
  static const String _keyPrefix = 'converter_state_';

  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$converterType';
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(key, jsonString);
      logInfo('Saved state for $converterType');
    } catch (e) {
      logError('Error saving state for $converterType: $e');
    }
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$converterType';
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final state = ConverterState.fromJson(json);
        logInfo(
            'Loaded state for $converterType with ${state.cards.length} cards');
        return state;
      }
    } catch (e) {
      logError('Error loading state for $converterType: $e');
    }

    // Return empty state if no saved state or error
    return const ConverterState(
      cards: [],
      globalVisibleUnits: {},
    );
  }

  @override
  Future<void> clearState(String converterType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$converterType';
      await prefs.remove(key);
      logInfo('Cleared state for $converterType');
    } catch (e) {
      logError('Error clearing state for $converterType: $e');
    }
  }
}
