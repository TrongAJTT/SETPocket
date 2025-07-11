import 'package:isar/isar.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/models/converter_models/unit_template_model.dart';
import 'package:setpocket/services/isar_service.dart';

class UnitTemplateServiceIsar {
  // Save a template
  static Future<void> saveTemplate({
    required String name,
    required String templateType,
    required List<String> units,
    Map<String, String>? metadata,
  }) async {
    try {
      final isar = IsarService.isar;

      final templateId = DateTime.now().millisecondsSinceEpoch.toString();
      final template = UnitTemplateModel(
        templateId: templateId,
        name: name,
        templateType: templateType,
        units: List<String>.from(units),
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await isar.writeTxn(() async {
        await isar.unitTemplateModels.put(template);
      });

      logInfo(
          'UnitTemplateService: Template saved: $name (Type: $templateType)');
    } catch (e) {
      String logMsg = 'UnitTemplateService: Error saving template: $e';
      logFatal(logMsg, e, StackTrace.current);
      rethrow;
    }
  }

  // Load templates by type
  static Future<List<UnitTemplateModel>> loadTemplatesByType(
    String templateType, {
    TemplateSortOrder sortOrder = TemplateSortOrder.date,
  }) async {
    try {
      final isar = IsarService.isar;

      var query =
          isar.unitTemplateModels.filter().templateTypeEqualTo(templateType);

      // Apply sorting
      switch (sortOrder) {
        case TemplateSortOrder.date:
          return await query.sortByCreatedAtDesc().findAll();
        case TemplateSortOrder.name:
          return await query.sortByName().findAll();
        case TemplateSortOrder.type:
          return await query.sortByTemplateType().findAll();
      }
    } catch (e) {
      logError('UnitTemplateService: Error loading templates by type: $e');
      return [];
    }
  }

  // Load all templates
  static Future<List<UnitTemplateModel>> loadAllTemplates({
    TemplateSortOrder sortOrder = TemplateSortOrder.date,
  }) async {
    try {
      final isar = IsarService.isar;

      // Apply sorting
      switch (sortOrder) {
        case TemplateSortOrder.date:
          return await isar.unitTemplateModels
              .where()
              .sortByCreatedAtDesc()
              .findAll();
        case TemplateSortOrder.name:
          return await isar.unitTemplateModels.where().sortByName().findAll();
        case TemplateSortOrder.type:
          return await isar.unitTemplateModels
              .where()
              .sortByTemplateType()
              .findAll();
      }
    } catch (e) {
      logError('UnitTemplateService: Error loading all templates: $e');
      return [];
    }
  }

  // Delete a template
  static Future<bool> deleteTemplate(String templateId) async {
    try {
      final isar = IsarService.isar;

      bool deleted = false;
      await isar.writeTxn(() async {
        deleted = await isar.unitTemplateModels
            .filter()
            .templateIdEqualTo(templateId)
            .deleteFirst();
      });

      if (deleted) {
        logInfo('UnitTemplateService: Template deleted: $templateId');
      }
      return deleted;
    } catch (e) {
      logError('UnitTemplateService: Error deleting template: $e');
      return false;
    }
  }

  // Get template by ID
  static Future<UnitTemplateModel?> getTemplateById(String templateId) async {
    try {
      final isar = IsarService.isar;
      return await isar.unitTemplateModels
          .filter()
          .templateIdEqualTo(templateId)
          .findFirst();
    } catch (e) {
      logError('UnitTemplateService: Error getting template by ID: $e');
      return null;
    }
  }

  // Update template
  static Future<bool> updateTemplate(UnitTemplateModel template) async {
    try {
      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        await isar.unitTemplateModels.put(template);
      });

      logInfo('UnitTemplateService: Template updated: ${template.templateId}');
      return true;
    } catch (e) {
      logError('UnitTemplateService: Error updating template: $e');
      return false;
    }
  }

  // Clear all templates for a specific type
  static Future<int> clearTemplatesByType(String templateType) async {
    try {
      final isar = IsarService.isar;

      int deletedCount = 0;
      await isar.writeTxn(() async {
        deletedCount = await isar.unitTemplateModels
            .filter()
            .templateTypeEqualTo(templateType)
            .deleteAll();
      });

      logInfo(
          'UnitTemplateService: Cleared $deletedCount templates of type: $templateType');
      return deletedCount;
    } catch (e) {
      logError('UnitTemplateService: Error clearing templates by type: $e');
      return 0;
    }
  }

  // Get template count by type
  static Future<int> getTemplateCountByType(String templateType) async {
    try {
      final isar = IsarService.isar;
      return await isar.unitTemplateModels
          .filter()
          .templateTypeEqualTo(templateType)
          .count();
    } catch (e) {
      logError('UnitTemplateService: Error getting template count: $e');
      return 0;
    }
  }

  // Get all template types
  static Future<List<String>> getAllTemplateTypes() async {
    try {
      final isar = IsarService.isar;
      final templates = await isar.unitTemplateModels
          .where()
          .distinctByTemplateType()
          .findAll();
      return templates.map((t) => t.templateType).toList();
    } catch (e) {
      logError('UnitTemplateService: Error getting template types: $e');
      return [];
    }
  }

  // Migration helper: migrate data from Hive to Isar
  static Future<void> migrateFromHive(
      List<UnitTemplateModel> hiveTemplates) async {
    try {
      final isar = IsarService.isar;

      // Check if migration already done by checking if any templates exist
      final existingCount = await isar.unitTemplateModels.count();
      if (existingCount > 0) {
        return; // Already migrated
      }

      await isar.writeTxn(() async {
        for (final template in hiveTemplates) {
          // Create new template with proper structure
          final newTemplate = UnitTemplateModel(
            templateId: template.templateId,
            name: template.name,
            templateType: template.templateType,
            units: template.units,
            createdAt: template.createdAt,
            metadata: template.getMetadata(),
          );
          await isar.unitTemplateModels.put(newTemplate);
        }
      });

      logInfo(
          'UnitTemplateService: Migrated ${hiveTemplates.length} templates from Hive to Isar');
    } catch (e) {
      throw Exception('Failed to migrate unit templates from Hive: $e');
    }
  }
}
