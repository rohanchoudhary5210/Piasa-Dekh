import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/savings_goals/domain/models/savings_goal.dart';

void main() {
  group('TASK 1: Savings Goals Unit & Domain Tests', () {
    test('1. Create Goal: target amount stored strictly as int paise and starts at 0', () {
      final deadline = DateTime(2026, 12, 31);
      final goal = SavingsGoal(
        id: 'goal_1',
        title: 'Emergency Fund',
        targetAmount: Money.fromRupees(50000), // 5,000,000 paise
        icon: '🛡️',
        deadline: deadline,
        isPrimary: true,
      );

      expect(goal.id, equals('goal_1'));
      expect(goal.title, equals('Emergency Fund'));
      expect(goal.targetAmount.paise, equals(5000000));
      expect(goal.savedAmount.paise, equals(0));
      expect(goal.progressRatio, equals(0.0));
      expect(goal.progressPercent, equals(0));
      expect(goal.remainingAmount.paise, equals(5000000));
      expect(goal.isCompleted, isFalse);
      expect(goal.isTargetReached, isFalse);
      expect(goal.deadline, equals(deadline));
      expect(goal.isPrimary, isTrue);
    });

    test('2. Fill / Deposit: deposits money in paise without float drift', () {
      final goal = SavingsGoal(
        id: 'goal_2',
        title: 'New M4 MacBook Pro',
        targetAmount: Money.fromRupees(150000), // 15,000,000 paise
      );

      // Deposit 1: ₹50,000 (5,000,000 paise)
      final step1 = goal.deposit(Money.fromRupees(50000));
      expect(step1.savedAmount.paise, equals(5000000));
      expect(step1.remainingAmount.paise, equals(10000000));
      expect(step1.progressRatio, closeTo(0.3333, 0.001));
      expect(step1.isCompleted, isFalse);

      // Deposit 2: ₹25,500.50 (2,550,050 paise)
      final step2 = step1.deposit(Money.fromRupees(25500.50));
      expect(step2.savedAmount.paise, equals(7550050));
      expect(step2.remainingAmount.paise, equals(7449950));
      expect(step2.isCompleted, isFalse);
    });

    test('3. Complete Goal: reaching target triggers completion flag and progress clamp', () {
      final goal = SavingsGoal(
        id: 'goal_3',
        title: 'Goa Trip',
        targetAmount: Money.fromRupees(20000), // 2,000,000 paise
      );

      final filled = goal.deposit(Money.fromRupees(20000));
      expect(filled.savedAmount.paise, equals(2000000));
      expect(filled.remainingAmount.paise, equals(0));
      expect(filled.isTargetReached, isTrue);
      expect(filled.isCompleted, isTrue);
      expect(filled.progressRatio, equals(1.0));
      expect(filled.progressPercent, equals(100));

      // Overfill deposit (e.g. ₹22,000)
      final overfilled = goal.deposit(Money.fromRupees(22000));
      expect(overfilled.savedAmount.paise, equals(2200000));
      expect(overfilled.progressRatio, equals(1.0)); // clamped to 1.0
      expect(overfilled.isCompleted, isTrue);
    });

    test('4. Withdraw Money: reduces saved amount and never drops below zero', () {
      final goal = SavingsGoal(
        id: 'goal_4',
        title: 'Bike Downpayment',
        targetAmount: Money.fromRupees(40000),
        savedAmount: Money.fromRupees(25000), // 2,500,000 paise
      );

      // Normal withdrawal
      final w1 = goal.withdraw(Money.fromRupees(10000));
      expect(w1.savedAmount.paise, equals(1500000));
      expect(w1.remainingAmount.paise, equals(2500000));

      // Excessive withdrawal clamps at 0 paise
      final w2 = w1.withdraw(Money.fromRupees(50000));
      expect(w2.savedAmount.paise, equals(0));
      expect(w2.remainingAmount.paise, equals(4000000));
      expect(w2.progressRatio, equals(0.0));
    });

    test('5. StateNotifier Flow: Create, deposit and complete awards XP, Coins and Badge', () async {
      final notifier = SalaryQuestNotifier();
      final initialXp = notifier.state.hero.currentXp;
      final initialCoins = notifier.state.hero.coins;

      // Create Goal
      final created = await notifier.createSavingsGoal(
        title: 'Emergency Stash',
        targetAmount: Money.fromRupees(5000),
        icon: '🛡️',
        isPrimary: true,
      );

      expect(notifier.state.savingsGoals.length, equals(1));
      expect(notifier.state.savingsGoals.first.id, equals(created.id));
      expect(notifier.state.autoFlowGoalId, equals(created.id));

      // Deposit partially
      await notifier.depositToGoal(
        goalId: created.id,
        amount: Money.fromRupees(2000),
      );
      expect(notifier.state.savingsGoals.first.savedAmount.paise, equals(200000));
      expect(notifier.state.savingsGoals.first.isCompleted, isFalse);
      expect(notifier.state.hero.currentXp, equals(initialXp));

      // Complete Goal (+₹3,000)
      await notifier.depositToGoal(
        goalId: created.id,
        amount: Money.fromRupees(3000),
      );

      final completedGoal = notifier.state.savingsGoals.first;
      expect(completedGoal.isCompleted, isTrue);
      // Awards +150 XP and +50 Coins
      expect(notifier.state.hero.currentXp, equals(initialXp + 150));
      expect(notifier.state.hero.coins, equals(initialCoins + 50));

      // Unlocks Badge/Achievement
      final badge = notifier.state.achievements
          .firstWhere((a) => a.id == 'badge_goal_${created.id}');
      expect(badge.title, contains('Goal Crusher'));
      expect(badge.icon, equals('🏆'));
      expect(badge.isUnlocked, isTrue);
    });

    test('6. Delete Goal: returns saved amount back to general savings pool', () async {
      final notifier = SalaryQuestNotifier();

      final created = await notifier.createSavingsGoal(
        title: 'Gadget Fund',
        targetAmount: Money.fromRupees(10000),
      );

      // Deposit ₹4,000
      await notifier.depositToGoal(
        goalId: created.id,
        amount: Money.fromRupees(4000),
      );
      expect(notifier.state.savingsGoals.first.savedAmount.paise, equals(400000));

      final prevSavingsTarget = notifier.state.cycle.savingsTargetAmount.paise;

      // Delete goal
      await notifier.deleteSavingsGoal(created.id);
      expect(notifier.state.savingsGoals.isEmpty, isTrue);

      // Accumulated ₹4,000 returned to general savings pool (savingsTarget reduced by ₹4,000)
      expect(
        notifier.state.cycle.savingsTargetAmount.paise,
        equals(prevSavingsTarget - 400000),
      );
    });

    test('7. Auto-Flow: transfers unspent daily budget into chosen primary goal', () async {
      final notifier = SalaryQuestNotifier();

      // Create a goal and enable auto-flow
      final goal = await notifier.createSavingsGoal(
        title: 'Auto Reserve',
        targetAmount: Money.fromRupees(20000),
        isPrimary: true,
      );

      await notifier.toggleAutoFlowSavings(true, goalId: goal.id);
      expect(notifier.state.isAutoFlowSavingsEnabled, isTrue);

      // Simulate day 1: allocated ₹2,000, spent ₹600 -> surplus ₹1,400
      final dailyBudgets = List<DailyBudget>.from(notifier.state.dailyBudgets);
      dailyBudgets[0] = DailyBudget(
        id: dailyBudgets[0].id,
        cycleId: dailyBudgets[0].cycleId,
        date: dailyBudgets[0].date,
        dayIndex: 1,
        allocatedBudget: Money.fromRupees(2000),
        actualSpent: Money.fromRupees(600),
      );
      notifier.state = notifier.state.copyWith(dailyBudgets: dailyBudgets);

      final transferred = await notifier.processAutoFlowForUnderspentDay(1);
      expect(transferred.paise, equals(140000)); // ₹1,400

      // Goal receives ₹1,400
      final updatedGoal = notifier.state.savingsGoals.first;
      expect(updatedGoal.savedAmount.paise, equals(140000));
    });

    test('8. Auto-Flow Disabled / Overspent: zero transferred', () async {
      final notifier = SalaryQuestNotifier();

      final goal = await notifier.createSavingsGoal(
        title: 'Auto Reserve',
        targetAmount: Money.fromRupees(20000),
        isPrimary: true,
      );

      // Case A: Auto-flow is OFF
      await notifier.toggleAutoFlowSavings(false, goalId: goal.id);

      final transferredWhenOff =
          await notifier.processAutoFlowForUnderspentDay(1);
      expect(transferredWhenOff.paise, equals(0));
      expect(notifier.state.savingsGoals.first.savedAmount.paise, equals(0));

      // Case B: Auto-flow is ON, but day was OVERSPENT (allocated ₹1000, spent ₹1500)
      await notifier.toggleAutoFlowSavings(true, goalId: goal.id);
      final dailyBudgets = List<DailyBudget>.from(notifier.state.dailyBudgets);
      dailyBudgets[0] = DailyBudget(
        id: dailyBudgets[0].id,
        cycleId: dailyBudgets[0].cycleId,
        date: dailyBudgets[0].date,
        dayIndex: 1,
        allocatedBudget: Money.fromRupees(1000),
        actualSpent: Money.fromRupees(1500),
      );
      notifier.state = notifier.state.copyWith(dailyBudgets: dailyBudgets);

      final transferredWhenOver =
          await notifier.processAutoFlowForUnderspentDay(1);
      expect(transferredWhenOver.paise, equals(0));
      expect(notifier.state.savingsGoals.first.savedAmount.paise, equals(0));
    });
  });
}
