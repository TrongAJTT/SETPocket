import 'package:isar/isar.dart';

part 'data_state_model.g.dart';

@embedded
class DataCardState {
  String? unitCode;
  double? amount;
  String? name;
  List<String>? visibleUnits;

  DataCardState({
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
      'visibleUnits': visibleUnits ?? ['kilobyte', 'megabyte', 'gigabyte'],
    };
  }

  // Create from JSON
  factory DataCardState.fromJson(Map<String, dynamic> json) {
    return DataCardState(
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
class DataStateModel {
  Id id = Isar.autoIncrement;

  List<DataCardState> cards = [];
  List<String> visibleUnits = [];
  DateTime? lastUpdated;
  bool isFocusMode = false;
  String viewMode = 'cards'; // Store as string for compatibility

  DataStateModel();

  // Create default state
  static DataStateModel createDefault() {
    final model = DataStateModel()
      ..cards = [
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
      ]
      ..visibleUnits = [
        'kilobyte',
        'megabyte',
        'gigabyte',
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
  factory DataStateModel.fromJson(Map<String, dynamic> json) {
    final model = DataStateModel()
      ..cards = (json['cards'] as List?)
              ?.map((cardJson) =>
                  DataCardState.fromJson(cardJson as Map<String, dynamic>))
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
