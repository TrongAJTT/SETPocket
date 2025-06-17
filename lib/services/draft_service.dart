import 'dart:convert';
import 'package:setpocket/models/text_template.dart';
import 'package:setpocket/services/template_service.dart';
import 'hive_service.dart';

class DraftService {
  static const String _draftsKey = 'drafts';

  static Future<List<TemplateDraft>> getDrafts() async {
    try {
      final box = HiveService.templatesBox;
      final draftsJson = box.get(_draftsKey, defaultValue: <String>[]);

      if (draftsJson is List) {
        final drafts = draftsJson
            .cast<String>()
            .map((json) => TemplateDraft.fromJson(jsonDecode(json)))
            .toList();

        // Remove expired drafts
        final validDrafts = drafts.where((draft) => !draft.isExpired).toList();

        // If we removed any drafts, save the updated list
        if (validDrafts.length != drafts.length) {
          await _saveDraftsList(validDrafts);
        }

        return validDrafts;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveDraft(TemplateDraft draft) async {
    try {
      final drafts = await getDrafts();

      // Check if draft already exists by ID
      final existingIndex = drafts.indexWhere((d) => d.id == draft.id);

      if (existingIndex >= 0) {
        // Update existing draft with new updatedAt time
        drafts[existingIndex] = draft.copyWith(updatedAt: DateTime.now());
      } else {
        // Add new draft
        drafts.add(draft);
      }

      await _saveDraftsList(drafts);
    } catch (e) {
      throw Exception('Failed to save draft: $e');
    }
  }

  static Future<void> deleteDraft(String draftId) async {
    try {
      final drafts = await getDrafts();
      final updatedDrafts = drafts.where((d) => d.id != draftId).toList();
      await _saveDraftsList(updatedDrafts);
    } catch (e) {
      throw Exception('Failed to delete draft: $e');
    }
  }

  static Future<TemplateDraft?> getDraftById(String draftId) async {
    try {
      final drafts = await getDrafts();
      return drafts.firstWhere((d) => d.id == draftId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _saveDraftsList(List<TemplateDraft> drafts) async {
    final box = HiveService.templatesBox;
    final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await box.put(_draftsKey, draftsJson);
  }

  static Future<void> clearExpiredDrafts() async {
    try {
      final drafts = await getDrafts();
      final validDrafts = drafts.where((draft) => !draft.isExpired).toList();

      if (validDrafts.length != drafts.length) {
        await _saveDraftsList(validDrafts);
      }
    } catch (e) {
      // Ignore errors in cleanup
    }
  }

  static Future<void> clearAllDrafts() async {
    try {
      await _saveDraftsList([]);
    } catch (e) {
      throw Exception('Failed to clear all drafts: $e');
    }
  }

  static String generateDraftId() {
    return 'draft_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Auto-save functionality
  static Future<void> autoSaveDraft({
    required String draftId,
    required DraftType type,
    String? originalTemplateId,
    required String title,
    required String content,
  }) async {
    try {
      // Only auto-save if there's meaningful content
      if (title.trim().isEmpty && content.trim().isEmpty) {
        return;
      }

      final existingDraft = await getDraftById(draftId);
      final now = DateTime.now();

      final draft = TemplateDraft(
        id: draftId,
        type: type,
        originalTemplateId: originalTemplateId,
        title: title,
        content: content,
        createdAt: existingDraft?.createdAt ?? now,
        updatedAt: now,
      );

      await saveDraft(draft);
    } catch (e) {
      // Auto-save should fail silently to not interrupt user workflow
    }
  }

  // Convert draft to template and delete draft
  static Future<Template> publishDraft(String draftId) async {
    try {
      final draft = await getDraftById(draftId);
      if (draft == null) {
        throw Exception('Draft not found');
      }

      final template = draft.toTemplate();
      await TemplateService.saveTemplate(template);
      await deleteDraft(draftId);

      return template;
    } catch (e) {
      throw Exception('Failed to publish draft: $e');
    }
  }

  // Global callback for emergency saves (e.g., window close)
  static final List<Function()> _emergencySaveCallbacks = [];

  static void registerEmergencySaveCallback(Function() callback) {
    _emergencySaveCallbacks.add(callback);
  }

  static void unregisterEmergencySaveCallback(Function() callback) {
    _emergencySaveCallbacks.remove(callback);
  }

  static void triggerEmergencySave() {
    for (final callback in _emergencySaveCallbacks) {
      try {
        callback();
      } catch (e) {
        // Ignore errors in emergency save
      }
    }
  }
}
