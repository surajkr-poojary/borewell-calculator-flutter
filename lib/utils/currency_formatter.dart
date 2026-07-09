import 'package:intl/intl.dart';

/// Formats numbers using the Indian numbering system, e.g. ₹1,50,000.
class CurrencyFormatter {
  static final NumberFormat _rupeeFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(num amount) => _rupeeFormat.format(amount);
}
