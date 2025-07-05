import 'package:isar/isar.dart';

part 'volume_state_model.g.dart';

@embedded
class VolumeCardState {
  String? unitCode;
  double? amount;
  String? name;
  List<String>? visibleUnits;

  VolumeCardState({
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
      'visibleUnits': visibleUnits ?? ['cubic_meter', 'liter'],
    };
  }

  // Create from JSON
  factory VolumeCardState.fromJson(Map<String, dynamic> json) {
    return VolumeCardState(
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
class VolumeStateModel {
  Id id = Isar.autoIncrement;

  List<VolumeCardState> cards = [];
  List<String> visibleUnits = [];
  DateTime? lastUpdated;
  bool isFocusMode = false;
  String viewMode = 'cards'; // Store as string for compatibility

  VolumeStateModel();

  // Create default state
  static VolumeStateModel createDefault() {
    final model = VolumeStateModel()
      ..cards = [
        VolumeCardState(
          unitCode: 'cubic_meter',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'cubic_meter',
            'liter',
          ],
        ),
      ]
      ..visibleUnits = [
        'cubic_meter',
        'liter',
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
  factory VolumeStateModel.fromJson(Map<String, dynamic> json) {
    final model = VolumeStateModel()
      ..cards = (json['cards'] as List?)
              ?.map((cardJson) =>
                  VolumeCardState.fromJson(cardJson as Map<String, dynamic>))
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

  // Copy with method
  VolumeStateModel copyWith({
    List<VolumeCardState>? cards,
    List<String>? visibleUnits,
    DateTime? lastUpdated,
    bool? isFocusMode,
    String? viewMode,
  }) {
    return VolumeStateModel()
      ..cards = cards ?? this.cards
      ..visibleUnits = visibleUnits ?? this.visibleUnits
      ..lastUpdated = lastUpdated ?? this.lastUpdated
      ..isFocusMode = isFocusMode ?? this.isFocusMode
      ..viewMode = viewMode ?? this.viewMode;
  }
}
