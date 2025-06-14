import 'package:hive/hive.dart';

part 'time_state_model.g.dart';

@HiveType(typeId: 24)
class TimeCardState extends HiveObject {
  @HiveField(0)
  String unitCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<String>? visibleUnits;

  @HiveField(4)
  DateTime createdAt;

  TimeCardState({
    required this.unitCode,
    required this.amount,
    this.name,
    this.visibleUnits,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'unitCode': unitCode,
        'amount': amount,
        'name': name,
        'visibleUnits': visibleUnits,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TimeCardState.fromJson(Map<String, dynamic> json) {
    return TimeCardState(
      unitCode: json['unitCode'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      name: json['name'],
      visibleUnits: json['visibleUnits'] != null
          ? List<String>.from(json['visibleUnits'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

@HiveType(typeId: 25)
class TimeStateModel extends HiveObject {
  @HiveField(0)
  List<TimeCardState> cards;

  @HiveField(1)
  List<String> visibleUnits;

  @HiveField(2)
  DateTime lastUpdated;

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
  String viewMode;

  TimeStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
    this.isFocusMode = false,
    this.viewMode = 'cards',
  });

  Map<String, dynamic> toJson() => {
        'cards': cards.map((card) => card.toJson()).toList(),
        'visibleUnits': visibleUnits,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isFocusMode': isFocusMode,
        'viewMode': viewMode,
      };

  factory TimeStateModel.fromJson(Map<String, dynamic> json) {
    return TimeStateModel(
      cards: (json['cards'] as List<dynamic>?)?.map((cardJson) {
            if (cardJson is TimeCardState) {
              return cardJson;
            } else if (cardJson is Map<String, dynamic>) {
              return TimeCardState.fromJson(cardJson);
            } else {
              // Handle Map<dynamic, dynamic> case
              return TimeCardState.fromJson(
                  Map<String, dynamic>.from(cardJson));
            }
          }).toList() ??
          [],
      visibleUnits: List<String>.from(json['visibleUnits'] ?? []),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      isFocusMode: json['isFocusMode'] ?? false,
      viewMode: json['viewMode'] ?? 'cards',
    );
  }
}
