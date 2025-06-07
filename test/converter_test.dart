import 'package:flutter_test/flutter_test.dart';
import 'package:my_multi_tools/models/converter_models.dart';

void main() {
  group('Converter Tests', () {
    test('Length conversion works correctly', () {
      final converter = LengthConverter();
      final result = converter.convert(1000, 'millimeters', 'meters');
      expect(result, equals(1.0));
    });

    test('Weight conversion works correctly', () {
      final converter = WeightConverter();
      final result = converter.convert(1000, 'grams', 'kilograms');
      expect(result, equals(1.0));
    });

    test('Temperature conversion works correctly', () {
      final converter = TemperatureConverter();
      final result = converter.convert(0, 'celsius', 'fahrenheit');
      expect(result, equals(32.0));
    });

    test('Volume conversion works correctly', () {
      final converter = VolumeConverter();
      final result = converter.convert(1, 'liters', 'milliliters');
      expect(result, equals(1000.0));
    });

    test('Currency conversion uses CurrencyService', () {
      final converter = CurrencyConverter();
      final result = converter.convert(100, 'USD', 'EUR');
      expect(result, equals(85.0)); // Based on static rates
    });
  });
}
