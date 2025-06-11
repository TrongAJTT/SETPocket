import 'package:live_currency_rate/live_currency_rate.dart';
import 'package:logger/logger.dart';
import '../settings_service.dart';

enum CurrencyStatus {
  success,
  failed,
  timeout,
  notSupported,
  staticRate,
  fetchedRecently
}

class CurrencyFetchResult {
  final double rate;
  final CurrencyStatus status;

  CurrencyFetchResult({required this.rate, required this.status});
}

class CurrencyService {
  // Extended static rates for fallback (Updated December 2024)
  static const Map<String, double> _staticRates = {
    'USD': 1.0, // Base currency
    'EUR': 0.8769,
    'GBP': 0.7387,
    'JPY': 144.67,
    'CAD': 1.3694,
    'AUD': 1.5393,
    'VND': 26052.17,
    'CNY': 7.1893,
    'INR': 85.84,
    'KRW': 1422.50,
    'SGD': 1.2873,
    'THB': 32.69,
    'MYR': 4.2281,
    'IDR': 16307.83,
    'PHP': 55.84,
    'CHF': 0.8217,
    'SEK': 10.58,
    'NOK': 10.10,
    'DKK': 6.53,
    'PLN': 3.96,
    'CZK': 21.71,
    'HUF': 353.57,
    'RON': 4.42,
    'BGN': 1.715,
    'HRK': 6.58,
    'RUB': 78.93,
    'TRY': 39.25,
    'BRL': 5.57,
    'MXN': 20.15,
    'ARS': 1015.50,
    'CLP': 965.00,
    'COP': 4112.07,
    'PEN': 3.63,
    'UYU': 43.20,
    'ZAR': 17.85,
    'EGP': 49.64,
    'MAD': 9.72,
    'NGN': 1561.69,
    'KES': 129.50,
    'GHS': 15.85,
    'UGX': 3638.47,
    'TZS': 2660.66,
    'ETB': 133.75,
    'XOF': 575.00,
    'XAF': 575.00,
    'ILS': 3.52,
    'SAR': 3.75,
    'AED': 3.67,
    'QAR': 3.64,
    'KWD': 0.304,
    'BHD': 0.376,
    'OMR': 0.3845,
    'JOD': 0.709,
    'LBP': 89500.0,
    'IRR': 42350.0,
    'PKR': 282.71,
    'BDT': 119.85,
    'LKR': 291.50,
    'NPR': 134.28,
    'BTN': 85.84,
    'MVR': 15.42,
    'AFN': 70.25,
    'UZS': 12850.0,
    'KZT': 523.50,
    'KGS': 86.75,
    'TJS': 10.85,
    'TMT': 3.50,
    'GEL': 2.73,
    'AMD': 383.95,
    'AZN': 1.70,
    'BYN': 3.28,
    'MDL': 17.85,
    'UAH': 41.50,
    'HKD': 7.85,
    'TWD': 29.84,
    'MOP': 8.08,
    'BND': 1.2873,
    'LAK': 21630.65,
    'KHR': 4050.0,
    'MMK': 2101.84,
    'FJD': 2.25,
    'PGK': 4.02,
    'SBD': 8.57,
    'TOP': 2.35,
    'VUV': 118.50,
    'WST': 2.75,
    'XPF': 104.25,
    'NZD': 1.65,
  };

  // Get static rates for fallback
  static Map<String, double> getStaticRates() {
    return Map.from(_staticRates);
  }

  static DateTime? _lastUpdated;
  static bool _isUsingLiveRates = false;
  static Map<String, double> _currentRates = _staticRates;
  static final Map<String, CurrencyStatus> _currencyStatus = {};

