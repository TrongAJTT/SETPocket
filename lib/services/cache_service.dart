import 'package:shared_preferences/shared_preferences.dart';
import 'template_service.dart';

class CacheInfo {
  final String name;
  final String description;
  final int itemCount;
  final int sizeBytes;
  final List<String> keys;

  CacheInfo({
    required this.name,
    required this.description,
    required this.itemCount,
    required this.sizeBytes,
    required this.keys,
  });
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
  }
}

class CacheService {
  static const String _templatesKey = 'templates';

  // Cache keys for different features
  static const Map<String, List<String>> _cacheKeys = {
    'text_templates': [_templatesKey],
    'settings': ['themeMode', 'language'],
    'random_generators': [
      'lastGeneratedPasswords',
      'lastGeneratedNumbers',
      'lastGeneratedDates'
    ],
  };

  static Future<Map<String, CacheInfo>> getAllCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, CacheInfo> cacheInfoMap = {};

    // Text Templates Cache
    final templates = await TemplateService.getTemplates();
    final templatesJson = prefs.getStringList(_templatesKey) ?? [];
    final templatesSize = _calculateStringListSize(templatesJson);

    cacheInfoMap['text_templates'] = CacheInfo(
      name: 'Text Templates',
      description: 'Saved text templates and content',
      itemCount: templates.length,
      sizeBytes: templatesSize,
      keys: [_templatesKey],
    );

    // Settings Cache
    final settingsKeys = ['themeMode', 'language'];
    int settingsSize = 0;
    int settingsCount = 0;

    for (final key in settingsKeys) {
      if (prefs.containsKey(key)) {
        settingsCount++;
        final value = prefs.get(key);
        if (value is String) {
          settingsSize += value.length * 2; // UTF-16 encoding
        } else if (value is int) {
          settingsSize += 4; // 32-bit integer
        }
      }
    }

    cacheInfoMap['settings'] = CacheInfo(
      name: 'App Settings',
      description: 'Theme, language, and user preferences',
      itemCount: settingsCount,
      sizeBytes: settingsSize,
      keys: settingsKeys,
    );

    // Random Generators Cache (potential future cache)
    cacheInfoMap['random_generators'] = CacheInfo(
      name: 'Random Generators',
      description: 'Generated results cache (currently empty)',
      itemCount: 0,
      sizeBytes: 0,
      keys: [
        'lastGeneratedPasswords',
        'lastGeneratedNumbers',
        'lastGeneratedDates'
      ],
    );

    return cacheInfoMap;
  }

  static Future<void> clearCache(String cacheType) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = _cacheKeys[cacheType] ?? [];

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Get all cache keys
    final allKeys = <String>{};
    for (final keyList in _cacheKeys.values) {
      allKeys.addAll(keyList);
    }

    // Remove all cache keys except settings (preserve user preferences)
    for (final key in allKeys) {
      if (!['themeMode', 'language'].contains(key)) {
        await prefs.remove(key);
      }
    }
  }

  static Future<int> getTotalCacheSize() async {
    final cacheInfoMap = await getAllCacheInfo();
    return cacheInfoMap.values
        .fold<int>(0, (sum, info) => sum + info.sizeBytes);
  }

  static String formatCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
  }

  static int _calculateStringListSize(List<String> list) {
    return list.fold(
        0, (sum, str) => sum + (str.length * 2)); // UTF-16 encoding
  }

  // Method to add cache tracking for other features in the future
  static Future<void> addCacheKey(String cacheType, String key) async {
    // This can be used to dynamically add cache keys for new features
  }
}
