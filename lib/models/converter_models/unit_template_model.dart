import 'package:hive/hive.dart';

part 'unit_template_model.g.dart';

@HiveType(typeId: 15)
class UnitTemplateModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String templateType; // 'currency', 'length', 'weight', etc.

  @HiveField(3)
  List<String> units; // List of unit IDs

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  Map<String, dynamic>? metadata; // Additional data specific to template type

  UnitTemplateModel({
    required this.id,
    required this.name,
    required this.templateType,
    required this.units,
    required this.createdAt,
    this.metadata,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'templateType': templateType,
      'units': units,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory UnitTemplateModel.fromJson(Map<String, dynamic> json) {
    return UnitTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      templateType: json['templateType'] as String,
      units: List<String>.from(json['units'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitTemplateModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 16)
enum TemplateSortOrder {
  @HiveField(0)
  date,

  @HiveField(1)
  name,

  @HiveField(2)
  type,
}
