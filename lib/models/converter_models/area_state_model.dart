import 'package:hive/hive.dart';

part 'area_state_model.g.dart';

@HiveType(typeId: 22)
class AreaCardState extends HiveObject {
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

  AreaCardState({
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

  factory AreaCardState.fromJson(Map<String, dynamic> json) {
    return AreaCardState(
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

@HiveType(typeId: 23)
class AreaStateModel extends HiveObject {
  @HiveField(0)
  List<AreaCardState> cards;

  @HiveField(1)
  List<String> visibleUnits;

  @HiveField(2)
  DateTime lastUpdated;

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
  String viewMode;

  AreaStateModel({
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

  factory AreaStateModel.fromJson(Map<String, dynamic> json) {
    return AreaStateModel(
      cards: (json['cards'] as List<dynamic>?)
              ?.map((cardJson) => AreaCardState.fromJson(cardJson))
              .toList() ??
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
