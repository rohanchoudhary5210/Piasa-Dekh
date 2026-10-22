import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/transactions/domain/models/duplicate_transaction_exception.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/fixed_expense_matcher.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_deduplication_service.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_event_recomputer.dart';

void main() {
  group('TASK 5: Transaction Correctness Tests', () {
    late BudgetCycle cycle;

    setUp(() {
      cycle = BudgetCycle.createValidated(
        id: 'cycle_test_task5',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(10000),
      );
    });

    test('1. Transaction Type Neutrality: Transfers, Top-ups, CC Bill Payments have zero daily budget impact', () {
      final transfer = Transaction(
        id: 'tx_transfer',
        cycleId: cycle.id,
        amount: Money.fromRupees(5000),
        title: 'Transfer to Savings Acct',
        category: TransactionCategory.other,
        timestamp: DateTime(2026, 10, 25, 10, 0),
        type: TransactionType.transfer,
      );

      final topup = Transaction(
        id: 'tx_topup',
        cycleId: cycle.id,
        amount: Money.fromRupees(2000),
        title: 'Paytm Wallet Topup',
        category: TransactionCategory.bills,
        timestamp: DateTime(2026, 10, 25, 11, 0),
        type: TransactionType.walletTopup,
      );

      final ccBill = Transaction(
        id: 'tx_cc_bill',
        cycleId: cycle.id,
        amount: Money.fromRupees(18000),
        title: 'HDFC Credit Card Bill Payment',
        category: TransactionCategory.bills,
        timestamp: DateTime(2026, 10, 25, 12, 0),
        type: TransactionType.creditCardBillPayment,
      );

      expect(transfer.netDailyBudgetImpact, equals(const Money.zero()));
      expect(topup.netDailyBudgetImpact, equals(const Money.zero()));
      expect(ccBill.netDailyBudgetImpact, equals(const Money.zero()));
      expect(transfer.type.affectsDailyBudget, isFalse);
      expect(topup.type.affectsDailyBudget, isFalse);
      expect(ccBill.type.affectsDailyBudget, isFalse);
    });

    test('2. Recurring Fixed Expenses Auto-Matching & Zero Daily Impact', () {
      expect(FixedExpenseMatcher.isLikelyFixedExpense('House Rent via Cred'), isTrue);
      expect(FixedExpenseMatcher.isLikelyFixedExpense('HDFC Car Loan EMI Auto-debit'), isTrue);
      expect(FixedExpenseMatcher.isLikelyFixedExpense('Nippon Mutual Fund SIP'), isTrue);
      expect(FixedExpenseMatcher.isLikelyFixedExpense('Jio Fiber Broadband Bill'), isTrue);
      expect(FixedExpenseMatcher.isLikelyFixedExpense('Swiggy Dinner Order'), isFalse);
      expect(FixedExpenseMatcher.isLikelyFixedExpense('Uber Premier Ride'), isFalse);

      final emiTx = Transaction(
        id: 'tx_emi',
        cycleId: cycle.id,
        amount: Money.fromRupees(15000),
        title: 'Home Loan EMI',
        category: TransactionCategory.bills,
        timestamp: DateTime(2026, 10, 26, 9, 0),
        isFixedExpense: true,
      );

      // Pre-budgeted fixed expense must NOT count against daily spendable pool
      expect(emiTx.netDailyBudgetImpact, equals(const Money.zero()));
    });

    test('3. Deduplication: Rejects Bank SMS + UPI Notification within 10-minute window for same spend', () {
      final baseTime = DateTime(2026, 10, 25, 14, 0);

      final existingTx = Transaction(
        id: 'tx_sms_1',
        cycleId: cycle.id,
        amount: Money.fromRupees(420),
        title: 'HDFC Bank: Rs 420.00 debited at SWIGGY',
        category: TransactionCategory.food,
        timestamp: baseTime,
        source: TransactionSource.smsAuto,
      );

      final existingList = [existingTx];

      // Duplicate case: UPI notification for same Swiggy spend 3 minutes later
      final duplicateCandidateTime = baseTime.add(const Duration(minutes: 3));
      final isDupe = TransactionDeduplicationService.isDuplicate(
        amount: Money.fromRupees(420),
        timestamp: duplicateCandidateTime,
        merchant: 'Google Pay: Paid Rs 420 to Swiggy Bangalore',
        existingTransactions: existingList,
      );
      expect(isDupe, isTrue);

      // Non-duplicate case 1: Different amount at same time
      final differentAmountTime = baseTime.add(const Duration(minutes: 2));
      final isDifferentAmount = TransactionDeduplicationService.isDuplicate(
        amount: Money.fromRupees(650),
        timestamp: differentAmountTime,
        merchant: 'Swiggy',
        existingTransactions: existingList,
      );
      expect(isDifferentAmount, isFalse);

      // Non-duplicate case 2: Same amount & merchant but 45 minutes later
      final differentTime = baseTime.add(const Duration(minutes: 45));
      final isLaterSpend = TransactionDeduplicationService.isDuplicate(
        amount: Money.fromRupees(420),
        timestamp: differentTime,
        merchant: 'Swiggy',
        existingTransactions: existingList,
      );
      expect(isLaterSpend, isFalse);
    });

    test('4. Split Bill with Delayed Payback: Tracks pending reimbursements and accurately credits back spending', () {
      // Day 1: User pays ₹2000 for dinner with friends.
      // User's own share is ₹500. Friends owe ₹1500 total.
      final dinnerTx = Transaction(
        id: 'split_dinner_1',
        cycleId: cycle.id,
        amount: Money.fromRupees(2000),
        title: 'Dinner at Mainland China',
        category: TransactionCategory.food,
        timestamp: DateTime(2026, 10, 25, 20, 0), // Day 1
        type: TransactionType.splitShare,
        splitTotal: Money.fromRupees(2000),
        splitUserShare: Money.fromRupees(500),
        pendingReimbursement: Money.fromRupees(1500),
      );

      // Initial state: ₹2000 spent upfront on Day 1
      var result = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [dinnerTx],
        currentDayIndex: 1,
      );

      expect(result.budgets[0].actualSpent, equals(Money.fromRupees(2000)));
      expect(result.updatedTransactions.first.pendingReimbursement, equals(Money.fromRupees(1500)));

      // Day 2: Friend 1 reimburses ₹500 via UPI
      final reimbursement1 = Transaction(
        id: 'reimburse_1',
        cycleId: cycle.id,
        amount: Money.fromRupees(500),
        title: 'Reimbursement from Rahul',
        category: TransactionCategory.other,
        timestamp: DateTime(2026, 10, 26, 11, 0), // Day 2
        type: TransactionType.splitShare,
        isReimbursement: true,
        parentTransactionId: 'split_dinner_1',
      );

      result = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [dinnerTx, reimbursement1],
        currentDayIndex: 2,
      );

      // Pending reimbursement drops from ₹1500 to ₹1000
      final parentSplit = result.updatedTransactions.firstWhere((t) => t.id == 'split_dinner_1');
      expect(parentSplit.pendingReimbursement, equals(Money.fromRupees(1000)));

      // Day 3: Friend 2 & 3 reimburse ₹1000 total (settling the split completely)
      final reimbursement2 = Transaction(
        id: 'reimburse_2',
        cycleId: cycle.id,
        amount: Money.fromRupees(1000),
        title: 'Reimbursement from Priya & Amit',
        category: TransactionCategory.other,
        timestamp: DateTime(2026, 10, 27, 15, 0), // Day 3
        type: TransactionType.splitShare,
        isReimbursement: true,
        parentTransactionId: 'split_dinner_1',
      );

      result = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [dinnerTx, reimbursement1, reimbursement2],
        currentDayIndex: 3,
      );

      final settledParent = result.updatedTransactions.firstWhere((t) => t.id == 'split_dinner_1');
      expect(settledParent.pendingReimbursement, equals(const Money.zero()));

      // Across the 3 days: Initial ₹2000 debit minus ₹1500 reimbursements = net ₹500 user expense!
      var totalNetDiscretionarySpent = const Money.zero();
      for (final tx in result.updatedTransactions) {
        totalNetDiscretionarySpent = totalNetDiscretionarySpent + tx.netDailyBudgetImpact;
      }
      expect(totalNetDiscretionarySpent, equals(Money.fromRupees(500)));
    });

    test('5. Refund Across Day Boundary: Day 1 expense refunded on Day 2 rolls surplus into remaining days', () {
      // Day 1: Purchase shoes for ₹3000
      final buyShoes = Transaction(
        id: 'buy_shoes',
        cycleId: cycle.id,
        amount: Money.fromRupees(3000),
        title: 'Puma Running Shoes',
        category: TransactionCategory.shopping,
        timestamp: DateTime(2026, 10, 25, 16, 0), // Day 1
        type: TransactionType.expense,
      );

      // Day 2: Return shoes and get ₹3000 refund
      final refundShoes = Transaction(
        id: 'refund_shoes',
        cycleId: cycle.id,
        amount: Money.fromRupees(3000),
        title: 'Puma Refund',
        category: TransactionCategory.shopping,
        timestamp: DateTime(2026, 10, 26, 10, 0), // Day 2
        type: TransactionType.refund,
      );

      final result = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [buyShoes, refundShoes],
        currentDayIndex: 2,
      );

      // Day 1 had ₹3000 spent
      expect(result.budgets[0].actualSpent, equals(Money.fromRupees(3000)));

      // Day 2 had -₹3000 net spent (refund)
      expect(result.budgets[1].actualSpent, equals(Money.fromRupees(-3000)));

      // Since net spend across day 1 and 2 is 0, future days (Day 3..31)
      // receive higher daily allocations (~₹1034 vs baseline ~₹967)
      final initialBaseBudgets = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);
      expect(result.budgets[2].allocatedBudget.paise,
          greaterThan(initialBaseBudgets[2].allocatedBudget.paise));
    });

    test('6. Edit Past Transaction: Downstream days recalculate smoothly', () {
      // Day 1 expense originally logged as ₹5000 (huge overspend)
      final originalTx = Transaction(
        id: 'tx_overspend',
        cycleId: cycle.id,
        amount: Money.fromRupees(5000),
        title: 'Dinner Party',
        category: TransactionCategory.food,
        timestamp: DateTime(2026, 10, 25, 21, 0),
        type: TransactionType.expense,
      );

      final resultBeforeEdit = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [originalTx],
        currentDayIndex: 1,
      );

      final day2BudgetBefore = resultBeforeEdit.budgets[1].allocatedBudget;

      // User realizes typo and corrects it to ₹500 (₹4500 less)
      final editedTx = originalTx.copyWith(amount: Money.fromRupees(500));

      final resultAfterEdit = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [editedTx],
        currentDayIndex: 1,
      );

      final day2BudgetAfter = resultAfterEdit.budgets[1].allocatedBudget;

      // Day 2 budget must be significantly higher after correcting the overspend
      expect(day2BudgetAfter.paise, greaterThan(day2BudgetBefore.paise));
      expect(resultAfterEdit.budgets[0].actualSpent, equals(Money.fromRupees(500)));
    });

    test('7. Delete Transaction & Gamification Revert: Rolls back XP, Coins and recomputes downstream days', () async {
      final notifier = SalaryQuestNotifier();

      final initialXp = notifier.state.hero.currentXp;

      // 1. Add an expense of ₹1000 on Day 1
      await notifier.addTransaction(
        amount: Money.fromRupees(1000),
        title: 'Fancy Brunch',
        category: TransactionCategory.food,
        customTimestamp: notifier.state.cycle.startDate,
      );

      expect(notifier.state.transactions.length, equals(1));
      final loggedTx = notifier.state.transactions.first;
      expect(loggedTx.earnedXp, equals(15));
      expect(notifier.state.hero.currentXp, equals(initialXp + 15));

      final day2BudgetWithSpend = notifier.state.dailyBudgets[1].allocatedBudget;

      // 2. Delete the transaction
      await notifier.deleteTransaction(loggedTx.id);

      // Verify transaction was deleted
      expect(notifier.state.transactions.isEmpty, isTrue);

      // Verify XP was rolled back cleanly
      expect(notifier.state.hero.currentXp, equals(initialXp));

      // Verify downstream Day 2 budget increased back after deleting the ₹1000 spend
      final day2BudgetAfterDelete = notifier.state.dailyBudgets[1].allocatedBudget;
      expect(day2BudgetAfterDelete.paise, greaterThan(day2BudgetWithSpend.paise));
    });

    test('8. DuplicateTransactionException is thrown when logging duplicate transaction within 10 minutes', () async {
      final notifier = SalaryQuestNotifier();

      await notifier.addTransaction(
        amount: Money.fromRupees(250),
        title: 'Starbucks Coffee',
        category: TransactionCategory.food,
        customTimestamp: DateTime(2026, 10, 25, 15, 0),
      );

      // Adding the same transaction 2 minutes later must throw DuplicateTransactionException
      expect(
        () async {
          await notifier.addTransaction(
            amount: Money.fromRupees(250),
            title: 'Starbucks Coffee',
            category: TransactionCategory.food,
            customTimestamp: DateTime(2026, 10, 25, 15, 2),
          );
        },
        throwsA(isA<DuplicateTransactionException>()),
      );
    });
  });
}
