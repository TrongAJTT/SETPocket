import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/models/text_template.dart';
import 'package:setpocket/services/template_service.dart';

class DraftService {
  static const String _draftsKey = 'drafts';

  static Future<List<TemplateDraft>> getDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getStringList(_draftsKey) ?? [];
      return draftsJson.map((json) => TemplateDraft.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveDraft(TemplateDraft draft) async {
    try {
      final drafts = await getDrafts();
      final existingIndex = drafts.indexWhere((d) => d.id == draft.id);
      
      if (existingIndex >= 0) {
        drafts[existingIndex] = draft;
      } else {
        drafts.add(draft);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
      await prefs.setStringList(_draftsKey, draftsJson);
    } catch (e) {
      throw Exception('Failed to save draft: $e');
    }
  }

  static Future<void> deleteDraft(String draftId) async {
    try {
      final drafts = await getDrafts();
      drafts.removeWhere((d) => d.id == draftId);
      
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
      await prefs.setStringList(_draftsKey, draftsJson);
    } catch (e) {
      throw Exception('Failed to delete draft: $e');
    }
  }

  static Future<TemplateDraft?> getDraftById(String draftId) async {
    try {
      final drafts = await getDrafts();
      return drafts.where((d) => d.id == draftId).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearExpiredDrafts() async {
    try {
      final drafts = await getDrafts();
      final now = DateTime.now();
      const expireDays = 30; // Drafts expire after 30 days
      
      final validDrafts = drafts.where((draft) {
        final age = now.difference(draft.createdAt).inDays;
        return age <= expireDays;
      }).toList();
      
      if (validDrafts.length != drafts.length) {
        final prefs = await SharedPreferences.getInstance();
        final draftsJson = validDrafts.map((d) => jsonEncode(d.toJson())).toList();
        await prefs.setStringList(_draftsKey, draftsJson);
      }
    } catch (e) {
      // Ignore errors in cleanup
    }
  }

  static Future<void> clearAllDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftsKey);
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

      final draft = TemplateDraft(
        id: draftId,
        type: type,
        originalTemplateId: originalTemplateId,
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
