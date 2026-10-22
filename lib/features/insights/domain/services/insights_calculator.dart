import 'dart:math';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

class MonthEndPrediction {
  final Money projectedSavings;
  final Money averageDailySpend;
  final Money totalDiscretionarySpentSoFar;
  final int daysRemaining;
  final bool isOnTrack;
  final String paceMessage;

  const MonthEndPrediction({
    required this.projectedSavings,
    required this.averageDailySpend,
    required this.totalDiscretionarySpentSoFar,
    required this.daysRemaining,
    required this.isOnTrack,
    required this.paceMessage,
  });
}

class CategorySpending {
  final TransactionCategory category;
  final Money totalSpent;
  final double percentage;

  const CategorySpending({
    required this.category,
    required this.totalSpent,
    required this.percentage,
  });
}

class DailySpendingPoint {
  final int dayIndex;
  final String label;
  final Money spent;
  final Money budget;

  const DailySpendingPoint({
    required this.dayIndex,
    required this.label,
    required this.spent,
    required this.budget,
  });
}

class SavingsGrowthPoint {
  final int dayIndex;
  final Money cumulativeSaved;
  final Money plannedSaved;

  const SavingsGrowthPoint({
    required this.dayIndex,
    required this.cumulativeSaved,
    required this.plannedSaved,
  });
}

class InsightsCalculator {
  InsightsCalculator._();

  /// Calculates Month-End Savings Prediction:
  /// "At this pace you will save ₹X"
  /// Handles Day 1 with 0 transactions without crashing or showing nonsense.
  static MonthEndPrediction calculateMonthEndPrediction({
    required BudgetCycle cycle,
    required List<Transaction> transactions,
    required int currentDayIndex,
  }) {
    // 1. Calculate net discretionary spending so far
    int totalSpentPaise = 0;
    for (final tx in transactions) {
      if (!tx.type.affectsDailyBudget || tx.isFixedExpense) continue;
      if (tx.type == TransactionType.refund ||
          (tx.type == TransactionType.splitShare && tx.isReimbursement)) {
        totalSpentPaise -= tx.amount.paise;
      } else {
        totalSpentPaise += tx.amount.paise;
      }
    }
    // Net discretionary spent cannot be negative for prediction purposes
    final netSpentPaise = max(0, totalSpentPaise);
    final totalSpentSoFar = Money.fromPaise(netSpentPaise);

    final totalDays = max(1, cycle.totalDays);
    final effectiveDay = currentDayIndex.clamp(1, totalDays);
    final daysRemaining = max(0, totalDays - effectiveDay);

    // Day 1 with zero transactions edge-case:
    // If Day 1 and no spends logged yet, pace equals planned budget
    if (effectiveDay == 1 && netSpentPaise == 0) {
      return MonthEndPrediction(
        projectedSavings: cycle.savingsTargetAmount,
        averageDailySpend: const Money.zero(),
        totalDiscretionarySpentSoFar: const Money.zero(),
        daysRemaining: daysRemaining,
        isOnTrack: true,
        paceMessage:
            'At this pace you will save ${CurrencyFormatter.formatMoney(cycle.savingsTargetAmount)} by cycle end!',
      );
    }

    // Average daily spend so far
    final averageDailySpendPaise = (netSpentPaise / effectiveDay).round();
    final averageDailySpend = Money.fromPaise(averageDailySpendPaise);

    // Projected total discretionary spend at end of cycle
    final projectedSpendPaise =
        netSpentPaise + (averageDailySpendPaise * daysRemaining);

    // In-hand salary minus fixed expenses is total spendable capacity
    final maxSpendableCapacityPaise =
        cycle.inHandSalary.paise - cycle.fixedExpensesTotal.paise;

    // Projected savings = In-hand - Fixed Expenses - Projected Spend
    final projectedSavingsPaise =
        maxSpendableCapacityPaise - projectedSpendPaise;

    final projectedSavings = Money.fromPaise(max(0, projectedSavingsPaise));
    final isOnTrack =
        projectedSavingsPaise >= cycle.savingsTargetAmount.paise;

    String paceMessage;
    if (projectedSavingsPaise >= cycle.savingsTargetAmount.paise) {
      paceMessage =
          'At this pace you will save ${CurrencyFormatter.formatMoney(projectedSavings)} (Target met! 🟢)';
    } else if (projectedSavingsPaise > 0) {
      final shortfall = Money.fromPaise(
          cycle.savingsTargetAmount.paise - projectedSavingsPaise);
      paceMessage =
          'At this pace you will save ${CurrencyFormatter.formatMoney(projectedSavings)} (${CurrencyFormatter.formatMoney(shortfall)} below target 🟡)';
    } else {
      final deficit = Money.fromPaise(projectedSavingsPaise.abs());
      paceMessage =
          'At this pace you will exceed your treasury by ${CurrencyFormatter.formatMoney(deficit)} 🔴';
    }

    return MonthEndPrediction(
      projectedSavings: projectedSavings,
      averageDailySpend: averageDailySpend,
      totalDiscretionarySpentSoFar: totalSpentSoFar,
      daysRemaining: daysRemaining,
      isOnTrack: isOnTrack,
      paceMessage: paceMessage,
    );
  }

