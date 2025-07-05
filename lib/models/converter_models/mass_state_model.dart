import 'package:isar/isar.dart';

part 'mass_state_model.g.dart';

@embedded
class MassCardState {
  String? unitCode;
  double? amount;
  String? name;
  List<String>? visibleUnits;
  DateTime? createdAt;

  MassCardState({
    this.unitCode,
    this.amount,
    this.name,
    this.visibleUnits,
    this.createdAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unitCode': unitCode,
      'amount': amount,
      'name': name ?? 'Card 1',
      'visibleUnits':
          visibleUnits ?? ['kilograms', 'grams', 'pounds', 'ounces'],
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory MassCardState.fromJson(Map<String, dynamic> json) {
    return MassCardState(
      unitCode: json['unitCode'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      name: json['name'] as String?,
      visibleUnits: json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MassCardState(unitCode: $unitCode, amount: $amount, name: $name)';
  }
}

@Collection()
class MassStateModel {
  Id id = Isar.autoIncrement;

  List<MassCardState> cards = [];
  List<String> visibleUnits = [];
  DateTime? lastUpdated;
  bool isFocusMode = false;
  String viewMode = 'cards'; // Store as string for compatibility

  MassStateModel();

  /// Create default state with common mass units
  static MassStateModel createDefault() {
    final model = MassStateModel()
      ..cards = [
        MassCardState(
          unitCode: 'kilograms',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'kilograms',
            'grams',
            'pounds',
            'ounces',
          ],
          createdAt: DateTime.now(),
        ),
      ]
      ..visibleUnits = [
        'kilograms',
        'grams',
        'pounds',
        'ounces',
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
  factory MassStateModel.fromJson(Map<String, dynamic> json) {
    final model = MassStateModel()
      ..cards = (json['cards'] as List?)
              ?.map((cardJson) =>
                  MassCardState.fromJson(cardJson as Map<String, dynamic>))
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

  @override
  String toString() {
    return 'MassStateModel(cards: $cards, visibleUnits: $visibleUnits, lastUpdated: $lastUpdated, isFocusMode: $isFocusMode, viewMode: $viewMode)';
  }
}
