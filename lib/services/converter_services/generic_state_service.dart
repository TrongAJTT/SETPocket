import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'converter_service_base.dart';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_service.dart';

class GenericStateService implements ConverterStateService {
  static const String _keyPrefix = 'converter_state_';

  // Check if feature state saving is enabled
  static Future<bool> _isFeatureStateSavingEnabled() async {
    try {
      final enabled = await SettingsService.getFeatureStateSaving();
      logInfo('GenericStateService: Feature state saving enabled: $enabled');
      return enabled;
    } catch (e) {
      logError(
          'GenericStateService: Error checking feature state saving settings: $e');
      // Default to enabled if error occurs
      return true;
    }
  }

  @override
  Future<void> saveState(String converterType, ConverterState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'GenericStateService: Feature state saving is disabled, skipping save for $converterType');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$converterType';
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(key, jsonString);
      logInfo('GenericStateService: Saved state for $converterType');
    } catch (e) {
      logError(
          'GenericStateService: Error saving state for $converterType: $e');
    }
  }

  @override
  Future<ConverterState> loadState(String converterType) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'GenericStateService: Feature state saving is disabled, returning default state for $converterType');
        return const ConverterState(
          cards: [],
          globalVisibleUnits: {},
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$converterType';
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final state = ConverterState.fromJson(json);
        logInfo(
            'GenericStateService: Loaded state for $converterType with ${state.cards.length} cards');
        return state;
      }
    } catch (e) {
      logError(
          'GenericStateService: Error loading state for $converterType: $e');
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
      logInfo('GenericStateService: Cleared state for $converterType');
    } catch (e) {
      logError(
          'GenericStateService: Error clearing state for $converterType: $e');
    }
  }
}
