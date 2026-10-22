import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_date_calculator.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/sms_parser_service.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_deduplication_service.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_event_recomputer.dart';
import 'package:salary_quest/core/database/app_database.dart';
import 'package:salary_quest/core/database/salary_quest_repository.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  group('TASK 8: TOP 5 HIGHEST RISK TESTS', () {
    // -------------------------------------------------------------------------
    // RISK 1: Duplicate transactions (SMS + notification)
    // -------------------------------------------------------------------------
    test(
        'RISK 1: Duplicate transactions from Bank SMS and UPI Push Notification within 10-minute window stored only once',
        () {
      final baseTime = DateTime(2026, 10, 15, 14, 30);
      final smsTime = baseTime;
      final notifTime = baseTime.add(const Duration(minutes: 3)); // 3 mins later

      // 1. Ingest via Bank SMS: "Rs. 450 debited for Swiggy"
      final parser = SmsParserService();
      final parsedSms = parser.parse(
        sender: 'VK-HDFCBK',
        body: 'Alert: Rs 450.00 debited from A/c XX1234 towards Swiggy on 15-Oct-26.',
        timestamp: smsTime,
        source: TransactionSource.smsAuto,
      );

      expect(parsedSms.isFinancial, isTrue);
      expect(parsedSms.amount, equals(Money.fromRupees(450)));
      expect(parsedSms.cleanedMerchant, equals('Swiggy'));

      final tx1 = parsedSms.toTransaction(cycleId: 'cycle_test')!;

      // 2. Ingest via PhonePe Push Notification: "Paid ₹450 to Swiggy"
      final parsedNotif = parser.parse(
        sender: 'PhonePe',
        body: 'Paid ₹450 to Swiggy successfully.',
        timestamp: notifTime,
        source: TransactionSource.upiNotification,
      );

      expect(parsedNotif.isFinancial, isTrue);
      expect(parsedNotif.amount, equals(Money.fromRupees(450)));
      expect(parsedNotif.cleanedMerchant, equals('Swiggy'));

      final tx2 = parsedNotif.toTransaction(cycleId: 'cycle_test')!;

      // Deduplication check
      final isDupe = TransactionDeduplicationService.isDuplicate(
        existingTransactions: [tx1],
        amount: tx2.amount,
        timestamp: tx2.timestamp,
        merchant: tx2.title,
        explicitDedupeKey: tx2.dedupeKey,
      );

      expect(isDupe, isTrue,
          reason: 'Same spend from SMS + Notification within 10 mins must be detected as duplicate');
    });

    // -------------------------------------------------------------------------
    // RISK 2: Credit treated as debit
    // -------------------------------------------------------------------------
    test(
        'RISK 2: Credit received (salary, refund, friend sent money, cashback) is NOT treated as an expense',
        () {
      final parser = SmsParserService();
      final now = DateTime(2026, 10, 15, 10, 0);

      // Case A: Refund SMS
      final refundSms = parser.parse(
        sender: 'VK-ICICIB',
        body: 'Your A/c XX4321 is credited with INR 750.00 on 15-Oct-26 towards Refund of Swiggy order.',
        timestamp: now,
      );
      expect(refundSms.type, equals(ParsedSmsType.credit));
      expect(refundSms.amount, equals(Money.fromRupees(750)));

      // Case B: Salary credit SMS
      final salarySms = parser.parse(
        sender: 'AXISBK',
        body: 'Salary of Rs 85,000.00 credited to your A/c XX9876 on 15-Oct-26.',
        timestamp: now,
      );
      expect(salarySms.type, equals(ParsedSmsType.credit));
      expect(salarySms.amount, equals(Money.fromRupees(85000)));

      // Case C: Friend sent money (P2P UPI Received)
      final p2pSms = parser.parse(
        sender: 'PhonePe',
        body: 'Received Rs 1200.00 from Rahul Kumar via UPI.',
        timestamp: now,
      );
      expect(p2pSms.type, equals(ParsedSmsType.credit));
      expect(p2pSms.amount, equals(Money.fromRupees(1200)));

      // Verify Domain impact: A refund reduces total daily spent, rather than consuming budget
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_test',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(10000),
      );

      final debitTx = Transaction(
        id: 'tx_debit_1',
        cycleId: cycle.id,
        amount: Money.fromRupees(1000),
        title: 'Zomato Lunch',
        category: TransactionCategory.food,
        timestamp: now,
        type: TransactionType.expense,
      );

      final refundTx = Transaction(
        id: 'tx_refund_1',
        cycleId: cycle.id,
        amount: Money.fromRupees(300),
        title: 'Zomato Cancelled Item Refund',
        category: TransactionCategory.food,
        timestamp: now.add(const Duration(hours: 1)),
        type: TransactionType.refund,
      );

      final recompute = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [debitTx, refundTx],
        currentDayIndex: 1,
      );

      final day1 = recompute.budgets.first;
      // Net spent is 1000 - 300 = 700, NOT 1300!
      expect(day1.actualSpent, equals(Money.fromRupees(700)),
          reason: 'Refund must decrease actual spent, not add to it');
    });

    // -------------------------------------------------------------------------
    // RISK 3: 28, 29, 30, and 31-day cycles exact paisa sum
    // -------------------------------------------------------------------------
    test(
        'RISK 3: Cycles of 28, 29, 30, and 31 days daily budgets sum exactly to the discretionary pool down to 1 paisa',
        () {
      final testCases = [
        {'name': '28-day cycle (Feb non-leap)', 'year': 2025, 'month': 2, 'payday': 1, 'expectedDays': 28},
        {'name': '29-day cycle (Feb leap year)', 'year': 2024, 'month': 2, 'payday': 1, 'expectedDays': 29},
        {'name': '30-day cycle (April)', 'year': 2026, 'month': 4, 'payday': 1, 'expectedDays': 30},
        {'name': '31-day cycle (March)', 'year': 2026, 'month': 3, 'payday': 1, 'expectedDays': 31},
      ];

      for (final tc in testCases) {
        final cycle = BudgetCycle.createValidated(
          id: 'cycle_${tc['expectedDays']}',
          year: tc['year'] as int,
          month: tc['month'] as int,
          paydayDay: tc['payday'] as int,
          inHandSalary: Money.fromRupees(50000), // ₹50,000
          fixedExpensesTotal: Money.fromRupees(15000), // ₹15,000
          savingsTargetAmount: Money.fromRupees(10000), // ₹10,000
        );

        expect(cycle.totalDays, equals(tc['expectedDays']));
        final pool = cycle.discretionaryPool; // ₹25,000 = 2,500,000 paise

        // Allocate across all days
        final dailyBudgets = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);
        expect(dailyBudgets.length, equals(tc['expectedDays']));

        // Sum of all daily budgets
        final totalAllocatedPaise = dailyBudgets.fold<int>(
          0,
          (sum, b) => sum + b.allocatedBudget.paise,
        );

        expect(totalAllocatedPaise, equals(pool.paise),
            reason: '${tc['name']} must sum to exactly ${pool.paise} paise with zero remainder loss');
      }
    });

    // -------------------------------------------------------------------------
    // RISK 4: App killed in the background / crash recovery mid-transaction
    // -------------------------------------------------------------------------
    test(
        'RISK 4: App crash or abort mid-transaction leaves zero half-written or corrupt data in SQLite',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = SalaryQuestRepository(db);
      addTearDown(db.close);

      final cycle = BudgetCycle.createValidated(
        id: 'cycle_crash_test',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(10000),
      );

      final dailyBudgets = BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

      // Save initial clean state
      await repo.saveCycleAndBudgets(
        cycle: cycle,
        dailyBudgets: dailyBudgets,
        hero: const HeroCharacter(name: 'Hero', level: 1, currentXp: 0, currentHp: 100),
        quests: [],
      );

      // Simulate a multi-table atomic write where step 2 throws a crash exception
      try {
        await db.transaction(() async {
          // Step 1: Insert transaction
          await db.into(db.transactionsTable).insert(
                TransactionsTableCompanion.insert(
                  id: 'tx_corrupt_candidate',
                  cycleId: cycle.id,
                  amountPaise: 250000,
                  title: 'Crash Spend',
                  category: 'shopping',
                  timestamp: DateTime.now(),
                  transactionType: const drift.Value('expense'),
                  source: const drift.Value('manual'),
                ),
              );

          // Step 2: Crash occurs before hero state or budget updates are committed
          throw StateError('SIMULATED CRASH / OEM FORCE-CLOSE MID-WRITE');
        });
      } catch (e) {
        expect(e, isA<StateError>());
      }

      // Verify rollback: zero corrupt or partial data was retained
      final txs = await db.select(db.transactionsTable).get();
      expect(txs.isEmpty, isTrue,
          reason: 'Atomic SQLite transaction must roll back completely on mid-save crash');
    });

    // -------------------------------------------------------------------------
    // RISK 5: Payments around midnight (23:59 vs 00:01)
    // -------------------------------------------------------------------------
    test(
        'RISK 5: Transactions at 23:59 vs 00:01 land on the correct distinct days according to device local time',
        () {
      final cycleStartDate = DateTime(2026, 10, 25); // Day 1 is Oct 25
      const totalDays = 31;

      // Oct 25 at 23:59:59 (End of Day 1)
      final paymentNight = DateTime(2026, 10, 25, 23, 59, 59);
      final dayNight = CycleDateCalculator.getDayIndexForTimestamp(
        timestamp: paymentNight,
        cycleStartDate: cycleStartDate,
        totalDays: totalDays,
      );
      expect(dayNight, equals(1),
          reason: '23:59 on Oct 25 must be classified as Day 1');

      // Oct 26 at 00:00:01 (Start of Day 2)
      final paymentMorning = DateTime(2026, 10, 26, 0, 0, 1);
      final dayMorning = CycleDateCalculator.getDayIndexForTimestamp(
        timestamp: paymentMorning,
        cycleStartDate: cycleStartDate,
        totalDays: totalDays,
      );
      expect(dayMorning, equals(2),
          reason: '00:01 on Oct 26 must be classified as Day 2');

      // Verify that Day 1 and Day 2 expenses do not leak into each other's budgets
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_midnight',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(62000),
        fixedExpensesTotal: Money.fromRupees(0),
        savingsTargetAmount: Money.fromRupees(0),
      );

      final txNight = Transaction(
        id: 'tx_night',
        cycleId: cycle.id,
        amount: Money.fromRupees(500),
        title: 'Late Night Snack',
        category: TransactionCategory.food,
        timestamp: paymentNight,
        type: TransactionType.expense,
      );

      final txMorning = Transaction(
        id: 'tx_morning',
        cycleId: cycle.id,
        amount: Money.fromRupees(150),
        title: 'Morning Chai',
        category: TransactionCategory.food,
        timestamp: paymentMorning,
        type: TransactionType.expense,
      );

      final recompute = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: [txNight, txMorning],
        currentDayIndex: 2,
      );

      // Day 1 spent is 500, Day 2 spent is 150
      expect(recompute.budgets[0].actualSpent, equals(Money.fromRupees(500)));
      expect(recompute.budgets[1].actualSpent, equals(Money.fromRupees(150)));
    });
  });
}