  /// Calculates spending breakdown by category with percentages.
  static List<CategorySpending> calculateCategoryBreakdown({
    required List<Transaction> transactions,
  }) {
    if (transactions.isEmpty) return const [];

    final Map<TransactionCategory, int> categoryTotals = {};
    int grandTotalPaise = 0;

    for (final tx in transactions) {
      if (!tx.type.affectsDailyBudget || tx.isFixedExpense) continue;

      int paiseImpact = 0;
      if (tx.type == TransactionType.refund ||
          (tx.type == TransactionType.splitShare && tx.isReimbursement)) {
        paiseImpact = -tx.amount.paise;
      } else {
        paiseImpact = tx.amount.paise;
      }

      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + paiseImpact;
      grandTotalPaise += paiseImpact;
    }

    if (grandTotalPaise <= 0) return const [];

    final List<CategorySpending> results = [];
    for (final entry in categoryTotals.entries) {
      if (entry.value <= 0) continue;
      final percentage = (entry.value / grandTotalPaise) * 100.0;
      results.add(
        CategorySpending(
          category: entry.key,
          totalSpent: Money.fromPaise(entry.value),
          percentage: double.parse(percentage.toStringAsFixed(1)),
        ),
      );
    }

    results.sort((a, b) => b.totalSpent.paise.compareTo(a.totalSpent.paise));
    return results;
  }

  /// Calculates weekly spending points for the last 7 days leading up to [currentDayIndex].
  static List<DailySpendingPoint> calculateWeeklySpending({
    required BudgetCycle cycle,
    required List<DailyBudget> dailyBudgets,
    required int currentDayIndex,
  }) {
    if (dailyBudgets.isEmpty) return const [];

    final startDay = max(1, currentDayIndex - 6);
    final endDay = currentDayIndex.clamp(1, dailyBudgets.length);

    final List<DailySpendingPoint> points = [];
    for (int day = startDay; day <= endDay; day++) {
      final idx = day - 1;
      if (idx < dailyBudgets.length) {
        final b = dailyBudgets[idx];
        points.add(
          DailySpendingPoint(
            dayIndex: day,
            label: 'D$day',
            spent: b.actualSpent,
            budget: b.allocatedBudget,
          ),
        );
      }
    }
    return points;
  }

  /// Calculates cumulative savings growth day by day.
  static List<SavingsGrowthPoint> calculateSavingsGrowth({
    required BudgetCycle cycle,
    required List<DailyBudget> dailyBudgets,
    required int currentDayIndex,
  }) {
    if (dailyBudgets.isEmpty) return const [];

    final List<SavingsGrowthPoint> points = [];
    int cumulativeSavedPaise = 0;
    final totalDays = max(1, cycle.totalDays);
    final dailyPlannedSavingsPaise =
        cycle.savingsTargetAmount.paise ~/ totalDays;

    for (int i = 0; i < currentDayIndex && i < dailyBudgets.length; i++) {
      final b = dailyBudgets[i];
      final unspent = b.allocatedBudget.paise - b.actualSpent.paise;
      cumulativeSavedPaise += max(0, unspent);

      points.add(
        SavingsGrowthPoint(
          dayIndex: b.dayIndex,
          cumulativeSaved: Money.fromPaise(cumulativeSavedPaise),
          plannedSaved:
              Money.fromPaise(dailyPlannedSavingsPaise * b.dayIndex),
        ),
      );
    }
    return points;
  }

  /// 30-Day (full cycle) Budget vs Spent dataset.
  static List<DailySpendingPoint> calculateFullCycleBudgetVsSpent({
    required List<DailyBudget> dailyBudgets,
  }) {
    return dailyBudgets.map((b) {
      return DailySpendingPoint(
        dayIndex: b.dayIndex,
        label: '${b.dayIndex}',
        spent: b.actualSpent,
        budget: b.allocatedBudget,
      );
    }).toList();
  }
}
