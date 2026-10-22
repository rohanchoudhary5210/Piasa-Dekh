import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';

class CycleManagerService {
  CycleManagerService._();

  /// Mid-cycle edit of salary, fixed expenses, or savings goal:
  /// Past days (1 .. currentDayIndex - 1) keep their historical allocated budgets and actual spends.
  /// Remaining days (currentDayIndex .. totalDays) are recalculated using the new pool minus past spending.
  static ({BudgetCycle updatedCycle, List<DailyBudget> updatedBudgets}) recalculateMidCycle({
    required BudgetCycle currentCycle,
    required List<DailyBudget> currentBudgets,
    required int currentDayIndex,
    required Money newSalary,
    required Money newFixedExpenses,
    required Money newSavingsTarget,
  }) {
    final updatedCycle = currentCycle.copyWith(
      inHandSalary: newSalary,
      fixedExpensesTotal: newFixedExpenses,
      savingsTargetAmount: newSavingsTarget,
    );

    final updatedList = List<DailyBudget>.from(currentBudgets);
    updatedList.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));

    // Sum past actual expenditures (Days 1 .. currentDayIndex - 1)
    Money pastSpent = const Money.zero();
    for (int i = 0; i < currentDayIndex - 1 && i < updatedList.length; i++) {
      pastSpent = pastSpent + updatedList[i].actualSpent;
    }

    final newDiscretionaryPool = updatedCycle.discretionaryPool;
    final remainingPool = newDiscretionaryPool - pastSpent;
    final remainingDaysCount = updatedCycle.totalDays - (currentDayIndex - 1);

    if (remainingDaysCount > 0) {
      if (remainingPool.isPositive) {
        final distributed =
            Money.distribute(remainingPool, remainingDaysCount);
        for (int i = 0; i < remainingDaysCount; i++) {
          final targetIndex = (currentDayIndex - 1) + i;
          if (targetIndex < updatedList.length) {
            updatedList[targetIndex] = updatedList[targetIndex].copyWith(
              allocatedBudget: distributed[i],
            );
          }
        }
      } else {
        // Deficit: future days get zero
        for (int i = currentDayIndex - 1; i < updatedList.length; i++) {
          updatedList[i] = updatedList[i].copyWith(
            allocatedBudget: const Money.zero(),
          );
        }
      }
    }

    return (
      updatedCycle: updatedCycle,
      updatedBudgets: updatedList,
    );
  }

  /// Injects second income (bonus, arrears, freelance payment) into the active cycle.
  /// The bonus expands the discretionary pool and boosts all remaining days equally.
  static ({BudgetCycle updatedCycle, List<DailyBudget> updatedBudgets}) injectExtraIncome({
    required BudgetCycle currentCycle,
    required List<DailyBudget> currentBudgets,
    required int currentDayIndex,
    required Money extraIncome,
  }) {
    final updatedCycle = currentCycle.copyWith(
      inHandSalary: currentCycle.inHandSalary + extraIncome,
    );

    final rebalanced = recalculateMidCycle(
      currentCycle: updatedCycle,
      currentBudgets: currentBudgets,
      currentDayIndex: currentDayIndex,
      newSalary: updatedCycle.inHandSalary,
      newFixedExpenses: updatedCycle.fixedExpensesTotal,
      newSavingsTarget: updatedCycle.savingsTargetAmount,
    );

    return rebalanced;
  }

  /// When the app was closed for several days, intermediate days are closed
  /// and future days are rebalanced via Dynamic Smoothing rollover.
  static List<DailyBudget> catchUpMissedDays({
    required BudgetCycle cycle,
    required List<DailyBudget> budgets,
    required int lastKnownDayIndex,
    required int currentDayIndex,
  }) {
    if (currentDayIndex <= lastKnownDayIndex) return budgets;

    final updated = List<DailyBudget>.from(budgets);
    for (int i = lastKnownDayIndex - 1;
        i < currentDayIndex - 1 && i < updated.length;
        i++) {
      updated[i] = updated[i].copyWith(isClosed: true);
    }

    return BudgetCalculator.rebalanceBudgets(
      cycle: cycle,
      currentBudgets: updated,
      currentDayIndex: currentDayIndex,
    );
  }
}