  // Get available currencies - extensive list
  static List<Currency> getSupportedCurrencies() {
    return [
      // Major currencies
      Currency('USD', 'US Dollar', '\$'),
      Currency('EUR', 'Euro', '€'),
      Currency('GBP', 'British Pound', '£'),
      Currency('JPY', 'Japanese Yen', '¥'),
      Currency('CAD', 'Canadian Dollar', 'C\$'),
      Currency('AUD', 'Australian Dollar', 'A\$'),
      Currency('CHF', 'Swiss Franc', 'CHF'),

      // Asian currencies
      Currency('VND', 'Vietnamese Dong', '₫'),
      Currency('CNY', 'Chinese Yuan', '¥'),
      Currency('HKD', 'Hong Kong Dollar', 'HK\$'),
      Currency('TWD', 'Taiwan Dollar', 'NT\$'),
      Currency('SGD', 'Singapore Dollar', 'S\$'),
      Currency('MYR', 'Malaysian Ringgit', 'RM'),
      Currency('THB', 'Thai Baht', '฿'),
      Currency('IDR', 'Indonesian Rupiah', 'Rp'),
      Currency('PHP', 'Philippine Peso', '₱'),
      Currency('INR', 'Indian Rupee', '₹'),
      Currency('KRW', 'South Korean Won', '₩'),
      Currency('BND', 'Brunei Dollar', 'B\$'),
      Currency('LAK', 'Lao Kip', '₭'),
      Currency('KHR', 'Cambodian Riel', '៛'),
      Currency('MMK', 'Myanmar Kyat', 'K'),
      Currency('MOP', 'Macau Pataca', 'MOP'),

      // European currencies
      Currency('SEK', 'Swedish Krona', 'kr'),
      Currency('NOK', 'Norwegian Krone', 'kr'),
      Currency('DKK', 'Danish Krone', 'kr'),
      Currency('PLN', 'Polish Zloty', 'zł'),
      Currency('CZK', 'Czech Koruna', 'Kč'),
      Currency('HUF', 'Hungarian Forint', 'Ft'),
      Currency('RON', 'Romanian Leu', 'lei'),
      Currency('BGN', 'Bulgarian Lev', 'лв'),
      Currency('HRK', 'Croatian Kuna', 'kn'),
      Currency('RUB', 'Russian Ruble', '₽'),
      Currency('TRY', 'Turkish Lira', '₺'),
      Currency('UAH', 'Ukrainian Hryvnia', '₴'),
      Currency('BYN', 'Belarusian Ruble', 'Br'),
      Currency('MDL', 'Moldovan Leu', 'L'),
      Currency('GEL', 'Georgian Lari', '₾'),
      Currency('AMD', 'Armenian Dram', '֏'),
      Currency('AZN', 'Azerbaijani Manat', '₼'),

      // Middle East & Africa
      Currency('ILS', 'Israeli Shekel', '₪'),
      Currency('SAR', 'Saudi Riyal', '﷼'),
      Currency('AED', 'UAE Dirham', 'د.إ'),
      Currency('QAR', 'Qatari Riyal', '﷼'),
      Currency('KWD', 'Kuwaiti Dinar', 'د.ك'),
      Currency('BHD', 'Bahraini Dinar', '.د.ب'),
      Currency('OMR', 'Omani Rial', '﷼'),
      Currency('JOD', 'Jordanian Dinar', 'د.ا'),
      Currency('LBP', 'Lebanese Pound', '£'),
      Currency('EGP', 'Egyptian Pound', 'E£'),
      Currency('MAD', 'Moroccan Dirham', 'د.م.'),
      Currency('ZAR', 'South African Rand', 'R'),
      Currency('NGN', 'Nigerian Naira', '₦'),
      Currency('KES', 'Kenyan Shilling', 'KSh'),
      Currency('GHS', 'Ghanaian Cedi', '₵'),
      Currency('UGX', 'Ugandan Shilling', 'USh'),
      Currency('TZS', 'Tanzanian Shilling', 'TSh'),
      Currency('ETB', 'Ethiopian Birr', 'Br'),
      Currency('XOF', 'West African CFA Franc', 'CFA'),
      Currency('XAF', 'Central African CFA Franc', 'FCFA'),

      // Americas
      Currency('BRL', 'Brazilian Real', 'R\$'),
      Currency('MXN', 'Mexican Peso', '\$'),
      Currency('ARS', 'Argentine Peso', '\$'),
      Currency('CLP', 'Chilean Peso', '\$'),
      Currency('COP', 'Colombian Peso', '\$'),
      Currency('PEN', 'Peruvian Sol', 'S/'),
      Currency('UYU', 'Uruguayan Peso', '\$U'),

      // Central Asia
      Currency('KZT', 'Kazakhstani Tenge', '₸'),
      Currency('UZS', 'Uzbekistani Som', 'soʻm'),
      Currency('KGS', 'Kyrgyzstani Som', 'лв'),
      Currency('TJS', 'Tajikistani Somoni', 'ЅМ'),
      Currency('TMT', 'Turkmenistani Manat', 'T'),
      Currency('AFN', 'Afghan Afghani', '؋'),

      // South Asia
      Currency('PKR', 'Pakistani Rupee', '₨'),
      Currency('BDT', 'Bangladeshi Taka', '৳'),
      Currency('LKR', 'Sri Lankan Rupee', '₨'),
      Currency('NPR', 'Nepalese Rupee', '₨'),
      Currency('BTN', 'Bhutanese Ngultrum', 'Nu.'),
      Currency('MVR', 'Maldivian Rufiyaa', '.ރ'),

      // Pacific
      Currency('NZD', 'New Zealand Dollar', 'NZ\$'),
      Currency('FJD', 'Fijian Dollar', 'FJ\$'),
      Currency('PGK', 'Papua New Guinea Kina', 'K'),
      Currency('SBD', 'Solomon Islands Dollar', 'SI\$'),
      Currency('TOP', 'Tongan Paʻanga', 'T\$'),
      Currency('VUV', 'Vanuatu Vatu', 'VT'),
      Currency('WST', 'Samoan Tala', 'WS\$'),
      Currency('XPF', 'CFP Franc', '₣'),
    ];
  }

