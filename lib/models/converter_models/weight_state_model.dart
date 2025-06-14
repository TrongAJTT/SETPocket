import 'package:hive/hive.dart';

part 'weight_state_model.g.dart';

@HiveType(typeId: 20)
class WeightCardState extends HiveObject {
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

  WeightCardState({
    required this.unitCode,
    required this.amount,
    this.name,
    this.visibleUnits,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() {
    return 'WeightCardState(unitCode: $unitCode, amount: $amount, name: $name, visibleUnits: $visibleUnits, createdAt: $createdAt)';
  }
}

@HiveType(typeId: 21)
class WeightStateModel extends HiveObject {
  @HiveField(0)
  List<WeightCardState> cards;

  @HiveField(1)
  List<String> visibleUnits;

  @HiveField(2)
  DateTime lastUpdated;

  @HiveField(3)
  bool isFocusMode;

  @HiveField(4)
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

  @override
  String toString() {
    return 'WeightStateModel(cards: ${cards.length}, visibleUnits: ${visibleUnits.length}, lastUpdated: $lastUpdated, isFocusMode: $isFocusMode, viewMode: $viewMode)';
  }
}
