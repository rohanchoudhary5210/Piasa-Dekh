import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/services/clock_integrity_service.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_date_calculator.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_manager_service.dart';

void main() {
  group('TASK 4: Payday Cycle & Edge Cases Tests', () {
    test('Mid-cycle edit: past days keep old budgets, future days get recalculated', () {
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_mid_edit',
        year: 2026,
        month: 10,
        paydayDay: 1,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(10000), // Discretionary pool = 30,000 in Oct (31 days)
      );

      final days = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);
      expect(days.length, equals(31));

      // Days 1..4 have spent amounts
      days[0] = days[0].copyWith(actualSpent: Money.fromRupees(800)); // Day 1
      days[1] = days[1].copyWith(actualSpent: Money.fromRupees(1200)); // Day 2
      days[2] = days[2].copyWith(actualSpent: Money.fromRupees(1000)); // Day 3
      days[3] = days[3].copyWith(actualSpent: Money.fromRupees(500)); // Day 4
      // Total spent Days 1..4 = 3,500

      // On Day 5, user gets a salary raise:
      // In-hand salary increases to 70,000 (+10,000)
      // New discretionary pool = 70k - 20k - 10k = 40,000
      final result = CycleManagerService.recalculateMidCycle(
        currentCycle: cycle,
        currentBudgets: days,
        currentDayIndex: 5,
        newSalary: Money.fromRupees(70000),
        newFixedExpenses: Money.fromRupees(20000),
        newSavingsTarget: Money.fromRupees(10000),
      );

      // Verify: Past days (Days 1..4) preserved their historical spent and allocations
      expect(result.updatedBudgets[0].actualSpent, equals(Money.fromRupees(800)));
      expect(result.updatedBudgets[1].actualSpent, equals(Money.fromRupees(1200)));
      expect(result.updatedBudgets[2].actualSpent, equals(Money.fromRupees(1000)));
      expect(result.updatedBudgets[3].actualSpent, equals(Money.fromRupees(500)));

      // Remaining pool for Days 5..31 (27 days) = 40,000 - 3,500 = 36,500
      // 36,500 / 27 = 1351.85 / day
      expect(result.updatedBudgets[4].allocatedBudget.inRupees, closeTo(1351.85, 0.05));
      expect(result.updatedBudgets.last.allocatedBudget.inRupees, closeTo(1351.85, 0.05));

      // Sum of past spends (3,500) + future allocations must match the new pool exactly!
      final futureSum = result.updatedBudgets
          .sublist(4)
          .fold<int>(0, (sum, b) => sum + b.allocatedBudget.paise);
      expect(350000 + futureSum, equals(4000000)); // 40,000.00 exact paise match
    });

    test('Second income in a cycle (bonus): increases pool and boosts remaining days', () {
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_bonus_test',
        year: 2026,
        month: 10,
        paydayDay: 1,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(25000),
        savingsTargetAmount: Money.fromRupees(15000), // Pool = 20,000 in Oct (31 days)
      );

      final days = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

      // On Day 10, user receives a ₹5,000 Diwali bonus!
      final result = CycleManagerService.injectExtraIncome(
        currentCycle: cycle,
        currentBudgets: days,
        currentDayIndex: 10,
        extraIncome: Money.fromRupees(5000),
      );

      expect(result.updatedCycle.inHandSalary, equals(Money.fromRupees(65000)));
      expect(result.updatedCycle.discretionaryPool, equals(Money.fromRupees(25000)));

      // Future days (Days 10..31) each get a boost of ~5,000 / 22 days = ~₹227 extra
      expect(result.updatedBudgets[9].allocatedBudget.inRupees, greaterThan(645.0));
    });

    test('Midnight handling: 23:59 vs 00:01 lands on the correct respective days', () {
      final startDate = DateTime(2026, 10, 1);

      // 11:59:50 PM on Oct 5 -> Day 5
      final txDay5 = DateTime(2026, 10, 5, 23, 59, 50);
      final indexDay5 = CycleDateCalculator.getDayIndexForTimestamp(
        timestamp: txDay5,
        cycleStartDate: startDate,
        totalDays: 31,
      );
      expect(indexDay5, equals(5));

      // 12:00:10 AM on Oct 6 -> Day 6
      final txDay6 = DateTime(2026, 10, 6, 0, 0, 10);
      final indexDay6 = CycleDateCalculator.getDayIndexForTimestamp(
        timestamp: txDay6,
        cycleStartDate: startDate,
        totalDays: 31,
      );
      expect(indexDay6, equals(6));
    });

    test('App closed for 3 to 4 days: intermediate days closed and rollover rebalanced', () {
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_missed_days',
        year: 2026,
        month: 10,
        paydayDay: 1,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(10000), // Pool = 30,000 in Oct (31 days)
      );

      final days = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

      // User closed app on Day 5 and reopened on Day 9 (missed Days 6, 7, 8)
      final caughtUp = CycleManagerService.catchUpMissedDays(
        cycle: cycle,
        budgets: days,
        lastKnownDayIndex: 5,
        currentDayIndex: 9,
      );

      // Intermediate days 6, 7, 8 marked as closed
      expect(caughtUp[5].isClosed, isTrue); // Day 6
      expect(caughtUp[6].isClosed, isTrue); // Day 7
      expect(caughtUp[7].isClosed, isTrue); // Day 8

      // Formula: B(t+1..N) = R(t) / (N - t)
      // Days 10..31 (index 9) receive the unspent surplus rollover
      expect(caughtUp[9].allocatedBudget.inRupees, greaterThan(1000.0));
    });

    test('Cheating protection: device clock moving backwards flags manipulation', () {
      final lastKnownTime = DateTime(2026, 10, 21, 15, 30);

      // Device time moved 10 minutes into the past
      final tamperedTime = DateTime(2026, 10, 21, 15, 20);
      expect(
        ClockIntegrityService.isClockManipulated(
          currentTimestamp: tamperedTime,
          lastKnownTimestamp: lastKnownTime,
        ),
        isTrue,
      );

      // Device time moved forward normally
      final normalTime = DateTime(2026, 10, 21, 15, 35);
      expect(
        ClockIntegrityService.isClockManipulated(
          currentTimestamp: normalTime,
          lastKnownTimestamp: lastKnownTime,
        ),
        isFalse,
      );
    });
  });
}
