import 'package:hive/hive.dart';

part 'length_state_model.g.dart';

@HiveType(typeId: 17)
class LengthCardState extends HiveObject {
  @HiveField(0)
  String unitCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<String>? visibleUnits;

  LengthCardState({
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
          ['meter', 'kilometer', 'centimeter', 'millimeter', 'inch', 'foot'],
    };
  }

  // Create from JSON
  factory LengthCardState.fromJson(Map<String, dynamic> json) {
    return LengthCardState(
      unitCode: json['unitCode'] as String,
      amount: (json['amount'] as num).toDouble(),
      name: json['name'] as String?,
      visibleUnits: json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'])
          : null,
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

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
  String viewMode; // Store as string for Hive compatibility

  LengthStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
    this.isFocusMode = false,
    this.viewMode = 'cards',
  });

  // Create default state
  static LengthStateModel createDefault() {
    return LengthStateModel(
      cards: [
        LengthCardState(
          unitCode: 'meter',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'kilometer',
            'meter',
            'centimeter',
            'millimeter',
            'inch',
            'foot',
            'yard',
            'mile'
          ],
        ),
      ],
      visibleUnits: [
        'kilometer',
        'meter',
        'centimeter',
        'millimeter',
        'inch',
        'foot',
        'yard',
        'mile'
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
  factory LengthStateModel.fromJson(Map<String, dynamic> json) {
    return LengthStateModel(
      cards: (json['cards'] as List)
          .map((cardJson) =>
              LengthCardState.fromJson(cardJson as Map<String, dynamic>))
          .toList(),
      visibleUnits: List<String>.from(json['visibleUnits'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isFocusMode: json['isFocusMode'] ?? false,
      viewMode: json['viewMode'] ?? 'cards',
    );
  }
}
