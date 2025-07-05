import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/models/generation_history.dart';
import 'package:setpocket/services/generation_history_service_isar.dart';
import 'hive_service.dart';

// Legacy class for backward compatibility - now uses Isar internally
class GenerationHistoryItem {
  final String value;
  final DateTime timestamp;
  final String type; // 'password', 'number', 'date', 'color', etc.

  GenerationHistoryItem({
    required this.value,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory GenerationHistoryItem.fromJson(Map<String, dynamic> json) {
    return GenerationHistoryItem(
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }
}

class GenerationHistoryService {
  static const String _historyEnabledKey = 'generation_history_enabled';
  static const String _historyKey = 'generation_history';
  static const String _encryptionKey =
      'my_multi_tools_history_encryption_key_2024';

  // Maximum number of items to keep in history
  static const int maxHistoryItems = 100;
  static bool _migrationCompleted = false;

  // Migration helper - run once to migrate from Hive to Isar
  static Future<void> _ensureMigration() async {
    if (_migrationCompleted) return;

    try {
      // Check if there's any data in Hive to migrate
      final hiveHistory = await _getHistoryFromHive();

      if (hiveHistory.isNotEmpty) {
        // Migrate each type to Isar
        for (final type in hiveHistory.keys) {
          final items = hiveHistory[type] ?? [];
          for (final item in items) {
            await GenerationHistoryServiceIsar.addHistoryItem(
                item.value, item.type);
          }
        }
      }

      _migrationCompleted = true;
    } catch (e) {
      // If migration fails, continue with Isar anyway
      _migrationCompleted = true;
    }
  }

  static Future<Map<String, List<GenerationHistoryItem>>>
      _getHistoryFromHive() async {
    try {
      // Hive access disabled during migration
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Simple encryption using base64 and key rotation
  static String _encrypt(String plainText) {
    final bytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(_encryptionKey);

    // Simple XOR encryption with key rotation
    final encrypted = Uint8List(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      encrypted[i] = bytes[i] ^ keyBytes[i % keyBytes.length];
    }

    return base64.encode(encrypted);
  }

  /// Simple decryption
  static String _decrypt(String encryptedText) {
    try {
      final encrypted = base64.decode(encryptedText);
      final keyBytes = utf8.encode(_encryptionKey);

      // Simple XOR decryption with key rotation
      final decrypted = Uint8List(encrypted.length);
      for (int i = 0; i < encrypted.length; i++) {
        decrypted[i] = encrypted[i] ^ keyBytes[i % keyBytes.length];
      }

      return utf8.decode(decrypted);
    } catch (e) {
      // If decryption fails, return empty string
      return '';
    }
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
  static Future<void> addHistoryItem(String value, String type) async {
    await _ensureMigration();
    return await GenerationHistoryServiceIsar.addHistoryItem(value, type);
  }

  /// Get history items for a specific type
  static Future<List<GenerationHistoryItem>> getHistory(String type) async {
    await _ensureMigration();
    final isarItems = await GenerationHistoryServiceIsar.getHistory(type);

    // Convert Isar models to legacy models for compatibility
    return isarItems
        .map((item) => GenerationHistoryItem(
              value: item.value,
              timestamp: item.timestamp,
              type: item.type,
            ))
        .toList();
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
}