  // Convert currency - now uses cache service
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    // Try to get rates from cache, fallback to current rates if cache not available
    Map<String, double>? cachedRates;
    try {
      // Note: We can't use await here, so we'll use the cached rates if available
      // The rates should be updated through the cache service when needed
      cachedRates = _currentRates.isNotEmpty ? _currentRates : _staticRates;
    } catch (e) {
      cachedRates = _staticRates;
    }

    final fromRate =
        cachedRates[fromCurrency] ?? _staticRates[fromCurrency] ?? 1.0;
    final toRate = cachedRates[toCurrency] ?? _staticRates[toCurrency] ?? 1.0;

    // Convert to USD first, then to target currency
    final usdAmount = amount / fromRate;
    return usdAmount * toRate;
  }

  // Get exchange rate between two currencies
  static double getExchangeRate(String fromCurrency, String toCurrency) {
    return convert(1.0, fromCurrency, toCurrency);
  }

  // Get last updated time
  static String getLastUpdated() {
    if (_lastUpdated != null) {
      return _lastUpdated!
          .toString()
          .substring(0, 19); // Format: YYYY-MM-DD HH:MM:SS
    }
    return 'Static rates (no live data)';
  }

  // Check if using live rates
  static bool get isUsingLiveRates => _isUsingLiveRates;

  // Initialize or refresh rates
  static Future<void> refreshRates() async {
    try {
      final newRates = await fetchLiveRates();
      _currentRates = newRates;
    } catch (e) {
      print('Failed to refresh rates: $e');
      _currentRates = _staticRates;
      _isUsingLiveRates = false;
    }
  } // Progress tracking

  static void Function(String currency, CurrencyStatus status)? _onProgress;
  static bool _isCancelled = false;

  // Set progress callback
  static void setProgressCallback(
      void Function(String currency, CurrencyStatus status)? callback) {
    _onProgress = callback;
  }

  // Cancel current fetch operation
  static void cancelFetch() {
    _isCancelled = true;
  }

  // Future method for real API integration

  // Map to track last fetch time for each currency
  static Map<String, DateTime> _currencyFetchTimes = {};

  // Get last fetch time for a currency
  static DateTime? getCurrencyLastFetchTime(String currencyCode) {
    return _currencyFetchTimes[currencyCode];
  }

  // Update currency fetch time (used by cache service)
  static void updateCurrencyFetchTime(String currencyCode, DateTime fetchTime) {
    _currencyFetchTimes[currencyCode] = fetchTime;
  }

  // Load status from cache (used by cache service)
  static void updateCurrencyStatuses(Map<String, CurrencyStatus> statuses) {
    _currencyStatus.clear();
    _currencyStatus.addAll(statuses);
  }

  // Check if currency needs refresh (older than 1 hour)
  static bool currencyNeedsRefresh(String currencyCode) {
    final fetchTime = _currencyFetchTimes[currencyCode];
    if (fetchTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(fetchTime);
    return difference.inHours >= 1;
  }

  static Future<Map<String, double>> fetchLiveRates() async {
    try {
      print('CurrencyService: Starting to fetch live rates...');
      _isCancelled = false; // Reset cancel flag
      var rates = <String, double>{};
      bool hasLiveData = false;

      // Get retry settings
      final retryTimes = await SettingsService.getFetchRetryTimes();

      // Keep existing statuses for currencies that don't need refresh
      Map<String, CurrencyStatus> existingStatuses = Map.from(_currencyStatus);
      _currencyStatus.clear(); // Clear previous status

      // Add USD as base
      rates['USD'] = 1.0;
      _currencyStatus['USD'] = CurrencyStatus.success;
      _currencyFetchTimes['USD'] = DateTime.now();
      _onProgress?.call('USD', CurrencyStatus.success);
      print('CurrencyService: Added USD base rate');

      // Try to get rates for each currency - PARALLEL FETCHING for better performance
      final currencies = getSupportedCurrencies();
      print(
          'CurrencyService: Fetching rates for ${currencies.length} currencies in parallel...');

      // Create futures for all currency fetches (except USD)
      final fetchFutures = <String, Future<CurrencyFetchResult>>{};
      for (final currency in currencies) {
        if (currency.code != 'USD') {
          // Only fetch if currency needs refresh (older than 1 hour) or had failed/timeout status
          final needsRefresh = currencyNeedsRefresh(currency.code);
          final previousStatus = existingStatuses[currency.code];
          final shouldFetch = needsRefresh ||
              previousStatus == CurrencyStatus.failed ||
              previousStatus == CurrencyStatus.timeout;

          if (shouldFetch) {
            fetchFutures[currency.code] =
                _fetchSingleRateWithStatus(currency.code);
            print(
                'CurrencyService: Will fetch ${currency.code} (needs refresh: $needsRefresh, previous status: $previousStatus)');
          } else {
            // Skip fetch but report as recently fetched for progress dialog
            _onProgress?.call(currency.code, CurrencyStatus.fetchedRecently);
            print(
                'CurrencyService: Skipping fetch for ${currency.code} (recently fetched)');
          }
        }
      }

      // Initial fetch attempt
      Map<String, CurrencyFetchResult> allResults = {};
      Map<String, Future<CurrencyFetchResult>> currentFutures =
          Map.from(fetchFutures);

      // Retry logic - try up to retryTimes + 1 times (initial + retries)
      for (int attempt = 0;
          attempt <= retryTimes && currentFutures.isNotEmpty;
          attempt++) {
        if (_isCancelled) break;

        if (attempt > 0) {
          print(
              'CurrencyService: Retry attempt $attempt for ${currentFutures.length} currencies');
        }

        final results = await Future.wait(
          currentFutures.entries.map((entry) async {
            if (_isCancelled) {
              _onProgress?.call(entry.key, CurrencyStatus.failed);
              return MapEntry(
                  entry.key,
                  CurrencyFetchResult(
                      rate: _staticRates[entry.key] ?? 1.0,
                      status: CurrencyStatus.failed));
            }
            try {
              // Get timeout from settings service
              final timeoutSeconds = await SettingsService.getFetchTimeout();
              final result =
                  await entry.value.timeout(Duration(seconds: timeoutSeconds));

              // Update fetch time for this currency if successful
              if (result.status == CurrencyStatus.success) {
                _currencyFetchTimes[entry.key] = DateTime.now();
              }

              _onProgress?.call(entry.key, result.status);
              return MapEntry(entry.key, result);
            } catch (e) {
              print('CurrencyService: Timeout/Error for ${entry.key}: $e');
              _onProgress?.call(entry.key, CurrencyStatus.timeout);
              return MapEntry(
                  entry.key,
                  CurrencyFetchResult(
                      rate: _staticRates[entry.key] ?? 1.0,
                      status: CurrencyStatus.timeout));
            }
          }),
        );

        // Process results and collect successful ones
        Map<String, Future<CurrencyFetchResult>> nextFutures = {};
        for (final result in results) {
          allResults[result.key] = result.value;

          // If failed/timeout and not the last attempt, prepare for retry
          if (attempt < retryTimes &&
              (result.value.status == CurrencyStatus.failed ||
                  result.value.status == CurrencyStatus.timeout)) {
            nextFutures[result.key] = _fetchSingleRateWithStatus(result.key);
            print(
                'CurrencyService: Will retry ${result.key} (status: ${result.value.status})');
          }
        }

        currentFutures = nextFutures;

        // Small delay between retries to avoid overwhelming the API
        if (currentFutures.isNotEmpty && attempt < retryTimes) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Process final results for currencies that were fetched
      for (final result in allResults.entries) {
        rates[result.key] = result.value.rate;
        _currencyStatus[result.key] = result.value.status;
        if (result.value.status == CurrencyStatus.success) {
          hasLiveData = true;
        }
      }

      // Add currencies that weren't fetched (using existing values)
      for (final currency in currencies) {
        if (currency.code != 'USD' &&
            !rates.containsKey(currency.code) &&
            !allResults.containsKey(currency.code)) {
          // Get rate from current rates
          final rate = _currentRates[currency.code] ??
              _staticRates[currency.code] ??
              1.0;
          rates[currency.code] = rate;

          // Keep existing status (but don't overwrite fetchedRecently from progress callback)
          final currentStatus = _currencyStatus[currency.code];
          if (currentStatus != CurrencyStatus.fetchedRecently) {
            final status =
                existingStatuses[currency.code] ?? CurrencyStatus.staticRate;
            _currencyStatus[currency.code] = status;
          }
        }
      }

      // Update tracking variables
      if (hasLiveData) {
        _lastUpdated = DateTime.now();
        _isUsingLiveRates = true;
        Logger().i('CurrencyService: Successfully fetched live currency rates');
      } else {
        _isUsingLiveRates = false;
        Logger().i(
            'CurrencyService: Using static currency rates (live data unavailable)');
      }

      Logger().i('CurrencyService: Final rates count: ${rates.length}');
      Logger().i(
          'CurrencyService: Sample rates: ${rates.entries.take(3).map((e) => '${e.key}: ${e.value}').join(', ')}');

      // Update current rates for use in convert() method
      _currentRates = Map<String, double>.from(rates);
      Logger().i('CurrencyService: Updated _currentRates with new data');

      return rates;
    } catch (e) {
      Logger().e('CurrencyService: Error fetching live rates: $e');
      // Fall back to static rates
      _isUsingLiveRates = false;
      await Future.delayed(const Duration(milliseconds: 500));
      Logger().e('CurrencyService: Returning static rates as fallback');
      return Map<String, double>.from(_staticRates);
    }
  }

  // Enhanced method to fetch rate with status tracking
  static Future<CurrencyFetchResult> _fetchSingleRateWithStatus(
      String currencyCode) async {
    try {
      Logger().i('CurrencyService: Fetching rate for $currencyCode...');
      final result =
          await LiveCurrencyRate.convertCurrency('USD', currencyCode, 1.0);
      if (result.result > 0) {
        Logger().i(
            'CurrencyService: Got live rate for $currencyCode: ${result.result}');
        return CurrencyFetchResult(
            rate: result.result, status: CurrencyStatus.success);
      } else {
        Logger().i(
            'CurrencyService: Invalid result for $currencyCode, using static rate');
        return CurrencyFetchResult(
            rate: _staticRates[currencyCode] ?? 1.0,
            status: CurrencyStatus.failed);
      }
    } catch (e) {
      Logger()
          .e('CurrencyService: Failed to get live rate for $currencyCode: $e');
      return CurrencyFetchResult(
          rate: _staticRates[currencyCode] ?? 1.0,
          status: CurrencyStatus.failed);
    }
  }

  // Update current rates (used by cache service)
  static void updateCurrentRates(Map<String, double> newRates) {
    _currentRates = Map<String, double>.from(newRates);
    _lastUpdated = DateTime.now();
    _isUsingLiveRates = true;
    Logger().i(
        'CurrencyService: Current rates updated with ${newRates.length} currencies');
  }

  // Check if API is available
  static bool get isLiveDataAvailable =>
      true; // Set to true now that we have real API integration

  // Get currency status
  static CurrencyStatus getCurrencyStatus(String currencyCode) {
    return _currencyStatus[currencyCode] ?? CurrencyStatus.staticRate;
  }

  // Get all currency statuses
  static Map<String, CurrencyStatus> get currencyStatuses =>
      Map.unmodifiable(_currencyStatus);

  // Get localized status text
  static String getLocalizedStatus(String currencyCode, dynamic l10n) {
    final status = getCurrencyStatus(currencyCode);
    switch (status) {
      case CurrencyStatus.success:
        return l10n?.currencyStatusSuccess ?? 'Live rate';
      case CurrencyStatus.failed:
        return l10n?.currencyStatusFailed ?? 'Failed to fetch';
      case CurrencyStatus.timeout:
        return l10n?.currencyStatusTimeout ?? 'Timeout';
      case CurrencyStatus.notSupported:
        return l10n?.currencyStatusNotSupported ?? 'Not supported';
      case CurrencyStatus.staticRate:
        return l10n?.currencyStatusStatic ?? 'Static rate';
      case CurrencyStatus.fetchedRecently:
        return l10n?.currencyStatusFetchedRecently ?? 'Recently fetched';
    }
  }

  // Get localized status description
  static String getLocalizedStatusDescription(
      String currencyCode, dynamic l10n) {
    final status = getCurrencyStatus(currencyCode);
    switch (status) {
      case CurrencyStatus.success:
        return l10n?.currencyStatusSuccessDesc ??
            'Successfully fetched live rate';
      case CurrencyStatus.failed:
        return l10n?.currencyStatusFailedDesc ??
            'Failed to fetch live rate, using static fallback';
      case CurrencyStatus.timeout:
        return l10n?.currencyStatusTimeoutDesc ??
            'Request timed out, using static fallback';
      case CurrencyStatus.notSupported:
        return l10n?.currencyStatusNotSupportedDesc ??
            'Currency not supported by API';
      case CurrencyStatus.staticRate:
        return l10n?.currencyStatusStaticDesc ?? 'Using static exchange rate';
      case CurrencyStatus.fetchedRecently:
        return l10n?.currencyStatusFetchedRecentlyDesc ??
            'Successfully fetched within the last hour';
    }
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency(this.code, this.name, this.symbol);

  @override
  String toString() => '$code - $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
