import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/budget_validation_exception.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_date_calculator.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/gamification/domain/services/gamification_engine.dart';

void main() {
  group('TASK 1: Money Type & Exact Remainder Distribution Tests', () {
    test('Money stores exact integer paise and parses correctly', () {
      final m1 = Money.fromRupees(99.50);
      expect(m1.paise, equals(9950));
      expect(m1.inRupees, equals(99.50));
      expect(m1.paiseComponent, equals(50));
      expect(m1.inWholeRupees, equals(99));

      final mParsed = Money.parse('₹99.50');
      expect(mParsed.paise, equals(9950));

      final mLarge = Money.fromRupees(10000000); // 1 Crore
      expect(mLarge.paise, equals(1000000000));
      expect(mLarge.formatCompact(), equals('₹1.00Cr'));
    });

    test('Money.distribute distributes remainder paise so sum equals total exactly', () {
      final parts = Money.distribute(const Money.fromPaise(100), 3);
      expect(parts.length, equals(3));
      expect(parts[0].paise, equals(34));
      expect(parts[1].paise, equals(33));
      expect(parts[2].paise, equals(33));

      final totalSum = parts.fold(const Money.zero(), (sum, item) => sum + item);
      expect(totalSum.paise, equals(100));
    });

    test('Money.distribute handles negative totals (deficits) with exact sum', () {
      final parts = Money.distribute(const Money.fromPaise(-100), 3);
      expect(parts.length, equals(3));
      expect(parts[0].paise, equals(-34));
      expect(parts[1].paise, equals(-33));
      expect(parts[2].paise, equals(-33));

      final totalSum = parts.fold(const Money.zero(), (sum, item) => sum + item);
      expect(totalSum.paise, equals(-100));
    });
  });

  group('TASK 2: Variable Cycle Length & Validations', () {
    test('Validation: Salary 0 or negative is rejected', () {
      expect(
        () => BudgetCycle.createValidated(
          id: 'test_cycle',
          year: 2026,
          month: 10,
          paydayDay: 1,
          inHandSalary: Money.fromRupees(0),
          fixedExpensesTotal: Money.fromRupees(5000),
          savingsTargetAmount: Money.fromRupees(2000),
        ),
        throwsA(isA<BudgetValidationException>()),
      );

      expect(
        () => BudgetCycle.createValidated(
          id: 'test_cycle',
          year: 2026,
          month: 10,
          paydayDay: 1,
          inHandSalary: Money.fromRupees(-1000),
          fixedExpensesTotal: Money.fromRupees(5000),
          savingsTargetAmount: Money.fromRupees(2000),
        ),
        throwsA(isA<BudgetValidationException>()),
      );
    });

    test('Validation: Fixed expenses + savings goal > salary is rejected, no negative daily budget', () {
      expect(
        () => BudgetCycle.createValidated(
          id: 'test_cycle',
          year: 2026,
          month: 10,
          paydayDay: 1,
          inHandSalary: Money.fromRupees(50000),
          fixedExpensesTotal: Money.fromRupees(35000),
          savingsTargetAmount: Money.fromRupees(20000), // 35k + 20k = 55k > 50k
        ),
        throwsA(isA<BudgetValidationException>()),
      );
    });

    test('Payday Anchoring: cycle runs from custom payday to day before next payday', () {
      // Anchored to 25th of October 2026
      // Cycle: Oct 25, 2026 to Nov 24, 2026 inclusive
      final dates = CycleDateCalculator.computeCycleDates(
        year: 2026,
        month: 10,
        paydayDay: 25,
      );

      expect(dates.startDate, equals(DateTime(2026, 10, 25)));
      expect(dates.endDate, equals(DateTime(2026, 11, 24)));
      expect(dates.totalDays, equals(31)); // Oct has 31 days (7 in Oct + 24 in Nov = 31)
    });

    test('Payday Anchoring in February (28 days non-leap year)', () {
      // Anchored to 25th of January 2027
      // Cycle: Jan 25 to Feb 24 (31 days)
      // Next cycle: Feb 25, 2027 to Mar 24, 2027 (28 days in non-leap year)
      final dates = CycleDateCalculator.computeCycleDates(
        year: 2027,
        month: 2,
        paydayDay: 25,
      );

      expect(dates.startDate, equals(DateTime(2027, 2, 25)));
      expect(dates.endDate, equals(DateTime(2027, 3, 24)));
      expect(dates.totalDays, equals(28)); // Feb 25, 26, 27, 28 + 24 in March = 28
    });

    test('Late Salary: shifts cycle start date and recalculates total days', () {
      // Payday was supposed to be 25th, but salary arrived on 27th
      final dates = CycleDateCalculator.computeCycleDates(
        year: 2026,
        month: 10,
        paydayDay: 25,
        salaryReceivedDate: DateTime(2026, 10, 27),
      );

      expect(dates.startDate, equals(DateTime(2026, 10, 27)));
      expect(dates.endDate, equals(DateTime(2026, 11, 24)));
      expect(dates.totalDays, equals(29)); // 31 - 2 = 29 days
    });

    test('Cycles of 28, 29, 30 and 31 days: daily budgets sum exactly to the pool', () {
      for (final daysCount in [28, 29, 30, 31]) {
        final cycle = BudgetCycle(
          id: 'cycle_${daysCount}_days',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, daysCount),
          totalDays: daysCount,
          inHandSalary: Money.fromRupees(65432.17),
          fixedExpensesTotal: Money.fromRupees(23456.78),
          savingsTargetAmount: Money.fromRupees(10000.00),
        );

        final dailyBudgets =
            BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);
        expect(dailyBudgets.length, equals(daysCount));

        final sumOfAllocatedPaise = dailyBudgets.fold<int>(
          0,
          (sum, b) => sum + b.allocatedBudget.paise,
        );

        expect(
          sumOfAllocatedPaise,
          equals(cycle.discretionaryPool.paise),
          reason: 'Failed for $daysCount days cycle',
        );
      }
    });

    test('Last day of cycle (N - t = 0): no divide-by-zero exception', () {
      final cycle = BudgetCycle(
        id: 'last_day_test',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 30),
        totalDays: 30,
        inHandSalary: Money.fromRupees(30000),
        fixedExpensesTotal: Money.fromRupees(10000),
        savingsTargetAmount: Money.fromRupees(5000),
      );

      final days = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

      // On Day 30 (the last day), t = 30, N - t = 0
      // User spends money on Day 30
      days[29] = days[29].copyWith(actualSpent: Money.fromRupees(800));

      // Rebalancing on day 30 must complete cleanly without division by zero!
      expect(
        () => BudgetCalculator.rebalanceBudgets(
          cycle: cycle,
          currentBudgets: days,
          currentDayIndex: 30,
        ),
        returnsNormally,
      );

      final rebalanced = BudgetCalculator.rebalanceBudgets(
        cycle: cycle,
        currentBudgets: days,
        currentDayIndex: 30,
      );
      expect(rebalanced.length, equals(30));
    });

    test('One day spending entire month salary: future days are 0, never silently negative', () {
      final cycle = BudgetCycle(
        id: 'exhaust_test',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 30),
        totalDays: 30,
        inHandSalary: Money.fromRupees(30000),
        fixedExpensesTotal: Money.fromRupees(10000),
        savingsTargetAmount: Money.fromRupees(5000), // Discretionary pool = 15,000
      );

      final days = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

      // Day 1 spends ₹20,000 (exceeds entire pool of 15,000 by 5,000)
      days[0] = days[0].copyWith(actualSpent: Money.fromRupees(20000));

      final rebalanced = BudgetCalculator.rebalanceBudgets(
        cycle: cycle,
        currentBudgets: days,
        currentDayIndex: 1,
      );

      // Future days must all be exactly ₹0, never negative
      for (int i = 1; i < 30; i++) {
        expect(rebalanced[i].allocatedBudget.paise, equals(0));
      }
    });

    test('Gamification Engine: XP curve and health impacts', () {
      var hero = const HeroCharacter(
        name: 'Aero',
        level: 1,
        currentXp: 0,
        maxXp: 100,
      );

      hero = GamificationEngine.awardXp(hero, 150);
      expect(hero.level, equals(2));
      expect(hero.currentXp, equals(50));

      const hero2 = HeroCharacter(name: 'Aero', currentHp: 80, maxHp: 100);
      final healed = GamificationEngine.evaluateDailyHealthImpact(
        hero: hero2,
        spentRatio: 0.4,
      );
      expect(healed.currentHp, equals(95));
    });
  });
}
