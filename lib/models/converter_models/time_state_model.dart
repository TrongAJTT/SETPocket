import 'package:isar/isar.dart';

part 'time_state_model.g.dart';

@embedded
class TimeCardState {
  String unitCode;

  double amount;

  String? name;

  List<String>? visibleUnits;

  DateTime createdAt;

  TimeCardState({
    this.unitCode = 'seconds',
    this.amount = 0.0,
    this.name,
    this.visibleUnits,
  }) : createdAt = DateTime.now();

  Map<String, dynamic> toJson() => {
        'unitCode': unitCode,
        'amount': amount,
        'name': name,
        'visibleUnits': visibleUnits,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TimeCardState.fromJson(Map<String, dynamic> json) {
    final state = TimeCardState(
      unitCode: json['unitCode'] ?? 'seconds',
      amount: (json['amount'] ?? 0.0).toDouble(),
      name: json['name'],
      visibleUnits: json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'])
          : null,
    );
    // Set createdAt after creation if needed
    if (json['createdAt'] != null) {
      state.createdAt = DateTime.parse(json['createdAt']);
    }
    return state;
  }

  @override
  String toString() {
    return 'TimeCardState(unitCode: $unitCode, amount: $amount, name: $name, visibleUnits: $visibleUnits, createdAt: $createdAt)';
  }
}

@collection
class TimeStateModel {
  Id get isarId => fastHash('time_state');

  List<TimeCardState> cards;

  List<String> visibleUnits;

  DateTime lastUpdated;

  bool isFocusMode;

  String viewMode;

  TimeStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
    this.isFocusMode = false,
    this.viewMode = 'cards',
  });

  Map<String, dynamic> toJson() => {
        'cards': cards.map((card) => card.toJson()).toList(),
        'visibleUnits': visibleUnits,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isFocusMode': isFocusMode,
        'viewMode': viewMode,
      };

  factory TimeStateModel.fromJson(Map<String, dynamic> json) {
    return TimeStateModel(
      cards: (json['cards'] as List<dynamic>?)?.map((cardJson) {
            if (cardJson is TimeCardState) {
              return cardJson;
            } else if (cardJson is Map<String, dynamic>) {
              return TimeCardState.fromJson(cardJson);
            } else {
              // Handle Map<dynamic, dynamic> case
              return TimeCardState.fromJson(
                  Map<String, dynamic>.from(cardJson));
            }
          }).toList() ??
          [],
      visibleUnits: List<String>.from(json['visibleUnits'] ?? []),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      isFocusMode: json['isFocusMode'] ?? false,
      viewMode: json['viewMode'] ?? 'cards',
    );
  }
}

/// Fast hash function to generate Isar Id from String
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
