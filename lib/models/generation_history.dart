import 'package:isar/isar.dart';

part 'generation_history.g.dart';

@collection
class GenerationHistoryItem {
  Id id = Isar.autoIncrement;

  late String value;
  late DateTime timestamp;

  @Index()
  late String type; // 'password', 'number', 'date', 'color', etc.

  GenerationHistoryItem({
    this.id = Isar.autoIncrement,
    required this.value,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory GenerationHistoryItem.fromJson(Map<String, dynamic> json) {
    return GenerationHistoryItem(
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }
}
