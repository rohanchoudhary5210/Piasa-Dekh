import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';

abstract class RolloverStrategy {
  String get name;
  String get description;

  /// Rebalances budgets for remaining days based on historical spends and remaining pool.
  List<DailyBudget> rebalance({
    required BudgetCycle cycle,
    required List<DailyBudget> currentBudgets,
    required int currentDayIndex,
  });
}

/// Strategy A (Default): Dynamic Smoothing
/// Formula: B(t+1..N) = R(t) / (N - t)
/// Evenly distributes any surplus across all remaining days in the cycle.
/// Strictly guards against N - t = 0 on the last day.
class DynamicSmoothingStrategy implements RolloverStrategy {
  const DynamicSmoothingStrategy();

  @override
  String get name => 'Dynamic Smoothing';

  @override
  String get description =>
      'Evenly adjusts future days when you spend more or less than planned.';

  @override
  List<DailyBudget> rebalance({
    required BudgetCycle cycle,
    required List<DailyBudget> currentBudgets,
    required int currentDayIndex,
  }) {
    final updatedList = List<DailyBudget>.from(currentBudgets);
    updatedList.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));

    Money totalSpentSoFar = const Money.zero();
    for (int i = 0; i < currentDayIndex && i < updatedList.length; i++) {
      totalSpentSoFar = totalSpentSoFar + updatedList[i].actualSpent;
    }

    final totalDiscretionary = cycle.discretionaryPool;
    final remainingPool = totalDiscretionary - totalSpentSoFar;
    final remainingDaysCount = cycle.totalDays - currentDayIndex;

    // Strict guard against (N - t) <= 0 on the last day of the cycle.
    // When remainingDaysCount <= 0, no future days exist; never divide by zero.
    // Leftover or deficit is preserved in the cycle totals (savings vault or debt).
    if (remainingDaysCount > 0) {
      if (remainingPool.isPositive) {
        // Distribute exact paise across remaining days with zero rounding drift
        final distributed = Money.distribute(remainingPool, remainingDaysCount);
        for (int i = 0; i < remainingDaysCount; i++) {
          final targetIndex = currentDayIndex + i;
          if (targetIndex < updatedList.length) {
            updatedList[targetIndex] = updatedList[targetIndex].copyWith(
              allocatedBudget: distributed[i],
            );
          }
        }
      } else {
        // Zero or deficit pool: future days get zero allocated budget
        for (int i = currentDayIndex; i < updatedList.length; i++) {
          updatedList[i] = updatedList[i].copyWith(
            allocatedBudget: const Money.zero(),
          );
        }
      }
    }

    return updatedList;
  }
}

/// Strategy B (Future setting placeholder): Vault Sweep
class VaultSweepStrategy implements RolloverStrategy {
  const VaultSweepStrategy();

  @override
  String get name => 'Vault Sweep';

  @override
  String get description =>
      'Daily savings go straight to your vault; overspending borrows from upcoming days.';

  @override
  List<DailyBudget> rebalance({
    required BudgetCycle cycle,
    required List<DailyBudget> currentBudgets,
    required int currentDayIndex,
  }) {
    return const DynamicSmoothingStrategy().rebalance(
      cycle: cycle,
      currentBudgets: currentBudgets,
      currentDayIndex: currentDayIndex,
    );
  }
}
