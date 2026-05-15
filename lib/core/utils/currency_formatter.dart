import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String toIDR(dynamic amount) {
    if (amount == null) return 'Rp 0';
    try {
      final double value = amount is String ? double.parse(amount) : amount.toDouble();
      final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      return formatter.format(value);
    } catch (e) {
      return 'Rp 0';
    }
  }

  static String toShortIDR(dynamic amount) {
    if (amount == null) return 'Rp 0';
    try {
      final double price = amount is String ? double.parse(amount) : amount.toDouble();
      if (price >= 1000000) {
        return 'Rp ${(price / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
      } else if (price >= 1000) {
        return 'Rp ${(price / 1000).toStringAsFixed(0)}k';
      }
      return toIDR(price);
    } catch (e) {
      return 'Rp 0';
    }
  }
}