import 'package:hive/hive.dart';
import '../models/unit_template_model.dart';

class UnitTemplateService {
  static const String _templateBoxName = 'unit_templates';
  static Box<UnitTemplateModel>? _templateBox;

  // Initialize the template service
  static Future<void> initialize() async {
    try {
      if (_templateBox == null || !_templateBox!.isOpen) {
        _templateBox = await Hive.openBox<UnitTemplateModel>(_templateBoxName);
        print('UnitTemplateService: Template box opened successfully');
      }
    } catch (e) {
      print('UnitTemplateService: Error opening template box: $e');
      rethrow;
    }
  }

  // Save a template
  static Future<void> saveTemplate({
    required String name,
    required String templateType,
    required List<String> units,
    Map<String, dynamic>? metadata,
  }) async {
    await initialize();

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final template = UnitTemplateModel(
      id: id,
      name: name,
      templateType: templateType,
      units: List<String>.from(units),
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    await _templateBox!.put(id, template);
    await _templateBox!.flush();
    print('UnitTemplateService: Template saved: $name (Type: $templateType)');
  }

  // Load templates by type
  static Future<List<UnitTemplateModel>> loadTemplatesByType(
    String templateType, {
    TemplateSortOrder sortOrder = TemplateSortOrder.date,
  }) async {
    await initialize();

    var templates = _templateBox!.values
        .where((template) => template.templateType == templateType)
        .toList();

    // Sort templates
    switch (sortOrder) {
      case TemplateSortOrder.date:
        templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TemplateSortOrder.name:
        templates.sort((a, b) => a.name.compareTo(b.name));
        break;
      case TemplateSortOrder.type:
        templates.sort((a, b) => a.templateType.compareTo(b.templateType));
        break;
    }

    print(
        'UnitTemplateService: Loaded ${templates.length} templates for type: $templateType');
    return templates;
  }

  // Load all templates
  static Future<List<UnitTemplateModel>> loadAllTemplates({
    TemplateSortOrder sortOrder = TemplateSortOrder.date,
  }) async {
    await initialize();

    var templates = _templateBox!.values.toList();

    // Sort templates
    switch (sortOrder) {
      case TemplateSortOrder.date:
        templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TemplateSortOrder.name:
        templates.sort((a, b) => a.name.compareTo(b.name));
        break;
      case TemplateSortOrder.type:
        templates.sort((a, b) => a.templateType.compareTo(b.templateType));
        break;
    }

    print('UnitTemplateService: Loaded ${templates.length} total templates');
    return templates;
  }

  // Delete a template
  static Future<void> deleteTemplate(String templateId) async {
    await initialize();

    await _templateBox!.delete(templateId);
    await _templateBox!.flush();
    print('UnitTemplateService: Template deleted: $templateId');
  }

  // Check if template name exists for a specific type
  static Future<bool> templateNameExists(
      String name, String templateType) async {
    await initialize();

    final exists = _templateBox!.values.any(
      (template) =>
          template.name == name && template.templateType == templateType,
    );
    return exists;
  }

  // Get template by ID
  static Future<UnitTemplateModel?> getTemplate(String templateId) async {
    await initialize();
    return _templateBox!.get(templateId);
  }

  // Clear all templates of a specific type
  static Future<void> clearTemplatesByType(String templateType) async {
    await initialize();

    final keysToDelete = _templateBox!.values
        .where((template) => template.templateType == templateType)
        .map((template) => template.id)
        .toList();

    for (final key in keysToDelete) {
      await _templateBox!.delete(key);
    }

    await _templateBox!.flush();
    print(
        'UnitTemplateService: Cleared ${keysToDelete.length} templates for type: $templateType');
  }

  // Clear all templates
  static Future<void> clearAllTemplates() async {
    await initialize();

    await _templateBox!.clear();
    await _templateBox!.flush();
    print('UnitTemplateService: All templates cleared');
  }

  // Get template count by type
  static Future<int> getTemplateCountByType(String templateType) async {
    await initialize();

    return _templateBox!.values
        .where((template) => template.templateType == templateType)
        .length;
  }

  // Get total template count
  static Future<int> getTotalTemplateCount() async {
    await initialize();
    return _templateBox!.length;
  }

  // Export templates to JSON
  static Future<Map<String, dynamic>> exportTemplates(
      String templateType) async {
    final templates = await loadTemplatesByType(templateType);

    return {
      'templateType': templateType,
      'exportDate': DateTime.now().toIso8601String(),
      'templates': templates.map((template) => template.toJson()).toList(),
    };
  }

  // Import templates from JSON
  static Future<void> importTemplates(Map<String, dynamic> data) async {
    await initialize();

    final templateType = data['templateType'] as String;
    final templatesList = data['templates'] as List;

    for (final templateData in templatesList) {
      final template =
          UnitTemplateModel.fromJson(templateData as Map<String, dynamic>);

      // Generate new ID to avoid conflicts
      template.id = DateTime.now().millisecondsSinceEpoch.toString();

      await _templateBox!.put(template.id, template);
    }

    await _templateBox!.flush();
    print(
        'UnitTemplateService: Imported ${templatesList.length} templates for type: $templateType');
  }
}
