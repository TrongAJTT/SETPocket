import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/services/hive_service.dart';
import 'lib/services/settings_service.dart';
import 'lib/services/currency_cache_service.dart';
import 'lib/models/currency_cache_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.init();

  print('=== Currency Cache Status Debug ===');

  // Get current settings
  final settings = await SettingsService.getSettings();
  print('Current fetch mode: ${settings.currencyFetchMode}');

  // Get cache info
  final cacheInfo = await CurrencyCacheService.getCacheInfo();
  if (cacheInfo != null) {
    print('Cache exists:');
    print('  Last updated: ${cacheInfo.lastUpdated}');
    print('  Is valid: ${cacheInfo.isValid}');
    print('  Is expired: ${cacheInfo.isExpired}');
    print(
        '  Should refresh for manual: ${cacheInfo.shouldRefresh(CurrencyFetchMode.manual)}');
    print(
        '  Should refresh for once a day: ${cacheInfo.shouldRefresh(CurrencyFetchMode.onceADay)}');
    print(
        '  Should refresh for everytime: ${cacheInfo.shouldRefresh(CurrencyFetchMode.everytime)}');
  } else {
    print('No cache found');
  }

  // Test cache behavior for different modes
  print('\n=== Testing Manual Mode ===');
  await SettingsService.setCurrencyFetchMode(CurrencyFetchMode.manual);
  await testFetchBehavior();

  print('\n=== Testing Once A Day Mode ===');
  await SettingsService.setCurrencyFetchMode(CurrencyFetchMode.onceADay);
  await testFetchBehavior();

  print('\n=== Testing Everytime Mode ===');
  await SettingsService.setCurrencyFetchMode(CurrencyFetchMode.everytime);
  await testFetchBehavior();

  exit(0);
}

Future<void> testFetchBehavior() async {
  final settings = await SettingsService.getSettings();
  final cacheInfo = await CurrencyCacheService.getCacheInfo();

  print('Mode: ${settings.currencyFetchMode}');
  if (cacheInfo != null) {
    print(
        'Should refresh: ${cacheInfo.shouldRefresh(settings.currencyFetchMode)}');
  }

  try {
    final rates = await CurrencyCacheService.getRates();
    print('Got ${rates.length} rates');

    final newCacheInfo = await CurrencyCacheService.getCacheInfo();
    print('Cache after fetch - Last updated: ${newCacheInfo?.lastUpdated}');
  } catch (e) {
    print('Error: $e');
  }
}
