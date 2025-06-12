import 'package:hive/hive.dart';
import 'package:my_multi_tools/services/app_logger.dart';
import '../../models/currency_cache_model.dart';
import 'currency_service.dart';
import '../settings_service.dart';

class CurrencyCacheService {
  static const String _cacheBoxName = 'currency_cache';
  static const String _cacheKey = 'current_rates';

  static Box<CurrencyCacheModel>? _cacheBox;
  static bool _isFetching = false;

  // Initialize the cache service
  static Future<void> initialize() async {
    try {
      if (_cacheBox == null || !_cacheBox!.isOpen) {
        _cacheBox = await Hive.openBox<CurrencyCacheModel>(_cacheBoxName);
        logInfo('CurrencyCacheService: Box opened successfully');
      }
    } catch (e) {
      logError('CurrencyCacheService: Error opening box: $e');
      rethrow;
    }
  }

  // Get cached rates only (no auto-fetch) - for safe loading
  static Future<Map<String, double>> getCachedRates() async {
    await initialize();

    // Get cached data
    final cachedData = _cacheBox!.get(_cacheKey);

    // Load fetch times from cache if available
    if (cachedData != null) {
      _loadFetchTimesFromCache(cachedData);
    }

    // Return cached data if available and valid
    if (cachedData != null && cachedData.isValid) {
      logInfo('CurrencyCacheService: Returning cached data');
      return cachedData.rates;
    }

    logInfo('CurrencyCacheService: No valid cache, returning static rates');
    return CurrencyService.getStaticRates();
  }

  // Check if fetch is needed based on settings (without fetching)
  static Future<bool> shouldFetchRates() async {
    await initialize();

    final settings = await SettingsService.getSettings();
    final fetchMode = settings.currencyFetchMode;

    // Get cached data
    final cachedData = _cacheBox!.get(_cacheKey);

    if (cachedData == null) {
      return true; // No cache, should fetch
    }

    return cachedData.shouldRefresh(fetchMode);
  }

  // Get cached rates or fetch new ones based on settings (DEPRECATED - use getCachedRates + shouldFetchRates)
  static Future<Map<String, double>> getRates(
      {bool forceRefresh = false}) async {
    await initialize();

    final settings = await SettingsService.getSettings();
    final fetchMode = settings.currencyFetchMode;

    // Get cached data
    final cachedData = _cacheBox!.get(_cacheKey);

    // Load fetch times from cache if available
    if (cachedData != null) {
      _loadFetchTimesFromCache(cachedData);
    }

    // Determine if we need to fetch new rates based on mode
    bool shouldFetch = forceRefresh;

    if (!shouldFetch && cachedData == null) {
      shouldFetch = true;
    } else if (!shouldFetch && cachedData != null) {
      shouldFetch = cachedData.shouldRefresh(fetchMode);
    }

    if (shouldFetch && !_isFetching) {
      logInfo('CurrencyCacheService: Starting fetch...');
      try {
        _isFetching = true;
        final newRates = await CurrencyService.fetchLiveRates();
        logInfo(
            'CurrencyCacheService: Fetched ${newRates.length} rates, now saving to cache...');

        await _saveToCache(newRates);
        logInfo('CurrencyCacheService: Successfully saved to cache');

        // Verify the save worked
        final verifyCache = _cacheBox!.get(_cacheKey);
        logInfo(
            'CurrencyCacheService: Cache verification - data exists: ${verifyCache != null}');
        if (verifyCache != null) {
          logInfo(
              'CurrencyCacheService: Cache verification - rates count: ${verifyCache.rates.length}');
        }

        return newRates;
      } catch (e) {
        logError('CurrencyCacheService: Failed to fetch new rates: $e');
        if (cachedData != null && cachedData.isValid) {
          logInfo('CurrencyCacheService: Returning cached data as fallback');
          return cachedData.rates;
        }
        logInfo('CurrencyCacheService: Returning static rates as fallback');
        return CurrencyService.getStaticRates();
      } finally {
        _isFetching = false;
      }
    }

    // Return cached data if available and valid
    if (cachedData != null && cachedData.isValid) {
      logInfo('CurrencyCacheService: Returning cached data (no fetch needed)');
      return cachedData.rates;
    }

    logInfo('CurrencyCacheService: Returning static rates (no valid cache)');
    return CurrencyService.getStaticRates();
  }

  // Load fetch times from cache into CurrencyService
  static void _loadFetchTimesFromCache(CurrencyCacheModel cacheModel) {
    // Load fetch times
    if (cacheModel.currencyFetchTimes != null) {
      for (final entry in cacheModel.currencyFetchTimes!.entries) {
        final fetchTime = DateTime.fromMillisecondsSinceEpoch(entry.value);
        CurrencyService.updateCurrencyFetchTime(entry.key, fetchTime);
      }
      logInfo(
          'CurrencyCacheService: Loaded ${cacheModel.currencyFetchTimes!.length} fetch times from cache');
    }

    // Load currency statuses
    final statuses = cacheModel.getCurrencyStatuses();
    if (statuses.isNotEmpty) {
      CurrencyService.updateCurrencyStatuses(statuses);
      logInfo(
          'CurrencyCacheService: Loaded ${statuses.length} currency statuses from cache');
    }

    // Apply status transitions based on current time to ensure status accuracy
    CurrencyService.updateStatusAfterLoad();
  }

