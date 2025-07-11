import 'dart:convert';
import 'package:isar/isar.dart';

part 'unified_random_state.g.dart';

/// Unified random tools state model using a single collection
/// with tool-specific IDs for efficient storage and retrieval
@Collection()
class UnifiedRandomState {
  /// Tool identifier (e.g., "password", "number", "date", etc.)
  String toolId = '';

  /// JSON string containing the tool's state data
  String stateData = '{}';

  /// Last update timestamp
  DateTime lastUpdated = DateTime.now();

  /// Version for future migration compatibility
  int version = 1;

  /// Auto-generated Isar ID
  Id id = Isar.autoIncrement;

  UnifiedRandomState();

  UnifiedRandomState.create({
    required this.toolId,
    required this.stateData,
    DateTime? lastUpdated,
    this.version = 1,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Convert state data from JSON string to Map
  Map<String, dynamic> getStateAsMap() {
    try {
      return Map<String, dynamic>.from(
        jsonDecode(stateData),
      );
    } catch (e) {
      return {};
    }
  }

  /// Set state data from Map to JSON string
  void setStateFromMap(Map<String, dynamic> data) {
    stateData = jsonEncode(data);
    lastUpdated = DateTime.now();
  }

  /// Create a copy with updated data
  UnifiedRandomState copyWith({
    String? toolId,
    String? stateData,
    DateTime? lastUpdated,
    int? version,
  }) {
    return UnifiedRandomState.create(
      toolId: toolId ?? this.toolId,
      stateData: stateData ?? this.stateData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      version: version ?? this.version,
    );
  }
}

/// Tool IDs constants for consistent naming
class RandomToolIds {
  static const String password = 'password';
  static const String number = 'number';
  static const String latinLetter = 'latin_letter';
  static const String diceRoll = 'dice_roll';
  static const String playingCard = 'playing_card';
  static const String color = 'color';
  static const String date = 'date';
  static const String time = 'time';
  static const String dateTime = 'date_time';
  static const String uuid = 'uuid';
  static const String coinFlip = 'coin_flip';
  static const String yesNo = 'yes_no';
  static const String rockPaperScissors = 'rock_paper_scissors';

  /// Get all available tool IDs
  static List<String> getAllToolIds() {
    return [
      password,
      number,
      latinLetter,
      diceRoll,
      playingCard,
      color,
      date,
      time,
      dateTime,
      uuid,
      coinFlip,
      yesNo,
      rockPaperScissors,
    ];
  }
}
