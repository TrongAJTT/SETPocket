import 'package:hive/hive.dart';

part 'weight_state_model.g.dart';

@HiveType(typeId: 8)
class WeightCardState extends HiveObject {
  @HiveField(0)
  final String unitCode;

  @HiveField(1)
  final double amount;

  WeightCardState({
    required this.unitCode,
    required this.amount,
  });

  @override
  String toString() {
    return 'WeightCardState(unitCode: $unitCode, amount: $amount)';
  }
}

@HiveType(typeId: 9)
class WeightStateModel extends HiveObject {
  @HiveField(0)
  final List<WeightCardState> cards;

  @HiveField(1)
  final List<String> visibleUnits;

  @HiveField(2)
  final DateTime lastUpdated;

  WeightStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
  });

  // Create default state
  static WeightStateModel createDefault() {
    return WeightStateModel(
      cards: [
        WeightCardState(unitCode: 'kilograms', amount: 1.0),
      ],
      visibleUnits: ['kilograms', 'pounds', 'ounces'],
      lastUpdated: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'WeightStateModel(cards: $cards, visibleUnits: $visibleUnits, lastUpdated: $lastUpdated)';
  }
}