  // Save rates to cache
  static Future<void> _saveToCache(Map<String, double> rates) async {
    try {
      await initialize();

      logInfo(
          'CurrencyCacheService: Creating cache model with ${rates.length} rates');
      final cacheModel = CurrencyCacheModel(
        rates: Map<String, double>.from(rates), // Ensure proper type
        lastUpdated: DateTime.now(),
        isValid: true,
      );

      // Also save currency statuses
      final statuses = CurrencyService.currencyStatuses;
      if (statuses.isNotEmpty) {
        cacheModel.setCurrencyStatuses(statuses);
        logInfo(
            'CurrencyCacheService: Saved ${statuses.length} currency statuses');
      }

      // Save currency fetch times
      final fetchTimes = <String, DateTime>{};
      for (final currency in rates.keys) {
        final fetchTime = CurrencyService.getCurrencyLastFetchTime(currency);
        if (fetchTime != null) {
          fetchTimes[currency] = fetchTime;
        }
      }

      if (fetchTimes.isNotEmpty) {
        cacheModel.setCurrencyFetchTimes(fetchTimes);
        logInfo(
            'CurrencyCacheService: Saved ${fetchTimes.length} currency fetch times');
      }

      logInfo('CurrencyCacheService: Saving to cache with key: $_cacheKey');
      await _cacheBox!.put(_cacheKey, cacheModel);

      // Force flush to disk
      await _cacheBox!.flush();
      logInfo('CurrencyCacheService: Cache saved and flushed to disk');
    } catch (e) {
      logError('CurrencyCacheService: Error saving to cache: $e');
      rethrow;
    }
  }

  // Get cached data info
  static Future<CurrencyCacheModel?> getCacheInfo() async {
    try {
      await initialize();
      final data = _cacheBox!.get(_cacheKey);
      logInfo(
          'CurrencyCacheService: getCacheInfo - data exists: ${data != null}');
      return data;
    } catch (e) {
      logError('CurrencyCacheService: Error getting cache info: $e');
      return null;
    }
  }

  // Check if currently fetching
  static bool get isFetching => _isFetching;

  // Clear cache
  static Future<void> clearCache() async {
    try {
      await initialize();
      await _cacheBox!.delete(_cacheKey);
      await _cacheBox!.flush();

      // Reset CurrencyService to static rates
      CurrencyService.resetToStaticRates();

      logInfo('CurrencyCacheService: Cache cleared and service reset');
    } catch (e) {
      logError('CurrencyCacheService: Error clearing cache: $e');
    }
  }

  // Get last updated time
  static Future<DateTime?> getLastUpdated() async {
    try {
      await initialize();
      final cachedData = _cacheBox!.get(_cacheKey);
      return cachedData?.lastUpdated;
    } catch (e) {
      logError('CurrencyCacheService: Error getting last updated: $e');
      return null;
    }
  }

  // Check if cache exists and is valid
  static Future<bool> hasCachedData() async {
    try {
      await initialize();
      final cachedData = _cacheBox!.get(_cacheKey);
      final hasData = cachedData != null && cachedData.isValid;
      logInfo('CurrencyCacheService: hasCachedData: $hasData');
      return hasData;
    } catch (e) {
      logError('CurrencyCacheService: Error checking cached data: $e');
      return false;
    }
  }

  // Force refresh rates (DEPRECATED - use forceRefreshWithDialog)
  static Future<Map<String, double>> forceRefresh() async {
    logInfo('CurrencyCacheService: Force refresh requested');
    return await getRates(forceRefresh: true);
  }

  // Force refresh rates (for use with dialog only - no background fetch)
  static Future<Map<String, double>> forceRefreshWithDialog() async {
    logInfo('CurrencyCacheService: Force refresh with dialog requested');
    await initialize();

    if (_isFetching) {
      logInfo('CurrencyCacheService: Already fetching, returning cached data');
      return await getCachedRates();
    }

    try {
      _isFetching = true;

      // This should only be called when progress dialog is already showing
      final newRates = await CurrencyService.fetchLiveRates();
      logInfo(
          'CurrencyCacheService: Fetched ${newRates.length} rates, now saving to cache...');

      await _saveToCache(newRates);
      logInfo('CurrencyCacheService: Successfully saved to cache');

      return newRates;
    } catch (e) {
      logError('CurrencyCacheService: Failed to fetch new rates: $e');
      // Return cached data as fallback
      return await getCachedRates();
    } finally {
      _isFetching = false;
    }
  }

  // Debug method to check cache content
  static Future<void> debugCache() async {
    try {
      await initialize();
      final cachedData = _cacheBox!.get(_cacheKey);
      logInfo('=== CACHE DEBUG ===');
      logInfo('Cache exists: ${cachedData != null}');
      if (cachedData != null) {
        logInfo('Last updated: ${cachedData.lastUpdated}');
        logInfo('Is valid: ${cachedData.isValid}');
        logInfo('Is expired: ${cachedData.isExpired}');
        logInfo('Rates count: ${cachedData.rates.length}');
        logInfo(
            'Sample rates: ${cachedData.rates.entries.take(3).map((e) => '${e.key}: ${e.value}').join(', ')}');
      }
      logInfo('=== END DEBUG ===');
    } catch (e) {
      logError('CurrencyCacheService: Error in debug: $e');
    }
  }
}
