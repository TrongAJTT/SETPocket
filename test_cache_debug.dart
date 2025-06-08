import 'dart:io';
import 'package:hive/hive.dart';
import 'lib/services/hive_service.dart';
import 'lib/services/currency_cache_service.dart';
import 'lib/services/settings_service.dart';

Future<void> main() async {
  print('=== Currency Cache Service Debug Test ===');

  try {
    // Initialize Hive first
    print('1. Initializing Hive...');
    await HiveService.initialize();
    print('   ✓ Hive initialized');

    // Initialize Settings Service
    print('2. Initializing Settings Service...');
    await SettingsService.initialize();
    print('   ✓ Settings initialized');

    // Test cache service
    print('3. Testing Currency Cache Service...');
    final cacheInfo = await CurrencyCacheService.getCacheInfo();
    print('   Cache info: $cacheInfo');

    if (cacheInfo != null) {
      print('   Last updated: ${cacheInfo.lastUpdated}');
      print('   Is valid: ${cacheInfo.isValid}');
      print('   Rates count: ${cacheInfo.rates.length}');
    } else {
      print('   No cached data found');
    }

    print('4. Fetching rates...');
    final rates = await CurrencyCacheService.getRates();
    print('   Fetched ${rates.length} rates');

    // Check cache again after fetch
    print('5. Checking cache after fetch...');
    final newCacheInfo = await CurrencyCacheService.getCacheInfo();
    if (newCacheInfo != null) {
      print('   New cache - Last updated: ${newCacheInfo.lastUpdated}');
      print('   New cache - Is valid: ${newCacheInfo.isValid}');
      print('   New cache - USD to EUR: ${newCacheInfo.rates['EUR']}');
    }

    print('\n=== Test completed successfully! ===');
  } catch (e, stack) {
    print('Error during test: $e');
    print('Stack trace: $stack');
  } finally {
    await Hive.close();
    exit(0);
  }
}
