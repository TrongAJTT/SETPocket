import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'hive_service.dart';
import 'graphing_calculator_service.dart';

class CalculatorHistoryItem {
  final String expression;
  final String result;
  final DateTime timestamp;
  final String type; // 'scientific', 'bmi', 'financial', etc.

  CalculatorHistoryItem({
    required this.expression,
    required this.result,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory CalculatorHistoryItem.fromJson(Map<String, dynamic> json) {
    return CalculatorHistoryItem(
      expression: json['expression'] ?? '',
      result: json['result'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'] ?? '',
    );
  }
}

class CalculatorHistoryService {
  static const String _historyEnabledKey = 'calculator_history_enabled';
  static const String _historyKey = 'calculator_history';
  static const String _encryptionKey =
      'my_multi_tools_calculator_history_encryption_key_2024';

  // Maximum number of items to keep in history
  static const int maxHistoryItems = 100;

  /// Check if calculator history saving is enabled
  static Future<bool> isHistoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_historyEnabledKey) ?? true; // Default to true
  }

  /// Enable or disable calculator history saving
  static Future<void> setHistoryEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_historyEnabledKey, enabled);
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

  /// Add a new item to calculator history
  static Future<void> addHistoryItem(
      String expression, String result, String type) async {
    final enabled = await GraphingCalculatorService.getRememberHistory();
    if (!enabled) return;

    try {
      final box = HiveService.historyBox;
      final history = await getHistory(type);

      // Add new item at the beginning
      final newItem = CalculatorHistoryItem(
        expression: expression,
        result: result,
        timestamp: DateTime.now(),
        type: type,
      );

      history.insert(0, newItem);

      // Keep only the latest items
      if (history.length > maxHistoryItems) {
        history.removeRange(maxHistoryItems, history.length);
      }

      // Encrypt and save to Hive
      final jsonList = history.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      final encryptedData = _encrypt(jsonString);

      await box.put('${_historyKey}_$type', encryptedData);
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  /// Get history for a specific calculator type
  static Future<List<CalculatorHistoryItem>> getHistory(String type) async {
    final enabled = await GraphingCalculatorService.getRememberHistory();
    if (!enabled) return [];

    try {
      final box = HiveService.historyBox;
      final encryptedData = box.get('${_historyKey}_$type');

      if (encryptedData == null || encryptedData.isEmpty) {
        return [];
      }

      final decryptedData = _decrypt(encryptedData);
      if (decryptedData.isEmpty) return [];

      final jsonList = json.decode(decryptedData) as List;
      return jsonList
          .map((json) => CalculatorHistoryItem.fromJson(json))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Clear history for a specific calculator type
  static Future<void> clearHistory(String type) async {
    try {
      final box = HiveService.historyBox;
      await box.delete('${_historyKey}_$type');
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  /// Clear all calculator history
  static Future<void> clearAllHistory() async {
    try {
      final box = HiveService.historyBox;

      // Get all keys that start with calculator history key prefix
      final keysToDelete = box.keys
          .where((key) => key.toString().startsWith(_historyKey))
          .toList();

      for (final key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  /// Get total count of calculator history items across all types
  static Future<int> getTotalHistoryCount() async {
    final enabled = await isHistoryEnabled();
    if (!enabled) return 0;

    try {
      final box = HiveService.historyBox;
      final keys = box.keys
          .where((key) =>
              key.toString().startsWith(_historyKey) &&
              key.toString() != _historyEnabledKey)
          .toList();

      int totalCount = 0;
      for (final key in keys) {
        final typeKey = key.toString().replaceFirst('${_historyKey}_', '');
        final history = await getHistory(typeKey);
        totalCount += history.length;
      }

      return totalCount;
    } catch (e) {
      return 0;
    }
  }

  /// Get size of calculator history data in bytes (estimated)
  static Future<int> getHistoryDataSize() async {
    final enabled = await isHistoryEnabled();
    if (!enabled) return 0;

    try {
      final box = HiveService.historyBox;
      final keys = box.keys
          .where((key) =>
              key.toString().startsWith(_historyKey) &&
              key.toString() != _historyEnabledKey)
          .toList();

      int totalSize = 0;
      for (final key in keys) {
        final data = box.get(key, defaultValue: '');
        if (data is String) {
          totalSize += data.length * 2; // UTF-16 encoding estimate
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
