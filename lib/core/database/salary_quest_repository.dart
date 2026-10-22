import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/budget/domain/services/rollover_strategy.dart';
import 'package:salary_quest/features/gamification/domain/models/achievement.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/gamification/domain/models/quest.dart';
import 'package:salary_quest/features/gamification/domain/services/gamification_engine.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/savings_goals/domain/models/savings_goal.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'app_database.dart';
import 'database_failure_exception.dart';

class SalaryQuestRepository {
  final AppDatabase db;

  SalaryQuestRepository(this.db);

  Never _handleDbError(Object e, StackTrace st) {
    if (e is SqliteException) {
      if (e.resultCode == 13 || e.message.toLowerCase().contains('full')) {
        throw DatabaseFailureException(
          'Device storage is full! Please free up storage space to save your financial data safely.',
          e,
        );
      }
    }
    throw DatabaseFailureException(
      'A local database error occurred. Your changes were safely rolled back to prevent corruption.',
      e,
    );
  }

  /// Atomically saves the complete cycle, daily budgets, and initial state in a single transaction.
  Future<void> saveCycleAndBudgets({
    required BudgetCycle cycle,
    required List<DailyBudget> dailyBudgets,
    required HeroCharacter hero,
    required List<DailyQuest> quests,
  }) async {
    try {
      await db.transaction(() async {
        // 1. Upsert Cycle
        await db.into(db.cyclesTable).insertOnConflictUpdate(
              CyclesTableCompanion.insert(
                id: cycle.id,
                startDate: cycle.startDate,
                endDate: cycle.endDate,
                totalDays: cycle.totalDays,
                paydayDay: Value(cycle.paydayDay),
                salaryReceivedDate: Value(cycle.salaryReceivedDate),
                inHandSalaryPaise: cycle.inHandSalary.paise,
                fixedExpensesPaise: cycle.fixedExpensesTotal.paise,
                savingsTargetPaise: cycle.savingsTargetAmount.paise,
                rolloverStrategy: Value(cycle.rolloverStrategy.name),
                bossCurrentHp: cycle.discretionaryPool.inWholeRupees,
                bossMaxHp: cycle.discretionaryPool.inWholeRupees,
              ),
            );

        // 2. Replace daily budgets for this cycle
        await (db.delete(db.dailyBudgetsTable)
              ..where((tbl) => tbl.cycleId.equals(cycle.id)))
            .go();

        for (final b in dailyBudgets) {
          await db.into(db.dailyBudgetsTable).insert(
                DailyBudgetsTableCompanion.insert(
                  id: b.id,
                  cycleId: b.cycleId,
                  date: b.date,
                  dayIndex: b.dayIndex,
                  allocatedBudgetPaise: b.allocatedBudget.paise,
                  actualSpentPaise: b.actualSpent.paise,
                  isClosed: Value(b.isClosed),
                ),
              );
        }

        // 3. Save Hero state
        await db.into(db.heroStateTable).insertOnConflictUpdate(
              HeroStateTableCompanion.insert(
                id: const Value(1),
                name: Value(hero.name),
                archetype: Value(hero.archetype.name),
                level: Value(hero.level),
                currentXp: Value(hero.currentXp),
                maxXp: Value(hero.maxXp),
                currentHp: Value(hero.currentHp),
                maxHp: Value(hero.maxHp),
                coins: Value(hero.coins),
                streakDays: Value(hero.streakDays),
                previousStreakDays: Value(hero.previousStreakDays),
                streakShieldAvailable: Value(hero.streakShieldAvailable),
                lastLoginDate: Value(DateTime.now()),
              ),
            );

        // 4. Save Quests
        for (final q in quests) {
          await db.into(db.questsTable).insertOnConflictUpdate(
                QuestsTableCompanion.insert(
                  id: q.id,
                  date: DateTime.now(),
                  title: q.title,
                  description: q.description,
                  type: q.type.name,
                  targetValue: q.targetValue,
                  progressValue: q.progressValue,
                  rewardXp: q.rewardXp,
                  rewardCoins: q.rewardCoins,
                  isCompleted: Value(q.isCompleted),
                  isClaimed: Value(q.isClaimed),
                ),
              );
        }
      });
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Atomically inserts a transaction and updates the daily budget snapshot in a single transaction.
  Future<void> recordTransaction({
    required Transaction transaction,
    required List<DailyBudget> rebalancedBudgets,
    required HeroCharacter hero,
    required List<DailyQuest> quests,
    required int newBossHp,
  }) async {
    try {
      await db.transaction(() async {
        // 1. Insert transaction
        await db.into(db.transactionsTable).insertOnConflictUpdate(
              TransactionsTableCompanion.insert(
                id: transaction.id,
                cycleId: transaction.cycleId,
                amountPaise: transaction.amount.paise,
                title: transaction.title,
                category: transaction.category.name,
                timestamp: transaction.timestamp,
                source: Value(transaction.source.name),
                isFixedExpense: Value(transaction.isFixedExpense),
                transactionType: Value(transaction.type.name),
                dedupeKey: Value(transaction.dedupeKey),
                earnedXp: Value(transaction.earnedXp),
                earnedCoins: Value(transaction.earnedCoins),
                splitTotalPaise: Value(transaction.splitTotal?.paise),
                splitUserSharePaise: Value(transaction.splitUserShare?.paise),
                pendingReimbursementPaise:
                    Value(transaction.pendingReimbursement?.paise),
                isReimbursement: Value(transaction.isReimbursement),
                parentTransactionId: Value(transaction.parentTransactionId),
              ),
            );

        // 2. Update all rebalanced daily budgets
        for (final b in rebalancedBudgets) {
          await db.into(db.dailyBudgetsTable).insertOnConflictUpdate(
                DailyBudgetsTableCompanion.insert(
                  id: b.id,
                  cycleId: b.cycleId,
                  date: b.date,
                  dayIndex: b.dayIndex,
                  allocatedBudgetPaise: b.allocatedBudget.paise,
                  actualSpentPaise: b.actualSpent.paise,
                  isClosed: Value(b.isClosed),
                ),
              );
        }

        // 3. Update Hero state
        await db.into(db.heroStateTable).insertOnConflictUpdate(
              HeroStateTableCompanion.insert(
                id: const Value(1),
                name: Value(hero.name),
                archetype: Value(hero.archetype.name),
                level: Value(hero.level),
                currentXp: Value(hero.currentXp),
                maxXp: Value(hero.maxXp),
                currentHp: Value(hero.currentHp),
                maxHp: Value(hero.maxHp),
                coins: Value(hero.coins),
                streakDays: Value(hero.streakDays),
                previousStreakDays: Value(hero.previousStreakDays),
                streakShieldAvailable: Value(hero.streakShieldAvailable),
              ),
            );

        // 4. Update Quests
        for (final q in quests) {
          await db.into(db.questsTable).insertOnConflictUpdate(
                QuestsTableCompanion.insert(
                  id: q.id,
                  date: DateTime.now(),
                  title: q.title,
                  description: q.description,
                  type: q.type.name,
                  targetValue: q.targetValue,
                  progressValue: q.progressValue,
                  rewardXp: q.rewardXp,
                  rewardCoins: q.rewardCoins,
                  isCompleted: Value(q.isCompleted),
                  isClaimed: Value(q.isClaimed),
                ),
              );
        }

        // 5. Update Boss HP in Cycle
        await (db.update(db.cyclesTable)
              ..where((tbl) => tbl.id.equals(transaction.cycleId)))
            .write(CyclesTableCompanion(
          bossCurrentHp: Value(newBossHp),
        ));
      });
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Atomically deletes a transaction and updates the recomputed daily budgets,
  /// hero state (with reverted XP/coins), and Boss HP.
  Future<void> deleteTransaction({
    required String transactionId,
    required String cycleId,
    required List<DailyBudget> rebalancedBudgets,
    required HeroCharacter hero,
    required int newBossHp,
  }) async {
    try {
      await db.transaction(() async {
        // 1. Delete transaction
        await (db.delete(db.transactionsTable)
              ..where((tbl) => tbl.id.equals(transactionId)))
            .go();

        // 2. Update all rebalanced daily budgets
        for (final b in rebalancedBudgets) {
          await db.into(db.dailyBudgetsTable).insertOnConflictUpdate(
                DailyBudgetsTableCompanion.insert(
                  id: b.id,
                  cycleId: b.cycleId,
                  date: b.date,
                  dayIndex: b.dayIndex,
                  allocatedBudgetPaise: b.allocatedBudget.paise,
                  actualSpentPaise: b.actualSpent.paise,
                  isClosed: Value(b.isClosed),
                ),
              );
        }

        // 3. Update Hero state with reverted rewards
        await db.into(db.heroStateTable).insertOnConflictUpdate(
              HeroStateTableCompanion.insert(
                id: const Value(1),
                name: Value(hero.name),
                archetype: Value(hero.archetype.name),
                level: Value(hero.level),
                currentXp: Value(hero.currentXp),
                maxXp: Value(hero.maxXp),
                currentHp: Value(hero.currentHp),
                maxHp: Value(hero.maxHp),
                coins: Value(hero.coins),
                streakDays: Value(hero.streakDays),
                previousStreakDays: Value(hero.previousStreakDays),
                streakShieldAvailable: Value(hero.streakShieldAvailable),
              ),
            );

        // 4. Update Boss HP
        await (db.update(db.cyclesTable)
              ..where((tbl) => tbl.id.equals(cycleId)))
            .write(CyclesTableCompanion(
          bossCurrentHp: Value(newBossHp),
        ));
      });
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Loads the persisted state from the database.
  /// Returns null if no active cycle has been saved yet.
  Future<SalaryQuestState?> loadPersistedState() async {
    try {
      // 1. Load active cycle
      final cycleRows = await (db.select(db.cyclesTable)
            ..where((tbl) => tbl.isArchived.equals(false))
            ..limit(1))
          .get();

      if (cycleRows.isEmpty) return null;
      final cRow = cycleRows.first;

      final cycle = BudgetCycle(
        id: cRow.id,
        startDate: cRow.startDate,
        endDate: cRow.endDate,
        totalDays: cRow.totalDays,
        paydayDay: cRow.paydayDay,
        salaryReceivedDate: cRow.salaryReceivedDate,
        inHandSalary: Money.fromPaise(cRow.inHandSalaryPaise),
        fixedExpensesTotal: Money.fromPaise(cRow.fixedExpensesPaise),
        savingsTargetAmount: Money.fromPaise(cRow.savingsTargetPaise),
        rolloverStrategy: const DynamicSmoothingStrategy(),
      );

      // 2. Load daily budgets
      final budgetRows = await (db.select(db.dailyBudgetsTable)
            ..where((tbl) => tbl.cycleId.equals(cycle.id))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.dayIndex)]))
          .get();

      final dailyBudgets = budgetRows
          .map((b) => DailyBudget(
                id: b.id,
                cycleId: b.cycleId,
                date: b.date,
                dayIndex: b.dayIndex,
                allocatedBudget: Money.fromPaise(b.allocatedBudgetPaise),
                actualSpent: Money.fromPaise(b.actualSpentPaise),
                isClosed: b.isClosed,
              ))
          .toList();

      // 3. Load transactions
      final txRows = await (db.select(db.transactionsTable)
            ..where((tbl) => tbl.cycleId.equals(cycle.id))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
          .get();

      final transactions = txRows
          .map((t) => Transaction(
                id: t.id,
                cycleId: t.cycleId,
                amount: Money.fromPaise(t.amountPaise),
                title: t.title,
                category: TransactionCategory.values.firstWhere(
                  (c) => c.name == t.category,
                  orElse: () => TransactionCategory.other,
                ),
                timestamp: t.timestamp,
                source: TransactionSource.values.firstWhere(
                  (s) => s.name == t.source,
                  orElse: () => TransactionSource.manual,
                ),
                isFixedExpense: t.isFixedExpense,
                type: TransactionType.values.firstWhere(
                  (ty) => ty.name == t.transactionType,
                  orElse: () => TransactionType.expense,
                ),
                dedupeKey: t.dedupeKey,
                earnedXp: t.earnedXp,
                earnedCoins: t.earnedCoins,
                splitTotal: t.splitTotalPaise != null
                    ? Money.fromPaise(t.splitTotalPaise!)
                    : null,
                splitUserShare: t.splitUserSharePaise != null
                    ? Money.fromPaise(t.splitUserSharePaise!)
                    : null,
                pendingReimbursement: t.pendingReimbursementPaise != null
                    ? Money.fromPaise(t.pendingReimbursementPaise!)
                    : null,
                isReimbursement: t.isReimbursement,
                parentTransactionId: t.parentTransactionId,
              ))
          .toList();

      // 4. Load Hero
      final heroRows = await db.select(db.heroStateTable).get();
      HeroCharacter hero;
      if (heroRows.isNotEmpty) {
        final hRow = heroRows.first;
        hero = HeroCharacter(
          name: hRow.name,
          archetype: HeroArchetype.values.firstWhere(
            (a) => a.name == hRow.archetype,
            orElse: () => HeroArchetype.knight,
          ),
          level: hRow.level,
          currentXp: hRow.currentXp,
          maxXp: hRow.maxXp,
          currentHp: hRow.currentHp,
          maxHp: hRow.maxHp,
          coins: hRow.coins,
          streakDays: hRow.streakDays,
          previousStreakDays: hRow.previousStreakDays,
          streakShieldAvailable: hRow.streakShieldAvailable,
        );
      } else {
        hero = const HeroCharacter(name: 'Aero');
      }

      // 5. Load Quests
      final questRows = await db.select(db.questsTable).get();
      final quests = questRows
          .map((q) => DailyQuest(
                id: q.id,
                title: q.title,
                description: q.description,
                type: QuestType.values.firstWhere(
                  (qt) => qt.name == q.type,
                  orElse: () => QuestType.logExpense,
                ),
                targetValue: q.targetValue,
                progressValue: q.progressValue,
                rewardXp: q.rewardXp,
                rewardCoins: q.rewardCoins,
                isCompleted: q.isCompleted,
                isClaimed: q.isClaimed,
              ))
          .toList();

      // 6. Load Settings (Serious Mode, Biometric Lock, Reduced Motion, Auto-flow)
      final settingsRows = await db.select(db.userSettingsTable).get();
      final bool isSeriousMode =
          settingsRows.isNotEmpty ? settingsRows.first.isSeriousMode : false;
      final bool isBiometricLock =
          settingsRows.isNotEmpty ? settingsRows.first.biometricLock : false;
      final bool isReducedMotion =
          settingsRows.isNotEmpty ? settingsRows.first.reducedMotion : false;
      final bool isAutoFlowSavings =
          settingsRows.isNotEmpty ? settingsRows.first.autoFlowSavings : false;
      final String? autoFlowGoalId =
          settingsRows.isNotEmpty ? settingsRows.first.autoFlowGoalId : null;

      // 7. Load Savings Goals
      final goalRows = await db.select(db.savingsGoalsTable).get();
      final savingsGoals = goalRows
          .map((r) => SavingsGoal(
                id: r.id,
                title: r.title,
                targetAmount: Money.fromPaise(r.targetAmountPaise),
                savedAmount: Money.fromPaise(r.savedAmountPaise),
                icon: r.icon,
                isPrimary: r.isPrimary,
                deadline: r.deadline,
                isCompleted: r.isCompleted,
              ))
          .toList();

      // 8. Load Achievements
      final achRows = await db.select(db.achievementsTable).get();
      final achievements = achRows
          .map((r) => Achievement(
                id: r.id,
                title: r.title,
                description: r.description,
                icon: r.icon,
                unlockedAt: r.unlockedAt,
              ))
          .toList();

      final currentDay = cycle.currentDayIndex(DateTime.now());

      return SalaryQuestState(
        cycle: cycle,
        dailyBudgets: dailyBudgets,
        currentDayIndex: currentDay,
        transactions: transactions,
        hero: hero,
        quests: quests.isNotEmpty ? quests : GamificationEngine.getStarterQuests(),
        bossCurrentHp: cRow.bossCurrentHp,
        bossMaxHp: cRow.bossMaxHp,
        isSeriousMode: isSeriousMode,
        isBiometricLockEnabled: isBiometricLock,
        isReduceMotion: isReducedMotion,
        savingsGoals: savingsGoals,
        isAutoFlowSavingsEnabled: isAutoFlowSavings,
        autoFlowGoalId: autoFlowGoalId,
        achievements: achievements,
      );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Retrieves all savings goals.
  Future<List<SavingsGoal>> getSavingsGoals() async {
    try {
      final rows = await db.select(db.savingsGoalsTable).get();
      return rows
          .map((r) => SavingsGoal(
                id: r.id,
                title: r.title,
                targetAmount: Money.fromPaise(r.targetAmountPaise),
                savedAmount: Money.fromPaise(r.savedAmountPaise),
                icon: r.icon,
                isPrimary: r.isPrimary,
                deadline: r.deadline,
                isCompleted: r.isCompleted,
              ))
          .toList();
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Saves or updates a savings goal.
  Future<void> saveSavingsGoal(SavingsGoal goal) async {
    try {
      await db.into(db.savingsGoalsTable).insertOnConflictUpdate(
            SavingsGoalsTableCompanion.insert(
              id: goal.id,
              title: goal.title,
              targetAmountPaise: goal.targetAmount.paise,
              savedAmountPaise: goal.savedAmount.paise,
              icon: Value(goal.icon),
              isPrimary: Value(goal.isPrimary),
              deadline: Value(goal.deadline),
              isCompleted: Value(goal.isCompleted),
            ),
          );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Permanently deletes a savings goal.
  Future<void> deleteSavingsGoal(String goalId) async {
    try {
      await (db.delete(db.savingsGoalsTable)
            ..where((tbl) => tbl.id.equals(goalId)))
          .go();
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Persists auto-flow settings.
  Future<void> saveAutoFlowSettings({
    required bool enabled,
    String? goalId,
  }) async {
    try {
      await db.into(db.userSettingsTable).insertOnConflictUpdate(
            UserSettingsTableCompanion.insert(
              id: const Value(1),
              autoFlowSavings: Value(enabled),
              autoFlowGoalId: Value(goalId),
            ),
          );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Retrieves unlocked achievements.
  Future<List<Achievement>> getAchievements() async {
    try {
      final rows = await db.select(db.achievementsTable).get();
      return rows
          .map((r) => Achievement(
                id: r.id,
                title: r.title,
                description: r.description,
                icon: r.icon,
                unlockedAt: r.unlockedAt,
              ))
          .toList();
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Records an achievement unlock.
  Future<void> unlockAchievement(Achievement achievement) async {
    try {
      await db.into(db.achievementsTable).insertOnConflictUpdate(
            AchievementsTableCompanion.insert(
              id: achievement.id,
              title: achievement.title,
              description: achievement.description,
              icon: achievement.icon,
              unlockedAt: Value(achievement.unlockedAt ?? DateTime.now()),
            ),
          );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Persists user serious mode toggle setting.
  Future<void> saveSeriousMode(bool enabled) async {
    try {
      await db.into(db.userSettingsTable).insertOnConflictUpdate(
            UserSettingsTableCompanion.insert(
              id: const Value(1),
              isSeriousMode: Value(enabled),
            ),
          );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Persists user biometric lock toggle setting.
  Future<void> saveBiometricLock(bool enabled) async {
    try {
      await db.into(db.userSettingsTable).insertOnConflictUpdate(
            UserSettingsTableCompanion.insert(
              id: const Value(1),
              biometricLock: Value(enabled),
            ),
          );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Persists user reduced motion toggle setting.
  Future<void> saveReducedMotion(bool enabled) async {
    try {
      await db.into(db.userSettingsTable).insertOnConflictUpdate(
            UserSettingsTableCompanion.insert(
              id: const Value(1),
              reducedMotion: Value(enabled),
            ),
          );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Privacy: Permanently drops and clears all database tables and records.
  Future<void> wipeAllData() async {
    try {
      await db.transaction(() async {
        await db.delete(db.transactionsTable).go();
        await db.delete(db.dailyBudgetsTable).go();
        await db.delete(db.cyclesTable).go();
        await db.delete(db.heroStateTable).go();
        await db.delete(db.questsTable).go();
        await db.delete(db.achievementsTable).go();
        await db.delete(db.savingsGoalsTable).go();
        await db.delete(db.userSettingsTable).go();
      });
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Persists hero state after recovery, XP award or streak repair.
  Future<void> saveHeroState(HeroCharacter hero) async {
    try {
      await db.into(db.heroStateTable).insertOnConflictUpdate(
            HeroStateTableCompanion.insert(
              id: const Value(1),
              name: Value(hero.name),
              archetype: Value(hero.archetype.name),
              level: Value(hero.level),
              currentXp: Value(hero.currentXp),
              maxXp: Value(hero.maxXp),
              currentHp: Value(hero.currentHp),
              maxHp: Value(hero.maxHp),
              coins: Value(hero.coins),
              streakDays: Value(hero.streakDays),
              previousStreakDays: Value(hero.previousStreakDays),
              streakShieldAvailable: Value(hero.streakShieldAvailable),
            ),
          );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Retrieves list of all previous archived cycles for cycle history.
  Future<List<BudgetCycle>> getArchivedCycles() async {
    try {
      final rows = await (db.select(db.cyclesTable)
            ..where((tbl) => tbl.isArchived.equals(true))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)]))
          .get();
      return rows
          .map((r) => BudgetCycle(
                id: r.id,
                startDate: r.startDate,
                endDate: r.endDate,
                totalDays: r.totalDays,
                paydayDay: r.paydayDay,
                salaryReceivedDate: r.salaryReceivedDate,
                inHandSalary: Money.fromPaise(r.inHandSalaryPaise),
                fixedExpensesTotal: Money.fromPaise(r.fixedExpensesPaise),
                savingsTargetAmount: Money.fromPaise(r.savingsTargetPaise),
                rolloverStrategy: const DynamicSmoothingStrategy(),
              ))
          .toList();
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Archives a completed cycle.
  Future<void> archiveCycle(String cycleId) async {
    try {
      await (db.update(db.cyclesTable)..where((tbl) => tbl.id.equals(cycleId)))
          .write(const CyclesTableCompanion(isArchived: Value(true)));
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }

  /// Retrieves read-only details of an archived cycle including its budgets and transactions.
  Future<({BudgetCycle cycle, List<DailyBudget> budgets, List<Transaction> transactions})?>
      getCycleHistoryDetails(String cycleId) async {
    try {
      final cycleRows = await (db.select(db.cyclesTable)
            ..where((tbl) => tbl.id.equals(cycleId)))
          .get();
      if (cycleRows.isEmpty) return null;
      final cRow = cycleRows.first;

      final cycle = BudgetCycle(
        id: cRow.id,
        startDate: cRow.startDate,
        endDate: cRow.endDate,
        totalDays: cRow.totalDays,
        paydayDay: cRow.paydayDay,
        salaryReceivedDate: cRow.salaryReceivedDate,
        inHandSalary: Money.fromPaise(cRow.inHandSalaryPaise),
        fixedExpensesTotal: Money.fromPaise(cRow.fixedExpensesPaise),
        savingsTargetAmount: Money.fromPaise(cRow.savingsTargetPaise),
        rolloverStrategy: const DynamicSmoothingStrategy(),
      );

      final budgetRows = await (db.select(db.dailyBudgetsTable)
            ..where((tbl) => tbl.cycleId.equals(cycleId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.dayIndex)]))
          .get();

      final budgets = budgetRows
          .map((b) => DailyBudget(
                id: b.id,
                cycleId: b.cycleId,
                date: b.date,
                dayIndex: b.dayIndex,
                allocatedBudget: Money.fromPaise(b.allocatedBudgetPaise),
                actualSpent: Money.fromPaise(b.actualSpentPaise),
                isClosed: b.isClosed,
              ))
          .toList();

      final txRows = await (db.select(db.transactionsTable)
            ..where((tbl) => tbl.cycleId.equals(cycleId))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
          .get();

      final transactions = txRows
          .map((t) => Transaction(
                id: t.id,
                cycleId: t.cycleId,
                amount: Money.fromPaise(t.amountPaise),
                title: t.title,
                category: TransactionCategory.values.firstWhere(
                  (c) => c.name == t.category,
                  orElse: () => TransactionCategory.other,
                ),
                timestamp: t.timestamp,
                source: TransactionSource.values.firstWhere(
                  (s) => s.name == t.source,
                  orElse: () => TransactionSource.manual,
                ),
                isFixedExpense: t.isFixedExpense,
                type: TransactionType.values.firstWhere(
                  (tp) => tp.name == t.transactionType,
                  orElse: () => TransactionType.expense,
                ),
                dedupeKey: t.dedupeKey,
                earnedXp: t.earnedXp,
                earnedCoins: t.earnedCoins,
                splitTotal: t.splitTotalPaise != null
                    ? Money.fromPaise(t.splitTotalPaise!)
                    : null,
                splitUserShare: t.splitUserSharePaise != null
                    ? Money.fromPaise(t.splitUserSharePaise!)
                    : null,
                pendingReimbursement: t.pendingReimbursementPaise != null
                    ? Money.fromPaise(t.pendingReimbursementPaise!)
                    : null,
                isReimbursement: t.isReimbursement,
                parentTransactionId: t.parentTransactionId,
              ))
          .toList();

      return (
        cycle: cycle,
        budgets: budgets,
        transactions: transactions,
      );
    } catch (e, st) {
      _handleDbError(e, st);
    }
  }
}
