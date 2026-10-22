import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/database/app_database.dart';
import 'package:salary_quest/core/database/database_failure_exception.dart';
import 'package:salary_quest/core/database/salary_quest_repository.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/gamification/domain/services/gamification_engine.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

void main() {
  late AppDatabase db;
  late SalaryQuestRepository repo;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    // In-memory SQLite database for test isolation
    db = AppDatabase(NativeDatabase.memory());
    repo = SalaryQuestRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TASK 3: Drift SQLite Persistence Tests', () {
    test('App reloads exactly the same state after being killed and reopened', () async {
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_test_persistence',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(75000),
        fixedExpensesTotal: Money.fromRupees(30000),
        savingsTargetAmount: Money.fromRupees(15000),
      );

      final dailyBudgets =
          BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);
      const hero = HeroCharacter(
        name: 'Aero',
        level: 5,
        currentXp: 350,
        currentHp: 92,
        coins: 240,
        streakDays: 7,
      );
      final quests = GamificationEngine.getStarterQuests();

      // 1. Save state
      await repo.saveCycleAndBudgets(
        cycle: cycle,
        dailyBudgets: dailyBudgets,
        hero: hero,
        quests: quests,
      );

      // 2. Record a transaction
      final tx = Transaction(
        id: 'tx_grocery_1',
        cycleId: cycle.id,
        amount: Money.fromRupees(450.50),
        title: 'Weekly Groceries',
        category: TransactionCategory.groceries,
        timestamp: DateTime(2026, 10, 25, 14, 30),
      );

      dailyBudgets[0] = dailyBudgets[0].copyWith(actualSpent: tx.amount);
      await repo.recordTransaction(
        transaction: tx,
        rebalancedBudgets: dailyBudgets,
        hero: hero,
        quests: quests,
        newBossHp: 29550,
      );

      // 3. Simulate "App Killed and Reopened" by creating a fresh repository instance
      final freshRepo = SalaryQuestRepository(db);
      final loadedState = await freshRepo.loadPersistedState();

      expect(loadedState, isNotNull);
      expect(loadedState!.cycle.id, equals(cycle.id));
      expect(loadedState.cycle.inHandSalary.paise, equals(7500000));
      expect(loadedState.cycle.fixedExpensesTotal.paise, equals(3000000));
      expect(loadedState.cycle.savingsTargetAmount.paise, equals(1500000));
      expect(loadedState.dailyBudgets.length, equals(cycle.totalDays));
      expect(loadedState.dailyBudgets[0].actualSpent.paise, equals(45050));
      expect(loadedState.transactions.length, equals(1));
      expect(loadedState.transactions.first.title, equals('Weekly Groceries'));
      expect(loadedState.hero.level, equals(5));
      expect(loadedState.hero.coins, equals(240));
      expect(loadedState.hero.streakDays, equals(7));
    });

    test('Atomic transactions: error mid-save rolls back and leaves no half-written data', () async {
      final initialCycleCount = (await db.select(db.cyclesTable).get()).length;
      final initialBudgetCount = (await db.select(db.dailyBudgetsTable).get()).length;

      expect(
        () async {
          await db.transaction(() async {
            // Write 1: insert valid cycle
            await db.into(db.cyclesTable).insert(
                  CyclesTableCompanion.insert(
                    id: 'cycle_will_abort',
                    startDate: DateTime(2026, 10, 1),
                    endDate: DateTime(2026, 10, 31),
                    totalDays: 31,
                    inHandSalaryPaise: 5000000,
                    fixedExpensesPaise: 2000000,
                    savingsTargetPaise: 1000000,
                    bossCurrentHp: 20000,
                    bossMaxHp: 20000,
                  ),
                );

            // Write 2: intentionally throw an unhandled error to trigger transaction rollback
            throw Exception('Simulated crash during write!');
          });
        },
        throwsException,
      );

      // Verify that NO partial data was committed
      final finalCycleCount = (await db.select(db.cyclesTable).get()).length;
      final finalBudgetCount = (await db.select(db.dailyBudgetsTable).get()).length;

      expect(finalCycleCount, equals(initialCycleCount));
      expect(finalBudgetCount, equals(initialBudgetCount));
    });

    test('Schema migration from v1 to v2 preserves existing data', () async {
      // 1. Drop existing table to simulate clean V1 database state
      await db.customStatement('DROP TABLE cycles_table;');

      // 2. Create V1 schema WITHOUT `is_archived`
      await db.customStatement('''
        CREATE TABLE cycles_table (
          id TEXT NOT NULL PRIMARY KEY,
          start_date INTEGER NOT NULL,
          end_date INTEGER NOT NULL,
          total_days INTEGER NOT NULL,
          payday_day INTEGER NOT NULL DEFAULT 25,
          salary_received_date INTEGER,
          in_hand_salary_paise INTEGER NOT NULL,
          fixed_expenses_paise INTEGER NOT NULL,
          savings_target_paise INTEGER NOT NULL,
          rollover_strategy TEXT NOT NULL DEFAULT 'dynamic_smoothing',
          boss_current_hp INTEGER NOT NULL,
          boss_max_hp INTEGER NOT NULL
        );
      ''');

      // 3. Insert existing user record in V1 schema
      await db.customStatement('''
        INSERT INTO cycles_table (
          id, start_date, end_date, total_days, payday_day,
          in_hand_salary_paise, fixed_expenses_paise, savings_target_paise,
          boss_current_hp, boss_max_hp
        ) VALUES (
          'v1_user_cycle', 1700000000000, 1702500000000, 30, 25,
          6000000, 2500000, 1500000, 20000, 20000
        );
      ''');

      // 4. Execute v1 -> v2 migration step
      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 1, 2);

      // 5. Verify existing data was preserved and new column is added with default value
      final rows = await (db.select(db.cyclesTable)
            ..where((t) => t.id.equals('v1_user_cycle')))
          .get();

      expect(rows.length, equals(1));
      expect(rows.first.inHandSalaryPaise, equals(6000000));
      expect(rows.first.isArchived, isFalse);
    });

    test('Schema migration from v2 to v3 preserves existing transactions and adds new columns', () async {
      // 1. Drop existing transactions table
      await db.customStatement('DROP TABLE transactions_table;');

      // 2. Create V2 schema
      await db.customStatement('''
        CREATE TABLE transactions_table (
          id TEXT NOT NULL PRIMARY KEY,
          cycle_id TEXT NOT NULL,
          amount_paise INTEGER NOT NULL,
          title TEXT NOT NULL,
          category TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          source TEXT NOT NULL DEFAULT 'manual',
          is_fixed_expense INTEGER NOT NULL DEFAULT 0,
          transaction_type TEXT NOT NULL DEFAULT 'expense',
          dedupe_key TEXT
        );
      ''');

      // 3. Insert V2 transaction
      await db.customStatement('''
        INSERT INTO transactions_table (
          id, cycle_id, amount_paise, title, category, timestamp, source, is_fixed_expense, transaction_type
        ) VALUES (
          'tx_v2_1', 'cycle_1', 25000, 'Lunch', 'food', 1700000000000, 'manual', 0, 'expense'
        );
      ''');

      // 4. Run upgrade migration from 2 -> 3
      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 2, 3);

      // 5. Verify data is intact and new columns have defaults
      final rows = await (db.select(db.transactionsTable)
            ..where((t) => t.id.equals('tx_v2_1')))
          .get();

      expect(rows.length, equals(1));
      expect(rows.first.amountPaise, equals(25000));
      expect(rows.first.title, equals('Lunch'));
      expect(rows.first.earnedXp, equals(0));
      expect(rows.first.isReimbursement, isFalse);
      expect(rows.first.splitTotalPaise, isNull);
    });

    test('Schema migration from v3 to v4 preserves hero state and adds streak recovery columns', () async {
      // 1. Drop existing hero table
      await db.customStatement('DROP TABLE hero_state_table;');

      // 2. Create V3 schema without previous_streak_days and streak_shield_available
      await db.customStatement('''
        CREATE TABLE hero_state_table (
          id INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
          name TEXT NOT NULL DEFAULT 'Aero',
          archetype TEXT NOT NULL DEFAULT 'knight',
          level INTEGER NOT NULL DEFAULT 1,
          current_xp INTEGER NOT NULL DEFAULT 0,
          max_xp INTEGER NOT NULL DEFAULT 100,
          current_hp INTEGER NOT NULL DEFAULT 100,
          max_hp INTEGER NOT NULL DEFAULT 100,
          coins INTEGER NOT NULL DEFAULT 50,
          streak_days INTEGER NOT NULL DEFAULT 1,
          last_login_date INTEGER
        );
      ''');

      // 3. Insert V3 hero record
      await db.customStatement('''
        INSERT INTO hero_state_table (
          id, name, archetype, level, current_xp, max_xp, current_hp, max_hp, coins, streak_days
        ) VALUES (
          1, 'Aero', 'knight', 5, 200, 500, 85, 100, 150, 4
        );
      ''');

      // 4. Run upgrade migration from 3 -> 4
      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 3, 4);

      // 5. Verify hero state is preserved and new streak recovery columns are added
      final heroRows = await db.select(db.heroStateTable).get();
      expect(heroRows.length, equals(1));
      expect(heroRows.first.level, equals(5));
      expect(heroRows.first.coins, equals(150));
      expect(heroRows.first.streakDays, equals(4));
      expect(heroRows.first.previousStreakDays, equals(0));
      expect(heroRows.first.streakShieldAvailable, isTrue);
    });

    test('Schema migration from v4 to v5 preserves settings and adds biometricLock column', () async {
      // 1. Drop existing user settings table
      await db.customStatement('DROP TABLE user_settings_table;');

      // 2. Create V4 schema without biometric_lock
      await db.customStatement('''
        CREATE TABLE user_settings_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          payday_day INTEGER NOT NULL DEFAULT 25,
          currency_symbol TEXT NOT NULL DEFAULT '₹',
          rollover_strategy TEXT NOT NULL DEFAULT 'dynamic_smoothing',
          is_serious_mode INTEGER NOT NULL DEFAULT 0,
          reduced_motion INTEGER NOT NULL DEFAULT 0,
          last_known_device_timestamp INTEGER
        );
      ''');

      // 3. Insert V4 user settings record
      await db.customStatement('''
        INSERT INTO user_settings_table (
          payday_day, currency_symbol, is_serious_mode, reduced_motion
        ) VALUES (
          28, '₹', 1, 1
        );
      ''');

      // 4. Run upgrade migration from 4 -> 5
      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 4, 5);

      // 5. Verify settings preserved and biometric_lock added with default false (using customSelect for V5)
      final rows = await db
          .customSelect(
              'SELECT id, payday_day, is_serious_mode, reduced_motion, biometric_lock FROM user_settings_table;')
          .get();
      expect(rows.length, equals(1));
      expect(rows.first.data['payday_day'], equals(28));
      expect(rows.first.data['is_serious_mode'], equals(1));
      expect(rows.first.data['reduced_motion'], equals(1));
      expect(rows.first.data['biometric_lock'], equals(0));
    });

    test(
        'Schema migration from v5 to v6 preserves goals and adds deadline, isCompleted and auto-flow',
        () async {
      await db.customStatement('DROP TABLE savings_goals_table;');
      await db.customStatement('''
        CREATE TABLE savings_goals_table (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          target_amount_paise INTEGER NOT NULL,
          saved_amount_paise INTEGER NOT NULL,
          icon TEXT NOT NULL DEFAULT '🎯',
          is_primary INTEGER NOT NULL DEFAULT 0
        );
      ''');

      await db.customStatement('''
        INSERT INTO savings_goals_table (
          id, title, target_amount_paise, saved_amount_paise, is_primary
        ) VALUES (
          'v5_goal', 'Emergency', 5000000, 1000000, 1
        );
      ''');

      await db.customStatement('DROP TABLE user_settings_table;');
      await db.customStatement('''
        CREATE TABLE user_settings_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          payday_day INTEGER NOT NULL DEFAULT 25,
          currency_symbol TEXT NOT NULL DEFAULT '₹',
          rollover_strategy TEXT NOT NULL DEFAULT 'dynamic_smoothing',
          is_serious_mode INTEGER NOT NULL DEFAULT 0,
          reduced_motion INTEGER NOT NULL DEFAULT 0,
          biometric_lock INTEGER NOT NULL DEFAULT 0,
          last_known_device_timestamp INTEGER
        );
      ''');

      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 5, 6);

      final goals = await db.select(db.savingsGoalsTable).get();
      expect(goals.length, equals(1));
      expect(goals.first.title, equals('Emergency'));
      expect(goals.first.targetAmountPaise, equals(5000000));
      expect(goals.first.savedAmountPaise, equals(1000000));
      expect(goals.first.isPrimary, isTrue);
      expect(goals.first.isCompleted, isFalse);
      expect(goals.first.deadline, isNull);

      final settings = await db.select(db.userSettingsTable).get();
      expect(settings.isEmpty, isTrue);
    });

    test('DatabaseFailureException formats user-friendly error message on storage full', () {
      const fullEx = DatabaseFailureException(
        'Device storage is full! Please free up storage space to save your financial data safely.',
      );

      expect(
        fullEx.toString(),
        contains('Device storage is full'),
      );
    });
  });
}
