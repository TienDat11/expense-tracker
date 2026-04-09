import 'package:intl/intl.dart';

/// Utility for formatting Vietnamese Dong currency values.
///
/// Provides consistent currency formatting across the application.
/// Uses Vietnamese locale and VND symbol.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a numeric value as Vietnamese Dong currency.
  ///
  /// Examples:
  /// - 100000 -> 100.000 ₫
  /// - 1250000.5 -> 1.250.001 ₫
  /// - 0 -> 0 ₫
  static String format(double amount) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  /// Formats a numeric value as Vietnamese Dong currency with decimal.
  ///
  /// Useful when fractional values need to be displayed.
  static String formatWithDecimal(double amount) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 2,
    );
    return format.format(amount);
  }
}
