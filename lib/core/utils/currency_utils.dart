import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatAmount(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.compactCurrency(
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
