import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/models/random_models/random_state_models.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_service.dart';

class RandomStateService {
  // Keys for different random tools
  static const String _numberGeneratorKey = 'number_generator_state';
  static const String _passwordGeneratorKey = 'password_generator_state';
  static const String _dateGeneratorKey = 'date_generator_state';
  static const String _colorGeneratorKey = 'color_generator_state';
  static const String _dateTimeGeneratorKey = 'date_time_generator_state';
  static const String _timeGeneratorKey = 'time_generator_state';
  static const String _playingCardGeneratorKey = 'playing_card_generator_state';
  static const String _latinLetterGeneratorKey = 'latin_letter_generator_state';
  static const String _diceRollGeneratorKey = 'dice_roll_generator_state';
  static const String _yesNoGeneratorKey = 'yes_no_generator_state';
  static const String _coinFlipGeneratorKey = 'coin_flip_generator_state';
  static const String _rockPaperScissorsGeneratorKey =
      'rock_paper_scissors_generator_state';

  // Check if feature state saving is enabled
  static Future<bool> _isFeatureStateSavingEnabled() async {
    try {
      final settings = await SettingsService.getSettings();
      logInfo(
          'RandomStateService: Feature state saving enabled: ${settings.featureStateSavingEnabled}');
      return settings.featureStateSavingEnabled;
    } catch (e) {
      logError(
          'RandomStateService: Failed to get settings, using default enabled=true: $e');
      return true; // Default to enabled if error occurs
    }
  }

