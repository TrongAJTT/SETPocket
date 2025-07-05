import 'package:isar/isar.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/models/converter_models/currency_cache_model.dart';
import 'package:setpocket/services/isar_service.dart';
import 'currency_service.dart';
import 'package:setpocket/services/settings_service.dart';

class CurrencyCacheServiceIsar {
  static bool _isFetching = false;

  // Get cached rates only (no auto-fetch) - for safe loading
  static Future<Map<String, double>> getCachedRates() async {
    try {
      // Get cached data
      final cachedData =
          await IsarService.isar.currencyCacheModels.where().findFirst();

      // Load fetch times from cache if available
      if (cachedData != null) {
        _loadFetchTimesFromCache(cachedData);
      }

      // Return cached data if available and valid
      if (cachedData != null && cachedData.isValid) {
        logInfo('CurrencyCacheServiceIsar: Returning cached data');
        return cachedData.getRatesAsMap;
      }

      logInfo(
          'CurrencyCacheServiceIsar: No valid cache, returning static rates');
      return CurrencyService.getStaticRates();
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error getting cached rates: $e');
      return CurrencyService.getStaticRates();
    }
  }

  // Check if fetch is needed based on settings (without fetching)
  static Future<bool> shouldFetchRates() async {
    try {
      final settings = await SettingsService.getSettings();
      final fetchMode = settings.currencyFetchMode;

      // Get cached data
      final cachedData =
          await IsarService.isar.currencyCacheModels.where().findFirst();

      if (cachedData == null) {
        return true; // No cache, should fetch
      }

      return cachedData.shouldRefresh(fetchMode);
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error checking should fetch: $e');
      return true;
    }
  }

