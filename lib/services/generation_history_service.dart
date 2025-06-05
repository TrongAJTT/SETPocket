import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Check if history saving is enabled
  static Future<bool> isHistoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_historyEnabledKey) ?? false;
  }

  /// Enable or disable history saving
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

  /// Add a new item to history
  static Future<void> addHistoryItem(String value, String type) async {
    final enabled = await isHistoryEnabled();
    if (!enabled) return;

    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory(type);

    // Add new item at the beginning
    final newItem = GenerationHistoryItem(
      value: value,
      timestamp: DateTime.now(),
      type: type,
    );

    history.insert(0, newItem);

    // Keep only the latest items
    if (history.length > maxHistoryItems) {
      history.removeRange(maxHistoryItems, history.length);
    }

    // Encrypt and save
    final jsonList = history.map((item) => item.toJson()).toList();
    final jsonString = json.encode(jsonList);
    final encryptedData = _encrypt(jsonString);

    await prefs.setString('${_historyKey}_$type', encryptedData);
  }

  /// Get history for a specific type
  static Future<List<GenerationHistoryItem>> getHistory(String type) async {
    final enabled = await isHistoryEnabled();
    if (!enabled) return [];

    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString('${_historyKey}_$type');

    if (encryptedData == null || encryptedData.isEmpty) {
      return [];
    }

    try {
      final decryptedData = _decrypt(encryptedData);
      if (decryptedData.isEmpty) return [];

      final jsonList = json.decode(decryptedData) as List;
      return jsonList
          .map((json) => GenerationHistoryItem.fromJson(json))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Clear history for a specific type
  static Future<void> clearHistory(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_historyKey}_$type');
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith(_historyKey)).toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Get total count of history items across all types
  static Future<int> getTotalHistoryCount() async {
    final enabled = await isHistoryEnabled();
    if (!enabled) return 0;

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where(
            (key) => key.startsWith(_historyKey) && key != _historyEnabledKey)
        .toList();

    int totalCount = 0;
    for (final key in keys) {
      final type = key.replaceFirst('${_historyKey}_', '');
      final history = await getHistory(type);
      totalCount += history.length;
    }

    return totalCount;
  }

  /// Get size of history data in bytes (estimated)
  static Future<int> getHistoryDataSize() async {
    final enabled = await isHistoryEnabled();
    if (!enabled) return 0;

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where(
            (key) => key.startsWith(_historyKey) && key != _historyEnabledKey)
        .toList();

    int totalSize = 0;
    for (final key in keys) {
      final data = prefs.getString(key) ?? '';
      totalSize += data.length * 2; // UTF-16 encoding estimate
    }

    return totalSize;
  }
}
