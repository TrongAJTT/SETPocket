import 'package:setpocket/services/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'template_service.dart';
import 'generation_history_service.dart';
import 'calculator_history_service.dart';
import 'graphing_calculator_service.dart';
import 'calculator_services/bmi_service.dart';
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
import 'converter_services/data_state_service.dart';
import 'converter_services/generic_preset_service.dart';
import 'random_services/random_state_service.dart';
import 'financial_calculator_service.dart';
import 'scientific_calculator_service.dart';
import 'date_calculator_service.dart';
import 'p2p_service.dart';
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
    'p2lan_transfer': [],
  };
  static Future<Map<String, CacheInfo>> getAllCacheInfo({
    String? textTemplatesName,
    String? textTemplatesDesc,
    String? appSettingsName,
    String? appSettingsDesc,
    String? randomGeneratorsName,
    String? randomGeneratorsDesc,
    String? calculatorToolsName,
    String? calculatorToolsDesc,
    String? converterToolsName,
    String? converterToolsDesc,
    String? p2pDataTransferName,
    String? p2pDataTransferDesc,
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

    // Random Generators Cache - Get actual history data and random states
    final historyEnabled = await GenerationHistoryService.isHistoryEnabled();
    final historyCount = await GenerationHistoryService.getTotalHistoryCount();
    final historySize = await GenerationHistoryService.getHistoryDataSize();

    // Add random states to cache calculation
    int randomStateSize = 0;
    int randomStateCount = 0;
    try {
      final hasRandomState = await RandomStateService.hasState();
      if (hasRandomState) {
        randomStateSize = await RandomStateService.getStateSize();
        final stateKeys = RandomStateService.getAllStateKeys();
        randomStateCount = stateKeys.length;
      }
    } catch (e) {
      logError('CacheService: Error checking random states: $e');
    }

    cacheInfoMap['random_generators'] = CacheInfo(
      name: randomGeneratorsName ?? 'Random Generators',
      description: randomGeneratorsDesc ??
          'Generation history, settings, and random tool states',
      itemCount: historyCount + (historyEnabled ? 1 : 0) + randomStateCount,
      sizeBytes: historySize + (historyEnabled ? 4 : 0) + randomStateSize,
      keys: (_cacheKeys['random_generators'] ?? []) +
          RandomStateService.getAllStateKeys(),
    );

    // Calculator Tools Cache
    try {
      final calculatorHistoryEnabled =
          await CalculatorHistoryService.isHistoryEnabled();
      final calculatorHistoryCount =
          await CalculatorHistoryService.getTotalHistoryCount();
      final calculatorHistorySize =
          await CalculatorHistoryService.getHistoryDataSize();

      // Include graphing calculator cache
      final graphingCalculatorCache =
          await GraphingCalculatorService.getCacheInfo();

      // Include BMI calculator cache
      int bmiSize = 0;
      int bmiCount = 0;
      try {
        final hasBmiData = await BmiService.hasData();
        if (hasBmiData) {
          bmiSize = await BmiService.getDataSize();
          final bmiHistory = await BmiService.getHistory();
          final bmiPreferences = await BmiService.getPreferences();

          // Count items
          bmiCount += bmiHistory.length;
          if (bmiPreferences.isNotEmpty) {
            bmiCount += 1; // Preferences as one item
          }
        }
      } catch (e) {
        logError('CacheService: Error checking BMI cache: $e');
      }

      // Include financial calculator cache
      int financialSize = 0;
      int financialCount = 0;
      try {
        final financialCache = await FinancialCalculatorService.getCacheInfo();
        financialSize = financialCache['size'] as int;
        financialCount = financialCache['items'] as int;
      } catch (e) {
        logError('CacheService: Error checking financial calculator cache: $e');
      }

      // Include scientific calculator cache
      int scientificSize = 0;
      int scientificCount = 0;
      try {
        final scientificCache =
            await ScientificCalculatorService.getCacheInfo();
        scientificSize = scientificCache['size'] as int;
        scientificCount = scientificCache['items'] as int;
      } catch (e) {
        logError(
            'CacheService: Error checking scientific calculator cache: $e');
      }

      // Include date calculator cache
      int dateCalculatorSize = 0;
      int dateCalculatorCount = 0;
      try {
        final dateCalculatorService = DateCalculatorService();
        final dateCalculatorCache = await dateCalculatorService.getCacheInfo();
        dateCalculatorSize = dateCalculatorCache['size'] as int;
        dateCalculatorCount = dateCalculatorCache['items'] as int;
      } catch (e) {
        logError('CacheService: Error checking date calculator cache: $e');
      }

      cacheInfoMap['calculator_tools'] = CacheInfo(
        name: calculatorToolsName ?? 'Calculator Tools',
        description: calculatorToolsDesc ??
            'Calculation history, graphing calculator data, BMI data, financial calculator data, scientific calculator data, date calculator data, and settings',
        itemCount: calculatorHistoryCount +
            (calculatorHistoryEnabled ? 1 : 0) +
            (graphingCalculatorCache['items'] as int) +
            bmiCount +
            financialCount +
            scientificCount +
            dateCalculatorCount,
        sizeBytes: calculatorHistorySize +
            (calculatorHistoryEnabled ? 4 : 0) +
            (graphingCalculatorCache['size'] as int) +
            bmiSize +
            financialSize +
            scientificSize +
            dateCalculatorSize,
        keys: [
          'calculator_history_enabled',
          'graphing_calculator_ask_before_loading',
          'bmi_data', // BMI cache key
          'financial_calculator_history',
          'financial_calculator_state',
          'scientific_calculator_state',
          'date_calculator_history',
          'date_calculator_state',
        ],
      );
    } catch (e) {
      logError('CacheService: Error getting calculator tools cache info: $e');
      cacheInfoMap['calculator_tools'] = CacheInfo(
        name: calculatorToolsName ?? 'Calculator Tools',
        description: calculatorToolsDesc ??
            'Calculation history, graphing calculator data, BMI data, financial calculator data, scientific calculator data, date calculator data, and settings',
        itemCount: 0,
        sizeBytes: 0,
        keys: [
          'calculator_history_enabled',
          'graphing_calculator_ask_before_loading',
          'bmi_data',
          'financial_calculator_history',
          'financial_calculator_state',
          'scientific_calculator_state',
          'date_calculator_history',
          'date_calculator_state',
        ],
      );
    }

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

      // Data Storage state
      try {
        final hasDataState = await DataStateService.hasState();
        if (hasDataState) {
          final dataStateSize = await DataStateService.getCacheSize();
          converterSize += dataStateSize;
          converterCount++; // Count as 1 item for data storage state
        }
      } catch (e) {
        logError('CacheService: Error checking data storage state: $e');
        // Continue without data storage state info
      }

      // Data Storage presets
      try {
        final dataPresets =
            await GenericPresetService.loadPresets('data_storage');
        if (dataPresets.isNotEmpty) {
          converterSize +=
              (dataPresets.length * 50).toInt(); // Approximate size per preset
          converterCount++; // Count as 1 item for data storage presets
        }
      } catch (e) {
        logError('CacheService: Error checking data storage presets: $e');
        // Continue without data storage presets info
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

    // P2P Data Transfer Cache
    try {
      int p2pSize = 0;
      int p2pCount = 0;

      // Check if P2P service has cached data
      final p2pBoxNames = [
        'p2p_users',
        'pairing_requests',
        'p2p_storage_settings'
      ];

      logInfo('CacheService: Checking P2P cache...');

      for (final boxName in p2pBoxNames) {
        try {
          logInfo('CacheService: Checking box $boxName...');

          final boxExists = await Hive.boxExists(boxName);
          logInfo('CacheService: Box $boxName exists: $boxExists');

          if (boxExists) {
            // Try to open box and read data - check if already open first
            Box box;
            bool wasAlreadyOpen = false;

            try {
              if (Hive.isBoxOpen(boxName)) {
                box = Hive.box(boxName);
                wasAlreadyOpen = true;
                logInfo('CacheService: Box $boxName was already open');
              } else {
                box = await Hive.openBox(boxName);
                logInfo('CacheService: Opened box $boxName');
              }

              final boxLength = box.length;

              // Calculate size manually since HiveService.getBoxSize doesn't support P2P boxes
              int boxSize = 0;
              try {
                for (var key in box.keys) {
                  final value = box.get(key);
                  if (value != null) {
                    // Estimate size based on JSON representation
                    final jsonString = value.toString();
                    boxSize += jsonString.length * 2; // UTF-16 estimate
                  }
                }
              } catch (e) {
                logError(
                    'CacheService: Error calculating size for $boxName: $e');
                boxSize = boxLength * 100; // Fallback estimate
              }

              logInfo(
                  'CacheService: Box $boxName has $boxLength items, size: $boxSize bytes');

              p2pSize += boxSize;
              p2pCount += boxLength;

              // Log some details about the content
              if (boxLength > 0) {
                logInfo(
                    'CacheService: Box $boxName keys: ${box.keys.take(5).toList()}');

                // Log first item details for debugging
                final firstKey = box.keys.first;
                final firstValue = box.get(firstKey);
                logInfo(
                    'CacheService: First item in $boxName: $firstKey -> ${firstValue.runtimeType}');
              }

              // Only close if we opened it ourselves
              if (!wasAlreadyOpen) {
                await box.close();
              }
            } catch (e) {
              logError('CacheService: Error accessing box $boxName: $e');
            }
          } else {
            logInfo(
                'CacheService: Box $boxName does not exist, checking if P2P service has data...');

            // Also check if P2P service has users that might not be saved yet
            if (boxName == 'p2p_users') {
              try {
                final p2pService = P2PService.instance;
                final pairedUsers = p2pService.pairedUsers;
                logInfo(
                    'CacheService: P2P service has ${pairedUsers.length} paired users');

                if (pairedUsers.isNotEmpty) {
                  // Estimate size for users that exist in memory but not in cache
                  p2pCount += pairedUsers.length;
                  p2pSize +=
                      pairedUsers.length * 200; // Approximate size per user
                  logInfo(
                      'CacheService: Added ${pairedUsers.length} in-memory users to cache count');
                }
              } catch (e) {
                logWarning('CacheService: Could not access P2P service: $e');
              }
            }
          }
        } catch (e) {
          logError('CacheService: Error checking P2P box $boxName: $e');
        }
      }

      logInfo(
          'CacheService: P2P cache total - Count: $p2pCount, Size: $p2pSize bytes');

      cacheInfoMap['p2lan_transfer'] = CacheInfo(
        name: p2pDataTransferName ?? 'P2Lan Transfer',
        description: p2pDataTransferDesc ??
            'P2P users, pairing data, and transfer settings',
        itemCount: p2pCount,
        sizeBytes: p2pSize,
        keys: _cacheKeys['p2lan_transfer'] ?? [],
      );
    } catch (e) {
      logError('CacheService: Error getting P2P cache info: $e');
      cacheInfoMap['p2lan_transfer'] = CacheInfo(
        name: p2pDataTransferName ?? 'P2Lan Transfer',
        description: p2pDataTransferDesc ??
            'P2P users, pairing data, and transfer settings',
        itemCount: 0,
        sizeBytes: 0,
        keys: _cacheKeys['p2lan_transfer'] ?? [],
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
    } else if (cacheType == 'calculator_tools') {
      // Clear all calculator history through the service
      await CalculatorHistoryService.clearAllHistory();
      // Clear graphing calculator data
      await GraphingCalculatorService.clearAllCache();
      // Clear BMI calculator data
      try {
        await BmiService.clearHistory();
        await BmiService.clearPreferences();
      } catch (e) {
        logError('CacheService: Error clearing BMI cache: $e');
      }
      // Clear financial calculator data
      try {
        await FinancialCalculatorService.clearAllData();
      } catch (e) {
        logError('CacheService: Error clearing financial calculator cache: $e');
      }
      // Clear scientific calculator data
      try {
        await ScientificCalculatorService.clearAllData();
      } catch (e) {
        logError(
            'CacheService: Error clearing scientific calculator cache: $e');
      }
      // Clear date calculator data
      try {
        final dateCalculatorService = DateCalculatorService();
        await dateCalculatorService.clearHistory();
        await dateCalculatorService.clearCurrentState();
      } catch (e) {
        logError('CacheService: Error clearing date calculator cache: $e');
      }
      // Also clear the history enabled settings
      await prefs.remove('calculator_history_enabled');
      await prefs.remove('graphing_calculator_ask_before_loading');
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
      await DataStateService.clearState();

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
      await GenericPresetService.clearAllPresets('data_storage');
    } else if (cacheType == 'p2lan_transfer') {
      // Clear P2P data transfer cache
      await clearP2PCache();
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
    await CalculatorHistoryService.clearAllHistory();

    // Clear BMI calculator data
    try {
      await BmiService.clearHistory();
      await BmiService.clearPreferences();
    } catch (e) {
      logError('CacheService: Error clearing BMI cache in clearAllCache: $e');
    }

    // Clear financial calculator data
    try {
      await FinancialCalculatorService.clearAllData();
    } catch (e) {
      logError(
          'CacheService: Error clearing financial calculator cache in clearAllCache: $e');
    }

    // Clear scientific calculator data
    try {
      await ScientificCalculatorService.clearAllData();
    } catch (e) {
      logError(
          'CacheService: Error clearing scientific calculator cache in clearAllCache: $e');
    }

    // Clear date calculator data
    try {
      final dateCalculatorService = DateCalculatorService();
      await dateCalculatorService.clearHistory();
      await dateCalculatorService.clearCurrentState();
    } catch (e) {
      logError(
          'CacheService: Error clearing date calculator cache in clearAllCache: $e');
    }

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
    await DataStateService.clearState();

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
    await GenericPresetService.clearAllPresets('data_storage');

    // Clear P2P data transfer cache only if not enabled
    try {
      if (!(await isP2PEnabled())) {
        await clearP2PCache();
        logInfo('CacheService: Cleared P2P cache in clearAllCache');
      } else {
        logInfo(
            'CacheService: Skipped P2P cache in clearAllCache (service enabled)');
      }
    } catch (e) {
      logError('CacheService: Error handling P2P cache in clearAllCache: $e');
    }

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

  static Future<int> getTotalLogSize() async {
    try {
      return await AppLogger.instance.getTotalLogSize();
    } catch (e) {
      return 0;
    }
  }

  static String formatCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Method to add cache tracking for other features in the future
  static Future<void> addCacheKey(String cacheType, String key) async {
    // This can be used to dynamically add cache keys for new features
  }

  /// Clear P2P Data Transfer cache
  static Future<void> clearP2PCache() async {
    final p2pBoxNames = [
      'p2p_users',
      'pairing_requests',
      'p2p_storage_settings'
    ];

    for (final boxName in p2pBoxNames) {
      try {
        await HiveService.clearBox(boxName);
        logInfo('CacheService: Cleared P2P box: $boxName');
      } catch (e) {
        logError('CacheService: Error clearing P2P box $boxName: $e');
      }
    }
  }

  /// Check if P2P Data Transfer is currently enabled
  static Future<bool> isP2PEnabled() async {
    try {
      return P2PService.instance.isEnabled;
    } catch (e) {
      logError('CacheService: Error checking P2P status: $e');
      return false;
    }
  }

  /// Check if a cache type can be cleared (conditional clearing)
  static Future<bool> canClearCache(String cacheType) async {
    switch (cacheType) {
      case 'p2lan_transfer':
        // Can't clear P2P cache if service is currently enabled
        return !(await isP2PEnabled());
      default:
        return true; // Other caches can always be cleared
    }
  }

  /// Get the reason why a cache type cannot be cleared
  static Future<String?> getClearCacheBlockReason(String cacheType) async {
    switch (cacheType) {
      case 'p2lan_transfer':
        if (await isP2PEnabled()) {
          return 'P2Lan Transfer is currently active. Stop the service to clear cache.';
        }
        return null;
      default:
        return null;
    }
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
      'bmi_data', // BMI calculator data box
      'scientific_calculator_state',
      'date_calculator_history',
      'date_calculator_state',
      'financial_calculator_history',
      'financial_calculator_state',
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

  /// Force sync P2P data from memory to cache (if data exists in memory but not in Hive)
  static Future<void> syncP2PDataToCache() async {
    try {
      logInfo('CacheService: Starting P2P data sync...');

      final p2pService = P2PService.instance;

      // Check discovered users
      final discoveredUsers = p2pService.discoveredUsers;
      logInfo(
          'CacheService: P2P service has ${discoveredUsers.length} discovered users');

      // Check paired users specifically
      final pairedUsers = p2pService.pairedUsers;
      logInfo(
          'CacheService: P2P service has ${pairedUsers.length} paired users');

      // Check stored users
      final storedUsers = discoveredUsers.where((u) => u.isStored).toList();
      logInfo(
          'CacheService: P2P service has ${storedUsers.length} stored users');

      if (pairedUsers.isNotEmpty) {
        logInfo('CacheService: Paired users details:');
        for (var user in pairedUsers) {
          logInfo(
              '  - ${user.displayName} (${user.id}): paired=${user.isPaired}, trusted=${user.isTrusted}, stored=${user.isStored}');
        }

        // Check if these users are actually saved to Hive
        try {
          final box = Hive.isBoxOpen('p2p_users')
              ? Hive.box<P2PUser>('p2p_users')
              : await Hive.openBox<P2PUser>('p2p_users');
          logInfo('CacheService: p2p_users box has ${box.length} items');

          for (var user in pairedUsers) {
            final savedUser = box.get(user.id);
            if (savedUser != null) {
              logInfo('CacheService: User ${user.displayName} found in cache');
            } else {
              logInfo(
                  'CacheService: User ${user.displayName} NOT found in cache - this might be the issue!');

              // Force save user to cache if it's paired but not saved
              if (user.isPaired && user.isStored) {
                await box.put(user.id, user);
                logInfo(
                    'CacheService: Force saved user ${user.displayName} to cache');
              }
            }
          }

          // Don't close the box if it was already open in the service
          if (!Hive.isBoxOpen('p2p_users')) {
            await box.close();
          }
        } catch (e) {
          logError('CacheService: Error checking p2p_users box: $e');
        }
      }

      logInfo('CacheService: P2P data sync completed');
    } catch (e) {
      logError('CacheService: Error during P2P data sync: $e');
    }
  }

  /// Debug P2P cache state
  static Future<Map<String, dynamic>> debugP2PCache() async {
    final result = <String, dynamic>{};

    try {
      // Check P2P service state
      final p2pService = P2PService.instance;
      result['service_enabled'] = p2pService.isEnabled;
      result['discovered_users'] = p2pService.discoveredUsers.length;
      result['paired_users'] = p2pService.pairedUsers.length;
      result['stored_users'] =
          p2pService.discoveredUsers.where((u) => u.isStored).length;

      // Check Hive boxes
      final boxStates = <String, Map<String, dynamic>>{};
      final boxNames = [
        'p2p_users',
        'pairing_requests',
        'p2p_storage_settings'
      ];

      for (final boxName in boxNames) {
        try {
          final exists = await Hive.boxExists(boxName);
          boxStates[boxName] = {'exists': exists};

          if (exists) {
            final box = Hive.isBoxOpen(boxName)
                ? Hive.box(boxName)
                : await Hive.openBox(boxName);
            boxStates[boxName]!['length'] = box.length;
            boxStates[boxName]!['keys'] = box.keys.take(5).toList();

            // Don't close if it was already open
            if (!Hive.isBoxOpen(boxName)) {
              await box.close();
            }
          }
        } catch (e) {
          boxStates[boxName] = {'error': e.toString()};
        }
      }

      result['hive_boxes'] = boxStates;

      // Get cache info
      final cacheInfo = await getAllCacheInfo();
      final p2pCache = cacheInfo['p2lan_transfer'];
      result['cache_info'] = {
        'item_count': p2pCache?.itemCount ?? 0,
        'size_bytes': p2pCache?.sizeBytes ?? 0,
      };
    } catch (e) {
      result['error'] = e.toString();
    }

    return result;
  }
}
