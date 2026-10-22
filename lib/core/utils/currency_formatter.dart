import 'package:intl/intl.dart';
import '../models/money.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String formatMoney(Money money, {bool showDecimals = false}) {
    final rupees = money.inRupees;
    if (showDecimals || money.paiseComponent != 0) {
      return _inrDecimals.format(rupees);
    }
    return _inrFormat.format(rupees);
  }

  static String formatCompactMoney(Money money) {
    final absPaise = money.paise.abs();
    final sign = money.isNegative ? '-' : '';

    // Indian Lakhs and Crores support
    // 1 Crore = 10,000,000 Rupees = 1,000,000,000 paise
    // 1 Lakh = 100,000 Rupees = 10,000,000 paise
    // 1 Thousand = 1,000 Rupees = 100,000 paise
    if (absPaise >= 1000000000) {
      final cr = money.inRupees.abs() / 10000000.0;
      return '$sign₹${cr.toStringAsFixed(cr >= 100 ? 0 : 2)}Cr';
    } else if (absPaise >= 10000000) {
      final lk = money.inRupees.abs() / 100000.0;
      return '$sign₹${lk.toStringAsFixed(lk >= 100 ? 0 : 1)}L';
    } else if (absPaise >= 100000) {
      final k = money.inRupees.abs() / 1000.0;
      return '$sign₹${k.toStringAsFixed(k >= 100 ? 0 : 1)}k';
    }
    return formatMoney(money, showDecimals: money.paiseComponent != 0);
  }

  // Legacy helper overloads for backwards compatibility
  static String format(num amount, {bool showDecimals = false}) {
    return formatMoney(Money.fromRupees(amount), showDecimals: showDecimals);
  }

  static String formatCompact(num amount) {
    return formatCompactMoney(Money.fromRupees(amount));
  }
}
