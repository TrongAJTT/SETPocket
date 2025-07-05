import 'package:isar/isar.dart';

part 'length_state_model.g.dart';

@embedded
class LengthCardState {
  String? unitCode;
  double? amount;
  String? name;
  List<String>? visibleUnits;

  LengthCardState({
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
      'visibleUnits': visibleUnits ?? ['meter', 'inch', 'foot', 'yard'],
    };
  }

  // Create from JSON
  factory LengthCardState.fromJson(Map<String, dynamic> json) {
    return LengthCardState(
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
class LengthStateModel {
  Id id = Isar.autoIncrement;

  List<LengthCardState> cards = [];
  List<String> visibleUnits = [];
  DateTime? lastUpdated;
  bool isFocusMode = false;
  String viewMode = 'cards'; // Store as string for compatibility

  LengthStateModel();

  // Create default state
  static LengthStateModel createDefault() {
    final model = LengthStateModel()
      ..cards = [
        LengthCardState(
          unitCode: 'meter',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'meter',
            'inch',
            'foot',
            'yard',
          ],
        ),
      ]
      ..visibleUnits = [
        'meter',
        'inch',
        'foot',
        'yard',
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
  factory LengthStateModel.fromJson(Map<String, dynamic> json) {
    final model = LengthStateModel()
      ..cards = (json['cards'] as List?)
              ?.map((cardJson) =>
                  LengthCardState.fromJson(cardJson as Map<String, dynamic>))
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
