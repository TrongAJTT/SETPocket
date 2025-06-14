import 'package:setpocket/services/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'template_service.dart';
import 'generation_history_service.dart';
import 'hive_service.dart';
import 'converter_services/currency_state_service.dart';
import 'converter_services/currency_preset_service.dart';
import 'converter_services/currency_cache_service.dart';
import 'converter_services/length_state_service.dart';
import 'converter_services/mass_state_service.dart';
import 'converter_services/weight_state_service.dart';
import 'converter_services/area_state_service.dart';
import 'converter_services/generic_preset_service.dart';

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
      'generation_history_enabled',
      'generation_history_password',
      'generation_history_number',
      'generation_history_date',
      'generation_history_time',
      'generation_history_date_time',
      'generation_history_color',
      'generation_history_latin_letter',
      'generation_history_playing_card',
      'generation_history_coin_flip',
      'generation_history_dice_roll',
      'generation_history_rock_paper_scissors',
    ],
    'converter_tools': [],
  };
  static Future<Map<String, CacheInfo>> getAllCacheInfo({
    String? textTemplatesName,
    String? textTemplatesDesc,
    String? appSettingsName,
    String? appSettingsDesc,
    String? randomGeneratorsName,
    String? randomGeneratorsDesc,
    String? converterToolsName,
    String? converterToolsDesc,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, CacheInfo> cacheInfoMap =
        {}; // Text Templates Cache - Now using Hive
    final templates = await TemplateService.getTemplates();
    final templatesSize = HiveService.getBoxSize(HiveService.templatesBoxName);

    cacheInfoMap['text_templates'] = CacheInfo(
      name: textTemplatesName ?? 'Text Templates',
      description: textTemplatesDesc ?? 'Saved text templates and content',
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
        } else if (value is bool) {
          settingsSize += 1; // 1 byte for boolean
        }
      }
    }
    cacheInfoMap['settings'] = CacheInfo(
      name: appSettingsName ?? 'App Settings',
      description: appSettingsDesc ?? 'Theme, language, and user preferences',
      itemCount: settingsCount,
      sizeBytes: settingsSize,
      keys: settingsKeys,
    );

    // Random Generators Cache - Get actual history data (now using Hive)
    final historyEnabled = await GenerationHistoryService.isHistoryEnabled();
    final historyCount = await GenerationHistoryService.getTotalHistoryCount();
    final historySize = await GenerationHistoryService.getHistoryDataSize();

    cacheInfoMap['random_generators'] = CacheInfo(
      name: randomGeneratorsName ?? 'Random Generators',
      description: randomGeneratorsDesc ?? 'Generation history and settings',
      itemCount:
          historyCount + (historyEnabled ? 1 : 0), // +1 for the enabled setting
      sizeBytes: historySize + (historyEnabled ? 4 : 0), // +4 bytes for boolean
      keys: _cacheKeys['random_generators'] ?? [],
    );

    // Converter Tools Cache (includes currency and length states)
    try {
      int converterSize = 0;
      int converterCount = 0;

      // Currency presets
      final presets = await CurrencyPresetService.loadPresets();
      for (final preset in presets) {
        converterSize +=
            preset.name.length * 2 + (preset.currencies.length * 6);
      }
      if (presets.isNotEmpty) {
        converterCount++; // Count as 1 item for currency presets
      }

      // Currency cache (exchange rates)
      final cacheInfo = await CurrencyCacheService.getCacheInfo();
      if (cacheInfo != null) {
        converterSize +=
            cacheInfo.rates.length * 12; // Approximate size per rate
        converterCount++; // Count as 1 item for currency cache
      }

      // Currency state
      final hasState = await CurrencyStateService.hasState();
      if (hasState) {
        final stateSize = await CurrencyStateService.getStateSize();
        converterSize += stateSize;
        converterCount++; // Count as 1 item for currency state
      }

      // Length state
      final hasLengthState = await LengthStateService.hasState();
      if (hasLengthState) {
        final lengthStateSize = await LengthStateService.getStateSize();
        converterSize += lengthStateSize;
        converterCount++; // Count as 1 item for length state
      }

      // Length presets
      final lengthPresets = await GenericPresetService.loadPresets('length');
      if (lengthPresets.isNotEmpty) {
        converterSize +=
            (lengthPresets.length * 50).toInt(); // Approximate size per preset
        converterCount++; // Count as 1 item for length presets
      }

      // Mass state
      final hasMassState = await MassStateService.hasState();
      if (hasMassState) {
        final massStateSize = await MassStateService.getStateSize();
        converterSize += massStateSize;
        converterCount++; // Count as 1 item for mass state
      }

      // Mass presets
      final massPresets = await GenericPresetService.loadPresets('mass');
      if (massPresets.isNotEmpty) {
        converterSize +=
            (massPresets.length * 50).toInt(); // Approximate size per preset
        converterCount++; // Count as 1 item for mass presets
      }

      // Weight state
      final hasWeightState = await WeightStateService.hasState();
      if (hasWeightState) {
        final weightStateSize = await WeightStateService.getStateSize();
        converterSize += weightStateSize.toInt();
        converterCount++; // Count as 1 item for weight state
      }

      // Weight presets
      final weightPresets = await GenericPresetService.loadPresets('weight');
      if (weightPresets.isNotEmpty) {
        converterSize +=
            (weightPresets.length * 50).toInt(); // Approximate size per preset
        converterCount++; // Count as 1 item for weight presets
      }

      // Area state
      final hasAreaState = await AreaStateService.hasState();
      if (hasAreaState) {
        final areaStateSize = await AreaStateService.getStateSize();
        converterSize += areaStateSize.toInt();
        converterCount++; // Count as 1 item for area state
      }

      // Area presets
      final areaPresets = await GenericPresetService.loadPresets('area');
      if (areaPresets.isNotEmpty) {
        converterSize +=
            (areaPresets.length * 50).toInt(); // Approximate size per preset
        converterCount++; // Count as 1 item for area presets
      }

      cacheInfoMap['converter_tools'] = CacheInfo(
        name: converterToolsName ?? 'Converter Tools',
        description: converterToolsDesc ??
            'Currency/length/mass/weight/area states, presets and exchange rates cache',
        itemCount: converterCount,
        sizeBytes: converterSize,
        keys: _cacheKeys['converter_tools'] ?? [],
      );
    } catch (e) {
      logError('CacheService: Error getting converter tools cache info: $e');
      cacheInfoMap['converter_tools'] = CacheInfo(
        name: converterToolsName ?? 'Converter Tools',
        description: converterToolsDesc ??
            'Currency/length/mass/weight/area states, presets and exchange rates cache',
        itemCount: 0,
        sizeBytes: 0,
        keys: _cacheKeys['converter_tools'] ?? [],
      );
    }

    return cacheInfoMap;
  }

  static Future<void> clearCache(String cacheType) async {
    final prefs = await SharedPreferences.getInstance();
    if (cacheType == 'random_generators') {
      // Clear all generation history through the service
      await GenerationHistoryService.clearAllHistory();
      // Also clear the history enabled setting
      await prefs.remove('generation_history_enabled');
    } else if (cacheType == 'text_templates') {
      // Clear templates cache from Hive
      await HiveService.clearBox(HiveService.templatesBoxName);
    } else if (cacheType == 'converter_tools') {
      // Clear currency presets, exchange rates cache, and converter states
      await CurrencyPresetService.clearAllPresets();
      await CurrencyCacheService.clearCache();
      await CurrencyStateService.clearState();
      await LengthStateService.clearState();
      await MassStateService.clearState();
      await WeightStateService.clearState();
      await AreaStateService.clearState();

      // Clear generic presets for all converter types
      await GenericPresetService.clearAllPresets('length');
      await GenericPresetService.clearAllPresets('mass');
      await GenericPresetService.clearAllPresets('weight');
      await GenericPresetService.clearAllPresets('area');
    } else {
      final keys = _cacheKeys[cacheType] ?? [];
      for (final key in keys) {
        await prefs.remove(key);
      }
    }
  }

  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear templates cache from Hive
    await HiveService.clearBox(HiveService.templatesBoxName);

    // Clear history cache from Hive
    await GenerationHistoryService.clearAllHistory();

    // Clear converter tools cache (includes states and presets)
    await CurrencyPresetService.clearAllPresets();
    await CurrencyCacheService.clearCache();
    await CurrencyStateService.clearState();
    await LengthStateService.clearState();
    await MassStateService.clearState();
    await WeightStateService.clearState();
    await AreaStateService.clearState();

    // Clear generic presets for all converter types
    await GenericPresetService.clearAllPresets('length');
    await GenericPresetService.clearAllPresets('mass');
    await GenericPresetService.clearAllPresets('weight');
    await GenericPresetService.clearAllPresets('area');

    // Get all cache keys from SharedPreferences (except settings)
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

  // Method to add cache tracking for other features in the future
  static Future<void> addCacheKey(String cacheType, String key) async {
    // This can be used to dynamically add cache keys for new features
  }
}
