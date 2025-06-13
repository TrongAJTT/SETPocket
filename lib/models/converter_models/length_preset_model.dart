import 'package:hive/hive.dart';

part 'length_preset_model.g.dart';

@HiveType(typeId: 4)
class LengthPresetModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> units;

  @HiveField(3)
  final DateTime createdAt;

  LengthPresetModel({
    required this.id,
    required this.name,
    required this.units,
    required this.createdAt,
  });

  // Factory constructor to create preset with current timestamp
  factory LengthPresetModel.create({
    required String name,
    required List<String> units,
  }) {
    final now = DateTime.now();
    return LengthPresetModel(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      units: List.from(units),
      createdAt: now,
    );
  }

  // Copy with method for updates
  LengthPresetModel copyWith({
    String? id,
    String? name,
    List<String>? units,
    DateTime? createdAt,
  }) {
    return LengthPresetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      units: units ?? this.units,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'LengthPresetModel(id: $id, name: $name, units: $units, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LengthPresetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
