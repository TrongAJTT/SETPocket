import 'package:live_currency_rate/live_currency_rate.dart';

class CurrencyService {
  // For demo purposes, using static rates. In production, this would connect to a real API
  static const Map<String, double> _staticRates = {
    'USD': 1.0, // Base currency
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.0,
    'CAD': 1.25,
    'AUD': 1.35,
    'VND': 23000.0,
    'CNY': 6.45,
    'INR': 74.0,
    'KRW': 1180.0,
    'SGD': 1.35,
    'THB': 32.0,
    'MYR': 4.15,
    'IDR': 14300.0,
    'PHP': 50.0,
  };

  // Get static rates for fallback
  static Map<String, double> getStaticRates() {
    return Map.from(_staticRates);
  }

  static DateTime? _lastUpdated;
  static bool _isUsingLiveRates = false;
  static Map<String, double> _currentRates = _staticRates;

  // Get available currencies
  static List<Currency> getSupportedCurrencies() {
    return [
      Currency('USD', 'US Dollar', '\$'),
      Currency('EUR', 'Euro', '€'),
      Currency('GBP', 'British Pound', '£'),
      Currency('JPY', 'Japanese Yen', '¥'),
      Currency('CAD', 'Canadian Dollar', 'C\$'),
      Currency('AUD', 'Australian Dollar', 'A\$'),
      Currency('VND', 'Vietnamese Dong', '₫'),
      Currency('CNY', 'Chinese Yuan', '¥'),
      Currency('INR', 'Indian Rupee', '₹'),
      Currency('KRW', 'South Korean Won', '₩'),
      Currency('SGD', 'Singapore Dollar', 'S\$'),
      Currency('THB', 'Thai Baht', '฿'),
      Currency('MYR', 'Malaysian Ringgit', 'RM'),
      Currency('IDR', 'Indonesian Rupiah', 'Rp'),
      Currency('PHP', 'Philippine Peso', '₱'),
    ];
  }

  // Convert currency
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    final fromRate = _currentRates[fromCurrency] ?? 1.0;
    final toRate = _currentRates[toCurrency] ?? 1.0;

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
  } // Future method for real API integration

  static Future<Map<String, double>> fetchLiveRates() async {
    try {
      // Try to use the live_currency_rate package
      var rates = <String, double>{};
      bool hasLiveData = false;

      // Add USD as base
      rates['USD'] = 1.0;

      // Try to get rates for each currency
      for (final currency in getSupportedCurrencies()) {
        if (currency.code != 'USD') {
          try {
            // Try to get live rate from the API
            final result = await LiveCurrencyRate.convertCurrency(
                'USD', currency.code, 1.0);
            if (result.result > 0) {
              rates[currency.code] = result.result;
              hasLiveData = true;
            } else {
              // Fall back to static rate
              rates[currency.code] = _staticRates[currency.code] ?? 1.0;
            }
          } catch (e) {
            print('Failed to get live rate for ${currency.code}: $e');
            // Fall back to static rate
            rates[currency.code] = _staticRates[currency.code] ?? 1.0;
          }
        }
      }

      // Update tracking variables
      if (hasLiveData) {
        _lastUpdated = DateTime.now();
        _isUsingLiveRates = true;
        print('Successfully fetched live currency rates');
      } else {
        _isUsingLiveRates = false;
        print('Using static currency rates (live data unavailable)');
      }

      return rates;
    } catch (e) {
      print('Error fetching live rates: $e');
      // Fall back to static rates
      _isUsingLiveRates = false;
      await Future.delayed(const Duration(milliseconds: 500));
      return _staticRates;
    }
  }

  // Check if API is available
  static bool get isLiveDataAvailable =>
      true; // Set to true now that we have real API integration
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
