import 'package:isar/isar.dart';
import 'package:setpocket/models/text_template.dart';
import 'package:setpocket/services/isar_service.dart';

class TemplateServiceIsar {
  static Future<List<Template>> getTemplates() async {
    try {
      final isar = IsarService.isar;
      return await isar.templates.where().findAll();
    } catch (e) {
      // Fallback to empty list if there's an error
      return [];
    }
  }

  static Future<void> saveTemplate(Template template) async {
    try {
      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        // Check if template already exists by templateId
        final existing = await isar.templates
            .filter()
            .templateIdEqualTo(template.templateId)
            .findFirst();

        if (existing != null) {
          // Update existing template - keep the same Isar ID
          template.id = existing.id;
        }

        await isar.templates.put(template);
      });
    } catch (e) {
      throw Exception('Failed to save template: $e');
    }
  }

  static Future<void> deleteTemplate(String templateId) async {
    try {
      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        await isar.templates.filter().templateIdEqualTo(templateId).deleteAll();
      });
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  static Future<Template?> getTemplateById(String templateId) async {
    try {
      final isar = IsarService.isar;
      return await isar.templates
          .filter()
          .templateIdEqualTo(templateId)
          .findFirst();
    } catch (e) {
      return null;
    }
  }

  static String generateTemplateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Migration helper: migrate data from Hive to Isar
  static Future<void> migrateFromHive(List<Template> hiveTemplates) async {
    try {
      final isar = IsarService.isar;

      // Check if migration already done by checking if any templates exist
      final existingCount = await isar.templates.count();
      if (existingCount > 0) {
        return; // Already migrated
      }

      await isar.writeTxn(() async {
        for (final template in hiveTemplates) {
          // Create new Template with proper structure
          final newTemplate = Template(
            templateId: template.templateId,
            title: template.title,
            content: template.content,
          );
          await isar.templates.put(newTemplate);
        }
      });
    } catch (e) {
      throw Exception('Failed to migrate templates from Hive: $e');
    }
  }

  static Future<void> clearAll() async {
    try {
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.templates.clear();
      });
    } catch (e) {
      throw Exception('Failed to clear all templates: $e');
    }
  }
}
