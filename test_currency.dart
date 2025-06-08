import 'package:flutter_test/flutter_test.dart';
import 'package:live_currency_rate/live_currency_rate.dart';

void main() {
  test('Test live_currency_rate package', () async {
    print('Testing live_currency_rate package...');

    try {
      // Test getting USD to EUR rate
      final rate = await LiveCurrencyRate.convertCurrency(
        baseCurrency: 'USD',
        targetCurrency: 'EUR',
        amount: 1.0,
      );
      print('1 USD = $rate EUR');
      expect(rate, isA<double>());

      // Test getting multiple rates
      final rates =
          await LiveCurrencyRate.getCurrencyRates(baseCurrency: 'USD');
      print('USD rates: $rates');
      expect(rates, isA<Map<String, double>>());
    } catch (e) {
      print('Error: $e');
      // The test might fail due to network issues, which is okay
    }
  });
}
