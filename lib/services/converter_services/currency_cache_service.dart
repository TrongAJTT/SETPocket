import 'package:hive/hive.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/models/converter_models/currency_cache_model.dart';
import 'currency_service.dart';
import 'package:setpocket/services/settings_service.dart';

class CurrencyCacheService {
  static const String _cacheBoxName = 'currency_cache';
  static const String _cacheKey = 'current_rates';
  static const String _lastManualFetchKey = 'last_manual_fetch';
  static const Duration _manualFetchCooldown = Duration(hours: 6);

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

  // Clear cache (but preserve currency rates and rate limiting data)
  static Future<void> clearCache() async {
    try {
      await initialize();

      // Only clear general cache, but preserve currency cache and rate limiting
      // This method should NOT clear currency rates or manual fetch times
      // as requested by user

      logInfo(
          'CurrencyCacheService: Cache clearing requested, but currency rates and rate limiting data preserved');
    } catch (e) {
      logError('CurrencyCacheService: Error in cache operation: $e');
    }
  }

  // Clear all currency data (for complete reset - not exposed to user)
  // static Future<void> _clearAllCurrencyData() async {
  //   try {
  //     await initialize();
  //     await _cacheBox!.delete(_cacheKey);
  //     await _cacheBox!.flush();

  //     // Reset CurrencyService to static rates
  //     CurrencyService.resetToStaticRates();

  //     logInfo(
  //         'CurrencyCacheService: All currency data cleared and service reset');
  //   } catch (e) {
  //     logError('CurrencyCacheService: Error clearing all currency data: $e');
  //   }
  // }

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

    // Check rate limiting for manual fetch
    final isAllowed = await isManualFetchAllowed();
    if (!isAllowed) {
      logInfo(
          'CurrencyCacheService: Manual fetch blocked by rate limiting, returning cached data');
      return await getCachedRates();
    }

    // Record manual fetch time for rate limiting
    await _recordManualFetch();

    return await getRates(forceRefresh: true);
  }

  // Check if manual fetch is allowed (respects 6-hour rate limit)
  static Future<bool> isManualFetchAllowed() async {
    await initialize();

    try {
      // Use a dedicated box for rate limiting to avoid conflicts
      final rateLimitBox = await Hive.openBox('rate_limiting');
      final lastFetch = rateLimitBox.get(_lastManualFetchKey);

      if (lastFetch == null) {
        logInfo(
            'CurrencyCacheService: No previous manual fetch recorded, allowing fetch');
        return true; // No previous fetch recorded
      }

      final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetch);
      final now = DateTime.now();
      final timeSinceLastFetch = now.difference(lastFetchTime);

      final isAllowed = timeSinceLastFetch >= _manualFetchCooldown;
      logInfo(
          'CurrencyCacheService: Manual fetch allowed: $isAllowed (time since last: ${timeSinceLastFetch.inHours} hours)');

      return isAllowed;
    } catch (e) {
      logError(
          'CurrencyCacheService: Error checking manual fetch cooldown: $e');
      return true; // Allow if there's an error
    }
  }

  // Get remaining time until next manual fetch is allowed
  static Future<Duration?> getManualFetchCooldownRemaining() async {
    await initialize();

    try {
      // Use the same dedicated box for consistency
      final rateLimitBox = await Hive.openBox('rate_limiting');
      final lastFetch = rateLimitBox.get(_lastManualFetchKey);

      if (lastFetch == null) {
        return null; // No cooldown
      }

      final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetch);
      final now = DateTime.now();
      final timeSinceLastFetch = now.difference(lastFetchTime);

      if (timeSinceLastFetch >= _manualFetchCooldown) {
        return null; // No cooldown
      }

      return _manualFetchCooldown - timeSinceLastFetch;
    } catch (e) {
      logError(
          'CurrencyCacheService: Error getting manual fetch cooldown remaining: $e');
      return null; // No cooldown if error
    }
  }

  // Record manual fetch time
  static Future<void> _recordManualFetch() async {
    try {
      // Use the same dedicated box for consistency
      final rateLimitBox = await Hive.openBox('rate_limiting');
      await rateLimitBox.put(
          _lastManualFetchKey, DateTime.now().millisecondsSinceEpoch);
      await rateLimitBox.flush(); // Force flush to disk for mobile reliability
      logInfo('CurrencyCacheService: Recorded manual fetch time');
    } catch (e) {
      logError('CurrencyCacheService: Error recording manual fetch time: $e');
    }
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

      // Record manual fetch time for rate limiting
      await _recordManualFetch();

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

  // Reset rate limiting (for testing/debugging)
  static Future<void> resetRateLimiting() async {
    try {
      final rateLimitBox = await Hive.openBox('rate_limiting');
      await rateLimitBox.delete(_lastManualFetchKey);
      await rateLimitBox.flush();
      logInfo('CurrencyCacheService: Rate limiting reset');
    } catch (e) {
      logError('CurrencyCacheService: Error resetting rate limiting: $e');
    }
  }

  // Check mobile platform reliability
  static Future<bool> isCacheReliable() async {
    try {
      await initialize();

      // Basic reliability check - can we read/write?
      // Use a separate test box to avoid type conflicts
      final testBox = await Hive.openBox('cache_test');
      const testKey = 'test_reliability';
      final testValue = DateTime.now().millisecondsSinceEpoch;

      await testBox.put(testKey, testValue);
      await testBox.flush();

      final readValue = testBox.get(testKey);
      await testBox.delete(testKey);
      await testBox.close();

      final isReliable = readValue == testValue;
      logInfo('CurrencyCacheService: Cache reliability test: $isReliable');
      return isReliable;
    } catch (e) {
      logError('CurrencyCacheService: Cache reliability test failed: $e');
      return false;
    }
  }
}
