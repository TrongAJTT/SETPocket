import 'package:isar/isar.dart';

part 'weight_state_model.g.dart';

@embedded
class WeightCardState {
  String unitCode;

  double amount;

  String? name;

  List<String>? visibleUnits;

  DateTime? createdAt;

  WeightCardState({
    this.unitCode = 'kilogram',
    this.amount = 0.0,
    this.name,
    this.visibleUnits,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() {
    return 'WeightCardState(unitCode: $unitCode, amount: $amount, name: $name, visibleUnits: $visibleUnits, createdAt: $createdAt)';
  }
}

@collection
class WeightStateModel {
  Id id = Isar.autoIncrement;

  List<WeightCardState> cards;

  List<String> visibleUnits;

  DateTime lastUpdated;

  bool isFocusMode;

  String viewMode;

  WeightStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
    required this.isFocusMode,
    required this.viewMode,
  });

  /// Create default weight state
  factory WeightStateModel.createDefault() {
    return WeightStateModel(
      cards: [
        WeightCardState(
          unitCode: 'newtons',
          amount: 1.0,
          name: 'Card 1',
          visibleUnits: [
            'newtons',
            'kilogram_force',
            'pound_force',
          ],
        ),
      ],
      visibleUnits: [
        'newtons',
        'kilogram_force',
        'pound_force',
      ],
      lastUpdated: DateTime.now(),
      isFocusMode: false,
      viewMode: 'cards',
    );
  }

  /// Copy with method
  WeightStateModel copyWith({
    List<WeightCardState>? cards,
    List<String>? visibleUnits,
    DateTime? lastUpdated,
    bool? isFocusMode,
    String? viewMode,
  }) {
    return WeightStateModel(
      cards: cards ?? this.cards,
      visibleUnits: visibleUnits ?? this.visibleUnits,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  String toString() {
    return 'WeightStateModel(cards: ${cards.length}, visibleUnits: ${visibleUnits.length}, lastUpdated: $lastUpdated, isFocusMode: $isFocusMode, viewMode: $viewMode)';
  }
}

/// Fast hash function to generate Isar Id from String
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
