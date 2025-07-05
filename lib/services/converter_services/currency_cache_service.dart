import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/models/converter_models/currency_cache_model.dart';
import 'currency_cache_service_isar.dart';

class CurrencyCacheService {
  // Delegate all calls to Isar implementation

  // Get cached rates only (no auto-fetch) - for safe loading
  static Future<Map<String, double>> getCachedRates() async {
    return CurrencyCacheServiceIsar.getCachedRates();
  }

  // Check if fetch is needed based on settings (without fetching)
  static Future<bool> shouldFetchRates() async {
    return CurrencyCacheServiceIsar.shouldFetchRates();
  }

  // Get cached rates or fetch new ones based on settings (DEPRECATED - use getCachedRates + shouldFetchRates)
  static Future<Map<String, double>> getRates(
      {bool forceRefresh = false}) async {
    return CurrencyCacheServiceIsar.getRates(forceRefresh: forceRefresh);
  }

  // Get cached data info
  static Future<CurrencyCacheModel?> getCacheInfo() async {
    return CurrencyCacheServiceIsar.getCacheInfo();
  }

  // Check if currently fetching
  static bool get isFetching => CurrencyCacheServiceIsar.isFetching;

  // Clear cache (but preserve currency rates and rate limiting data)
  static Future<void> clearCache() async {
    return CurrencyCacheServiceIsar.clearCache();
  }

  // Get last updated time
  static Future<DateTime?> getLastUpdated() async {
    return CurrencyCacheServiceIsar.getLastUpdated();
  }

  // Check if cache exists and is valid
  static Future<bool> hasCachedData() async {
    return CurrencyCacheServiceIsar.hasCachedData();
  }

  // Force refresh rates (DEPRECATED - use forceRefreshWithDialog)
  static Future<Map<String, double>> forceRefresh() async {
    return CurrencyCacheServiceIsar.forceRefresh();
  }

  // Check if manual fetch is allowed (respects 6-hour rate limit)
  static Future<bool> isManualFetchAllowed() async {
    return CurrencyCacheServiceIsar.isManualFetchAllowed();
  }

  // Get remaining time until next manual fetch is allowed
  static Future<Duration?> getManualFetchCooldownRemaining() async {
    return CurrencyCacheServiceIsar.getManualFetchCooldownRemaining();
  }

  // Force refresh rates (for use with dialog only - no background fetch)
  static Future<Map<String, double>> forceRefreshWithDialog() async {
    return CurrencyCacheServiceIsar.forceRefreshWithDialog();
  }

  // Debug method to check cache content
  static Future<void> debugCache() async {
    return CurrencyCacheServiceIsar.debugCache();
  }

  // Reset rate limiting (for testing/debugging)
  static Future<void> resetRateLimiting() async {
    return CurrencyCacheServiceIsar.resetRateLimiting();
  }

  // Check mobile platform reliability
  static Future<bool> isCacheReliable() async {
    return CurrencyCacheServiceIsar.isCacheReliable();
  }

  // Initialize the cache service (for backward compatibility)
  static Future<void> initialize() async {
    // No longer needed with Isar, but keep for compatibility
    logInfo('CurrencyCacheService: Initialization delegated to Isar');
  }
}
