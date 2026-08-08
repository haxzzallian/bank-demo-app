import 'package:intl/intl.dart';

/// Formats amounts as Naira currency, e.g. `₦24,500.00`. Shared across every
/// screen that displays money — balance, transactions, deposit/withdraw/
/// transfer amounts — so formatting stays consistent everywhere.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _format = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  );

  static final NumberFormat _formatWhole = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  static String format(num amount) => _format.format(amount);

  /// Same as [format] but without decimal digits — useful for large,
  /// glanceable figures like the dashboard balance.
  static String formatWhole(num amount) => _formatWhole.format(amount);
}
