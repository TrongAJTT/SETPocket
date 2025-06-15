import 'dart:convert';
import 'package:setpocket/models/text_template.dart';
import 'hive_service.dart';

class TemplateService {
  static const String _templatesKey = 'templates';

  static Future<List<Template>> getTemplates() async {
    try {
      final box = HiveService.templatesBox;
      final templatesJson = box.get(_templatesKey, defaultValue: <String>[]);

      if (templatesJson is List) {
        return templatesJson
            .cast<String>()
            .map((json) => Template.fromJson(jsonDecode(json)))
            .toList();
      }

      return [];
    } catch (e) {
      // Fallback to empty list if there's an error
      return [];
    }
  }

  static Future<void> saveTemplate(Template template) async {
    try {
      final box = HiveService.templatesBox;

      // Retrieve current templates
      final List<Template> templates = await getTemplates();

      // Check if template already exists by id
      final existingIndex = templates.indexWhere((t) => t.id == template.id);

      if (existingIndex >= 0) {
        // Update existing template
        templates[existingIndex] = template;
      } else {
        // Add new template
        templates.add(template);
      }

      // Convert templates to JSON strings
      final templatesJson =
          templates.map((t) => jsonEncode(t.toJson())).toList();

      // Save updated list to Hive
      await box.put(_templatesKey, templatesJson);
    } catch (e) {
      throw Exception('Failed to save template: $e');
    }
  }

  static Future<void> deleteTemplate(String id) async {
    try {
      final box = HiveService.templatesBox;

      // Retrieve current templates
      List<Template> templates = await getTemplates();

      // Remove the template with the matching id
      templates = templates.where((t) => t.id != id).toList();

      // Convert templates to JSON strings
      final templatesJson =
          templates.map((t) => jsonEncode(t.toJson())).toList();

      // Save updated list to Hive
      await box.put(_templatesKey, templatesJson);
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  static Future<Template?> getTemplateById(String id) async {
    try {
      final templates = await getTemplates();
      return templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  static String generateTemplateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
