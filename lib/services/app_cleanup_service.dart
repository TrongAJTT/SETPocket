import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:isar/isar.dart';

class AppCleanupService {
  static Future<void> cleanStartUp() async {
    final isar = IsarService.isar;
    final now = DateTime.now();
    // Xóa draft quá 7 ngày
    final expiredDrafts = await isar.textTemplatesDatas
        .filter()
        .statusEqualTo(TemplateStatus.draft)
        .updatedAtLessThan(now.subtract(const Duration(days: 7)))
        .findAll();
    if (expiredDrafts.isNotEmpty) {
      await isar.writeTxn(() async {
        for (final t in expiredDrafts) {
          await isar.textTemplatesDatas.delete(t.isarId);
        }
      });
    }
    // Xóa deleted quá 30 ngày
    final expiredDeleted = await isar.textTemplatesDatas
        .filter()
        .statusEqualTo(TemplateStatus.deleted)
        .updatedAtLessThan(now.subtract(const Duration(days: 30)))
        .findAll();
    if (expiredDeleted.isNotEmpty) {
      await isar.writeTxn(() async {
        for (final t in expiredDeleted) {
          await isar.textTemplatesDatas.delete(t.isarId);
        }
      });
    }
  }
}
