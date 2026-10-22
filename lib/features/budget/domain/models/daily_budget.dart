import '../../../../core/models/money.dart';

enum DailyBudgetStatus {
  under,      // Spent < Allocated
  exact,      // Spent == Allocated
  over,       // Spent > Allocated
  zeroSpend,  // Spent == 0 (Special streak achievement)
  pending,    // Future day, not yet started
}

class DailyBudget {
  final String id;
  final String cycleId;
  final DateTime date;
  final int dayIndex; // 1 to totalDays
  final Money allocatedBudget;
  final Money actualSpent;
  final bool isClosed;

  const DailyBudget({
    required this.id,
    required this.cycleId,
    required this.date,
    required this.dayIndex,
    required this.allocatedBudget,
    this.actualSpent = const Money.zero(),
    this.isClosed = false,
  });

  /// Remaining spendable balance for today
  Money get remainingBudget => allocatedBudget - actualSpent;

  /// Surplus if positive, deficit if negative
  Money get balanceDelta => allocatedBudget - actualSpent;

  /// Percentage of daily budget used (0.0 to 1.0+)
  double get spentRatio {
    if (allocatedBudget.paise <= 0) {
      return actualSpent.paise > 0 ? 1.0 : 0.0;
    }
    return actualSpent.paise / allocatedBudget.paise;
  }

  DailyBudgetStatus get status {
    if (!isClosed && actualSpent.isZero) {
      return DailyBudgetStatus.pending;
    }
    if (actualSpent.isZero) {
      return DailyBudgetStatus.zeroSpend;
    }
    if (actualSpent < allocatedBudget) {
      return DailyBudgetStatus.under;
    }
    if (actualSpent == allocatedBudget) {
      return DailyBudgetStatus.exact;
    }
    return DailyBudgetStatus.over;
  }

  DailyBudget copyWith({
    String? id,
    String? cycleId,
    DateTime? date,
    int? dayIndex,
    Money? allocatedBudget,
    Money? actualSpent,
    bool? isClosed,
  }) {
    return DailyBudget(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      date: date ?? this.date,
      dayIndex: dayIndex ?? this.dayIndex,
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
      actualSpent: actualSpent ?? this.actualSpent,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cycleId': cycleId,
      'date': date.toIso8601String(),
      'dayIndex': dayIndex,
      'allocatedBudgetPaise': allocatedBudget.paise,
      'actualSpentPaise': actualSpent.paise,
      'isClosed': isClosed,
    };
  }

  factory DailyBudget.fromJson(Map<String, dynamic> json) {
    return DailyBudget(
      id: json['id'] as String,
      cycleId: json['cycleId'] as String,
      date: DateTime.parse(json['date'] as String),
      dayIndex: json['dayIndex'] as int,
      allocatedBudget: Money.fromPaise(json['allocatedBudgetPaise'] as int),
      actualSpent: Money.fromPaise(json['actualSpentPaise'] as int? ?? 0),
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }
}
