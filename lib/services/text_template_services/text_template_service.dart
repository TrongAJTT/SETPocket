import 'package:isar/isar.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:uuid/uuid.dart';

/// A unified service for managing text templates.
/// This service handles all CRUD operations and state management for [TextTemplatesData].
class TemplateService {
  static final Isar isar = IsarService.isar;
  static const Uuid _uuid = Uuid();

  /// Generates a new unique ID for a template.
  static String generateTemplateId() => _uuid.v4();

  /// Retrieves all templates with a 'complete' status, sorted by last update time.
  static Future<List<TextTemplatesData>> getCompletedTemplates() async {
    return await isar.textTemplatesDatas
        .filter()
        .statusEqualTo(TemplateStatus.complete)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Retrieves all templates with a 'draft' status, sorted by last update time.
  static Future<List<TextTemplatesData>> getDraftTemplates() async {
    return await isar.textTemplatesDatas
        .filter()
        .statusEqualTo(TemplateStatus.draft)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Retrieves all templates with a 'deleted' status, sorted by last update time.
  static Future<List<TextTemplatesData>> getDeletedTemplates() async {
    return await isar.textTemplatesDatas
        .filter()
        .statusEqualTo(TemplateStatus.deleted)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Retrieves a single template by its unique ID.
  static Future<TextTemplatesData?> getTemplateById(String id) async {
    return await isar.textTemplatesDatas.where().idEqualTo(id).findFirst();
  }

  /// Saves or updates a template.
  /// If it's a new template, it assigns a new ID and sets creation/update times.
  /// If it's an existing template, it just updates the content and 'updatedAt' timestamp.
  static Future<void> saveTemplate(TextTemplatesData template) async {
    await isar.writeTxn(() async {
      await isar.textTemplatesDatas.put(template);
    });
  }

  /// Deletes a template permanently from the database.
  static Future<void> deleteTemplatePermanently(String id) async {
    await isar.writeTxn(() async {
      await isar.textTemplatesDatas.where().idEqualTo(id).deleteAll();
    });
  }

  /// Moves a template to the 'deleted' status (soft delete).
  static Future<void> moveToTrash(String id) async {
    await isar.writeTxn(() async {
      final template = await getTemplateById(id);
      if (template != null) {
        template.status = TemplateStatus.deleted;
        template.updatedAt = DateTime.now();
        await isar.textTemplatesDatas.put(template);
      }
    });
  }

  /// Moves a list of templates to the 'deleted' status (soft delete).
  static Future<void> batchMoveToTrash(List<String> ids) async {
    await isar.writeTxn(() async {
      final templates = await isar.textTemplatesDatas.getAllById(ids);
      for (var template in templates) {
        if (template != null) {
          template.status = TemplateStatus.deleted;
          template.updatedAt = DateTime.now();
        }
      }
      await isar.textTemplatesDatas
          .putAll(templates.whereType<TextTemplatesData>().toList());
    });
  }

  /// Restores a template from the 'deleted' status back to 'draft'.
  static Future<void> restoreFromTrash(String id) async {
    await isar.writeTxn(() async {
      final template = await getTemplateById(id);
      if (template != null) {
        template.status = TemplateStatus.draft; // Restore as draft
        template.updatedAt = DateTime.now();
        await isar.textTemplatesDatas.put(template);
      }
    });
  }

  /// Finds duplicate titles among completed templates.
  static Future<bool> isTitleDuplicate(String title,
      {String? currentId}) async {
    var query = isar.textTemplatesDatas
        .filter()
        .statusEqualTo(TemplateStatus.complete)
        .titleEqualTo(title, caseSensitive: false);

    if (currentId != null) {
      query = query.not().idEqualTo(currentId);
    }

    return await query.count() > 0;
  }

  static Future<void> deleteTemplate(String id,
      {bool permanent = false}) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      final template =
          await isar.textTemplatesDatas.where().idEqualTo(id).findFirst();
      if (template != null) {
        if (permanent) {
          await isar.textTemplatesDatas.delete(template.isarId);
        } else {
          template.status = TemplateStatus.deleted;
          await isar.textTemplatesDatas.put(template);
        }
      }
    });
  }
}
