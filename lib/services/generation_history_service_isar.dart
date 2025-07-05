import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/models/generation_history.dart';
import 'package:setpocket/services/isar_service.dart';

class GenerationHistoryServiceIsar {
  static const String _historyEnabledKey = 'generation_history_enabled';
  static const int maxHistoryItems = 100;

  /// Check if history saving is enabled
  static Future<bool> isHistoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_historyEnabledKey) ?? true; // Default to true
  }

  /// Enable or disable history saving
  static Future<void> setHistoryEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_historyEnabledKey, enabled);
  }

  /// Add a new item to the history
  static Future<void> addHistoryItem(String value, String type) async {
    if (!await isHistoryEnabled()) return;

    try {
      final isar = IsarService.isar;

      await isar.writeTxn(() async {
        // Add new item
        final newItem = GenerationHistoryItem(
          value: value,
          timestamp: DateTime.now(),
          type: type,
        );
        await isar.generationHistoryItems.put(newItem);

        // Cleanup old items if we exceed the limit
        final count = await isar.generationHistoryItems
            .filter()
            .typeEqualTo(type)
            .count();

        if (count > maxHistoryItems) {
          // Get oldest items to delete
          final oldItems = await isar.generationHistoryItems
              .filter()
              .typeEqualTo(type)
              .sortByTimestamp()
              .limit(count - maxHistoryItems)
              .findAll();

          for (final item in oldItems) {
            await isar.generationHistoryItems.delete(item.id);
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to add history item: $e');
    }
  }

  /// Get history items for a specific type
  static Future<List<GenerationHistoryItem>> getHistory(String type) async {
    try {
      final isar = IsarService.isar;
      return await isar.generationHistoryItems
          .filter()
          .typeEqualTo(type)
          .sortByTimestampDesc()
          .findAll();
    } catch (e) {
      return [];
    }
  }

  /// Clear history for a specific type
  static Future<void> clearHistory(String type) async {
    try {
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.generationHistoryItems
            .filter()
            .typeEqualTo(type)
            .deleteAll();
      });
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    try {
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        await isar.generationHistoryItems.clear();
      });
    } catch (e) {
      throw Exception('Failed to clear all history: $e');
    }
  }

  /// Get all unique history types
  static Future<List<String>> getHistoryTypes() async {
    try {
      final isar = IsarService.isar;
      final items =
          await isar.generationHistoryItems.where().distinctByType().findAll();
      return items.map((item) => item.type).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get history count for a specific type
  static Future<int> getHistoryCount(String type) async {
    try {
      final isar = IsarService.isar;
      return await isar.generationHistoryItems
          .filter()
          .typeEqualTo(type)
          .count();
    } catch (e) {
      return 0;
    }
  }

  /// Get estimated data size of history in bytes
  static Future<int> getHistoryDataSize() async {
    try {
      final isar = IsarService.isar;
      final items = await isar.generationHistoryItems.where().findAll();

      int totalSize = 0;
      for (final item in items) {
        // Estimate size: value + type + timestamp overhead
        totalSize += item.value.length * 2; // UTF-16 encoding
        totalSize += item.type.length * 2;
        totalSize += 8; // timestamp (int64)
        totalSize += 16; // object overhead
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
