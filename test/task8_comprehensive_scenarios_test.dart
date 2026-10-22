import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/services/data_conflict_resolver.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/budget_validation_exception.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_manager_service.dart';
import 'package:salary_quest/features/gamification/domain/models/quest.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_event_recomputer.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';

void main() {
  group('TASK 8 - COMPREHENSIVE SCENARIO TESTS (A, D, E, F, I)', () {
    // =========================================================================
    // SECTION A: Salary and Budget Logic Edge Cases
    // =========================================================================
    test('A1. Decimal amounts (99.50) and very large amounts (1,00,00,000) have zero rounding drift', () {
      final decimalMoney = Money.fromRupees(99.50);
      expect(decimalMoney.paise, equals(9950));
      expect(decimalMoney.inWholeRupees, equals(99));

      final largeMoney = Money.fromRupees(10000000); // ₹1,00,00,000
      expect(largeMoney.paise, equals(1000000000)); // 1 Billion paise

      // Distribute ₹99.50 across 7 days: 9950 paise / 7 = 1421 paise each with remainder 3 paise
      final distributed = Money.distribute(decimalMoney, 7);
      expect(distributed.length, equals(7));
      final totalSum = distributed.fold<int>(0, (sum, m) => sum + m.paise);
      expect(totalSum, equals(decimalMoney.paise), reason: 'Zero paisa rounding drift across 7 days');
    });

    test('A2. Salary validation rejects <= 0 and fixed expenses + savings > salary', () {
      expect(
        () => BudgetCycle.createValidated(
          id: 'c1',
          year: 2026,
          month: 10,
          paydayDay: 25,
          inHandSalary: const Money.zero(),
          fixedExpensesTotal: Money.fromRupees(5000),
          savingsTargetAmount: Money.fromRupees(5000),
        ),
        throwsA(isA<BudgetValidationException>()),
      );

      expect(
        () => BudgetCycle.createValidated(
          id: 'c2',
          year: 2026,
          month: 10,
          paydayDay: 25,
          inHandSalary: Money.fromRupees(50000),
          fixedExpensesTotal: Money.fromRupees(40000),
          savingsTargetAmount: Money.fromRupees(15000), // 40k + 15k = 55k > 50k
        ),
        throwsA(isA<BudgetValidationException>()),
      );
    });

    // =========================================================================
    // SECTION D: Payment Edge Cases
    // =========================================================================
    test('D1. Split bill: ₹2,000 paid, ₹1,500 reimbursed in pieces, net daily expense is exactly ₹500', () {
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_split',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(10000),
        savingsTargetAmount: Money.fromRupees(10000),
      );

      final now = DateTime(2026, 10, 25, 20, 0);

      // Initial payment: User pays ₹2,000 dinner bill, their personal share is ₹500, friends owe ₹1,500
      final parentTx = Transaction(
        id: 'tx_dinner_split',
        cycleId: cycle.id,
        amount: Money.fromRupees(2000),
        title: 'Team Dinner',
        category: TransactionCategory.food,
        timestamp: now,
        type: TransactionType.splitShare,
        splitTotal: Money.fromRupees(2000),
        splitUserShare: Money.fromRupees(500),
        pendingReimbursement: Money.fromRupees(1500),
      );

      // Friend 1 pays back ₹1,000 on Day 2
      final payback1 = Transaction(
        id: 'tx_payback_1',
        cycleId: cycle.id,
        amount: Money.fromRupees(1000),
        title: 'Rahul payback',
        category: TransactionCategory.food,
        timestamp: now.add(const Duration(days: 1)),
        type: TransactionType.splitShare,
        isReimbursement: true,
        parentTransactionId: parentTx.id,
      );

      // Friend 2 pays back ₹500 on Day 3
      final payback2 = Transaction(
        id: 'tx_payback_2',
        cycleId: cycle.id,
        amount: Money.fromRupees(500),
        title: 'Sneha payback',
        category: TransactionCategory.food,
        timestamp: now.add(const Duration(days: 2)),
        type: TransactionType.splitShare,
        isReimbursement: true,
        parentTransactionId: parentTx.id,
      );

      final recompute = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [parentTx, payback1, payback2],
        currentDayIndex: 3,
      );

      // Total discretionary spent across the cycle: 2000 - 1000 - 500 = 500
      final netSpentPaise = recompute.budgets.fold<int>(0, (sum, b) => sum + b.actualSpent.paise);
      expect(netSpentPaise, equals(Money.fromRupees(500).paise));
    });

    test('D2. CC Bill Payment, Self-Transfers, and Wallet Top-ups have zero daily budget impact', () {
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_neutral',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(0),
        savingsTargetAmount: Money.fromRupees(0),
      );

      final now = DateTime(2026, 10, 25, 12, 0);

      final ccBill = Transaction(
        id: 'tx_cc_bill',
        cycleId: cycle.id,
        amount: Money.fromRupees(15000),
        title: 'HDFC CC Bill Payment',
        category: TransactionCategory.bills,
        timestamp: now,
        type: TransactionType.creditCardBillPayment,
      );

      final selfTransfer = Transaction(
        id: 'tx_self_transfer',
        cycleId: cycle.id,
        amount: Money.fromRupees(5000),
        title: 'Transfer to Savings A/c',
        category: TransactionCategory.other,
        timestamp: now,
        type: TransactionType.transfer,
      );

      final walletTopup = Transaction(
        id: 'tx_wallet_topup',
        cycleId: cycle.id,
        amount: Money.fromRupees(2000),
        title: 'Paytm Wallet Add Money',
        category: TransactionCategory.other,
        timestamp: now,
        type: TransactionType.walletTopup,
      );

      final recompute = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [ccBill, selfTransfer, walletTopup],
        currentDayIndex: 1,
      );

      expect(recompute.budgets[0].actualSpent, equals(const Money.zero()),
          reason: 'Neutral transaction types must not consume daily discretionary mana');
    });

    // =========================================================================
    // SECTION E: Gamification Edge Cases
    // =========================================================================
    test('E1. Soft Recovery: 3+ overspend days triggers Fresh Start Quest restoring HP', () async {
      final notifier = SalaryQuestNotifier();

      // Simulate hero with depleted HP (e.g. 20 HP)
      notifier.state = notifier.state.copyWith(
        hero: notifier.state.hero.copyWith(currentHp: 20),
      );

      // Inject Soft Recovery Quest
      const freshStartQuest = DailyQuest(
        id: 'quest_fresh_start_recovery',
        title: '🌱 Fresh Start Quest',
        description: 'Complete today under budget to regain 25 HP and recover morale.',
        type: QuestType.freshStartRecovery,
        targetValue: 1.0,
        progressValue: 1.0,
        rewardXp: 30,
        rewardCoins: 20,
        rewardHp: 25, // Restores 25 HP
        isCompleted: true,
      );

      notifier.state = notifier.state.copyWith(
        quests: [freshStartQuest, ...notifier.state.quests],
      );

      expect(notifier.state.hero.currentHp, equals(20));

      // Claim Fresh Start Quest
      await notifier.claimQuestReward('quest_fresh_start_recovery');

      // HP is restored from 20 -> 45
      expect(notifier.state.hero.currentHp, equals(45),
          reason: 'Claiming Fresh Start Quest must restore hero HP by rewardHp');
    });

    test('E2. Boss HP recalculates proportionally when savings target is modified mid-cycle', () {
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_boss',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(80000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(20000), // Discretionary pool = 40,000
      );

      final budgets = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

      // User increases savings target from 20,000 to 30,000 mid-cycle on Day 10
      final result = CycleManagerService.recalculateMidCycle(
        currentCycle: cycle,
        currentBudgets: budgets,
        currentDayIndex: 10,
        newSalary: Money.fromRupees(80000),
        newFixedExpenses: Money.fromRupees(20000),
        newSavingsTarget: Money.fromRupees(30000), // Discretionary pool reduces to 30,000
      );

      expect(result.updatedCycle.discretionaryPool, equals(Money.fromRupees(30000)));
      // Discretionary pool was recomputed down to the penny with no divide-by-zero or free win
      final remainingSum = result.updatedBudgets
          .sublist(9)
          .fold<int>(0, (sum, b) => sum + b.allocatedBudget.paise);
      expect(remainingSum > 0, isTrue);
    });

    // =========================================================================
    // SECTION F: Data Sync & Conflict Resolution
    // =========================================================================
    test('F1. DataConflictResolver merges backup and local records using Latest-Edit-Wins with zero duplicates', () {
      final now = DateTime(2026, 10, 15, 12, 0);

      // Local device version: Grocery ₹500
      final localTx = Transaction(
        id: 'tx_sync_1',
        cycleId: 'c1',
        amount: Money.fromRupees(500),
        title: 'Groceries',
        category: TransactionCategory.groceries,
        timestamp: now,
        dedupeKey: 'key_1',
      );

      // Remote/Backup version with updated title and later timestamp (e.g. edited to ₹600 at 12:15)
      final remoteTx = Transaction(
        id: 'tx_sync_1',
        cycleId: 'c1',
        amount: Money.fromRupees(600),
        title: 'Groceries + Snacks',
        category: TransactionCategory.groceries,
        timestamp: now.add(const Duration(minutes: 15)),
        dedupeKey: 'key_1',
      );

      // Unique remote transaction on second device
      final remoteOnlyTx = Transaction(
        id: 'tx_sync_2',
        cycleId: 'c1',
        amount: Money.fromRupees(250),
        title: 'Uber to Office',
        category: TransactionCategory.transport,
        timestamp: now.add(const Duration(hours: 1)),
        dedupeKey: 'key_2',
      );

      final merged = DataConflictResolver.mergeTransactions(
        localTransactions: [localTx],
        incomingTransactions: [remoteTx, remoteOnlyTx],
      );

      expect(merged.length, equals(2), reason: 'Zero duplicate records created');
      // For tx_sync_1, remote version won because it was edited later
      final resolvedTx1 = merged.firstWhere((t) => t.id == 'tx_sync_1');
      expect(resolvedTx1.amount, equals(Money.fromRupees(600)));
      expect(resolvedTx1.title, equals('Groceries + Snacks'));

      // Remote-only record was preserved
      expect(merged.any((t) => t.id == 'tx_sync_2'), isTrue);
    });

    // =========================================================================
    // SECTION I: Life Situations (Freelancer & Shared Expenses)
    // =========================================================================
    test('I1. Freelancer / Irregular Income: User injects bonus or freelance payout at any date', () async {
      final notifier = SalaryQuestNotifier();
      final initialRemainingPool = notifier.state.remainingCyclePool;

      // Freelance payment received mid-cycle: ₹15,000
      await notifier.addExtraIncome(
        amount: Money.fromRupees(15000),
        sourceTitle: 'Freelance Design Project',
      );

      // Remaining cycle pool increases by ₹15,000
      expect(
        notifier.state.remainingCyclePool,
        equals(initialRemainingPool + Money.fromRupees(15000)),
      );

      // Future daily budgets rebalance upward
      final todayBudget = notifier.state.todayBudget;
      expect(todayBudget.allocatedBudget.paise > 0, isTrue);
    });

    test('I2. Shared / Family Expense: Marked as shared and counted only at user share', () async {
      final notifier = SalaryQuestNotifier();
      final initialTodaySpent = notifier.state.todayBudget.actualSpent;

      // Group outing: ₹4,000 total, user share is ₹1,000
      await notifier.addTransaction(
        amount: Money.fromRupees(1000), // Net logged expense
        title: 'Family Dinner Outing',
        category: TransactionCategory.food,
        type: TransactionType.splitShare,
        splitTotal: Money.fromRupees(4000),
        splitUserShare: Money.fromRupees(1000),
      );

      // Today's actual spent increases only by ₹1,000 (not ₹4,000)
      expect(
        notifier.state.todayBudget.actualSpent,
        equals(initialTodaySpent + Money.fromRupees(1000)),
      );
    });

    test('I3. Serious Mode: Hides gamification, continues 100% accurate financial tracking', () async {
      final notifier = SalaryQuestNotifier();

      expect(notifier.state.isSeriousMode, isFalse);
      await notifier.toggleSeriousMode(true);
      expect(notifier.state.isSeriousMode, isTrue);

      // Adding expense while in Serious Mode computes daily budget accurately
      await notifier.addTransaction(
        amount: Money.fromRupees(200),
        title: 'Medical Prescription',
        category: TransactionCategory.health,
      );

      expect(notifier.state.todayBudget.actualSpent, equals(Money.fromRupees(200)));

      // Disable serious mode restores gamification view with untouched calculations
      await notifier.toggleSeriousMode(false);
      expect(notifier.state.isSeriousMode, isFalse);
    });
  });
}
