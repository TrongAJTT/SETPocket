import 'package:isar/isar.dart';

part 'area_state_model.g.dart';

@embedded
class AreaCardState {
  String? unitCode;
  double? amount;
  String? name;
  List<String>? visibleUnits;
  DateTime? createdAt;

  AreaCardState({
    this.unitCode,
    this.amount,
    this.name,
    this.visibleUnits,
    this.createdAt,
  });

  factory AreaCardState.create({
    required String unitCode,
    required double amount,
    String? name,
    List<String>? visibleUnits,
  }) {
    return AreaCardState(
      unitCode: unitCode,
      amount: amount,
      name: name,
      visibleUnits: visibleUnits,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'unitCode': unitCode,
        'amount': amount,
        'name': name,
        'visibleUnits': visibleUnits,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory AreaCardState.fromJson(Map<String, dynamic> json) {
    return AreaCardState(
      unitCode: json['unitCode'],
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

@Collection()
class AreaStateModel {
  Id id = Isar.autoIncrement;

  List<AreaCardState> cards = [];
  List<String> visibleUnits = [];
  DateTime? lastUpdated;
  bool isFocusMode = false;
  String viewMode = 'cards';

  AreaStateModel();

  Map<String, dynamic> toJson() => {
        'cards': cards.map((card) => card.toJson()).toList(),
        'visibleUnits': visibleUnits,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'isFocusMode': isFocusMode,
        'viewMode': viewMode,
      };

  factory AreaStateModel.fromJson(Map<String, dynamic> json) {
    final model = AreaStateModel()
      ..cards = (json['cards'] as List<dynamic>?)
              ?.map((cardJson) => AreaCardState.fromJson(cardJson))
              .toList() ??
          []
      ..visibleUnits = List<String>.from(json['visibleUnits'] ?? [])
      ..lastUpdated = json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now()
      ..isFocusMode = json['isFocusMode'] ?? false
      ..viewMode = json['viewMode'] ?? 'cards';
    return model;
  }
}