  // Number Generator State Management
  static Future<NumberGeneratorState> getNumberGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default number generator state');
        return NumberGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_numberGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return NumberGeneratorState.fromJson(json);
      }
      return NumberGeneratorState.createDefault();
    } catch (e) {
      logError('RandomStateService: Failed to get number generator state: $e');
      return NumberGeneratorState.createDefault();
    }
  }

  static Future<void> saveNumberGeneratorState(
      NumberGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping number generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_numberGeneratorKey, jsonString);
      logInfo('RandomStateService: Number generator state saved');
    } catch (e) {
      logError('RandomStateService: Failed to save number generator state: $e');
      rethrow;
    }
  }

  // Password Generator State Management
  static Future<PasswordGeneratorState> getPasswordGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default password generator state');
        return PasswordGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_passwordGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return PasswordGeneratorState.fromJson(json);
      }
      return PasswordGeneratorState.createDefault();
    } catch (e) {
      logError(
          'RandomStateService: Failed to get password generator state: $e');
      return PasswordGeneratorState.createDefault();
    }
  }

  static Future<void> savePasswordGeneratorState(
      PasswordGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping password generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_passwordGeneratorKey, jsonString);
      logInfo('RandomStateService: Password generator state saved');
    } catch (e) {
      logError(
          'RandomStateService: Failed to save password generator state: $e');
      rethrow;
    }
  }

  // Date Generator State Management
  static Future<DateGeneratorState> getDateGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default date generator state');
        return DateGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_dateGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return DateGeneratorState.fromJson(json);
      }
      return DateGeneratorState.createDefault();
    } catch (e) {
      logError('RandomStateService: Failed to get date generator state: $e');
      return DateGeneratorState.createDefault();
    }
  }

  static Future<void> saveDateGeneratorState(DateGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping date generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_dateGeneratorKey, jsonString);
      logInfo('RandomStateService: Date generator state saved');
    } catch (e) {
      logError('RandomStateService: Failed to save date generator state: $e');
      rethrow;
    }
  }

  // Color Generator State Management
  static Future<ColorGeneratorState> getColorGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default color generator state');
        return ColorGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_colorGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return ColorGeneratorState.fromJson(json);
      }
      return ColorGeneratorState.createDefault();
    } catch (e) {
      logError('RandomStateService: Failed to get color generator state: $e');
      return ColorGeneratorState.createDefault();
    }
  }

  static Future<void> saveColorGeneratorState(ColorGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping color generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_colorGeneratorKey, jsonString);
      logInfo('RandomStateService: Color generator state saved');
    } catch (e) {
      logError('RandomStateService: Failed to save color generator state: $e');
      rethrow;
    }
  }

  // Date Time Generator State Management
  static Future<DateTimeGeneratorState> getDateTimeGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default date time generator state');
        return DateTimeGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_dateTimeGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return DateTimeGeneratorState.fromJson(json);
      }
      return DateTimeGeneratorState.createDefault();
    } catch (e) {
      logError(
          'RandomStateService: Failed to get date time generator state: $e');
      return DateTimeGeneratorState.createDefault();
    }
  }

  static Future<void> saveDateTimeGeneratorState(
      DateTimeGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping date time generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_dateTimeGeneratorKey, jsonString);
      logInfo('RandomStateService: Date time generator state saved');
    } catch (e) {
      logError(
          'RandomStateService: Failed to save date time generator state: $e');
      rethrow;
    }
  }

  // Time Generator State Management
  static Future<TimeGeneratorState> getTimeGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default time generator state');
        return TimeGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_timeGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return TimeGeneratorState.fromJson(json);
      }
      return TimeGeneratorState.createDefault();
    } catch (e) {
      logError('RandomStateService: Failed to get time generator state: $e');
      return TimeGeneratorState.createDefault();
    }
  }

  static Future<void> saveTimeGeneratorState(TimeGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping time generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_timeGeneratorKey, jsonString);
      logInfo('RandomStateService: Time generator state saved');
    } catch (e) {
      logError('RandomStateService: Failed to save time generator state: $e');
      rethrow;
    }
  }

  // Playing Card Generator State Management
  static Future<PlayingCardGeneratorState>
      getPlayingCardGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default playing card generator state');
        return PlayingCardGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_playingCardGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return PlayingCardGeneratorState.fromJson(json);
      }
      return PlayingCardGeneratorState.createDefault();
    } catch (e) {
      logError(
          'RandomStateService: Failed to get playing card generator state: $e');
      return PlayingCardGeneratorState.createDefault();
    }
  }

  static Future<void> savePlayingCardGeneratorState(
      PlayingCardGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping playing card generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_playingCardGeneratorKey, jsonString);
      logInfo('RandomStateService: Playing card generator state saved');
    } catch (e) {
      logError(
          'RandomStateService: Failed to save playing card generator state: $e');
      rethrow;
    }
  }

  // Latin Letter Generator State Management
  static Future<LatinLetterGeneratorState>
      getLatinLetterGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default latin letter generator state');
        return LatinLetterGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_latinLetterGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return LatinLetterGeneratorState.fromJson(json);
      }
      return LatinLetterGeneratorState.createDefault();
    } catch (e) {
      logError(
          'RandomStateService: Failed to get latin letter generator state: $e');
      return LatinLetterGeneratorState.createDefault();
    }
  }

  static Future<void> saveLatinLetterGeneratorState(
      LatinLetterGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping latin letter generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_latinLetterGeneratorKey, jsonString);
      logInfo('RandomStateService: Latin letter generator state saved');
    } catch (e) {
      logError(
          'RandomStateService: Failed to save latin letter generator state: $e');
      rethrow;
    }
  }

  // Dice Roll Generator State Management
  static Future<DiceRollGeneratorState> getDiceRollGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default dice roll generator state');
        return DiceRollGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_diceRollGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return DiceRollGeneratorState.fromJson(json);
      }
      return DiceRollGeneratorState.createDefault();
    } catch (e) {
      logError(
          'RandomStateService: Failed to get dice roll generator state: $e');
      return DiceRollGeneratorState.createDefault();
    }
  }

  static Future<void> saveDiceRollGeneratorState(
      DiceRollGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping dice roll generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_diceRollGeneratorKey, jsonString);
      logInfo('RandomStateService: Dice roll generator state saved');
    } catch (e) {
      logError(
          'RandomStateService: Failed to save dice roll generator state: $e');
      rethrow;
    }
  }

  // Simple Generators (Yes/No, Coin Flip, Rock Paper Scissors)
  static Future<SimpleGeneratorState> getYesNoGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default yes no generator state');
        return SimpleGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_yesNoGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return SimpleGeneratorState.fromJson(json);
      }
      return SimpleGeneratorState.createDefault();
    } catch (e) {
      logError('RandomStateService: Failed to get yes no generator state: $e');
      return SimpleGeneratorState.createDefault();
    }
  }

  static Future<void> saveYesNoGeneratorState(
      SimpleGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping yes no generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_yesNoGeneratorKey, jsonString);
      logInfo('RandomStateService: Yes no generator state saved');
    } catch (e) {
      logError('RandomStateService: Failed to save yes no generator state: $e');
      rethrow;
    }
  }

  static Future<SimpleGeneratorState> getCoinFlipGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default coin flip generator state');
        return SimpleGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_coinFlipGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return SimpleGeneratorState.fromJson(json);
      }
      return SimpleGeneratorState.createDefault();
    } catch (e) {
      logError(
          'RandomStateService: Failed to get coin flip generator state: $e');
      return SimpleGeneratorState.createDefault();
    }
  }

  static Future<void> saveCoinFlipGeneratorState(
      SimpleGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping coin flip generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_coinFlipGeneratorKey, jsonString);
      logInfo('RandomStateService: Coin flip generator state saved');
    } catch (e) {
      logError(
          'RandomStateService: Failed to save coin flip generator state: $e');
      rethrow;
    }
  }

  static Future<SimpleGeneratorState>
      getRockPaperScissorsGeneratorState() async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State loading disabled, returning default rock paper scissors generator state');
        return SimpleGeneratorState.createDefault();
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_rockPaperScissorsGeneratorKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return SimpleGeneratorState.fromJson(json);
      }
      return SimpleGeneratorState.createDefault();
    } catch (e) {
      logError(
          'RandomStateService: Failed to get rock paper scissors generator state: $e');
      return SimpleGeneratorState.createDefault();
    }
  }

  static Future<void> saveRockPaperScissorsGeneratorState(
      SimpleGeneratorState state) async {
    try {
      // Check if feature state saving is enabled
      final enabled = await _isFeatureStateSavingEnabled();
      if (!enabled) {
        logInfo(
            'RandomStateService: State saving disabled, skipping rock paper scissors generator state save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_rockPaperScissorsGeneratorKey, jsonString);
      logInfo('RandomStateService: Rock paper scissors generator state saved');
    } catch (e) {
      logError(
          'RandomStateService: Failed to save rock paper scissors generator state: $e');
      rethrow;
    }
  }

  // Utility methods
  static Future<bool> hasState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return getAllStateKeys().any((key) => prefs.containsKey(key));
    } catch (e) {
      logError('RandomStateService: Failed to check if has state: $e');
      return false;
    }
  }

  static Future<int> getStateSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int totalSize = 0;

      for (final key in getAllStateKeys()) {
        final value = prefs.getString(key);
        if (value != null) {
          totalSize += value.length * 2; // UTF-16 encoding
        }
      }

      return totalSize;
    } catch (e) {
      logError('RandomStateService: Failed to get state size: $e');
      return 0;
    }
  }

  static Future<void> clearAllStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final key in getAllStateKeys()) {
        await prefs.remove(key);
      }

      logInfo('RandomStateService: All states cleared');
    } catch (e) {
      logError('RandomStateService: Failed to clear all states: $e');
      rethrow;
    }
  }

  static List<String> getAllStateKeys() {
    return [
      _numberGeneratorKey,
      _passwordGeneratorKey,
      _dateGeneratorKey,
      _colorGeneratorKey,
      _dateTimeGeneratorKey,
      _timeGeneratorKey,
      _playingCardGeneratorKey,
      _latinLetterGeneratorKey,
      _diceRollGeneratorKey,
      _yesNoGeneratorKey,
      _coinFlipGeneratorKey,
      _rockPaperScissorsGeneratorKey,
    ];
  }
}
