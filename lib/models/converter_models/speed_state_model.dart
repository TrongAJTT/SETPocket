import 'package:isar/isar.dart';

part 'speed_state_model.g.dart';

@embedded
class SpeedCardState {
  String? unitCode;
  double? amount;
  String? name;
  List<String>? visibleUnits;

  SpeedCardState({
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
      'visibleUnits': visibleUnits ??
          [
            'meters_per_second',
            'kilometers_per_hour',
            'miles_per_hour',
            'knots'
          ],
    };
  }

  // Create from JSON
  factory SpeedCardState.fromJson(Map<String, dynamic> json) {
    return SpeedCardState(
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
class SpeedStateModel {
  Id id = Isar.autoIncrement;

  List<SpeedCardState> cards = [];
  List<String> visibleUnits = [];
  DateTime? lastUpdated;
  bool isFocusMode = false;
  String viewMode = 'cards'; // Store as string for compatibility

  SpeedStateModel();

  // Create default state
  static SpeedStateModel createDefault() {
    final model = SpeedStateModel()
      ..cards = [
        SpeedCardState(
          unitCode: 'meters_per_second',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'meters_per_second',
            'kilometers_per_hour',
            'miles_per_hour',
            'knots',
          ],
        ),
      ]
      ..visibleUnits = [
        'meters_per_second',
        'kilometers_per_hour',
        'miles_per_hour',
        'knots',
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
  factory SpeedStateModel.fromJson(Map<String, dynamic> json) {
    final model = SpeedStateModel()
      ..cards = (json['cards'] as List?)
              ?.map((cardJson) =>
                  SpeedCardState.fromJson(cardJson as Map<String, dynamic>))
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
