import 'package:isar/isar.dart';
import 'package:setpocket/services/generation_history_service_isar.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/services/isar_service.dart';

class GenerationHistoryService {
  // Maximum number of items to keep in history
  static const int maxHistoryItems = 100;
  static bool _migrationCompleted = false;

  // Migration helper - run once to migrate from Hive to Isar
  static Future<void> _ensureMigration() async {
    if (_migrationCompleted) return;
    // Since this is a one-time migration, we assume it has been completed
    // and the old Hive data is no longer relevant.
    _migrationCompleted = true;
  }

  /// Check if history saving is enabled
  static Future<bool> isHistoryEnabled() async {
    return await GenerationHistoryServiceIsar.isHistoryEnabled();
  }

  /// Enable or disable history saving
  static Future<void> setHistoryEnabled(bool enabled) async {
    return await GenerationHistoryServiceIsar.setHistoryEnabled(enabled);
  }

  /// Add a new item to history
  static Future<void> addHistoryItem(UnifiedHistoryData item) async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.addHistoryItem(item);
  }

  /// Get history items for a specific type
  static Future<List<UnifiedHistoryData>> getHistory(String type) async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.getHistory(type);
  }

  /// Clear history for a specific type
  static Future<void> clearHistory(String type) async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.clearHistory(type);
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.clearAllHistory();
  }

  /// Delete a specific history item by its ID
  static Future<void> deleteHistoryItem(Id id) async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.deleteHistoryItem(id);
  }

  /// Get all unique history types
  static Future<List<String>> getHistoryTypes() async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.getHistoryTypes();
  }

  /// Get history count for a specific type
  static Future<int> getHistoryCount(String type) async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.getHistoryCount(type);
  }

  /// Get total history count across all types
  static Future<int> getTotalHistoryCount() async {
    await _ensureMigration();
    final types = await getHistoryTypes();
    int total = 0;
    for (final type in types) {
      total += await getHistoryCount(type);
    }
    return total;
  }

  /// Get estimated data size of history in bytes
  static Future<int> getHistoryDataSize() async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.getHistoryDataSize();
  }

  static Future<void> deleteHistoryItemById(int id) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.unifiedHistoryDatas.delete(id);
    });
  }
}
