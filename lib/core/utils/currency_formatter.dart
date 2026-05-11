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
}