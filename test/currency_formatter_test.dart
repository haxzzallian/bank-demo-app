import 'package:flutter_test/flutter_test.dart';

import 'package:bank_dump/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formats a whole number with two decimal places', () {
      expect(CurrencyFormatter.format(1000), '₦1,000.00');
    });

    test('formats a fractional amount', () {
      expect(CurrencyFormatter.format(24500.5), '₦24,500.50');
    });

    test('formats zero', () {
      expect(CurrencyFormatter.format(0), '₦0.00');
    });

    test('formats a large amount with thousands separators', () {
      expect(CurrencyFormatter.format(5017000), '₦5,017,000.00');
    });
  });

  group('CurrencyFormatter.formatWhole', () {
    test('formats without decimal places', () {
      expect(CurrencyFormatter.formatWhole(1000), '₦1,000');
    });

    test('rounds a fractional amount', () {
      expect(CurrencyFormatter.formatWhole(24500.5), '₦24,501');
    });

    test('formats zero', () {
      expect(CurrencyFormatter.formatWhole(0), '₦0');
    });
  });
}
