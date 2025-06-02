import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/text_template.dart';

class TemplateService {
  static const String _templatesKey = 'templates';

  static Future<List<Template>> getTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getStringList(_templatesKey) ?? [];

    return templatesJson
        .map((json) => Template.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> saveTemplate(Template template) async {
    final prefs = await SharedPreferences.getInstance();

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
    final templatesJson = templates.map((t) => jsonEncode(t.toJson())).toList();

    // Save updated list
    await prefs.setStringList(_templatesKey, templatesJson);
  }

  static Future<void> deleteTemplate(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve current templates
    List<Template> templates = await getTemplates();

    // Remove the template with the matching id
    templates = templates.where((t) => t.id != id).toList();

    // Convert templates to JSON strings
    final templatesJson = templates.map((t) => jsonEncode(t.toJson())).toList();

    // Save updated list
    await prefs.setStringList(_templatesKey, templatesJson);
  }

  static Future<Template?> getTemplateById(String id) async {
    final templates = await getTemplates();
    try {
      return templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  static String generateTemplateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
