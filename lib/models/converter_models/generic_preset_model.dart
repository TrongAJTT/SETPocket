import 'package:hive/hive.dart';

part 'generic_preset_model.g.dart';

@HiveType(typeId: 19)
class GenericPresetModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> units;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String presetType; // 'currency', 'length', 'weight', etc.

  GenericPresetModel({
    required this.id,
    required this.name,
    required this.units,
    required this.createdAt,
    required this.presetType,
  });

  // Factory constructor to create preset with current timestamp
  factory GenericPresetModel.create({
    required String name,
    required List<String> units,
    required String presetType,
  }) {
    final now = DateTime.now();
    return GenericPresetModel(
      id: '${presetType}_${now.millisecondsSinceEpoch}',
      name: name,
      units: List.from(units),
      createdAt: now,
      presetType: presetType,
    );
  }

  // Copy with method for updates
  GenericPresetModel copyWith({
    String? id,
    String? name,
    List<String>? units,
    DateTime? createdAt,
    String? presetType,
  }) {
    return GenericPresetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      units: units ?? this.units,
      createdAt: createdAt ?? this.createdAt,
      presetType: presetType ?? this.presetType,
    );
  }

  @override
  String toString() {
    return 'GenericPresetModel(id: $id, name: $name, units: $units, type: $presetType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenericPresetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
