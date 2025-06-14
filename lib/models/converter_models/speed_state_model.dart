import 'package:hive/hive.dart';

part 'speed_state_model.g.dart';

@HiveType(typeId: 30)
class SpeedCardState extends HiveObject {
  @HiveField(0)
  String unitCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<String>? visibleUnits;

  SpeedCardState({
    required this.unitCode,
    required this.amount,
    this.name,
    this.visibleUnits,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unitCode': unitCode,
      'amount': amount,
      'name': name ?? 'Card 1',
      'visibleUnits': visibleUnits ??
          ['kilometers_per_hour', 'meters_per_second', 'miles_per_hour'],
    };
  }

  // Create from JSON
  factory SpeedCardState.fromJson(Map<String, dynamic> json) {
    return SpeedCardState(
      unitCode: json['unitCode'] as String,
      amount: (json['amount'] as num).toDouble(),
      name: json['name'] as String?,
      visibleUnits: json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'])
          : null,
    );
  }
}

@HiveType(typeId: 31)
class SpeedStateModel extends HiveObject {
  @HiveField(0)
  List<SpeedCardState> cards;

  @HiveField(1)
  List<String> visibleUnits;

  @HiveField(2)
  DateTime lastUpdated;

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
  String viewMode; // Store as string for Hive compatibility

  SpeedStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
    this.isFocusMode = false,
    this.viewMode = 'cards',
  });

  // Create default state
  static SpeedStateModel createDefault() {
    return SpeedStateModel(
      cards: [
        SpeedCardState(
          unitCode: 'kilometers_per_hour',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'kilometers_per_hour',
            'meters_per_second',
            'miles_per_hour',
            'knots',
            'feet_per_second',
            'mach'
          ],
        ),
      ],
      visibleUnits: [
        'kilometers_per_hour',
        'meters_per_second',
        'miles_per_hour',
        'knots',
        'feet_per_second',
        'mach'
      ],
      lastUpdated: DateTime.now(),
      isFocusMode: false,
      viewMode: 'cards',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((card) => card.toJson()).toList(),
      'visibleUnits': visibleUnits,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isFocusMode': isFocusMode,
      'viewMode': viewMode,
    };
  }

  // Create from JSON
  factory SpeedStateModel.fromJson(Map<String, dynamic> json) {
    return SpeedStateModel(
      cards: (json['cards'] as List)
          .map((cardJson) =>
              SpeedCardState.fromJson(cardJson as Map<String, dynamic>))
          .toList(),
      visibleUnits: List<String>.from(json['visibleUnits'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isFocusMode: json['isFocusMode'] ?? false,
      viewMode: json['viewMode'] ?? 'cards',
    );
  }
}
