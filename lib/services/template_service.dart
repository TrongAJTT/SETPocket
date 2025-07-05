import 'dart:convert';
import 'package:setpocket/models/text_template.dart';
import 'package:setpocket/services/template_service_isar.dart';
// import 'hive_service.dart'; // Commented out during Hive to Isar migration

class TemplateService {
  static const String _templatesKey = 'templates';
  static bool _migrationCompleted = false;

  // Migration helper - run once to migrate from Hive to Isar - DISABLED
  static Future<void> _ensureMigration() async {
    if (_migrationCompleted) return;

    try {
      // Migration disabled - using Isar directly
      _migrationCompleted = true;
    } catch (e) {
      // If migration fails, continue with Isar anyway
      _migrationCompleted = true;
    }
  }

  static Future<List<Template>> _getTemplatesFromHive() async {
    try {
      // Hive access disabled during migration
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Template>> getTemplates() async {
    await _ensureMigration();
    return await TemplateServiceIsar.getTemplates();
  }

  static Future<void> saveTemplate(Template template) async {
    await _ensureMigration();
    return await TemplateServiceIsar.saveTemplate(template);
  }

  static Future<void> deleteTemplate(String templateId) async {
    await _ensureMigration();
    return await TemplateServiceIsar.deleteTemplate(templateId);
  }

  static Future<Template?> getTemplateById(String templateId) async {
    await _ensureMigration();
    return await TemplateServiceIsar.getTemplateById(templateId);
  }

  static Future<void> clearAllTemplates() async {
    await _ensureMigration();
    return await TemplateServiceIsar.clearAll();
  }

  static String generateTemplateId() {
    return TemplateServiceIsar.generateTemplateId();
  }
}
