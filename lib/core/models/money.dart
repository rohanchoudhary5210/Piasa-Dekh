import 'package:flutter/foundation.dart';
import '../utils/currency_formatter.dart';

@immutable
class Money implements Comparable<Money> {
  /// Amount stored as an exact integer number of paise (1 Rupee = 100 paise).
  final int paise;

  const Money.fromPaise(this.paise);

  const Money.zero() : paise = 0;

  /// Creates Money from rupees (converts to integer paise via rounding to eliminate float drift).
  factory Money.fromRupees(num rupees) {
    return Money.fromPaise((rupees * 100).round());
  }

  /// Parses an input string (e.g. "150", "99.50", "1500.00") into Money.
  /// Throws FormatException if invalid.
  factory Money.parse(String text) {
    final cleaned = text.trim().replaceAll(',', '').replaceAll('₹', '');
    if (cleaned.isEmpty) {
      throw const FormatException('Empty money string');
    }
    final parsed = double.tryParse(cleaned);
    if (parsed == null) {
      throw FormatException('Invalid money format: $text');
    }
    return Money.fromRupees(parsed);
  }

  static Money? tryParse(String? text) {
    if (text == null) return null;
    try {
      return Money.parse(text);
    } catch (_) {
      return null;
    }
  }

  double get inRupees => paise / 100.0;
  int get inWholeRupees => paise ~/ 100;
  int get paiseComponent => paise.remainder(100).abs();

  bool get isZero => paise == 0;
  bool get isPositive => paise > 0;
  bool get isNegative => paise < 0;

  Money abs() => Money.fromPaise(paise.abs());

  Money operator +(Money other) => Money.fromPaise(paise + other.paise);
  Money operator -(Money other) => Money.fromPaise(paise - other.paise);
  Money operator -() => Money.fromPaise(-paise);
  Money operator *(num factor) => Money.fromPaise((paise * factor).round());

  bool operator <(Money other) => paise < other.paise;
  bool operator <=(Money other) => paise <= other.paise;
  bool operator >(Money other) => paise > other.paise;
  bool operator >=(Money other) => paise >= other.paise;

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Money && other.paise == paise);

  @override
  int get hashCode => paise.hashCode;

  /// Distributes an exact total across [count] days.
  /// Remainder paise are distributed 1-by-1 across days so:
  /// sum(distributed) == total.paise exactly with 0 rounding drift.
  static List<Money> distribute(Money total, int count) {
    if (count <= 0) return const [];
    final totalPaise = total.paise;
    final basePaise = totalPaise ~/ count;
    int remainder = totalPaise.remainder(count);

    final result = <Money>[];
    for (int i = 0; i < count; i++) {
      int current = basePaise;
      if (remainder > 0) {
        current += 1;
        remainder -= 1;
      } else if (remainder < 0) {
        current -= 1;
        remainder += 1;
      }
      result.add(Money.fromPaise(current));
    }
    return result;
  }

  String format({bool showDecimals = false}) {
    return CurrencyFormatter.formatMoney(this, showDecimals: showDecimals);
  }

  String formatCompact() {
    return CurrencyFormatter.formatCompactMoney(this);
  }

  @override
  String toString() => format(showDecimals: paiseComponent != 0);
}
