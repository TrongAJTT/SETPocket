import 'package:isar/isar.dart';

part 'temperature_state_model.g.dart';

@embedded
class TemperatureCardState {
  String? unitCode;
  double? amount;
  String? name;
  List<String>? visibleUnits;

  TemperatureCardState({
    this.unitCode,
    this.amount,
    this.name,
    this.visibleUnits,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unitCode': unitCode,
      'amount': amount,
      'name': name ?? 'Card 1',
      'visibleUnits': visibleUnits ?? ['celsius', 'fahrenheit', 'kelvin'],
    };
  }

  // Create from JSON
  factory TemperatureCardState.fromJson(Map<String, dynamic> json) {
    return TemperatureCardState(
      unitCode: json['unitCode'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      name: json['name'] as String?,
      visibleUnits: json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'])
          : null,
    );
  }
}

@Collection()
class TemperatureStateModel {
  Id id = Isar.autoIncrement;

  List<TemperatureCardState> cards = [];
  List<String> visibleUnits = [];
  DateTime? lastUpdated;
  bool isFocusMode = false;
  String viewMode = 'cards'; // Store as string for compatibility

  TemperatureStateModel();

  // Create default state
  static TemperatureStateModel createDefault() {
    final model = TemperatureStateModel()
      ..cards = [
        TemperatureCardState(
          unitCode: 'celsius',
          amount: 0.0,
          name: 'Card 1',
          visibleUnits: [
            'celsius',
            'fahrenheit',
            'kelvin',
          ],
        ),
      ]
      ..visibleUnits = [
        'celsius',
        'fahrenheit',
        'kelvin',
      ]
      ..lastUpdated = DateTime.now()
      ..isFocusMode = false
      ..viewMode = 'cards';
    return model;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((card) => card.toJson()).toList(),
      'visibleUnits': visibleUnits,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isFocusMode': isFocusMode,
      'viewMode': viewMode,
    };
  }

  // Create from JSON
  factory TemperatureStateModel.fromJson(Map<String, dynamic> json) {
    final model = TemperatureStateModel()
      ..cards = (json['cards'] as List?)
              ?.map((cardJson) => TemperatureCardState.fromJson(
                  cardJson as Map<String, dynamic>))
              .toList() ??
          []
      ..visibleUnits = json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'] as List)
          : []
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now()
      ..isFocusMode = json['isFocusMode'] ?? false
      ..viewMode = json['viewMode'] ?? 'cards';
    return model;
  }
}
