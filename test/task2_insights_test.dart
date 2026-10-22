import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/insights/domain/services/insights_calculator.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

void main() {
  group('TASK 2: Insights & Prediction Math Tests', () {
    late BudgetCycle testCycle;

    setUp(() {
      testCycle = BudgetCycle.createValidated(
        id: 'cycle_test_insights',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(60000), // ₹60,000
        fixedExpensesTotal: Money.fromRupees(25000), // ₹25,000
        savingsTargetAmount: Money.fromRupees(15000), // ₹15,000
      );
      // Discretionary pool = 60,000 - 25,000 - 15,000 = ₹20,000
      // Total days = 31 (Oct 25 to Nov 24)
    });

    test('1. Day 1 with Zero Transactions: handles empty day without crashing or division by zero', () {
      final prediction = InsightsCalculator.calculateMonthEndPrediction(
        cycle: testCycle,
        transactions: const [],
        currentDayIndex: 1,
      );

      // On day 1 with zero spend, projected savings equals planned savings target
      expect(prediction.projectedSavings.paise, equals(1500000)); // ₹15,000
      expect(prediction.averageDailySpend.paise, equals(0));
      expect(prediction.totalDiscretionarySpentSoFar.paise, equals(0));
      expect(prediction.daysRemaining, equals(testCycle.totalDays - 1));
      expect(prediction.isOnTrack, isTrue);
      expect(prediction.paceMessage, contains('₹15,000'));
      expect(prediction.paceMessage, isNot(contains('NaN')));
      expect(prediction.paceMessage, isNot(contains('Infinity')));
    });

    test('2. Mid-Cycle Prediction: calculates exact pace and projected savings', () {
      // 30 days total, currently at Day 10.
      // Suppose total days = 30 for clear math
      final cycle30 = testCycle.copyWith(totalDays: 30);

      // Day 10: user spent total ₹5,000 so far
      // Avg spend = ₹5,000 / 10 = ₹500/day
      // Remaining 20 days * ₹500 = ₹10,000 projected spend
      // Total projected spend = ₹15,000
      // Max spendable = 60,000 - 25,000 = ₹35,000
      // Projected savings = 35,000 - 15,000 = ₹20,000
      final txs = [
        Transaction(
          id: 'tx_1',
          cycleId: cycle30.id,
          amount: Money.fromRupees(3000),
          title: 'Groceries',
          category: TransactionCategory.groceries,
          timestamp: DateTime(2026, 10, 26),
        ),
        Transaction(
          id: 'tx_2',
          cycleId: cycle30.id,
          amount: Money.fromRupees(2000),
          title: 'Dining Out',
          category: TransactionCategory.food,
          timestamp: DateTime(2026, 10, 28),
        ),
      ];

      final prediction = InsightsCalculator.calculateMonthEndPrediction(
        cycle: cycle30,
        transactions: txs,
        currentDayIndex: 10,
      );

      expect(prediction.totalDiscretionarySpentSoFar.paise, equals(500000)); // ₹5,000
      expect(prediction.averageDailySpend.paise, equals(50000)); // ₹500/day
      expect(prediction.daysRemaining, equals(20));
      expect(prediction.projectedSavings.paise, equals(2000000)); // ₹20,000
      expect(prediction.isOnTrack, isTrue); // target is 15,000
      expect(prediction.paceMessage, contains('Target met!'));
    });

    test('3. Overspending Scenario: detects deficit pace and generates warning message', () {
      final cycle30 = testCycle.copyWith(totalDays: 30);

      // Day 10: user already spent ₹30,000 (avg ₹3,000/day!)
      // Remaining 20 days * 3000 = ₹60,000
      // Total projected spend = ₹90,000 (Exceeds capacity of ₹35,000 by ₹55,000)
      final txs = [
        Transaction(
          id: 'tx_heavy',
          cycleId: cycle30.id,
          amount: Money.fromRupees(30000),
          title: 'Shopping Spree',
          category: TransactionCategory.shopping,
          timestamp: DateTime(2026, 10, 28),
        ),
      ];

      final prediction = InsightsCalculator.calculateMonthEndPrediction(
        cycle: cycle30,
        transactions: txs,
        currentDayIndex: 10,
      );

      expect(prediction.projectedSavings.paise, equals(0));
      expect(prediction.isOnTrack, isFalse);
      expect(prediction.paceMessage, contains('exceed your treasury'));
      expect(prediction.paceMessage, contains('🔴'));
    });

    test('4. Last Day of Cycle (daysRemaining == 0): exact actual savings without crash', () {
      final cycle30 = testCycle.copyWith(totalDays: 30);

      // Day 30 of 30: spent total ₹18,000 throughout cycle
      final txs = [
        Transaction(
          id: 'tx_end',
          cycleId: cycle30.id,
          amount: Money.fromRupees(18000),
          title: 'Month Total Expenses',
          category: TransactionCategory.other,
          timestamp: DateTime(2026, 11, 20),
        ),
      ];

      final prediction = InsightsCalculator.calculateMonthEndPrediction(
        cycle: cycle30,
        transactions: txs,
        currentDayIndex: 30,
      );

      expect(prediction.daysRemaining, equals(0));
      // In-hand (60k) - Fixed (25k) - Spent (18k) = ₹17,000
      expect(prediction.projectedSavings.paise, equals(1700000));
      expect(prediction.isOnTrack, isTrue);
    });

    test('5. Category Breakdown: sums spending per category and computes correct percentages', () {
      final txs = [
        Transaction(
          id: '1',
          cycleId: 'c1',
          amount: Money.fromRupees(5000), // Food: ₹5,000
          title: 'Restaurant',
          category: TransactionCategory.food,
          timestamp: DateTime.now(),
        ),
        Transaction(
          id: '2',
          cycleId: 'c1',
          amount: Money.fromRupees(3000), // Shopping: ₹3,000
          title: 'Clothes',
          category: TransactionCategory.shopping,
          timestamp: DateTime.now(),
        ),
        Transaction(
          id: '3',
          cycleId: 'c1',
          amount: Money.fromRupees(2000), // Commute: ₹2,000
          title: 'Metro',
          category: TransactionCategory.transport,
          timestamp: DateTime.now(),
        ),
        // Refund on Food: -₹1,000 -> Food net becomes ₹4,000
        Transaction(
          id: '4',
          cycleId: 'c1',
          amount: Money.fromRupees(1000),
          title: 'Food Refund',
          category: TransactionCategory.food,
          type: TransactionType.refund,
          timestamp: DateTime.now(),
        ),
        // Neutral transfer: ₹10,000 (must be ignored)
        Transaction(
          id: '5',
          cycleId: 'c1',
          amount: Money.fromRupees(10000),
          title: 'Savings Transfer',
          category: TransactionCategory.other,
          type: TransactionType.transfer,
          timestamp: DateTime.now(),
        ),
      ];

      // Net spends: Food: ₹4,000, Shopping: ₹3,000, Commute: ₹2,000 -> Total: ₹9,000
      final breakdown = InsightsCalculator.calculateCategoryBreakdown(transactions: txs);

      expect(breakdown.length, equals(3));

      // Sorted descending:
      // 1. Food: ₹4,000 (44.4%)
      expect(breakdown[0].category, equals(TransactionCategory.food));
      expect(breakdown[0].totalSpent.paise, equals(400000));
      expect(breakdown[0].percentage, equals(44.4));

      // 2. Shopping: ₹3,000 (33.3%)
      expect(breakdown[1].category, equals(TransactionCategory.shopping));
      expect(breakdown[1].totalSpent.paise, equals(300000));
      expect(breakdown[1].percentage, equals(33.3));

      // 3. Transport: ₹2,000 (22.2%)
      expect(breakdown[2].category, equals(TransactionCategory.transport));
      expect(breakdown[2].totalSpent.paise, equals(200000));
      expect(breakdown[2].percentage, equals(22.2));
    });

    test('6. Empty States: zero transactions returns empty list cleanly without throwing', () {
      final breakdown = InsightsCalculator.calculateCategoryBreakdown(transactions: const []);
      expect(breakdown.isEmpty, isTrue);

      final weekly = InsightsCalculator.calculateWeeklySpending(
        cycle: testCycle,
        dailyBudgets: const [],
        currentDayIndex: 1,
      );
      expect(weekly.isEmpty, isTrue);

      final growth = InsightsCalculator.calculateSavingsGrowth(
        cycle: testCycle,
        dailyBudgets: const [],
        currentDayIndex: 1,
      );
      expect(growth.isEmpty, isTrue);
    });

    test('7. Weekly Spending & Savings Growth Datasets format properly', () {
      final budgets = [
        DailyBudget(
          id: 'b1',
          cycleId: 'c1',
          date: DateTime(2026, 10, 25),
          dayIndex: 1,
          allocatedBudget: Money.fromRupees(1000),
          actualSpent: Money.fromRupees(400), // Saved: ₹600
        ),
        DailyBudget(
          id: 'b2',
          cycleId: 'c1',
          date: DateTime(2026, 10, 26),
          dayIndex: 2,
          allocatedBudget: Money.fromRupees(1000),
          actualSpent: Money.fromRupees(700), // Saved: ₹300 (Cumulative: ₹900)
        ),
      ];

      final weekly = InsightsCalculator.calculateWeeklySpending(
        cycle: testCycle,
        dailyBudgets: budgets,
        currentDayIndex: 2,
      );
      expect(weekly.length, equals(2));
      expect(weekly[0].spent.paise, equals(40000));
      expect(weekly[1].spent.paise, equals(70000));

      final growth = InsightsCalculator.calculateSavingsGrowth(
        cycle: testCycle,
        dailyBudgets: budgets,
        currentDayIndex: 2,
      );
      expect(growth.length, equals(2));
      expect(growth[0].cumulativeSaved.paise, equals(60000)); // ₹600
      expect(growth[1].cumulativeSaved.paise, equals(90000)); // ₹900
    });
  });
}
