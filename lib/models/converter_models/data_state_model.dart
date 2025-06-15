import 'package:hive/hive.dart';

part 'data_state_model.g.dart';

@HiveType(typeId: 34)
class DataCardState extends HiveObject {
  @HiveField(0)
  String unitCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<String>? visibleUnits;

  DataCardState({
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
      'visibleUnits': visibleUnits ?? ['kilobyte', 'megabyte', 'gigabyte'],
    };
  }

  // Create from JSON
  factory DataCardState.fromJson(Map<String, dynamic> json) {
    return DataCardState(
      unitCode: json['unitCode'] as String,
      amount: (json['amount'] as num).toDouble(),
      name: json['name'] as String?,
      visibleUnits: json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'])
          : null,
    );
  }
}

@HiveType(typeId: 35)
class DataStateModel extends HiveObject {
  @HiveField(0)
  List<DataCardState> cards;

  @HiveField(1)
  List<String> visibleUnits;

  @HiveField(2)
  DateTime lastUpdated;

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
  String viewMode; // Store as string for Hive compatibility

  DataStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
    this.isFocusMode = false,
    this.viewMode = 'cards',
  });

  // Create default state
  static DataStateModel createDefault() {
    return DataStateModel(
      cards: [
        DataCardState(
          unitCode: 'kilobyte',
          amount: 1024.0,
          name: 'Card 1',
          visibleUnits: [
            'kilobyte',
            'megabyte',
            'gigabyte',
          ],
        ),
      ],
      visibleUnits: [
        'kilobyte',
        'megabyte',
        'gigabyte',
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
  factory DataStateModel.fromJson(Map<String, dynamic> json) {
    return DataStateModel(
      cards: (json['cards'] as List)
          .map((cardJson) =>
              DataCardState.fromJson(cardJson as Map<String, dynamic>))
          .toList(),
      visibleUnits: List<String>.from(json['visibleUnits'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isFocusMode: json['isFocusMode'] ?? false,
      viewMode: json['viewMode'] ?? 'cards',
    );
  }
}
