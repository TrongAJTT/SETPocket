import 'dart:convert';
import 'package:http/http.dart' as http;

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

  static const String _lastUpdated = '2025-06-07 15:30:00';

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

    final fromRate = _staticRates[fromCurrency] ?? 1.0;
    final toRate = _staticRates[toCurrency] ?? 1.0;

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
    return _lastUpdated;
  }

  // Future method for real API integration
  static Future<Map<String, double>> fetchLiveRates() async {
    // This would connect to a real currency API like:
    // - exchangerate-api.com
    // - openexchangerates.org
    // - currencylayer.com

    // For now, return static rates
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    return _staticRates;
  }

  // Check if API is available
  static bool get isLiveDataAvailable =>
      false; // Set to true when real API is integrated
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
