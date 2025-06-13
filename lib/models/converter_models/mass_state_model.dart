import 'package:hive/hive.dart';

part 'mass_state_model.g.dart';

@HiveType(typeId: 8)
class MassCardState extends HiveObject {
  @HiveField(0)
  final String unitCode;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime createdAt;

  MassCardState({
    required this.unitCode,
    required this.amount,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() {
    return 'MassCardState(unitCode: $unitCode, amount: $amount)';
  }
}

@HiveType(typeId: 9)
class MassStateModel extends HiveObject {
  @HiveField(0)
  final List<MassCardState> cards;

  @HiveField(1)
  final List<String> visibleUnits;

  @HiveField(2)
  final DateTime lastUpdated;

  MassStateModel({
    required this.cards,
    required this.visibleUnits,
    required this.lastUpdated,
  });

  /// Create default state with common mass units
  static MassStateModel createDefault() {
    return MassStateModel(
      cards: [
        MassCardState(
          unitCode: 'kilograms',
          amount: 1.0,
        ),
      ],
      visibleUnits: ['kilograms', 'pounds', 'ounces'],
      lastUpdated: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MassStateModel(cards: $cards, visibleUnits: $visibleUnits, lastUpdated: $lastUpdated)';
  }
}
