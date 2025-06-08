import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/services/hive_service.dart';
import 'lib/services/currency_cache_service.dart';
import 'lib/services/settings_service.dart';
import 'lib/models/currency_cache_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== Currency Cache Debug ===');

  try {
    // Initialize Hive
    await HiveService.initialize();
    print('✓ Hive initialized');

    // Initialize services
    await SettingsService.initialize();
    await CurrencyCacheService.initialize();
    print('✓ Services initialized');

    // Check current settings
    final fetchMode = await SettingsService.getCurrencyFetchMode();
    print('Current fetch mode: $fetchMode');

    // Check cache info
    final cacheInfo = await CurrencyCacheService.getCacheInfo();
    print('Cache info: $cacheInfo');
    if (cacheInfo != null) {
      print('  - Last updated: ${cacheInfo.lastUpdated}');
      print('  - Is valid: ${cacheInfo.isValid}');
      print('  - Is expired: ${cacheInfo.isExpired}');
      print('  - Rates count: ${cacheInfo.rates.length}');
    } else {
      print('  - No cache found');
    }

    // Try to get rates
    print('\nFetching rates...');
    final rates = await CurrencyCacheService.getRates();
    print('Got ${rates.length} rates');

    // Check cache info again
    final newCacheInfo = await CurrencyCacheService.getCacheInfo();
    print('\nUpdated cache info: $newCacheInfo');
    if (newCacheInfo != null) {
      print('  - Last updated: ${newCacheInfo.lastUpdated}');
      print('  - Is valid: ${newCacheInfo.isValid}');
      print('  - Is expired: ${newCacheInfo.isExpired}');
      print(
          '  - Should refresh (manual): ${newCacheInfo.shouldRefresh(CurrencyFetchMode.manual)}');
      print(
          '  - Should refresh (once a day): ${newCacheInfo.shouldRefresh(CurrencyFetchMode.onceADay)}');
      print(
          '  - Should refresh (everytime): ${newCacheInfo.shouldRefresh(CurrencyFetchMode.everytime)}');
    }
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }

  print('\n=== Debug Complete ===');
}
