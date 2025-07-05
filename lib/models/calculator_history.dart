import 'package:isar/isar.dart';

part 'calculator_history.g.dart';

@collection
class CalculatorHistory {
  Id id = Isar.autoIncrement;

  late String expression;

  late String result;

  late DateTime timestamp;

  @Index(type: IndexType.hash)
  late String type; // 'scientific', 'bmi', 'financial', etc.
}
