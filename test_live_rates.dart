import 'package:my_multi_tools/services/currency_service.dart';

void main() async {
  print('Testing live currency rates...');

  try {
    // Test refresh rates
    print('Refreshing rates...');
    await CurrencyService.refreshRates();

    // Check if using live rates
    print('Using live rates: ${CurrencyService.isUsingLiveRates}');
    print('Last updated: ${CurrencyService.getLastUpdated()}');

    // Test conversion
    final usdToEur = CurrencyService.convert(100, 'USD', 'EUR');
    print('100 USD = $usdToEur EUR');

    final eurToJpy = CurrencyService.convert(100, 'EUR', 'JPY');
    print('100 EUR = $eurToJpy JPY');

    print('Test completed successfully!');
  } catch (e) {
    print('Error during test: $e');
  }
}