  // Get cached rates or fetch new ones based on settings (DEPRECATED - use getCachedRates + shouldFetchRates)
  static Future<Map<String, double>> getRates(
      {bool forceRefresh = false}) async {
    try {
      final settings = await SettingsService.getSettings();
      final fetchMode = settings.currencyFetchMode;

      // Get cached data
      final cachedData =
          await IsarService.isar.currencyCacheModels.where().findFirst();

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
        logInfo('CurrencyCacheServiceIsar: Starting fetch...');
        try {
          _isFetching = true;
          final newRates = await CurrencyService.fetchLiveRates();
          logInfo(
              'CurrencyCacheServiceIsar: Fetched ${newRates.length} rates, now saving to cache...');

          await _saveToCache(newRates);
          logInfo('CurrencyCacheServiceIsar: Successfully saved to cache');

          // Verify the save worked
          final verifyCache =
              await IsarService.isar.currencyCacheModels.where().findFirst();
          logInfo(
              'CurrencyCacheServiceIsar: Cache verification - data exists: ${verifyCache != null}');
          if (verifyCache != null) {
            logInfo(
                'CurrencyCacheServiceIsar: Cache verification - rates count: ${verifyCache.rates.length}');
          }

          return newRates;
        } catch (e) {
          logError('CurrencyCacheServiceIsar: Failed to fetch new rates: $e');
          if (cachedData != null && cachedData.isValid) {
            logInfo(
                'CurrencyCacheServiceIsar: Returning cached data as fallback');
            return cachedData.getRatesAsMap;
          }
          logInfo(
              'CurrencyCacheServiceIsar: Returning static rates as fallback');
          return CurrencyService.getStaticRates();
        } finally {
          _isFetching = false;
        }
      }

      // Return cached data if available and valid
      if (cachedData != null && cachedData.isValid) {
        logInfo(
            'CurrencyCacheServiceIsar: Returning cached data (no fetch needed)');
        return cachedData.getRatesAsMap;
      }

      logInfo(
          'CurrencyCacheServiceIsar: Returning static rates (no valid cache)');
      return CurrencyService.getStaticRates();
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error in getRates: $e');
      return CurrencyService.getStaticRates();
    }
  }

  // Load fetch times from cache into CurrencyService
  static void _loadFetchTimesFromCache(CurrencyCacheModel cacheModel) {
    // Load fetch times
    if (cacheModel.currencyFetchTimes.isNotEmpty) {
      for (final entry in cacheModel.currencyFetchTimes) {
        if (entry.key != null && entry.value != null) {
          final fetchTime = DateTime.fromMillisecondsSinceEpoch(entry.value!);
          CurrencyService.updateCurrencyFetchTime(entry.key!, fetchTime);
        }
      }
      logInfo(
          'CurrencyCacheServiceIsar: Loaded ${cacheModel.currencyFetchTimes.length} fetch times from cache');
    }

    // Load currency statuses
    final statuses = cacheModel.getCurrencyStatuses;
    if (statuses.isNotEmpty) {
      CurrencyService.updateCurrencyStatuses(statuses);
      logInfo(
          'CurrencyCacheServiceIsar: Loaded ${statuses.length} currency statuses from cache');
    }

    // Apply status transitions based on current time to ensure status accuracy
    CurrencyService.updateStatusAfterLoad();
  }

  // Save rates to cache
  static Future<void> _saveToCache(Map<String, double> rates) async {
    try {
      logInfo(
          'CurrencyCacheServiceIsar: Creating cache model with ${rates.length} rates');

      // Convert Map to List<RateEntry>
      final rateEntries = rates.entries
          .map((e) => RateEntry()
            ..key = e.key
            ..value = e.value)
          .toList();

      final cacheModel = CurrencyCacheModel(
        rates: rateEntries,
        lastUpdated: DateTime.now(),
        isValid: true,
      );

      // Also save currency statuses
      final statuses = CurrencyService.currencyStatuses;
      if (statuses.isNotEmpty) {
        cacheModel.setCurrencyStatuses(statuses);
        logInfo(
            'CurrencyCacheServiceIsar: Saved ${statuses.length} currency statuses');
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
            'CurrencyCacheServiceIsar: Saved ${fetchTimes.length} currency fetch times');
      }

      // Clear existing cache and save new one
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.currencyCacheModels.clear();
        await IsarService.isar.currencyCacheModels.put(cacheModel);
      });

      logInfo('CurrencyCacheServiceIsar: Cache saved successfully');
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error saving to cache: $e');
      rethrow;
    }
  }

  // Get cached data info
  static Future<CurrencyCacheModel?> getCacheInfo() async {
    try {
      final data =
          await IsarService.isar.currencyCacheModels.where().findFirst();
      logInfo(
          'CurrencyCacheServiceIsar: getCacheInfo - data exists: ${data != null}');
      return data;
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error getting cache info: $e');
      return null;
    }
  }

  // Check if currently fetching
  static bool get isFetching => _isFetching;

  // Clear cache (but preserve currency rates and rate limiting data)
  static Future<void> clearCache() async {
    try {
      // Only clear general cache, but preserve currency cache and rate limiting
      // This method should NOT clear currency rates or manual fetch times
      // as requested by user

      logInfo(
          'CurrencyCacheServiceIsar: Cache clearing requested, but currency rates and rate limiting data preserved');
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error in cache operation: $e');
    }
  }

  // Get last updated time
  static Future<DateTime?> getLastUpdated() async {
    try {
      final cachedData =
          await IsarService.isar.currencyCacheModels.where().findFirst();
      return cachedData?.lastUpdated;
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error getting last updated: $e');
      return null;
    }
  }

  // Check if cache exists and is valid
  static Future<bool> hasCachedData() async {
    try {
      final cachedData =
          await IsarService.isar.currencyCacheModels.where().findFirst();
      final hasData = cachedData != null && cachedData.isValid;
      logInfo('CurrencyCacheServiceIsar: hasCachedData: $hasData');
      return hasData;
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error checking cached data: $e');
      return false;
    }
  }

  // Force refresh rates (DEPRECATED - use forceRefreshWithDialog)
  static Future<Map<String, double>> forceRefresh() async {
    logInfo('CurrencyCacheServiceIsar: Force refresh requested');

    // Check rate limiting for manual fetch
    final isAllowed = await isManualFetchAllowed();
    if (!isAllowed) {
      logInfo(
          'CurrencyCacheServiceIsar: Manual fetch blocked by rate limiting, returning cached data');
      return await getCachedRates();
    }

    // Record manual fetch time for rate limiting
    await _recordManualFetch();

    return await getRates(forceRefresh: true);
  }

  // Check if manual fetch is allowed (respects 6-hour rate limit)
  static Future<bool> isManualFetchAllowed() async {
    try {
      // For rate limiting, we'll use SettingsService to store the last manual fetch time
      // We need to add a field to settings for last manual fetch time
      // For now, let's use a simple approach with Isar collections
      // We could create a simple key-value store collection for this

      // TODO: Implement rate limiting storage in Isar
      // For now, allow all manual fetches
      logInfo(
          'CurrencyCacheServiceIsar: Manual fetch allowed (rate limiting not yet implemented)');
      return true;
    } catch (e) {
      logError(
          'CurrencyCacheServiceIsar: Error checking manual fetch cooldown: $e');
      return true; // Allow if there's an error
    }
  }

  // Get remaining time until next manual fetch is allowed
  static Future<Duration?> getManualFetchCooldownRemaining() async {
    try {
      // TODO: Implement rate limiting storage in Isar
      // For now, return null (no cooldown)
      return null;
    } catch (e) {
      logError(
          'CurrencyCacheServiceIsar: Error getting manual fetch cooldown remaining: $e');
      return null; // No cooldown if error
    }
  }

  // Record manual fetch time
  static Future<void> _recordManualFetch() async {
    try {
      // TODO: Implement rate limiting storage in Isar
      logInfo(
          'CurrencyCacheServiceIsar: Recorded manual fetch time (placeholder)');
    } catch (e) {
      logError(
          'CurrencyCacheServiceIsar: Error recording manual fetch time: $e');
    }
  }

  // Force refresh rates (for use with dialog only - no background fetch)
  static Future<Map<String, double>> forceRefreshWithDialog() async {
    logInfo('CurrencyCacheServiceIsar: Force refresh with dialog requested');

    if (_isFetching) {
      logInfo(
          'CurrencyCacheServiceIsar: Already fetching, returning cached data');
      return await getCachedRates();
    }

    try {
      _isFetching = true;

      // Record manual fetch time for rate limiting
      await _recordManualFetch();

      // This should only be called when progress dialog is already showing
      final newRates = await CurrencyService.fetchLiveRates();
      logInfo(
          'CurrencyCacheServiceIsar: Fetched ${newRates.length} rates, now saving to cache...');

      await _saveToCache(newRates);
      logInfo('CurrencyCacheServiceIsar: Successfully saved to cache');

      return newRates;
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Failed to fetch new rates: $e');
      // Return cached data as fallback
      return await getCachedRates();
    } finally {
      _isFetching = false;
    }
  }

  // Debug method to check cache content
  static Future<void> debugCache() async {
    try {
      final cachedData =
          await IsarService.isar.currencyCacheModels.where().findFirst();
      logInfo('=== CACHE DEBUG ===');
      logInfo('Cache exists: ${cachedData != null}');
      if (cachedData != null) {
        logInfo('Last updated: ${cachedData.lastUpdated}');
        logInfo('Is valid: ${cachedData.isValid}');
        logInfo('Is expired: ${cachedData.isExpired}');
        logInfo('Rates count: ${cachedData.rates.length}');
        logInfo(
            'Sample rates: ${cachedData.rates.take(3).map((e) => '${e.key}: ${e.value}').join(', ')}');
      }
      logInfo('=== END DEBUG ===');
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error in debug: $e');
    }
  }

  // Reset rate limiting (for testing/debugging)
  static Future<void> resetRateLimiting() async {
    try {
      // TODO: Implement rate limiting reset in Isar
      logInfo('CurrencyCacheServiceIsar: Rate limiting reset (placeholder)');
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Error resetting rate limiting: $e');
    }
  }

  // Check mobile platform reliability
  static Future<bool> isCacheReliable() async {
    try {
      // Basic reliability check - can we read/write?
      final testModel = CurrencyCacheModel(
        rates: [
          RateEntry()
            ..key = 'TEST'
            ..value = 1.0
        ],
        lastUpdated: DateTime.now(),
        isValid: true,
      );

      // Test write
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.currencyCacheModels.put(testModel);
      });

      // Test read
      final readModel =
          await IsarService.isar.currencyCacheModels.where().findFirst();

      // Clean up test data
      if (readModel != null) {
        await IsarService.isar.writeTxn(() async {
          await IsarService.isar.currencyCacheModels.delete(readModel.id);
        });
      }

      final isReliable = readModel != null;
      logInfo('CurrencyCacheServiceIsar: Cache reliability test: $isReliable');
      return isReliable;
    } catch (e) {
      logError('CurrencyCacheServiceIsar: Cache reliability test failed: $e');
      return false;
    }
  }
}
