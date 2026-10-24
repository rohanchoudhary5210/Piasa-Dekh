import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/database/app_database.dart';
import 'package:salary_quest/core/database/salary_quest_repository.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/services/backup_restore_service.dart';
import 'package:salary_quest/core/services/local_security_service.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/gamification/domain/models/quest.dart';
import 'package:salary_quest/features/gamification/domain/services/gamification_engine.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/notifications/infrastructure/fake_notification_service.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/sms_parser_service.dart';

/// Cycle Oct 25 2026 – Nov 24 2026 (payday 25), pool = 60k - 20k - 10k = 30k.
BudgetCycle _octoberCycle() => BudgetCycle.createValidated(
      id: 'cycle_test_oct',
      year: 2026,
      month: 10,
      paydayDay: 25,
      inHandSalary: Money.fromRupees(60000),
      fixedExpensesTotal: Money.fromRupees(20000),
      savingsTargetAmount: Money.fromRupees(10000),
    );

SalaryQuestNotifier _notifierOn(BudgetCycle cycle, {HeroCharacter? hero}) {
  final notifier = SalaryQuestNotifier(
    notificationService: FakeNotificationService(),
  );
  notifier.state = notifier.state.copyWith(
    cycle: cycle,
    dailyBudgets: BudgetCalculator.generateInitialCycleBudgets(cycle: cycle),
    transactions: const [],
    currentDayIndex: 1,
    isOnboarded: true,
    hero: hero ??
        const HeroCharacter(
          name: 'Aero',
          currentHp: 80,
          streakDays: 4,
        ),
  );
  return notifier;
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('SMS credits are classified correctly', () {
    final parser = SmsParserService();
    final now = DateTime(2026, 10, 15, 10, 0);

    test('Salary credit never counts as spending', () {
      final salary = parser.parse(
        sender: 'AXISBK',
        body: 'Salary of Rs 85,000.00 credited to your A/c XX9876 on 15-Oct-26.',
        timestamp: now,
      );
      expect(salary.type, ParsedSmsType.credit);
      expect(salary.isSalaryCredit, isTrue);
      expect(salary.affectsBudget, isFalse);
      expect(salary.toTransaction(cycleId: 'c'), isNull);
    });

    test('Refund credit reduces spending', () {
      final refund = parser.parse(
        sender: 'VK-ICICIB',
        body:
            'Your A/c XX4321 is credited with INR 750.00 on 15-Oct-26 towards Refund of Swiggy order.',
        timestamp: now,
      );
      expect(refund.isRefundCredit, isTrue);
      expect(refund.affectsBudget, isTrue);
      expect(refund.toTransaction(cycleId: 'c')!.type, TransactionType.refund);
    });

    test('Money received from a friend is not a refund', () {
      final p2p = parser.parse(
        sender: 'PhonePe',
        body: 'Received Rs 1200.00 from Rahul Kumar via UPI.',
        timestamp: now,
      );
      expect(p2p.type, ParsedSmsType.credit);
      expect(p2p.creditKind, CreditKind.other);
      expect(p2p.affectsBudget, isFalse);
    });

    test('Debits still affect the budget', () {
      final debit = parser.parse(
        sender: 'HDFCBK',
        body: 'Rs 450.00 debited from A/c XX1234 towards Swiggy on 15-Oct-26.',
        timestamp: now,
      );
      expect(debit.affectsBudget, isTrue);
    });
  });

  group('Day rollover: streak, HP and quests are evaluated once per day', () {
    test('First run sets a baseline and does not touch past days', () async {
      final notifier = _notifierOn(_octoberCycle());
      await notifier.runDailyMaintenance(now: DateTime(2026, 10, 27, 9));

      expect(notifier.state.currentDayIndex, 3);
      expect(notifier.state.hero.streakDays, 4);
      expect(notifier.state.hero.currentHp, 80);
      expect(notifier.state.dailySummary, isNull);
    });

    test('Two zero-spend days add streak, HP and auto-claim quests', () async {
      final notifier = _notifierOn(_octoberCycle());
      await notifier.runDailyMaintenance(now: DateTime(2026, 10, 27, 9));
      final xpBefore = notifier.state.hero.currentXp;
      final coinsBefore = notifier.state.hero.coins;

      await notifier.runDailyMaintenance(now: DateTime(2026, 10, 29, 9));

      expect(notifier.state.currentDayIndex, 5);
      expect(notifier.state.hero.streakDays, 6);
      expect(notifier.state.hero.currentHp, 100); // +25 per zero-spend day, capped
      // Oct 27 quests: under-budget (+50 XP/20c) and no-spend (+100 XP/40c) auto-claimed
      expect(notifier.state.hero.coins, coinsBefore + 60);
      expect(
        notifier.state.hero.currentXp != xpBefore ||
            notifier.state.hero.level > 1,
        isTrue,
      );
      expect(notifier.state.dailySummary, contains('Last 2 days'));

      // Fresh, unclaimed quests for the new day
      expect(notifier.state.quests.every((q) => !q.isClaimed), isTrue);
      expect(notifier.state.quests.any((q) => q.type == QuestType.logExpense),
          isTrue);
    });

    test('An overspent day breaks the streak and costs HP', () async {
      final cycle = _octoberCycle();
      final notifier = _notifierOn(cycle);
      await notifier.runDailyMaintenance(now: DateTime(2026, 10, 27, 9));

      notifier.state = notifier.state.copyWith(transactions: [
        Transaction(
          id: 'tx_big',
          cycleId: cycle.id,
          amount: Money.fromRupees(5000),
          title: 'Big Shopping',
          category: TransactionCategory.shopping,
          timestamp: DateTime(2026, 10, 27, 18),
        ),
      ]);

      await notifier.runDailyMaintenance(now: DateTime(2026, 10, 28, 9));

      expect(notifier.state.hero.streakDays, 0);
      expect(notifier.state.hero.previousStreakDays, 4);
      expect(notifier.state.hero.currentHp, 50); // heavy overspend -30
      expect(notifier.state.dailySummary, contains('over budget'));
    });

    test('Logging an expense no longer changes HP immediately', () async {
      final notifier = _notifierOn(_octoberCycle());
      final hpBefore = notifier.state.hero.currentHp;
      await notifier.addTransaction(
        amount: Money.fromRupees(10),
        title: 'Chai',
        category: TransactionCategory.food,
        customTimestamp: DateTime(2026, 10, 25, 9),
      );
      expect(notifier.state.hero.currentHp, hpBefore);
    });

    test('Back-dated SMS entries are not flagged as clock tampering', () async {
      final notifier = _notifierOn(_octoberCycle());
      await notifier.addTransaction(
        amount: Money.fromRupees(100),
        title: 'Metro',
        category: TransactionCategory.transport,
      );
      await notifier.addTransaction(
        amount: Money.fromRupees(120),
        title: 'Lunch',
        category: TransactionCategory.food,
        customTimestamp: DateTime.now().subtract(const Duration(hours: 5)),
        source: TransactionSource.smsAuto,
      );
      expect(notifier.state.isClockManipulated, isFalse);
      expect(notifier.state.transactions.first.earnedXp, 15);
    });
  });

  group('Payday rollover starts a new cycle automatically', () {
    test('After the last day, the next cycle begins with a fresh budget', () async {
      final september = BudgetCycle.createValidated(
        id: 'cycle_test_sep',
        year: 2026,
        month: 9,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(10000),
      );
      final notifier = _notifierOn(september);
      notifier.state = notifier.state.copyWith(transactions: [
        Transaction(
          id: 'tx_sep',
          cycleId: september.id,
          amount: Money.fromRupees(300),
          title: 'Dinner',
          category: TransactionCategory.food,
          timestamp: DateTime(2026, 10, 20, 20),
        ),
      ]);

      await notifier.runDailyMaintenance(now: DateTime(2026, 10, 26, 9));

      final cycle = notifier.state.cycle;
      expect(cycle.id, isNot(september.id));
      expect(cycle.startDate, DateTime(2026, 10, 25));
      expect(cycle.endDate, DateTime(2026, 11, 24));
      expect(notifier.state.currentDayIndex, 2);
      expect(notifier.state.transactions, isEmpty);
      expect(notifier.state.bossMaxHp, 10000);
      expect(notifier.state.dailySummary, contains('New salary cycle'));
    });

    test('Month-end auto-flow moves leftover money into the primary goal', () async {
      final september = BudgetCycle.createValidated(
        id: 'cycle_test_sep2',
        year: 2026,
        month: 9,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(10000),
      );
      final notifier = _notifierOn(september);
      final goal = await notifier.createSavingsGoal(
        title: 'Bike',
        targetAmount: Money.fromRupees(100000),
        isPrimary: true,
      );
      await notifier.toggleAutoFlowSavings(true, goalId: goal.id);
      notifier.state = notifier.state.copyWith(transactions: [
        Transaction(
          id: 'tx_sep_spend',
          cycleId: september.id,
          amount: Money.fromRupees(25000),
          title: 'Month spends',
          category: TransactionCategory.shopping,
          timestamp: DateTime(2026, 10, 1, 12),
        ),
      ]);

      await notifier.runDailyMaintenance(now: DateTime(2026, 10, 26, 9));

      // Pool 30,000 - spent 25,000 = 5,000 left over
      expect(notifier.state.savingsGoals.first.savedAmount,
          Money.fromRupees(5000));
    });
  });

  group('Persistence fixes', () {
    test('Shop skins/themes and boss HP survive an app restart', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = SalaryQuestRepository(db);
      final cycle = _octoberCycle();

      const hero = HeroCharacter(
        name: 'Aero',
        coins: 10,
        skin: 'cyber_mage',
        unlockedSkins: ['default', 'cyber_mage'],
        themeId: 'emerald_grove',
        unlockedThemes: ['mana_purple', 'emerald_grove'],
      );

      await repo.saveCycleAndBudgets(
        cycle: cycle,
        dailyBudgets: BudgetCalculator.generateInitialCycleBudgets(cycle: cycle),
        hero: hero,
        quests: GamificationEngine.getStarterQuests(),
        bossCurrentHp: 4321,
        bossMaxHp: 10000,
      );
      await repo.savePreference(SalaryQuestRepository.kvLanguage, 'hi');

      final loaded = await SalaryQuestRepository(db).loadPersistedState();
      expect(loaded, isNotNull);
      expect(loaded!.hero.skin, 'cyber_mage');
      expect(loaded.hero.unlockedSkins, contains('cyber_mage'));
      expect(loaded.hero.themeId, 'emerald_grove');
      expect(loaded.bossCurrentHp, 4321);
      expect(loaded.bossMaxHp, 10000);
      expect(loaded.languageCode, 'hi');
    });

    test('Boss HP defaults to the savings target, not the spending pool', () {
      expect(SalaryQuestRepository.defaultBossHpFor(_octoberCycle()), 10000);
    });
  });

  group('Password-protected backups', () {
    test('Backup restores on a "new phone" with the right password', () async {
      final oldPhone = LocalSecurityService(memoryFallback: {});
      final newPhone = LocalSecurityService(memoryFallback: {});
      final source = _notifierOn(_octoberCycle());

      final backup = await BackupRestoreService.exportEncryptedBackup(
        state: source.state,
        securityService: oldPhone,
        password: 'mySecret123',
      );
      expect(LocalSecurityService.isPasswordProtected(backup), isTrue);

      final dest = _notifierOn(_octoberCycle());
      final result = await BackupRestoreService.restoreEncryptedBackup(
        encryptedData: backup,
        currentState: dest.state,
        securityService: newPhone,
        password: 'mySecret123',
      );
      expect(result.restoredState.cycle.id, 'cycle_test_oct');
    });

    test('Wrong or missing password is rejected', () async {
      final sec = LocalSecurityService(memoryFallback: {});
      final source = _notifierOn(_octoberCycle());
      final backup = await BackupRestoreService.exportEncryptedBackup(
        state: source.state,
        securityService: sec,
        password: 'rightPassword',
      );

      expect(
        () => BackupRestoreService.restoreEncryptedBackup(
          encryptedData: backup,
          currentState: source.state,
          securityService: sec,
          password: 'wrongPassword',
        ),
        throwsA(isA<BackupDecryptionException>()),
      );
      expect(
        () => BackupRestoreService.restoreEncryptedBackup(
          encryptedData: backup,
          currentState: source.state,
          securityService: sec,
        ),
        throwsA(isA<BackupDecryptionException>()),
      );
    });
  });

  group('Notifications', () {
    test('Daily reminders are scheduled and follow preferences', () async {
      final fake = FakeNotificationService();
      final notifier = SalaryQuestNotifier(notificationService: fake);

      await notifier.notificationManager.syncDailyReminders();
      expect(fake.scheduledNotifications.length, 2);

      notifier.notificationManager.updatePreferences(
        notifier.state.notificationPreferences.copyWith(enabled: false),
      );
      await notifier.notificationManager.syncDailyReminders();
      expect(fake.scheduledNotifications, isEmpty);
    });
  });
}
