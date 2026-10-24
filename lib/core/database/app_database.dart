import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// -------------------------------------------------------------
// DATABASE ENCRYPTION BOUNDARY & ARCHITECTURE DOCUMENTATION
// -------------------------------------------------------------
// 1. Storage Engine: SQLite Native Database (salary_quest.sqlite).
// 2. Encryption Boundaries:
//    - Master Encryption Key: Stored in hardware-backed Android Keystore via
//      FlutterSecureStorage with AndroidOptions(encryptedSharedPreferences: true).
//      Never stored in the database or hardcoded in Dart code.
//    - Field-Level Protected Data:
//      * Backup files and sync payloads: Fully encrypted with AES-256-GCM.
//      * Sensitive raw SMS logs and bank account snippets: AES-256-GCM encrypted.
//      * Biometric lock state & security preferences: Hardware-backed secure storage.
//    - Plaintext Indexed Fields in SQLite:
//      * Transaction amounts (integer paise), timestamps, and categories.
//      * Daily budget snapshots and cycle dates.
//      * Hero XP, coins, and quest progress.
//      Rationale: These fields are maintained in standard SQLite integers and varchars
//      to allow sub-millisecond aggregation queries, rolling sum calculations,
//      and Drift reactive stream observers without CPU-intensive cryptographic decrypt overhead.
//      App data is protected at rest by Android OS user sandbox encryption (FBE - File Based Encryption).
// -------------------------------------------------------------
// TABLE DEFINITIONS
// -------------------------------------------------------------

class UserSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get paydayDay => integer().withDefault(const Constant(25))();
  TextColumn get currencySymbol => text().withDefault(const Constant('₹'))();
  TextColumn get rolloverStrategy =>
      text().withDefault(const Constant('dynamic_smoothing'))();
  BoolColumn get isSeriousMode =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get reducedMotion =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get biometricLock =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get autoFlowSavings =>
      boolean().withDefault(const Constant(false))();
  TextColumn get autoFlowGoalId => text().nullable()();
  DateTimeColumn get lastKnownDeviceTimestamp => dateTime().nullable()();
}

class CyclesTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  IntColumn get totalDays => integer()();
  IntColumn get paydayDay => integer().withDefault(const Constant(25))();
  DateTimeColumn get salaryReceivedDate => dateTime().nullable()();
  IntColumn get inHandSalaryPaise => integer()();
  IntColumn get fixedExpensesPaise => integer()();
  IntColumn get savingsTargetPaise => integer()();
  TextColumn get rolloverStrategy =>
      text().withDefault(const Constant('dynamic_smoothing'))();
  IntColumn get bossCurrentHp => integer()();
  IntColumn get bossMaxHp => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DailyBudgetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get cycleId => text().references(CyclesTable, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get dayIndex => integer()();
  IntColumn get allocatedBudgetPaise => integer()();
  IntColumn get actualSpentPaise => integer()();
  BoolColumn get isClosed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get cycleId => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  BoolColumn get isFixedExpense =>
      boolean().withDefault(const Constant(false))();
  TextColumn get transactionType =>
      text().withDefault(const Constant('expense'))();
  TextColumn get dedupeKey => text().nullable()();
  IntColumn get earnedXp => integer().withDefault(const Constant(0))();
  IntColumn get earnedCoins => integer().withDefault(const Constant(0))();
  IntColumn get splitTotalPaise => integer().nullable()();
  IntColumn get splitUserSharePaise => integer().nullable()();
  IntColumn get pendingReimbursementPaise => integer().nullable()();
  BoolColumn get isReimbursement =>
      boolean().withDefault(const Constant(false))();
  TextColumn get parentTransactionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class HeroStateTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get name => text().withDefault(const Constant('Aero'))();
  TextColumn get archetype => text().withDefault(const Constant('knight'))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get currentXp => integer().withDefault(const Constant(0))();
  IntColumn get maxXp => integer().withDefault(const Constant(100))();
  IntColumn get currentHp => integer().withDefault(const Constant(100))();
  IntColumn get maxHp => integer().withDefault(const Constant(100))();
  IntColumn get coins => integer().withDefault(const Constant(50))();
  IntColumn get streakDays => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastLoginDate => dateTime().nullable()();
  IntColumn get previousStreakDays =>
      integer().withDefault(const Constant(0))();
  BoolColumn get streakShieldAvailable =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class QuestsTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get type => text()();
  RealColumn get targetValue => real()();
  RealColumn get progressValue => real()();
  IntColumn get rewardXp => integer()();
  IntColumn get rewardCoins => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isClaimed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class AchievementsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get icon => text()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SavingsGoalsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get targetAmountPaise => integer()();
  IntColumn get savedAmountPaise => integer()();
  TextColumn get icon => text().withDefault(const Constant('🎯'))();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deadline => dateTime().nullable()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// -------------------------------------------------------------
// DATABASE IMPLEMENTATION & MIGRATIONS
// -------------------------------------------------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'salary_quest.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [
  UserSettingsTable,
  CyclesTable,
  DailyBudgetsTable,
  TransactionsTable,
  HeroStateTable,
  QuestsTable,
  AchievementsTable,
  SavingsGoalsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2 && to >= 2) {
          // Schema Version 1 -> 2 migration:
          // Add isArchived column to CyclesTable if upgrading from v1
          await m.addColumn(cyclesTable, cyclesTable.isArchived);
        }
        if (from < 3 && to >= 3) {
          // Schema Version 2 -> 3 migration:
          // Add Task 5 Transaction fields (XP/coins rollback, split tracking, deduplication)
          await m.addColumn(transactionsTable, transactionsTable.earnedXp);
          await m.addColumn(transactionsTable, transactionsTable.earnedCoins);
          await m.addColumn(transactionsTable, transactionsTable.splitTotalPaise);
          await m.addColumn(transactionsTable, transactionsTable.splitUserSharePaise);
          await m.addColumn(transactionsTable, transactionsTable.pendingReimbursementPaise);
          await m.addColumn(transactionsTable, transactionsTable.isReimbursement);
          await m.addColumn(transactionsTable, transactionsTable.parentTransactionId);
        }
        if (from < 4 && to >= 4) {
          // Schema Version 3 -> 4 migration:
          // Add Task 6 Gamification fields (streak recovery, streak shield)
          await m.addColumn(heroStateTable, heroStateTable.previousStreakDays);
          await m.addColumn(heroStateTable, heroStateTable.streakShieldAvailable);
        }
        if (from < 5 && to >= 5) {
          // Schema Version 4 -> 5 migration:
          // Add Task 7 Security fields (biometricLock)
          await m.addColumn(userSettingsTable, userSettingsTable.biometricLock);
        }
        if (from < 6 && to >= 6) {
          // Schema Version 5 -> 6 migration:
          // Add savings goal deadline & completed status, and auto-flow settings
          await m.addColumn(savingsGoalsTable, savingsGoalsTable.deadline);
          await m.addColumn(savingsGoalsTable, savingsGoalsTable.isCompleted);
          await m.addColumn(userSettingsTable, userSettingsTable.autoFlowSavings);
          await m.addColumn(userSettingsTable, userSettingsTable.autoFlowGoalId);
        }
      },
      beforeOpen: (details) async {
        // Enforce foreign key constraints
        await customStatement('PRAGMA foreign_keys = ON');
        // Lightweight key-value store for app preferences and progress markers
        // (language, notification prefs, hero cosmetics, day-processing cursor).
        // Created with raw SQL so it needs no drift code generation and works on
        // both fresh installs and upgraded databases.
        await customStatement(
          'CREATE TABLE IF NOT EXISTS app_kv_store ('
          'k TEXT NOT NULL PRIMARY KEY, v TEXT NOT NULL)',
        );
      },
    );
  }

  /// Reads a value from the key-value store, or null if absent.
  Future<String?> readKv(String key) async {
    final row = await customSelect(
      'SELECT v FROM app_kv_store WHERE k = ?',
      variables: [Variable.withString(key)],
    ).getSingleOrNull();
    return row?.read<String>('v');
  }

  /// Inserts or replaces a value in the key-value store.
  Future<void> writeKv(String key, String value) async {
    await customStatement(
      'INSERT OR REPLACE INTO app_kv_store (k, v) VALUES (?, ?)',
      [key, value],
    );
  }

  /// Removes a single key from the key-value store.
  Future<void> deleteKv(String key) async {
    await customStatement('DELETE FROM app_kv_store WHERE k = ?', [key]);
  }

  /// Removes every key from the key-value store.
  Future<void> clearKv() async {
    await customStatement('DELETE FROM app_kv_store');
  }
}
