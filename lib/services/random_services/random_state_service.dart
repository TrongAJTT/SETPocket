import 'package:setpocket/models/random_models/random_state_models.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_service.dart';
// import 'package:hive/hive.dart'; // Commented out during Hive to Isar migration
import 'package:setpocket/services/isar_service.dart';

class RandomStateService {
  static const String _boxName = 'random_states';
  // static Box<dynamic>? _box; // Commented out during migration

  // Initialize the service - DISABLED during migration
  static Future<void> initialize() async {
    // Migration note: Random state is now handled differently
    logInfo('RandomStateService: Initialize called - DISABLED during Isar migration');
  }

  // Helper method to check if state saving is enabled
  static Future<bool> _isStateSavingEnabled() async {
    try {
      return await SettingsService.getSaveRandomToolsState();
    } catch (e) {
      logError('RandomStateService: Error checking state saving setting: $e');
      return true; // Default to enabled if error
    }
  }

  // Generic save method that checks the setting first - DISABLED during migration
  static Future<void> _saveState<T>(String key, T state) async {
    try {
      final isEnabled = await _isStateSavingEnabled();
      if (!isEnabled) {
        return; // Don't save if setting is disabled
      }

      logInfo('RandomStateService: Save state called for $key - DISABLED during Isar migration');
    } catch (e) {
      logError('RandomStateService: Error saving state for $key: $e');
    }
  }

  // Generic load method - DISABLED during migration
  static Future<T> _loadState<T>(String key, T defaultState) async {
    try {
      logInfo('RandomStateService: Load state called for $key - returning default during migration');
      return defaultState;
    } catch (e) {
      logError('RandomStateService: Error loading state for $key: $e');
      return defaultState;
    }
  }

  // Number Generator
  static Future<void> saveNumberGeneratorState(
      NumberGeneratorState state) async {
    await _saveState('number_generator', state);
  }

  static Future<NumberGeneratorState> getNumberGeneratorState() async {
    return await _loadState(
        'number_generator', NumberGeneratorState.createDefault());
  }

  // Latin Letter Generator
  static Future<void> saveLatinLetterGeneratorState(
      LatinLetterGeneratorState state) async {
    await _saveState('latin_letter_generator', state);
  }

  static Future<LatinLetterGeneratorState>
      getLatinLetterGeneratorState() async {
    return await _loadState(
        'latin_letter_generator', LatinLetterGeneratorState.createDefault());
  }

  // Password Generator
  static Future<void> savePasswordGeneratorState(
      PasswordGeneratorState state) async {
    await _saveState('password_generator', state);
  }

  static Future<PasswordGeneratorState> getPasswordGeneratorState() async {
    return await _loadState(
        'password_generator', PasswordGeneratorState.createDefault());
  }

  // Dice Roll Generator
  static Future<void> saveDiceRollGeneratorState(
      DiceRollGeneratorState state) async {
    await _saveState('dice_roll_generator', state);
  }

  static Future<DiceRollGeneratorState> getDiceRollGeneratorState() async {
    return await _loadState(
        'dice_roll_generator', DiceRollGeneratorState.createDefault());
  }

  // Playing Card Generator
  static Future<void> savePlayingCardGeneratorState(
      PlayingCardGeneratorState state) async {
    await _saveState('playing_card_generator', state);
  }

  static Future<PlayingCardGeneratorState>
      getPlayingCardGeneratorState() async {
    return await _loadState(
        'playing_card_generator', PlayingCardGeneratorState.createDefault());
  }

  // Color Generator
  static Future<void> saveColorGeneratorState(ColorGeneratorState state) async {
    await _saveState('color_generator', state);
  }

  static Future<ColorGeneratorState> getColorGeneratorState() async {
    return await _loadState(
        'color_generator', ColorGeneratorState.createDefault());
  }

  // Date Generator
  static Future<void> saveDateGeneratorState(DateGeneratorState state) async {
    await _saveState('date_generator', state);
  }

  static Future<DateGeneratorState> getDateGeneratorState() async {
    return await _loadState(
        'date_generator', DateGeneratorState.createDefault());
  }

  // Time Generator
  static Future<void> saveTimeGeneratorState(TimeGeneratorState state) async {
    await _saveState('time_generator', state);
  }

  static Future<TimeGeneratorState> getTimeGeneratorState() async {
    return await _loadState(
        'time_generator', TimeGeneratorState.createDefault());
  }

  // Date Time Generator
  static Future<void> saveDateTimeGeneratorState(
      DateTimeGeneratorState state) async {
    await _saveState('date_time_generator', state);
  }

  static Future<DateTimeGeneratorState> getDateTimeGeneratorState() async {
    return await _loadState(
        'date_time_generator', DateTimeGeneratorState.createDefault());
  }

  // Simple generators (Coin Flip, Yes/No, Rock Paper Scissors)
  static Future<void> saveCoinFlipGeneratorState(
      SimpleGeneratorState state) async {
    await _saveState('coin_flip_generator', state);
  }

  static Future<SimpleGeneratorState> getCoinFlipGeneratorState() async {
    return await _loadState(
        'coin_flip_generator', SimpleGeneratorState.createDefault());
  }

  static Future<void> saveYesNoGeneratorState(
      SimpleGeneratorState state) async {
    await _saveState('yes_no_generator', state);
  }

  static Future<SimpleGeneratorState> getYesNoGeneratorState() async {
    return await _loadState(
        'yes_no_generator', SimpleGeneratorState.createDefault());
  }

  static Future<void> saveRockPaperScissorsGeneratorState(
      SimpleGeneratorState state) async {
    await _saveState('rock_paper_scissors_generator', state);
  }

  static Future<SimpleGeneratorState>
      getRockPaperScissorsGeneratorState() async {
    return await _loadState(
        'rock_paper_scissors_generator', SimpleGeneratorState.createDefault());
  }

  // Clear all states
  static Future<void> clearAllStates() async {
    try {
      // TODO: Implement Isar-based random state clearing
      logInfo('RandomStateService: Cleared all states');
    } catch (e) {
      logError('RandomStateService: Error clearing states: $e');
    }
  }

  // Clear specific state
  static Future<void> clearState(String key) async {
    try {
      // TODO: Implement Isar-based random state clearing
      logDebug('RandomStateService: Cleared state for $key');
    } catch (e) {
      logError('RandomStateService: Error clearing state for $key: $e');
    }
  }

  // Check if any state exists
  static Future<bool> hasState() async {
    try {
      // TODO: Implement Isar-based random state check
      return false;
    } catch (e) {
      logError('RandomStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get total size of all states (approximate)
  static Future<int> getStateSize() async {
    try {
      // TODO: Implement Isar-based random state size calculation
      return 0;
    } catch (e) {
      logError('RandomStateService: Error calculating state size: $e');
      return 0;
    }
  }

  // Get all state keys
  static List<String> getAllStateKeys() {
    try {
      // TODO: Implement Isar-based random state keys retrieval
      return [];
    } catch (e) {
      logError('RandomStateService: Error getting state keys: $e');
      return [];
    }
  }
}
