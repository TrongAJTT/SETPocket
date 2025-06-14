import 'package:hive/hive.dart';

part 'mass_state_model.g.dart';

@HiveType(typeId: 8)
class MassCardState extends HiveObject {
  @HiveField(0)
  String unitCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<String>? visibleUnits;

  @HiveField(4)
  DateTime? createdAt;

  MassCardState({
    required this.unitCode,
    required this.amount,
    this.name,
    this.visibleUnits,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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
      unitCode: json['unitCode'] as String,
      amount: (json['amount'] as num).toDouble(),
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

@HiveType(typeId: 9)
class MassStateModel extends HiveObject {
  @HiveField(0)
  List<MassCardState> cards;

  @HiveField(1)
  List<String> visibleUnits;

  @HiveField(2)
  DateTime lastUpdated;

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
  String viewMode; // Store as string for Hive compatibility

  MassStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
    this.isFocusMode = false,
    this.viewMode = 'cards',
  });

  /// Create default state with common mass units
  static MassStateModel createDefault() {
    return MassStateModel(
      cards: [
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
        ),
      ],
      visibleUnits: [
        'kilograms',
        'grams',
        'pounds',
        'ounces',
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
  factory MassStateModel.fromJson(Map<String, dynamic> json) {
    return MassStateModel(
      cards: (json['cards'] as List)
          .map((cardJson) =>
              MassCardState.fromJson(cardJson as Map<String, dynamic>))
          .toList(),
      visibleUnits: List<String>.from(json['visibleUnits'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isFocusMode: json['isFocusMode'] ?? false,
      viewMode: json['viewMode'] ?? 'cards',
    );
  }

  @override
  String toString() {
    return 'MassStateModel(cards: $cards, visibleUnits: $visibleUnits, lastUpdated: $lastUpdated, isFocusMode: $isFocusMode, viewMode: $viewMode)';
  }
}
