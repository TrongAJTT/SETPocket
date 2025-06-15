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
import 'converter_services/time_state_service.dart';
import 'converter_services/volume_state_service.dart';
import 'converter_services/number_system_state_service.dart';
import 'converter_services/speed_state_service.dart';
import 'converter_services/temperature_state_service.dart';
import 'converter_services/generic_preset_service.dart';
import 'package:hive/hive.dart';

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
      try {
        final hasState = await CurrencyStateService.hasState();
        if (hasState) {
          final stateSize = await CurrencyStateService.getStateSize();
          converterSize += stateSize;
          converterCount++; // Count as 1 item for currency state
        }
      } catch (e) {
        logError('CacheService: Error checking currency state: $e');
        // Continue without currency state info
      }

      // Length state
      try {
        final hasLengthState = await LengthStateService.hasState();
        if (hasLengthState) {
          final lengthStateSize = await LengthStateService.getStateSize();
          converterSize += lengthStateSize;
          converterCount++; // Count as 1 item for length state
        }
      } catch (e) {
        logError('CacheService: Error checking length state: $e');
        // Continue without length state info
      }

      // Length presets
      try {
        final lengthPresets = await GenericPresetService.loadPresets('length');
        if (lengthPresets.isNotEmpty) {
          converterSize += (lengthPresets.length * 50)
              .toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for length presets
        }
      } catch (e) {
        logError('CacheService: Error checking length presets: $e');
        // Continue without length presets info
      }

      // Mass state
      try {
        final hasMassState = await MassStateService.hasState();
        if (hasMassState) {
          final massStateSize = await MassStateService.getStateSize();
          converterSize += massStateSize;
          converterCount++; // Count as 1 item for mass state
        }
      } catch (e) {
        logError('CacheService: Error checking mass state: $e');
        // Continue without mass state info
      }

      // Mass presets
      try {
        final massPresets = await GenericPresetService.loadPresets('mass');
        if (massPresets.isNotEmpty) {
          converterSize +=
              (massPresets.length * 50).toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for mass presets
        }
      } catch (e) {
        logError('CacheService: Error checking mass presets: $e');
        // Continue without mass presets info
      }

      // Weight state
      try {
        final hasWeightState = await WeightStateService.hasState();
        if (hasWeightState) {
          final weightStateSize = await WeightStateService.getStateSize();
          converterSize += weightStateSize.toInt();
          converterCount++; // Count as 1 item for weight state
        }
      } catch (e) {
        logError('CacheService: Error checking weight state: $e');
        // Continue without weight state info
      }

      // Weight presets
      try {
        final weightPresets = await GenericPresetService.loadPresets('weight');
        if (weightPresets.isNotEmpty) {
          converterSize += (weightPresets.length * 50)
              .toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for weight presets
        }
      } catch (e) {
        logError('CacheService: Error checking weight presets: $e');
        // Continue without weight presets info
      }

      // Area state
      try {
        final hasAreaState = await AreaStateService.hasState();
        if (hasAreaState) {
          final areaStateSize = await AreaStateService.getStateSize();
          converterSize += areaStateSize.toInt();
          converterCount++; // Count as 1 item for area state
        }
      } catch (e) {
        logError('CacheService: Error checking area state: $e');
        // Continue without area state info
      }

      // Area presets
      try {
        final areaPresets = await GenericPresetService.loadPresets('area');
        if (areaPresets.isNotEmpty) {
          converterSize +=
              (areaPresets.length * 50).toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for area presets
        }
      } catch (e) {
        logError('CacheService: Error checking area presets: $e');
        // Continue without area presets info
      }

      // Time state
      try {
        final hasTimeState = await TimeStateService.hasState();
        if (hasTimeState) {
          final timeStateSize = await TimeStateService.getStateSize();
          converterSize += timeStateSize.toInt();
          converterCount++; // Count as 1 item for time state
        }
      } catch (e) {
        logError('CacheService: Error checking time state: $e');
        // Continue without time state info
      }

      // Time presets
      try {
        final timePresets = await GenericPresetService.loadPresets('time');
        if (timePresets.isNotEmpty) {
          converterSize +=
              (timePresets.length * 50).toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for time presets
        }
      } catch (e) {
        logError('CacheService: Error checking time presets: $e');
        // Continue without time presets info
      }

      // Volume state
      try {
        final hasVolumeState = await VolumeStateService.hasState();
        if (hasVolumeState) {
          final volumeStateSize = await VolumeStateService.getStateSize();
          converterSize += volumeStateSize;
          converterCount++; // Count as 1 item for volume state
        }
      } catch (e) {
        logError('CacheService: Error checking volume state: $e');
        // Continue without volume state info
      }

      // Volume presets
      try {
        final volumePresets = await GenericPresetService.loadPresets('volume');
        if (volumePresets.isNotEmpty) {
          converterSize += (volumePresets.length * 50)
              .toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for volume presets
        }
      } catch (e) {
        logError('CacheService: Error checking volume presets: $e');
        // Continue without volume presets info
      }

      // Number system state
      try {
        final hasNumberSystemState = await NumberSystemStateService.hasState();
        if (hasNumberSystemState) {
          final numberSystemStateSize =
              await NumberSystemStateService.getStateSize();
          converterSize += numberSystemStateSize;
          converterCount++; // Count as 1 item for number system state
        }
      } catch (e) {
        logError('CacheService: Error checking number system state: $e');
        // Continue without number system state info
      }

      // Number system presets
      try {
        final numberSystemPresets =
            await GenericPresetService.loadPresets('number_system');
        if (numberSystemPresets.isNotEmpty) {
          converterSize += (numberSystemPresets.length * 50)
              .toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for number system presets
        }
      } catch (e) {
        logError('CacheService: Error checking number system presets: $e');
        // Continue without number system presets info
      }

      // Speed state
      try {
        final hasSpeedState = await SpeedStateService.hasState();
        if (hasSpeedState) {
          final speedStateSize = await SpeedStateService.getStateSize();
          converterSize += speedStateSize;
          converterCount++; // Count as 1 item for speed state
        }
      } catch (e) {
        logError('CacheService: Error checking speed state: $e');
        // Continue without speed state info
      }

      // Speed presets
      try {
        final speedPresets = await GenericPresetService.loadPresets('speed');
        if (speedPresets.isNotEmpty) {
          converterSize +=
              (speedPresets.length * 50).toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for speed presets
        }
      } catch (e) {
        logError('CacheService: Error checking speed presets: $e');
        // Continue without speed presets info
      }

      // Temperature state
      try {
        final hasTemperatureState = await TemperatureStateService.hasState();
        if (hasTemperatureState) {
          final temperatureStateSize =
              await TemperatureStateService.getStateSize();
          converterSize += temperatureStateSize;
          converterCount++; // Count as 1 item for temperature state
        }
      } catch (e) {
        logError('CacheService: Error checking temperature state: $e');
        // Continue without temperature state info
      }

      // Temperature presets
      try {
        final temperaturePresets =
            await GenericPresetService.loadPresets('temperature');
        if (temperaturePresets.isNotEmpty) {
          converterSize += (temperaturePresets.length * 50)
              .toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for temperature presets
        }
      } catch (e) {
        logError('CacheService: Error checking temperature presets: $e');
        // Continue without temperature presets info
      }

      cacheInfoMap['converter_tools'] = CacheInfo(
        name: converterToolsName ?? 'Converter Tools',
        description: converterToolsDesc ??
            'Currency/length/mass/weight/area/time/volume/number_system/speed/temperature states, presets and exchange rates cache',
        itemCount: converterCount,
        sizeBytes: converterSize,
        keys: _cacheKeys['converter_tools'] ?? [],
      );
    } catch (e) {
      logError('CacheService: Error getting converter tools cache info: $e');
      cacheInfoMap['converter_tools'] = CacheInfo(
        name: converterToolsName ?? 'Converter Tools',
        description: converterToolsDesc ??
            'Currency/length/mass/weight/area/time/volume/number_system/speed/temperature states, presets and exchange rates cache',
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
      // Close all converter boxes first to avoid type conflicts
      try {
        await _closeConverterBoxes();
      } catch (e) {
        logError('CacheService: Error closing converter boxes: $e');
      }

      // Clear currency presets, exchange rates cache, and converter states
      await CurrencyPresetService.clearAllPresets();
      await CurrencyCacheService.clearCache();
      await CurrencyStateService.clearState();
      await LengthStateService.clearState();
      await MassStateService.clearState();
      await WeightStateService.clearState();
      await AreaStateService.clearState();
      await TimeStateService.clearState();
      await VolumeStateService.clearState();
      await NumberSystemStateService.clearState();
      await SpeedStateService.clearState();
      await TemperatureStateService.clearState();

      // Clear generic presets for all converter types
      await GenericPresetService.clearAllPresets('length');
      await GenericPresetService.clearAllPresets('mass');
      await GenericPresetService.clearAllPresets('weight');
      await GenericPresetService.clearAllPresets('area');
      await GenericPresetService.clearAllPresets('time');
      await GenericPresetService.clearAllPresets('volume');
      await GenericPresetService.clearAllPresets('number_system');
      await GenericPresetService.clearAllPresets('speed');
      await GenericPresetService.clearAllPresets('temperature');
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

    // Close all converter boxes first to avoid type conflicts
    try {
      await _closeConverterBoxes();
    } catch (e) {
      logError('CacheService: Error closing converter boxes: $e');
    }

    // Clear converter tools cache (includes states and presets)
    await CurrencyPresetService.clearAllPresets();
    await CurrencyCacheService.clearCache();
    await CurrencyStateService.clearState();
    await LengthStateService.clearState();
    await MassStateService.clearState();
    await WeightStateService.clearState();
    await AreaStateService.clearState();
    await TimeStateService.clearState();
    await VolumeStateService.clearState();
    await NumberSystemStateService.clearState();
    await SpeedStateService.clearState();
    await TemperatureStateService.clearState();

    // Clear generic presets for all converter types
    await GenericPresetService.clearAllPresets('length');
    await GenericPresetService.clearAllPresets('mass');
    await GenericPresetService.clearAllPresets('weight');
    await GenericPresetService.clearAllPresets('area');
    await GenericPresetService.clearAllPresets('time');
    await GenericPresetService.clearAllPresets('volume');
    await GenericPresetService.clearAllPresets('number_system');
    await GenericPresetService.clearAllPresets('speed');
    await GenericPresetService.clearAllPresets('temperature');

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

  static Future<void> _closeConverterBoxes() async {
    // Close all converter state boxes to avoid type conflicts
    final boxNames = [
      'currency_state',
      'length_states',
      'mass_state',
      'weight_state',
      'area_converter_state',
      'time_state',
      'volume_state',
      'number_system_state',
      'speed_state',
      'temperature_states',
      'currency_presets',
      'generic_length_presets',
      'generic_mass_presets',
      'generic_weight_presets',
      'generic_area_presets',
      'generic_time_presets',
      'generic_volume_presets',
      'generic_number_system_presets',
      'generic_speed_presets',
      'generic_temperature_presets',
      'currency_cache',
    ];

    for (final boxName in boxNames) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.close();
          logInfo('CacheService: Closed box: $boxName');
        }
      } catch (e) {
        logError('CacheService: Error closing box $boxName: $e');
        // Continue with other boxes even if one fails
      }
    }
  }
}
