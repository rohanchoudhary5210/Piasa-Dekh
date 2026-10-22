import '../../../../core/models/money.dart';
import '../models/budget_cycle.dart';
import '../models/daily_budget.dart';

class BudgetCalculator {
  BudgetCalculator._();

  /// Generates initial daily budgets for a fresh cycle.
  /// Distributes remainder paise across days so the sum of all days
  /// equals cycle.discretionaryPool exactly.
  static List<DailyBudget> generateInitialCycleBudgets({
    required BudgetCycle cycle,
  }) {
    final List<DailyBudget> days = [];
    final totalDays = cycle.totalDays;
    if (totalDays <= 0) return days;

    final distributedBudgets =
        Money.distribute(cycle.discretionaryPool, totalDays);

    for (int i = 0; i < totalDays; i++) {
      final date = cycle.startDate.add(Duration(days: i));
      final dayNumber = i + 1;

      days.add(
        DailyBudget(
          id: '${cycle.id}_day_$dayNumber',
          cycleId: cycle.id,
          date: date,
          dayIndex: dayNumber,
          allocatedBudget: distributedBudgets[i],
          actualSpent: const Money.zero(),
          isClosed: false,
        ),
      );
    }
    return days;
  }

  /// Delegates to the cycle's configured RolloverStrategy (default: DynamicSmoothingStrategy)
  static List<DailyBudget> rebalanceBudgets({
    required BudgetCycle cycle,
    required List<DailyBudget> currentBudgets,
    required int currentDayIndex,
  }) {
    return cycle.rolloverStrategy.rebalance(
      cycle: cycle,
      currentBudgets: currentBudgets,
      currentDayIndex: currentDayIndex,
    );
  }

  /// Computes cumulative surplus accumulated from all past closed days.
  static Money calculateTotalSurplus(
      List<DailyBudget> budgets, int upToDayIndex) {
    Money surplus = const Money.zero();
    for (final day in budgets) {
      if (day.dayIndex < upToDayIndex) {
        surplus = surplus + day.balanceDelta;
      }
    }
    return surplus;
  }
}
