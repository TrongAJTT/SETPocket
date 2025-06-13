import 'package:hive/hive.dart';

part 'length_state_model.g.dart';

@HiveType(typeId: 17)
class LengthCardState extends HiveObject {
  @HiveField(0)
  String unitCode;

  @HiveField(1)
  double amount;

  LengthCardState({
    required this.unitCode,
    required this.amount,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unitCode': unitCode,
      'amount': amount,
    };
  }

  // Create from JSON
  factory LengthCardState.fromJson(Map<String, dynamic> json) {
    return LengthCardState(
      unitCode: json['unitCode'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

@HiveType(typeId: 18)
class LengthStateModel extends HiveObject {
  @HiveField(0)
  List<LengthCardState> cards;

  @HiveField(1)
  List<String> visibleUnits;

  @HiveField(2)
  DateTime lastUpdated;

  LengthStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
  });

  // Create default state
  static LengthStateModel createDefault() {
    return LengthStateModel(
      cards: [
        LengthCardState(unitCode: 'meters', amount: 1.0),
      ],
      visibleUnits: ['kilometers', 'meters', 'miles'],
      lastUpdated: DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((card) => card.toJson()).toList(),
      'visibleUnits': visibleUnits,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create from JSON
  factory LengthStateModel.fromJson(Map<String, dynamic> json) {
    return LengthStateModel(
      cards: (json['cards'] as List)
          .map((cardJson) =>
              LengthCardState.fromJson(cardJson as Map<String, dynamic>))
          .toList(),
      visibleUnits: List<String>.from(json['visibleUnits'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
