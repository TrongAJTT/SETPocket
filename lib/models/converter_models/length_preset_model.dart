import 'package:isar/isar.dart';

part 'length_preset_model.g.dart';

@collection
class LengthPresetModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String presetId;

  late String name;

  late List<String> units;

  late DateTime createdAt;

  late DateTime updatedAt;

  LengthPresetModel({
    this.id = Isar.autoIncrement,
    required this.presetId,
    required this.name,
    required this.units,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create preset with current timestamp
  factory LengthPresetModel.create({
    required String name,
    required List<String> units,
  }) {
    final now = DateTime.now();
    return LengthPresetModel(
      presetId: now.millisecondsSinceEpoch.toString(),
      name: name,
      units: List.from(units),
      createdAt: now,
      updatedAt: now,
    );
  }

  // Copy with method for updates
  LengthPresetModel copyWith({
    Id? id,
    String? presetId,
    String? name,
    List<String>? units,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LengthPresetModel(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      name: name ?? this.name,
      units: units ?? this.units,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'presetId': presetId,
      'name': name,
      'units': units,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // fromJson factory constructor
  factory LengthPresetModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String);
    return LengthPresetModel(
      presetId: json['presetId'] ?? json['id'], // Support old format
      name: json['name'] as String,
      units: List<String>.from(json['units'] as List),
      createdAt: createdAt,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : createdAt,
    );
  }

  @override
  String toString() {
    return 'LengthPresetModel(presetId: $presetId, name: $name, units: $units, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LengthPresetModel && other.presetId == presetId;
  }

  @override
  int get hashCode => presetId.hashCode;
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
