import 'dart:convert';
import 'package:setpocket/models/function_group_history.dart';
import 'package:setpocket/models/graphing_function.dart';
import 'package:flutter/material.dart';
import 'package:setpocket/services/hive_service.dart';

class GraphingCalculatorService {
  static const String _historyBoxName = 'graphing_calculator_history';
  static const String _settingsBoxName = 'graphing_calculator_settings';
  static const String _currentStateBoxName = 'graphing_calculator_state';

  static const String _rememberHistoryKey = 'remember_history';
  static const String _askBeforeLoadingKey = 'ask_before_loading';
  static const String _currentStateKey = 'current_state';
  static const String _saveDialogPreferenceKey = 'save_dialog_preference';
  static const String _autoSaveWhenLoadingKey = 'auto_save_when_loading';

  // Initialize the service
  static Future<void> initialize() async {
    await HiveService.getBox(_historyBoxName);
    await HiveService.getBox(_settingsBoxName);
    await HiveService.getBox(_currentStateBoxName);
  }

  // History management
  static Future<List<FunctionGroupHistory>> getHistory() async {
    final box = await HiveService.getBox(_historyBoxName);
    final List<FunctionGroupHistory> history = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null && data is Map) {
        try {
          final group =
              FunctionGroupHistory.fromJson(Map<String, dynamic>.from(data));
          history.add(group);
        } catch (e) {
          debugPrint('Error parsing history item: $e');
        }
      }
    }

    // Sort by saved date, newest first
    history.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return history;
  }

  static Future<void> saveToHistory(
      List<GraphingFunction> functions, double aspectRatio) async {
    if (functions.isEmpty) return;

    final box = await HiveService.getBox(_historyBoxName);
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final group = FunctionGroupHistory(
      id: id,
      functions: functions,
      savedAt: DateTime.now(),
      aspectRatio: aspectRatio,
    );

    await box.put(id, group.toJson());
  }

  static Future<void> removeFromHistory(String id) async {
    final box = await HiveService.getBox(_historyBoxName);
    await box.delete(id);
  }

  static Future<void> clearHistory() async {
    final box = await HiveService.getBox(_historyBoxName);
    await box.clear();
  }

  // Settings management
  static Future<bool> getRememberHistory() async {
    final box = await HiveService.getBox(_settingsBoxName);
    return box.get(_rememberHistoryKey, defaultValue: true);
  }

  static Future<void> setRememberHistory(bool value) async {
    final box = await HiveService.getBox(_settingsBoxName);
    await box.put(_rememberHistoryKey, value);

    // If remember history is disabled, also disable ask before loading
    if (!value) {
      await box.put(_askBeforeLoadingKey, false);
    }
  }

  static Future<bool> getAskBeforeLoading() async {
    final box = await HiveService.getBox(_settingsBoxName);
    return box.get(_askBeforeLoadingKey, defaultValue: true);
  }

  static Future<void> setAskBeforeLoading(bool value) async {
    final box = await HiveService.getBox(_settingsBoxName);
    await box.put(_askBeforeLoadingKey, value);
  }

  // Dialog preference management
  static Future<bool?> getSaveDialogPreference() async {
    final box = await HiveService.getBox(_settingsBoxName);
    final preference = box.get(_saveDialogPreferenceKey);
    return preference; // null = not set, true = always save, false = never save
  }

  static Future<void> setSaveDialogPreference(bool? value) async {
    final box = await HiveService.getBox(_settingsBoxName);
    if (value == null) {
      await box.delete(_saveDialogPreferenceKey);
    } else {
      await box.put(_saveDialogPreferenceKey, value);
    }
  }

  static Future<bool> getAutoSaveWhenLoading() async {
    final box = await HiveService.getBox(_settingsBoxName);
    return box.get(_autoSaveWhenLoadingKey, defaultValue: false);
  }

  static Future<void> setAutoSaveWhenLoading(bool value) async {
    final box = await HiveService.getBox(_settingsBoxName);
    await box.put(_autoSaveWhenLoadingKey, value);
  }

  // Utility methods
  static bool areFunctionGroupsEqual(
      List<GraphingFunction> group1, List<GraphingFunction> group2) {
    if (group1.length != group2.length) return false;

    for (int i = 0; i < group1.length; i++) {
      final f1 = group1[i];
      final f2 = group2[i];

      if (f1.expression != f2.expression ||
          f1.isVisible != f2.isVisible ||
          f1.color.toARGB32() != f2.color.toARGB32()) {
        return false;
      }
    }
    return true;
  }

  // Current state management
  static Future<Map<String, dynamic>?> getCurrentState() async {
    final box = await HiveService.getBox(_currentStateBoxName);
    final data = box.get(_currentStateKey);
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> saveCurrentState(
      List<GraphingFunction> functions, double aspectRatio) async {
    final box = await HiveService.getBox(_currentStateBoxName);

    final functionsData = functions.map((f) => f.toJson()).toList();
    final stateData = {
      'functions': functionsData,
      'aspectRatio': aspectRatio,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await box.put(_currentStateKey, stateData);
  }

  static Future<void> clearCurrentState() async {
    final box = await HiveService.getBox(_currentStateBoxName);
    await box.delete(_currentStateKey);
  }

  // Cache management for settings integration
  static Future<Map<String, dynamic>> getCacheInfo() async {
    final history = await getHistory();
    final currentState = await getCurrentState();

    // Calculate cache size (rough estimation)
    final historySize = history.fold<int>(0, (sum, group) {
      return sum +
          group.functions.fold<int>(0, (funcSum, func) {
            return funcSum +
                func.expression.length * 2; // Rough char size estimation
          });
    });

    final stateSize =
        currentState != null ? json.encode(currentState).length : 0;

    return {
      'items': history.length + (currentState != null ? 1 : 0),
      'size': historySize + stateSize,
      'history_count': history.length,
      'has_current_state': currentState != null,
    };
  }

  static Future<void> clearAllData() async {
    await clearHistory();
    await clearCurrentState();

    // Reset settings to defaults
    final settingsBox = await HiveService.getBox(_settingsBoxName);
    await settingsBox.put(_rememberHistoryKey, true);
    await settingsBox.put(_askBeforeLoadingKey, true);
  }

  static Future<void> clearAllCache() async {
    await clearAllData();
  }
}
