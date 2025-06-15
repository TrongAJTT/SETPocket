import 'package:hive/hive.dart';

part 'temperature_state_model.g.dart';

@HiveType(typeId: 32)
class TemperatureCardState extends HiveObject {
  @HiveField(0)
  String unitCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<String>? visibleUnits;

  TemperatureCardState({
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
      'visibleUnits': visibleUnits ?? ['celsius', 'fahrenheit'],
    };
  }

  // Create from JSON
  factory TemperatureCardState.fromJson(Map<String, dynamic> json) {
    return TemperatureCardState(
      unitCode: json['unitCode'] as String,
      amount: (json['amount'] as num).toDouble(),
      name: json['name'] as String?,
      visibleUnits: json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'])
          : null,
    );
  }
}

@HiveType(typeId: 33)
class TemperatureStateModel extends HiveObject {
  @HiveField(0)
  List<TemperatureCardState> cards;

  @HiveField(1)
  List<String> visibleUnits;

  @HiveField(2)
  DateTime lastUpdated;

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
  String viewMode; // Store as string for Hive compatibility

  TemperatureStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
    this.isFocusMode = false,
    this.viewMode = 'cards',
  });

  // Create default state
  static TemperatureStateModel createDefault() {
    return TemperatureStateModel(
      cards: [
        TemperatureCardState(
          unitCode: 'celsius',
          amount: 25.0,
          name: 'Card 1',
          visibleUnits: [
            'celsius',
            'fahrenheit',
          ],
        ),
      ],
      visibleUnits: [
        'celsius',
        'fahrenheit',
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
  factory TemperatureStateModel.fromJson(Map<String, dynamic> json) {
    return TemperatureStateModel(
      cards: (json['cards'] as List)
          .map((cardJson) =>
              TemperatureCardState.fromJson(cardJson as Map<String, dynamic>))
          .toList(),
      visibleUnits: List<String>.from(json['visibleUnits'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isFocusMode: json['isFocusMode'] ?? false,
      viewMode: json['viewMode'] ?? 'cards',
    );
  }
}
