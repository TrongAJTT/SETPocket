import 'dart:convert';
import 'package:isar/isar.dart';

part 'unit_template_model.g.dart';

@collection
class UnitTemplateModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String templateId;

  late String name;

  @Index()
  late String templateType; // 'currency', 'length', 'weight', etc.

  late List<String> units; // List of unit IDs

  late DateTime createdAt;

  // Store metadata as JSON string for Isar compatibility
  late String? metadataJson;

  UnitTemplateModel({
    this.id = Isar.autoIncrement,
    required this.templateId,
    required this.name,
    required this.templateType,
    required this.units,
    required this.createdAt,
    Map<String, String>? metadata,
  }) {
    // Set metadata JSON when metadata is provided
    if (metadata != null) {
      metadataJson = jsonEncode(metadata);
    } else {
      metadataJson = null;
    }
  }

  // Get metadata as map
  Map<String, String>? getMetadata() {
    if (metadataJson == null) return null;
    try {
      final decoded = jsonDecode(metadataJson!);
      return Map<String, String>.from(decoded);
    } catch (e) {
      return null;
    }
  }

  // Set metadata as map
  void setMetadata(Map<String, String>? value) {
    if (value != null) {
      metadataJson = jsonEncode(value);
    } else {
      metadataJson = null;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'name': name,
      'templateType': templateType,
      'units': units,
      'createdAt': createdAt.toIso8601String(),
      'metadata': getMetadata(),
    };
  }

  // Create from JSON
  factory UnitTemplateModel.fromJson(Map<String, dynamic> json) {
    return UnitTemplateModel(
      templateId: json['templateId'] ?? json['id'], // Support old format
      name: json['name'] as String,
      templateType: json['templateType'] as String,
      units: List<String>.from(json['units'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitTemplateModel &&
          runtimeType == other.runtimeType &&
          templateId == other.templateId;

  @override
  int get hashCode => templateId.hashCode;
}

enum TemplateSortOrder {
  date,
  name,
  type,
}
