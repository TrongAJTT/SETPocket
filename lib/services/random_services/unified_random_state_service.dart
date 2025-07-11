import 'dart:convert';
import 'package:setpocket/models/random_models/unified_random_state.dart';
import 'package:setpocket/models/random_models/random_state_models.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/settings_models_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:isar/isar.dart';

/// New optimized service for managing random tools state using UnifiedRandomState
class UnifiedRandomStateService {
  /// Initialize the service
  static Future<void> initialize() async {
    logInfo(
        'UnifiedRandomStateService: Initialize completed with unified Isar model');
  }

  /// Helper method to check if state saving is enabled
  static Future<bool> _isStateSavingEnabled() async {
    try {
      final settings = await ExtensibleSettingsService.getRandomToolsSettings();
      return settings.saveRandomToolsState;
    } catch (e) {
      logError(
          'UnifiedRandomStateService: Error checking state saving setting: $e');
      return true; // Default to enabled if error
    }
  }

  /// Generic save method that uses toolId as unique identifier
  static Future<void> _saveState(
      String toolId, Map<String, dynamic> stateData) async {
    try {
      final isEnabled = await _isStateSavingEnabled();
      if (!isEnabled) {
        logInfo(
            'UnifiedRandomStateService: State saving is disabled, skipping save for $toolId');
        return;
      }

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        // First, try to find existing record
        final existing = await isar
            .collection<UnifiedRandomState>()
            .filter()
            .toolIdEqualTo(toolId)
            .findFirst();

        if (existing != null) {
          // Update existing record
          existing.setStateFromMap(stateData);
          await isar.collection<UnifiedRandomState>().put(existing);
          logInfo(
              'UnifiedRandomStateService: Updated existing state for $toolId');
        } else {
          // Create new record
          final newState = UnifiedRandomState.create(
            toolId: toolId,
            stateData: jsonEncode(stateData),
          );
          await isar.collection<UnifiedRandomState>().put(newState);
          logInfo('UnifiedRandomStateService: Created new state for $toolId');
        }
      });
    } catch (e) {
      logError('UnifiedRandomStateService: Error saving state for $toolId: $e');
    }
  }

  /// Generic load method that retrieves state by toolId
  static Future<Map<String, dynamic>> _loadState(String toolId) async {
    try {
      final isar = IsarService.isar;
      final state = await isar
          .collection<UnifiedRandomState>()
          .filter()
          .toolIdEqualTo(toolId)
          .findFirst();

      if (state != null) {
        logInfo(
            'UnifiedRandomStateService: Successfully loaded state for $toolId');
        return state.getStateAsMap();
      } else {
        logInfo('UnifiedRandomStateService: No saved state found for $toolId');
        return {};
      }
    } catch (e) {
      logError(
          'UnifiedRandomStateService: Error loading state for $toolId: $e');
      return {};
    }
  }

  // Password Generator
  static Future<void> savePasswordGeneratorState(
      PasswordGeneratorState state) async {
    await _saveState(RandomToolIds.password, state.toJson());
  }

  static Future<PasswordGeneratorState> getPasswordGeneratorState() async {
    final data = await _loadState(RandomToolIds.password);
    return data.isEmpty
        ? PasswordGeneratorState.createDefault()
        : PasswordGeneratorState.fromJson(data);
  }

  // Number Generator
  static Future<void> saveNumberGeneratorState(
      NumberGeneratorState state) async {
    await _saveState(RandomToolIds.number, state.toJson());
  }

  static Future<NumberGeneratorState> getNumberGeneratorState() async {
    final data = await _loadState(RandomToolIds.number);
    return data.isEmpty
        ? NumberGeneratorState.createDefault()
        : NumberGeneratorState.fromJson(data);
  }

  // Latin Letter Generator
  static Future<void> saveLatinLetterGeneratorState(
      LatinLetterGeneratorState state) async {
    await _saveState(RandomToolIds.latinLetter, state.toJson());
  }

  static Future<LatinLetterGeneratorState>
      getLatinLetterGeneratorState() async {
    final data = await _loadState(RandomToolIds.latinLetter);
    return data.isEmpty
        ? LatinLetterGeneratorState.createDefault()
        : LatinLetterGeneratorState.fromJson(data);
  }

  // Dice Roll Generator
  static Future<void> saveDiceRollGeneratorState(
      DiceRollGeneratorState state) async {
    await _saveState(RandomToolIds.diceRoll, state.toJson());
  }

  static Future<DiceRollGeneratorState> getDiceRollGeneratorState() async {
    final data = await _loadState(RandomToolIds.diceRoll);
    return data.isEmpty
        ? DiceRollGeneratorState.createDefault()
        : DiceRollGeneratorState.fromJson(data);
  }

  // Playing Card Generator
  static Future<void> savePlayingCardGeneratorState(
      PlayingCardGeneratorState state) async {
    await _saveState(RandomToolIds.playingCard, state.toJson());
  }

  static Future<PlayingCardGeneratorState>
      getPlayingCardGeneratorState() async {
    final data = await _loadState(RandomToolIds.playingCard);
    return data.isEmpty
        ? PlayingCardGeneratorState.createDefault()
        : PlayingCardGeneratorState.fromJson(data);
  }

  // Color Generator
  static Future<void> saveColorGeneratorState(ColorGeneratorState state) async {
    await _saveState(RandomToolIds.color, state.toJson());
  }

  static Future<ColorGeneratorState> getColorGeneratorState() async {
    final data = await _loadState(RandomToolIds.color);
    return data.isEmpty
        ? ColorGeneratorState.createDefault()
        : ColorGeneratorState.fromJson(data);
  }

  // Date Generator
  static Future<void> saveDateGeneratorState(DateGeneratorState state) async {
    await _saveState(RandomToolIds.date, state.toJson());
  }

  static Future<DateGeneratorState> getDateGeneratorState() async {
    final data = await _loadState(RandomToolIds.date);
    return data.isEmpty
        ? DateGeneratorState.createDefault()
        : DateGeneratorState.fromJson(data);
  }

  // Time Generator
  static Future<void> saveTimeGeneratorState(TimeGeneratorState state) async {
    await _saveState(RandomToolIds.time, state.toJson());
  }

  static Future<TimeGeneratorState> getTimeGeneratorState() async {
    final data = await _loadState(RandomToolIds.time);
    return data.isEmpty
        ? TimeGeneratorState.createDefault()
        : TimeGeneratorState.fromJson(data);
  }

  // Date Time Generator
  static Future<void> saveDateTimeGeneratorState(
      DateTimeGeneratorState state) async {
    await _saveState(RandomToolIds.dateTime, state.toJson());
  }

  static Future<DateTimeGeneratorState> getDateTimeGeneratorState() async {
    final data = await _loadState(RandomToolIds.dateTime);
    return data.isEmpty
        ? DateTimeGeneratorState.createDefault()
        : DateTimeGeneratorState.fromJson(data);
  }

  // UUID Generator
  static Future<void> saveUuidGeneratorState(UuidGeneratorState state) async {
    await _saveState(RandomToolIds.uuid, state.toJson());
  }

  static Future<UuidGeneratorState> getUuidGeneratorState() async {
    final data = await _loadState(RandomToolIds.uuid);
    return data.isEmpty
        ? UuidGeneratorState.createDefault()
        : UuidGeneratorState.fromJson(data);
  }

  // Simple Generators (Coin Flip, Yes/No, Rock Paper Scissors)
  static Future<void> saveCoinFlipGeneratorState(
      SimpleGeneratorState state) async {
    await _saveState(RandomToolIds.coinFlip, state.toJson());
  }

  static Future<SimpleGeneratorState> getCoinFlipGeneratorState() async {
    final data = await _loadState(RandomToolIds.coinFlip);
    return data.isEmpty
        ? SimpleGeneratorState.createDefault()
        : SimpleGeneratorState.fromJson(data);
  }

  static Future<void> saveYesNoGeneratorState(
      SimpleGeneratorState state) async {
    await _saveState(RandomToolIds.yesNo, state.toJson());
  }

  static Future<SimpleGeneratorState> getYesNoGeneratorState() async {
    final data = await _loadState(RandomToolIds.yesNo);
    return data.isEmpty
        ? SimpleGeneratorState.createDefault()
        : SimpleGeneratorState.fromJson(data);
  }

  static Future<void> saveRockPaperScissorsGeneratorState(
      SimpleGeneratorState state) async {
    await _saveState(RandomToolIds.rockPaperScissors, state.toJson());
  }

  static Future<SimpleGeneratorState>
      getRockPaperScissorsGeneratorState() async {
    final data = await _loadState(RandomToolIds.rockPaperScissors);
    return data.isEmpty
        ? SimpleGeneratorState.createDefault()
        : SimpleGeneratorState.fromJson(data);
  }

  // Clear all states
  static Future<void> clearAllStates() async {
    try {
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.collection<UnifiedRandomState>().clear();
      });
      logInfo('UnifiedRandomStateService: Cleared all states');
    } catch (e) {
      logError('UnifiedRandomStateService: Error clearing states: $e');
    }
  }

  // Clear specific state by tool ID
  static Future<void> clearStateByToolId(String toolId) async {
    try {
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        final state = await isar
            .collection<UnifiedRandomState>()
            .filter()
            .toolIdEqualTo(toolId)
            .findFirst();
        if (state != null) {
          await isar.collection<UnifiedRandomState>().delete(state.id);
        }
      });
      logDebug('UnifiedRandomStateService: Cleared state for tool: $toolId');
    } catch (e) {
      logError(
          'UnifiedRandomStateService: Error clearing state for tool: $toolId: $e');
    }
  }

  // Check if any state exists
  static Future<bool> hasState() async {
    try {
      final isar = IsarService.isar;
      final count = await isar.collection<UnifiedRandomState>().count();
      return count > 0;
    } catch (e) {
      logError('UnifiedRandomStateService: Error checking state existence: $e');
      return false;
    }
  }

  // Get total count of all states
  static Future<int> getStateCount() async {
    try {
      final isar = IsarService.isar;
      return await isar.collection<UnifiedRandomState>().count();
    } catch (e) {
      logError('UnifiedRandomStateService: Error calculating state count: $e');
      return 0;
    }
  }

  // Get all available tool IDs that have saved states
  static Future<List<String>> getSavedToolIds() async {
    try {
      final isar = IsarService.isar;
      final states =
          await isar.collection<UnifiedRandomState>().where().findAll();
      return states.map((state) => state.toolId).toList();
    } catch (e) {
      logError('UnifiedRandomStateService: Error getting saved tool IDs: $e');
      return [];
    }
  }

  // Get all available tool IDs (for cache service compatibility)
  static List<String> getAllToolIds() {
    return RandomToolIds.getAllToolIds();
  }

  // Get state info for debugging
  static Future<Map<String, dynamic>> getStateInfo() async {
    try {
      final isar = IsarService.isar;
      final states =
          await isar.collection<UnifiedRandomState>().where().findAll();

      final Map<String, dynamic> info = {};
      for (final state in states) {
        info[state.toolId] = {
          'lastUpdated': state.lastUpdated.toIso8601String(),
          'version': state.version,
          'hasData': state.stateData.isNotEmpty,
        };
      }

      return info;
    } catch (e) {
      logError('UnifiedRandomStateService: Error getting state info: $e');
      return {};
    }
  }
}
