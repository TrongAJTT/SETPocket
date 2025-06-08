import 'package:hive/hive.dart';
import '../models/currency_cache_model.dart';
import 'currency_service.dart';
import 'settings_service.dart';

class CurrencyCacheService {
  static const String _cacheBoxName = 'currency_cache';
  static const String _cacheKey = 'current_rates';

  static Box<CurrencyCacheModel>? _cacheBox;
  static bool _isFetching = false;

  // Initialize the cache service
  static Future<void> initialize() async {
    if (_cacheBox == null || !_cacheBox!.isOpen) {
      _cacheBox = await Hive.openBox<CurrencyCacheModel>(_cacheBoxName);
    }
  } // Get cached rates or fetch new ones based on settings

  static Future<Map<String, double>> getRates(
      {bool forceRefresh = false}) async {
    await initialize();

    final settings = await SettingsService.getSettings();
    final fetchMode = settings.currencyFetchMode;

    print(
        'CurrencyCacheService: getRates called with fetchMode: $fetchMode, forceRefresh: $forceRefresh');

    // Get cached data
    final cachedData = _cacheBox!.get(_cacheKey);
    print('CurrencyCacheService: cachedData exists: ${cachedData != null}');
    if (cachedData != null) {
      print(
          'CurrencyCacheService: cache lastUpdated: ${cachedData.lastUpdated}, isValid: ${cachedData.isValid}, isExpired: ${cachedData.isExpired}');
    }

    // Determine if we need to fetch new rates based on mode
    bool shouldFetch = forceRefresh;

    if (!shouldFetch && cachedData == null) {
      // No cache at all, we need to fetch
      shouldFetch = true;
      print('CurrencyCacheService: No cache found, will fetch');
    } else if (!shouldFetch && cachedData != null) {
      // We have cache, check if we should refresh based on mode
      shouldFetch = cachedData.shouldRefresh(fetchMode);
      print('CurrencyCacheService: shouldRefresh for $fetchMode: $shouldFetch');
    }

    print(
        'CurrencyCacheService: Final shouldFetch decision: $shouldFetch, _isFetching: $_isFetching');

    if (shouldFetch && !_isFetching) {
      print('CurrencyCacheService: Starting fetch...');
      try {
        _isFetching = true;
        final newRates = await CurrencyService.fetchLiveRates();
        await _saveToCache(newRates);
        print(
            'CurrencyCacheService: Successfully fetched and cached ${newRates.length} rates');
        return newRates;
      } catch (e) {
        print('CurrencyCacheService: Failed to fetch new rates: $e');
        // Return cached data if available, otherwise return static rates
        if (cachedData != null && cachedData.isValid) {
          print('CurrencyCacheService: Returning cached data as fallback');
          return cachedData.rates;
        }
        print('CurrencyCacheService: Returning static rates as fallback');
        return CurrencyService.getStaticRates();
      } finally {
        _isFetching = false;
      }
    }

    // Return cached data if available and valid
    if (cachedData != null && cachedData.isValid) {
      print('CurrencyCacheService: Returning cached data (no fetch needed)');
      return cachedData.rates;
    }

    // Fall back to static rates
    print('CurrencyCacheService: Returning static rates (no valid cache)');
    return CurrencyService.getStaticRates();
  }

  // Save rates to cache
  static Future<void> _saveToCache(Map<String, double> rates) async {
    await initialize();

    final cacheModel = CurrencyCacheModel(
      rates: rates,
      lastUpdated: DateTime.now(),
      isValid: true,
    );

    await _cacheBox!.put(_cacheKey, cacheModel);
  }

  // Get cached data info
  static Future<CurrencyCacheModel?> getCacheInfo() async {
    await initialize();
    return _cacheBox!.get(_cacheKey);
  }

  // Check if currently fetching
  static bool get isFetching => _isFetching;

  // Clear cache
  static Future<void> clearCache() async {
    await initialize();
    await _cacheBox!.delete(_cacheKey);
  }

  // Get last updated time
  static Future<DateTime?> getLastUpdated() async {
    await initialize();
    final cachedData = _cacheBox!.get(_cacheKey);
    return cachedData?.lastUpdated;
  }

  // Check if cache exists and is valid
  static Future<bool> hasCachedData() async {
    await initialize();
    final cachedData = _cacheBox!.get(_cacheKey);
    return cachedData != null && cachedData.isValid;
  }

  // Force refresh rates
  static Future<Map<String, double>> forceRefresh() async {
    return await getRates(forceRefresh: true);
  }
}
