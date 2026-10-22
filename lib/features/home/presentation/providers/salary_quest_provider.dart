import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:salary_quest/core/database/app_database.dart';
import 'package:salary_quest/core/database/salary_quest_repository.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/services/backup_restore_service.dart';
import 'package:salary_quest/core/services/clock_integrity_service.dart';
import 'package:salary_quest/core/services/local_security_service.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/budget_validation_exception.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_date_calculator.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_manager_service.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/models/duplicate_transaction_exception.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_deduplication_service.dart';
import 'package:salary_quest/features/transactions/domain/services/fixed_expense_matcher.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_event_recomputer.dart';
import 'package:salary_quest/features/gamification/domain/models/achievement.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/gamification/domain/models/quest.dart';
import 'package:salary_quest/features/gamification/domain/services/achievement_engine.dart';
import 'package:salary_quest/features/gamification/domain/services/gamification_engine.dart';
import 'package:salary_quest/features/savings_goals/domain/models/savings_goal.dart';
import 'package:salary_quest/features/notifications/domain/models/notification_alert.dart';
import 'package:salary_quest/features/notifications/domain/models/notification_preferences.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_service_interface.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_manager.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_alert_factory.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_policy_engine.dart';
import 'package:salary_quest/features/notifications/infrastructure/flutter_local_notification_service.dart';

class SalaryQuestState {
  final BudgetCycle cycle;
  final List<DailyBudget> dailyBudgets;
  final int currentDayIndex; // 1 to totalDays
  final List<Transaction> transactions;
  final HeroCharacter hero;
  final List<DailyQuest> quests;
  final int bossCurrentHp;
  final int bossMaxHp;
  final bool isClockManipulated;
  final bool isSeriousMode;
  final bool isBiometricLockEnabled;
  final bool isReduceMotion;
  final bool isAuthenticated;
  final bool notificationsEnabled;
  final int maxNotificationsPerDay;
  final NotificationPreferences notificationPreferences;
  final List<SavingsGoal> savingsGoals;
  final bool isAutoFlowSavingsEnabled;
  final String? autoFlowGoalId;
  final List<Achievement> achievements;
  final bool isOnboarded;
  final String languageCode;

  const SalaryQuestState({
    required this.cycle,
    required this.dailyBudgets,
    required this.currentDayIndex,
    required this.transactions,
    required this.hero,
    required this.quests,
    required this.bossCurrentHp,
    required this.bossMaxHp,
    this.isClockManipulated = false,
    this.isSeriousMode = false,
    this.isBiometricLockEnabled = false,
    this.isReduceMotion = false,
    this.isAuthenticated = true,
    this.notificationsEnabled = true,
    this.maxNotificationsPerDay = 2,
    this.notificationPreferences = const NotificationPreferences(),
    this.savingsGoals = const [],
    this.isAutoFlowSavingsEnabled = false,
    this.autoFlowGoalId,
    this.achievements = const [],
    this.isOnboarded = true,
    this.languageCode = 'en',
  });

  DailyBudget get todayBudget {
    final idx = currentDayIndex - 1;
    if (idx >= 0 && idx < dailyBudgets.length) {
      return dailyBudgets[idx];
    }
    if (dailyBudgets.isNotEmpty) {
      return dailyBudgets.first;
    }
    return DailyBudget(
      id: 'fallback_today',
      cycleId: cycle.id,
      date: DateTime.now(),
      dayIndex: 1,
      allocatedBudget: cycle.baseDailyBudget,
    );
  }

  Money get totalDiscretionarySpent {
    int totalPaise = 0;
    for (final tx in transactions) {
      if (!tx.type.affectsDailyBudget || tx.isFixedExpense) continue;
      if (tx.type == TransactionType.refund ||
          (tx.type == TransactionType.splitShare && tx.isReimbursement)) {
        totalPaise -= tx.amount.paise;
      } else {
        totalPaise += tx.amount.paise;
      }
    }
    return Money.fromPaise(totalPaise);
  }

  Money get accumulatedSurplus {
    return BudgetCalculator.calculateTotalSurplus(
        dailyBudgets, currentDayIndex);
  }

  Money get remainingCyclePool =>
      cycle.discretionaryPool - totalDiscretionarySpent;

  bool get isCycleInDeficit => remainingCyclePool.isNegative;

  Money get cycleDebt =>
      isCycleInDeficit ? remainingCyclePool.abs() : const Money.zero();

  SalaryQuestState copyWith({
    BudgetCycle? cycle,
    List<DailyBudget>? dailyBudgets,
    int? currentDayIndex,
    List<Transaction>? transactions,
    HeroCharacter? hero,
    List<DailyQuest>? quests,
    int? bossCurrentHp,
    int? bossMaxHp,
    bool? isClockManipulated,
    bool? isSeriousMode,
    bool? isBiometricLockEnabled,
    bool? isReduceMotion,
    bool? isAuthenticated,
    bool? notificationsEnabled,
    int? maxNotificationsPerDay,
    NotificationPreferences? notificationPreferences,
    List<SavingsGoal>? savingsGoals,
    bool? isAutoFlowSavingsEnabled,
    String? autoFlowGoalId,
    List<Achievement>? achievements,
    bool? isOnboarded,
    String? languageCode,
  }) {
    return SalaryQuestState(
      cycle: cycle ?? this.cycle,
      dailyBudgets: dailyBudgets ?? this.dailyBudgets,
      currentDayIndex: currentDayIndex ?? this.currentDayIndex,
      transactions: transactions ?? this.transactions,
      hero: hero ?? this.hero,
      quests: quests ?? this.quests,
      bossCurrentHp: bossCurrentHp ?? this.bossCurrentHp,
      bossMaxHp: bossMaxHp ?? this.bossMaxHp,
      isClockManipulated: isClockManipulated ?? this.isClockManipulated,
      isSeriousMode: isSeriousMode ?? this.isSeriousMode,
      isBiometricLockEnabled:
          isBiometricLockEnabled ?? this.isBiometricLockEnabled,
      isReduceMotion: isReduceMotion ?? this.isReduceMotion,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      maxNotificationsPerDay:
          maxNotificationsPerDay ?? this.maxNotificationsPerDay,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      savingsGoals: savingsGoals ?? this.savingsGoals,
      isAutoFlowSavingsEnabled:
          isAutoFlowSavingsEnabled ?? this.isAutoFlowSavingsEnabled,
      autoFlowGoalId: autoFlowGoalId ?? this.autoFlowGoalId,
      achievements: achievements ?? this.achievements,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class SalaryQuestNotifier extends StateNotifier<SalaryQuestState> {
  final SalaryQuestRepository? _repository;
  DateTime? _lastKnownDeviceTimestamp;
  late final NotificationManager notificationManager;
  bool _isOnboardingInProgressOrDone = false;

  SalaryQuestNotifier({
    SalaryQuestRepository? repository,
    INotificationService? notificationService,
  })  : _repository = repository,
        super(_buildInitialState()) {
    notificationManager = NotificationManager(
      service: notificationService ?? FlutterLocalNotificationService(),
      preferences: state.notificationPreferences,
    );
    _initPersistenceAndCatchUp();
  }

  Future<void> _initPersistenceAndCatchUp() async {
    final repo = _repository;
    if (repo == null) return;
    try {
      final savedState = await repo.loadPersistedState();
      final now = DateTime.now();

      if (savedState != null) {
        final currentDay = savedState.cycle.currentDayIndex(now);
        final caughtUpBudgets = CycleManagerService.catchUpMissedDays(
          cycle: savedState.cycle,
          budgets: savedState.dailyBudgets,
          lastKnownDayIndex: savedState.currentDayIndex,
          currentDayIndex: currentDay,
        );

        state = savedState.copyWith(
          currentDayIndex: currentDay,
          dailyBudgets: caughtUpBudgets,
          isAuthenticated: !savedState.isBiometricLockEnabled,
          isOnboarded: true,
        );
      } else {
        // App is opened for the first time on a fresh device!
        // Direct the user to OnboardingScreen if onboarding hasn't been completed in the meantime.
        if (!_isOnboardingInProgressOrDone) {
          state = state.copyWith(isOnboarded: false);
        }
      }
      _lastKnownDeviceTimestamp = now;
    } catch (_) {
      // In-memory fallback
    }
  }

  static SalaryQuestState _buildInitialState() {
    final now = DateTime.now();

    final cycle = BudgetCycle.createValidated(
      id: 'cycle_${now.year}_${now.month}',
      year: now.year,
      month: now.month,
      paydayDay: 25,
      inHandSalary: Money.fromRupees(60000),
      fixedExpensesTotal: Money.fromRupees(25000),
      savingsTargetAmount: Money.fromRupees(15000),
    );

    final initialBudgets =
        BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);
    final currentDay = cycle.currentDayIndex(now);

    final targetRupees = cycle.savingsTargetAmount.inWholeRupees > 0
        ? cycle.savingsTargetAmount.inWholeRupees
        : cycle.discretionaryPool.inWholeRupees;

    return SalaryQuestState(
      cycle: cycle,
      dailyBudgets: initialBudgets,
      currentDayIndex: currentDay,
      transactions: const [],
      hero: const HeroCharacter(
        name: 'Aero',
        archetype: HeroArchetype.knight,
        level: 3,
        currentXp: 180,
        maxXp: 440,
        currentHp: 88,
        coins: 120,
        streakDays: 4,
      ),
      quests: GamificationEngine.getStarterQuests(),
      bossCurrentHp: targetRupees,
      bossMaxHp: targetRupees,
    );
  }

  Future<void> addTransaction({
    required Money amount,
    required String title,
    required TransactionCategory category,
    DateTime? customTimestamp,
    TransactionSource source = TransactionSource.manual,
    TransactionType type = TransactionType.expense,
    bool? isFixedExpense,
    Money? splitTotal,
    Money? splitUserShare,
    bool isReimbursement = false,
    String? parentTransactionId,
    bool allowDuplicates = false,
    String? explicitDedupeKey,
  }) async {
    if (amount.paise <= 0) return;

    final txTimestamp = customTimestamp ?? DateTime.now();

    final dedupeKey = explicitDedupeKey ??
        TransactionDeduplicationService.computeDedupeKey(
          amount: amount,
          timestamp: txTimestamp,
          merchant: title,
          source: source,
        );

    // 1. Deduplication check (within 10-minute window for same amount & merchant, OR matching dedupeKey)
    if (!allowDuplicates &&
        TransactionDeduplicationService.isDuplicate(
          amount: amount,
          timestamp: txTimestamp,
          merchant: title,
          existingTransactions: state.transactions,
          explicitDedupeKey: dedupeKey,
        )) {
      throw const DuplicateTransactionException(
        'Duplicate transaction rejected: a transaction with identical amount and merchant was recorded within 10 minutes.',
      );
    }

    // 2. Fixed expense detection (auto-tag if not explicitly specified)
    final effectiveFixedExpense =
        isFixedExpense ?? FixedExpenseMatcher.isLikelyFixedExpense(title);

    // 3. Clock integrity check
    final isTampered = ClockIntegrityService.isClockManipulated(
      currentTimestamp: txTimestamp,
      lastKnownTimestamp: _lastKnownDeviceTimestamp,
    );

    if (!isTampered &&
        (customTimestamp == null ||
            txTimestamp.isAfter(_lastKnownDeviceTimestamp ?? DateTime(2000)))) {
      _lastKnownDeviceTimestamp = txTimestamp;
    }

    // 4. Calculate earned XP with anti-farming limit (cap at 3 transactions/day, max 45 XP/day)
    final targetDayIndex = CycleDateCalculator.getDayIndexForTimestamp(
      timestamp: txTimestamp,
      cycleStartDate: state.cycle.startDate,
      totalDays: state.cycle.totalDays,
    );

    final existingLoggingXpCount = state.transactions.where((t) {
      final dayIdx = CycleDateCalculator.getDayIndexForTimestamp(
        timestamp: t.timestamp,
        cycleStartDate: state.cycle.startDate,
        totalDays: state.cycle.totalDays,
      );
      return dayIdx == targetDayIndex && t.earnedXp > 0;
    }).length;

    final int earnedXp = (!isTampered &&
            type == TransactionType.expense &&
            !effectiveFixedExpense &&
            existingLoggingXpCount < 3)
        ? 15
        : 0;

    final newTx = Transaction(
      id: const Uuid().v4(),
      cycleId: state.cycle.id,
      amount: amount,
      title: title,
      category: category,
      timestamp: txTimestamp,
      source: source,
      isFixedExpense: effectiveFixedExpense,
      type: type,
      dedupeKey: dedupeKey,
      earnedXp: earnedXp,
      earnedCoins: 0,
      splitTotal: splitTotal,
      splitUserShare: splitUserShare,
      pendingReimbursement: (splitTotal != null && splitUserShare != null)
          ? (splitTotal - splitUserShare)
          : null,
      isReimbursement: isReimbursement,
      parentTransactionId: parentTransactionId,
    );

    final updatedTxList = [newTx, ...state.transactions];

    // 5. Event-sourced recompute of all daily budgets & Boss HP
    final recompute = TransactionEventRecomputer.recompute(
      cycle: state.cycle,
      transactions: updatedTxList,
      currentDayIndex: state.currentDayIndex,
    );

    // 6. Gamification updates
    final todaySpentRatio =
        recompute.budgets[state.currentDayIndex - 1].spentRatio;
    var updatedHero = GamificationEngine.evaluateDailyHealthImpact(
      hero: state.hero,
      spentRatio: todaySpentRatio,
    );

    if (earnedXp > 0) {
      updatedHero = GamificationEngine.awardXp(updatedHero, earnedXp);
    }

    final updatedQuests = state.quests.map((quest) {
      if (quest.type == QuestType.logExpense &&
          !quest.isCompleted &&
          !effectiveFixedExpense &&
          type == TransactionType.expense) {
        return quest.copyWith(
          progressValue: 1.0,
          isCompleted: true,
        );
      }
      return quest;
    }).toList();

    state = state.copyWith(
      transactions: recompute.updatedTransactions,
      dailyBudgets: recompute.budgets,
      hero: updatedHero,
      quests: updatedQuests,
      bossCurrentHp: recompute.bossHp,
      isClockManipulated: isTampered,
    );

    // Evaluate 80% daily budget warning
    final today = state.todayBudget;
    if (today.allocatedBudget.paise > 0 &&
        today.actualSpent.paise >= (today.allocatedBudget.paise * 0.8)) {
      final alert = NotificationAlertFactory.createBudget80Alert(
        todayBudget: today,
        now: txTimestamp,
      );
      await notificationManager.dispatchAlert(alert: alert, now: txTimestamp);
    }

    final repo = _repository;
    if (repo != null) {
      await repo.recordTransaction(
        transaction: newTx,
        rebalancedBudgets: recompute.budgets,
        hero: updatedHero,
        quests: updatedQuests,
        newBossHp: recompute.bossHp,
      );
    }
  }

  /// Deletes a transaction and triggers an event-sourced recomputation of downstream days,
  /// cleanly rolling back any XP and coins earned from the deleted transaction.
  Future<Transaction?> deleteTransaction(String transactionId) async {
    final txIndex =
        state.transactions.indexWhere((t) => t.id == transactionId);
    if (txIndex == -1) return null;

    final txToDelete = state.transactions[txIndex];
    final updatedTxList =
        state.transactions.where((t) => t.id != transactionId).toList();

    // Revert gamification awards earned from this transaction (preserving level floor)
    var updatedHero = state.hero;
    if (txToDelete.earnedXp > 0) {
      updatedHero =
          GamificationEngine.revertXp(updatedHero, txToDelete.earnedXp);
    }
    if (txToDelete.earnedCoins > 0) {
      final newCoins =
          (updatedHero.coins - txToDelete.earnedCoins).clamp(0, 999999);
      updatedHero = updatedHero.copyWith(coins: newCoins);
    }

    // Event-sourced recompute from remaining transactions
    final recompute = TransactionEventRecomputer.recompute(
      cycle: state.cycle,
      transactions: updatedTxList,
      currentDayIndex: state.currentDayIndex,
    );

    // If no expense transactions remain today, revert logExpense quest progress
    final hasExpenseToday = updatedTxList.any((t) =>
        !t.isFixedExpense &&
        t.type == TransactionType.expense &&
        CycleDateCalculator.getDayIndexForTimestamp(
              timestamp: t.timestamp,
              cycleStartDate: state.cycle.startDate,
              totalDays: state.cycle.totalDays,
            ) ==
            state.currentDayIndex);

    final updatedQuests = state.quests.map((q) {
      if (q.type == QuestType.logExpense && !hasExpenseToday && !q.isClaimed) {
        return q.copyWith(progressValue: 0.0, isCompleted: false);
      }
      return q;
    }).toList();

    state = state.copyWith(
      transactions: recompute.updatedTransactions,
      dailyBudgets: recompute.budgets,
      hero: updatedHero,
      quests: updatedQuests,
      bossCurrentHp: recompute.bossHp,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.deleteTransaction(
        transactionId: transactionId,
        cycleId: state.cycle.id,
        rebalancedBudgets: recompute.budgets,
        hero: updatedHero,
        newBossHp: recompute.bossHp,
      );
    }
    return txToDelete;
  }

  /// Restores a previously deleted transaction (Undo), recomputing budgets and restoring awards.
  Future<void> restoreDeletedTransaction(Transaction tx) async {
    final updatedTxList = [tx, ...state.transactions];

    var updatedHero = state.hero;
    if (tx.earnedXp > 0) {
      updatedHero = GamificationEngine.awardXp(updatedHero, tx.earnedXp);
    }
    if (tx.earnedCoins > 0) {
      updatedHero =
          updatedHero.copyWith(coins: updatedHero.coins + tx.earnedCoins);
    }

    final recompute = TransactionEventRecomputer.recompute(
      cycle: state.cycle,
      transactions: updatedTxList,
      currentDayIndex: state.currentDayIndex,
    );

    state = state.copyWith(
      transactions: recompute.updatedTransactions,
      dailyBudgets: recompute.budgets,
      hero: updatedHero,
      bossCurrentHp: recompute.bossHp,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.recordTransaction(
        transaction: tx,
        rebalancedBudgets: recompute.budgets,
        hero: updatedHero,
        quests: state.quests,
        newBossHp: recompute.bossHp,
      );
    }
  }

  /// Edits an existing transaction and recalculates all downstream budgets.
  Future<void> editTransaction(Transaction updatedTx) async {
    final updatedTxList = state.transactions.map((t) {
      return t.id == updatedTx.id ? updatedTx : t;
    }).toList();

    final recompute = TransactionEventRecomputer.recompute(
      cycle: state.cycle,
      transactions: updatedTxList,
      currentDayIndex: state.currentDayIndex,
    );

    state = state.copyWith(
      transactions: recompute.updatedTransactions,
      dailyBudgets: recompute.budgets,
      bossCurrentHp: recompute.bossHp,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.recordTransaction(
        transaction: updatedTx,
        rebalancedBudgets: recompute.budgets,
        hero: state.hero,
        quests: state.quests,
        newBossHp: recompute.bossHp,
      );
    }
  }

  /// Records a reimbursement for a split bill, reducing spending and updating pending amount.
  Future<void> recordSplitReimbursement({
    required String parentTransactionId,
    required Money reimbursementAmount,
    String? note,
    DateTime? customTimestamp,
  }) async {
    await addTransaction(
      amount: reimbursementAmount,
      title: note ?? 'Split Reimbursement',
      category: TransactionCategory.other,
      type: TransactionType.splitShare,
      isReimbursement: true,
      parentTransactionId: parentTransactionId,
      customTimestamp: customTimestamp,
    );
  }

  Future<void> addExtraIncome({
    required Money amount,
    required String sourceTitle,
  }) async {
    if (amount.paise <= 0) return;

    final result = CycleManagerService.injectExtraIncome(
      currentCycle: state.cycle,
      currentBudgets: state.dailyBudgets,
      currentDayIndex: state.currentDayIndex,
      extraIncome: amount,
    );

    final incomeTx = Transaction(
      id: const Uuid().v4(),
      cycleId: state.cycle.id,
      amount: amount,
      title: sourceTitle.isEmpty ? 'Extra Income / Bonus' : sourceTitle,
      category: TransactionCategory.other,
      timestamp: DateTime.now(),
      type: TransactionType.income,
      source: TransactionSource.manual,
    );

    final updatedTxList = [incomeTx, ...state.transactions];
    final newBossHp = (state.bossCurrentHp + amount.inWholeRupees)
        .clamp(0, result.updatedCycle.discretionaryPool.inWholeRupees);

    state = state.copyWith(
      cycle: result.updatedCycle,
      dailyBudgets: result.updatedBudgets,
      transactions: updatedTxList,
      bossCurrentHp: newBossHp,
      bossMaxHp: result.updatedCycle.discretionaryPool.inWholeRupees,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.saveCycleAndBudgets(
        cycle: result.updatedCycle,
        dailyBudgets: result.updatedBudgets,
        hero: state.hero,
        quests: state.quests,
      );
    }
  }

  Future<void> updateSalarySetup({
    required Money inHandSalary,
    required Money fixedExpenses,
    required Money savingsTarget,
    int? paydayDay,
    DateTime? salaryReceivedDate,
  }) async {
    final now = DateTime.now();
    final effectivePayday = paydayDay ?? state.cycle.paydayDay;
    final paydayChanged = effectivePayday != state.cycle.paydayDay;

    final validationError = BudgetCycle.validateInputs(
      inHandSalary: inHandSalary,
      fixedExpenses: fixedExpenses,
      savingsTarget: savingsTarget,
    );
    if (validationError != null) {
      throw BudgetValidationException(validationError);
    }

    if (paydayChanged) {
      final activeDates = CycleDateCalculator.computeActiveCycleDates(
        now: now,
        paydayDay: effectivePayday,
        salaryReceivedDate: salaryReceivedDate ?? state.cycle.salaryReceivedDate,
      );

      final newCycle = BudgetCycle.createValidated(
        id: 'cycle_${activeDates.cycleYear}_${activeDates.cycleMonth}_$effectivePayday',
        year: activeDates.cycleYear,
        month: activeDates.cycleMonth,
        paydayDay: effectivePayday,
        salaryReceivedDate: salaryReceivedDate ?? state.cycle.salaryReceivedDate,
        inHandSalary: inHandSalary,
        fixedExpensesTotal: fixedExpenses,
        savingsTargetAmount: savingsTarget,
      );

      final newBudgets =
          BudgetCalculator.generateInitialCycleBudgets(cycle: newCycle);
      final newCurrentDay = newCycle.currentDayIndex(now);

      final poolInt = newCycle.discretionaryPool.inWholeRupees;
      final targetInt = newCycle.savingsTargetAmount.inWholeRupees > 0
          ? newCycle.savingsTargetAmount.inWholeRupees
          : poolInt;

      state = state.copyWith(
        cycle: newCycle,
        dailyBudgets: newBudgets,
        currentDayIndex: newCurrentDay,
        bossMaxHp: targetInt,
        bossCurrentHp: targetInt,
      );

      final repo = _repository;
      if (repo != null) {
        await repo.saveCycleAndBudgets(
          cycle: newCycle,
          dailyBudgets: newBudgets,
          hero: state.hero,
          quests: state.quests,
        );
      }
      return;
    }

    final result = CycleManagerService.recalculateMidCycle(
      currentCycle: state.cycle.copyWith(
        paydayDay: effectivePayday,
        salaryReceivedDate: salaryReceivedDate ?? state.cycle.salaryReceivedDate,
      ),
      currentBudgets: state.dailyBudgets,
      currentDayIndex: state.currentDayIndex,
      newSalary: inHandSalary,
      newFixedExpenses: fixedExpenses,
      newSavingsTarget: savingsTarget,
    );

    final currentDay = result.updatedCycle.currentDayIndex(now);
    final poolInt = result.updatedCycle.discretionaryPool.inWholeRupees;
    final targetInt = result.updatedCycle.savingsTargetAmount.inWholeRupees > 0
        ? result.updatedCycle.savingsTargetAmount.inWholeRupees
        : poolInt;

    state = state.copyWith(
      cycle: result.updatedCycle,
      currentDayIndex: currentDay,
      dailyBudgets: result.updatedBudgets,
      bossMaxHp: targetInt,
      bossCurrentHp: targetInt.clamp(0, state.bossCurrentHp),
    );

    final repo = _repository;
    if (repo != null) {
      await repo.saveCycleAndBudgets(
        cycle: result.updatedCycle,
        dailyBudgets: result.updatedBudgets,
        hero: state.hero,
        quests: state.quests,
      );
    }
  }

  void markSalaryReceivedDate(DateTime date) {
    updateSalarySetup(
      inHandSalary: state.cycle.inHandSalary,
      fixedExpenses: state.cycle.fixedExpensesTotal,
      savingsTarget: state.cycle.savingsTargetAmount,
      paydayDay: state.cycle.paydayDay,
      salaryReceivedDate: date,
    );
  }

  Future<void> claimQuestReward(String questId) async {
    DailyQuest? claimedQuest;
    final updatedQuests = state.quests.map((q) {
      if (q.id == questId && q.isCompleted && !q.isClaimed) {
        claimedQuest = q;
        return q.copyWith(isClaimed: true);
      }
      return q;
    }).toList();

    if (claimedQuest != null) {
      var updatedHero = GamificationEngine.awardXp(
        state.hero,
        claimedQuest!.rewardXp,
      );

      // Fainted state penalty: reduces coin earnings by 50%
      final effectiveCoins = GamificationEngine.calculateQuestCoinReward(
        state.hero,
        claimedQuest!.rewardCoins,
      );

      // Soft recovery: restore HP if quest provides an HP reward
      int effectiveHp = updatedHero.currentHp;
      if (claimedQuest!.rewardHp > 0) {
        effectiveHp = (effectiveHp + claimedQuest!.rewardHp).clamp(0, updatedHero.maxHp);
      }

      updatedHero = updatedHero.copyWith(
        coins: updatedHero.coins + effectiveCoins,
        currentHp: effectiveHp,
      );

      state = state.copyWith(
        quests: updatedQuests,
        hero: updatedHero,
      );

      final repo = _repository;
      if (repo != null) {
        await repo.saveCycleAndBudgets(
          cycle: state.cycle,
          dailyBudgets: state.dailyBudgets,
          hero: updatedHero,
          quests: updatedQuests,
        );
      }
    }
  }

  /// Repairs broken streak using 50 coins and the cycle's streak shield.
  Future<void> repairStreakWithCoins() async {
    final updatedHero = GamificationEngine.repairStreak(state.hero);
    state = state.copyWith(hero: updatedHero);

    final repo = _repository;
    if (repo != null) {
      await repo.saveHeroState(updatedHero);
    }
  }

  /// Toggles serious minimalist mode on/off.
  Future<void> toggleSeriousMode(bool enabled) async {
    state = state.copyWith(isSeriousMode: enabled);

    final repo = _repository;
    if (repo != null) {
      await repo.saveSeriousMode(enabled);
    }
  }

  /// Updates notification preferences across domain manager and state.
  Future<void> updateNotificationPreferences(
      NotificationPreferences prefs) async {
    notificationManager.updatePreferences(prefs);
    state = state.copyWith(
      notificationPreferences: prefs,
      notificationsEnabled: prefs.enabled,
      maxNotificationsPerDay: prefs.maxPerDay,
    );
  }

  /// Evaluates policy and dispatches an alert via NotificationManager.
  Future<NotificationDecision> dispatchNotificationAlert(
    NotificationAlert alert, {
    DateTime? now,
  }) async {
    return await notificationManager.dispatchAlert(
      alert: alert,
      now: now,
    );
  }

  /// Checks and dispatches evening streak risk alert if user has not logged today
  Future<NotificationDecision?> checkEveningStreakAlert({DateTime? now}) async {
    final currentTimestamp = now ?? DateTime.now();
    final hasExpenseToday = state.transactions.any((t) =>
        !t.isFixedExpense &&
        t.type == TransactionType.expense &&
        CycleDateCalculator.getDayIndexForTimestamp(
              timestamp: t.timestamp,
              cycleStartDate: state.cycle.startDate,
              totalDays: state.cycle.totalDays,
            ) ==
            state.currentDayIndex);

    if (!hasExpenseToday && state.hero.streakDays > 0) {
      final alert = NotificationAlertFactory.createStreakAtRiskAlert(
        hero: state.hero,
        now: currentTimestamp,
      );
      return await notificationManager.dispatchAlert(
        alert: alert,
        now: currentTimestamp,
      );
    }
    return null;
  }

  /// Checks and dispatches end-of-day cash reminder
  Future<NotificationDecision> checkCashReminderAlert({DateTime? now}) async {
    final currentTimestamp = now ?? DateTime.now();
    final alert = NotificationAlertFactory.createCashReminderAlert(
      now: currentTimestamp,
    );
    return await notificationManager.dispatchAlert(
      alert: alert,
      now: currentTimestamp,
    );
  }

  /// Toggles notifications on/off.
  void toggleNotifications(bool enabled) {
    final updatedPrefs =
        state.notificationPreferences.copyWith(enabled: enabled);
    updateNotificationPreferences(updatedPrefs);
  }

  /// Sets maximum notifications permitted per day (e.g. 1 to 5).
  void setMaxNotificationsPerDay(int count) {
    final updatedPrefs = state.notificationPreferences
        .copyWith(maxPerDay: count.clamp(1, 5));
    updateNotificationPreferences(updatedPrefs);
  }

  /// Toggles biometric lock on app resume.
  Future<void> toggleBiometricLock(bool enabled) async {
    state = state.copyWith(isBiometricLockEnabled: enabled);

    final repo = _repository;
    if (repo != null) {
      await repo.saveBiometricLock(enabled);
    }
  }

  /// Toggles accessibility reduce motion mode.
  Future<void> toggleReduceMotion(bool enabled) async {
    state = state.copyWith(isReduceMotion: enabled);

    final repo = _repository;
    if (repo != null) {
      await repo.saveReducedMotion(enabled);
    }
  }

  /// Sets current authenticated session status.
  void setAuthenticated(bool authenticated) {
    state = state.copyWith(isAuthenticated: authenticated);
  }

  /// Catches up missed days and midnight rollover when returning from background.
  Future<void> catchUpOnResume() async {
    final now = DateTime.now();
    final currentDay = state.cycle.currentDayIndex(now);
    if (currentDay > state.currentDayIndex) {
      final caughtUpBudgets = CycleManagerService.catchUpMissedDays(
        cycle: state.cycle,
        budgets: state.dailyBudgets,
        lastKnownDayIndex: state.currentDayIndex,
        currentDayIndex: currentDay,
      );

      state = state.copyWith(
        currentDayIndex: currentDay,
        dailyBudgets: caughtUpBudgets,
      );

      final repo = _repository;
      if (repo != null) {
        await repo.saveCycleAndBudgets(
          cycle: state.cycle,
          dailyBudgets: caughtUpBudgets,
          hero: state.hero,
          quests: state.quests,
        );
      }
      evaluateConsecutiveOverspends();
    }
  }

  /// Evaluates whether the user has had 10 consecutive overspend days.
  /// If triggered, injects a Soft Recovery / Fresh Start Quest to break the penalty loop,
  /// preserving hero level via Level Floor protection.
  void evaluateConsecutiveOverspends() {
    int consecutive = 0;
    int maxConsecutive = 0;
    final checkLimit =
        state.currentDayIndex.clamp(0, state.dailyBudgets.length);
    for (int i = 0; i < checkLimit; i++) {
      final b = state.dailyBudgets[i];
      if (b.actualSpent > b.allocatedBudget) {
        consecutive++;
        if (consecutive > maxConsecutive) {
          maxConsecutive = consecutive;
        }
      } else if (i < state.currentDayIndex - 1) {
        // Reset only if an earlier completed day was within budget
        consecutive = 0;
      }
    }

    final triggerCount =
        consecutive > maxConsecutive ? consecutive : maxConsecutive;
    final recoveryQuest = GamificationEngine.checkSoftRecoveryTrigger(
      consecutiveOverspendDays: triggerCount,
      hero: state.hero,
    );

    if (recoveryQuest != null &&
        !state.quests.any((q) => q.id == recoveryQuest.id)) {
      state = state.copyWith(
        quests: [recoveryQuest, ...state.quests],
      );
    }
  }

  /// Purchases a Hero Skin using coins. Coins cannot go negative.
  Future<bool> purchaseHeroSkin(String skinId, int cost) async {
    if (!state.hero.canAfford(cost) ||
        state.hero.unlockedSkins.contains(skinId)) {
      return false;
    }

    final updatedHero = state.hero.purchaseSkin(skinId, cost);
    state = state.copyWith(hero: updatedHero);

    _evaluateAchievements();

    final repo = _repository;
    if (repo != null) {
      await repo.saveHeroState(updatedHero);
    }
    return true;
  }

  /// Equips an already unlocked Hero Skin.
  Future<void> equipHeroSkin(String skinId) async {
    final updatedHero = state.hero.equipSkin(skinId);
    state = state.copyWith(hero: updatedHero);

    final repo = _repository;
    if (repo != null) {
      await repo.saveHeroState(updatedHero);
    }
  }

  /// Purchases a UI Theme using coins. Coins cannot go negative.
  Future<bool> purchaseTheme(String themeId, int cost) async {
    if (!state.hero.canAfford(cost) ||
        state.hero.unlockedThemes.contains(themeId)) {
      return false;
    }

    final updatedHero = state.hero.purchaseTheme(themeId, cost);
    state = state.copyWith(hero: updatedHero);

    _evaluateAchievements();

    final repo = _repository;
    if (repo != null) {
      await repo.saveHeroState(updatedHero);
    }
    return true;
  }

  /// Equips an already unlocked UI Theme.
  Future<void> equipTheme(String themeId) async {
    final updatedHero = state.hero.equipTheme(themeId);
    state = state.copyWith(hero: updatedHero);

    final repo = _repository;
    if (repo != null) {
      await repo.saveHeroState(updatedHero);
    }
  }

  /// Helper to evaluate achievements and persist any newly earned badges.
  void _evaluateAchievements() {
    final newBadges = AchievementEngine.evaluate(
      currentUnlocked: state.achievements,
      transactions: state.transactions,
      hero: state.hero,
      dailyBudgets: state.dailyBudgets,
      savingsGoals: state.savingsGoals,
      cycle: state.cycle,
      bossCurrentHp: state.bossCurrentHp,
    );

    if (newBadges.isNotEmpty) {
      final updatedList = List<Achievement>.from(state.achievements)
        ..addAll(newBadges);
      state = state.copyWith(achievements: updatedList);

      final repo = _repository;
      if (repo != null) {
        for (final b in newBadges) {
          repo.unlockAchievement(b);
        }
      }
    }
  }

  /// Concludes cycle and claims monthly Boss battle outcome and rewards.
  /// If Boss HP <= 0: Victory! Awards +500 XP, +200 Coins, unlocks 'boss_defeated' badge.
  Future<bool> claimBossBattleResult() async {
    final isDefeated = state.bossCurrentHp <= 0;
    if (!isDefeated) return false;

    HeroCharacter updatedHero = GamificationEngine.awardXp(state.hero, 500);
    updatedHero = updatedHero.copyWith(coins: updatedHero.coins + 200);

    state = state.copyWith(hero: updatedHero);
    _evaluateAchievements();

    final repo = _repository;
    if (repo != null) {
      await repo.saveHeroState(updatedHero);
    }
    return true;
  }

  /// Advances to next cycle: archives the current cycle, resets Boss HP to new savings target.
  Future<void> advanceToNextCycle({
    required int nextMonth,
    required int nextYear,
  }) async {
    final repo = _repository;
    if (repo != null) {
      await repo.archiveCycle(state.cycle.id);
    }

    final newCycle = BudgetCycle.createValidated(
      id: 'cycle_${nextYear}_$nextMonth',
      year: nextYear,
      month: nextMonth,
      paydayDay: state.cycle.paydayDay,
      inHandSalary: state.cycle.inHandSalary,
      fixedExpensesTotal: state.cycle.fixedExpensesTotal,
      savingsTargetAmount: state.cycle.savingsTargetAmount,
    );

    final newBudgets =
        BudgetCalculator.generateInitialCycleBudgets(cycle: newCycle);
    final targetRupees = newCycle.savingsTargetAmount.inWholeRupees;

    state = state.copyWith(
      cycle: newCycle,
      dailyBudgets: newBudgets,
      currentDayIndex: 1,
      transactions: const [],
      bossCurrentHp: targetRupees,
      bossMaxHp: targetRupees,
    );

    if (repo != null) {
      await repo.saveCycleAndBudgets(
        cycle: newCycle,
        dailyBudgets: newBudgets,
        hero: state.hero,
        quests: state.quests,
      );
    }
  }

  /// Creates a new savings goal and saves it to persistence.
  Future<SavingsGoal> createSavingsGoal({
    required String title,
    required Money targetAmount,
    DateTime? deadline,
    String icon = '🎯',
    bool isPrimary = false,
  }) async {
    final newId = 'goal_${DateTime.now().millisecondsSinceEpoch}_${state.savingsGoals.length}';
    final List<SavingsGoal> updatedGoals = [];

    // If new goal is primary, existing goals lose primary status
    for (final g in state.savingsGoals) {
      if (isPrimary && g.isPrimary) {
        final demoted = g.copyWith(isPrimary: false);
        updatedGoals.add(demoted);
        _repository?.saveSavingsGoal(demoted);
      } else {
        updatedGoals.add(g);
      }
    }

    final newGoal = SavingsGoal(
      id: newId,
      title: title,
      targetAmount: targetAmount,
      savedAmount: const Money.zero(),
      icon: icon,
      isPrimary: isPrimary || updatedGoals.isEmpty,
      deadline: deadline,
      isCompleted: false,
    );

    updatedGoals.add(newGoal);

    state = state.copyWith(
      savingsGoals: updatedGoals,
      autoFlowGoalId: isPrimary || updatedGoals.length == 1 ? newId : state.autoFlowGoalId,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.saveSavingsGoal(newGoal);
      if (isPrimary || updatedGoals.length == 1) {
        await repo.saveAutoFlowSettings(
          enabled: state.isAutoFlowSavingsEnabled,
          goalId: newId,
        );
      }
    }

    return newGoal;
  }

  /// Deposits funds into a savings goal.
  /// When goal target is reached, awards +150 XP, +50 Coins, and unlocks Goal Crusher achievement!
  Future<void> depositToGoal({
    required String goalId,
    required Money amount,
    DateTime? customTimestamp,
  }) async {
    if (amount.paise <= 0) return;
    final effectiveNow = customTimestamp ?? DateTime.now();

    final index = state.savingsGoals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final goal = state.savingsGoals[index];
    final wasCompleted = goal.isCompleted;
    final updatedGoal = goal.deposit(amount);

    final updatedList = List<SavingsGoal>.from(state.savingsGoals);
    updatedList[index] = updatedGoal;

    HeroCharacter updatedHero = state.hero;
    List<Achievement> updatedAchievements = List.from(state.achievements);

    // Goal Completed! Award XP, Coins & Badge
    if (!wasCompleted && updatedGoal.isCompleted) {
      updatedHero = GamificationEngine.awardXp(updatedHero, 150);
      updatedHero = updatedHero.copyWith(coins: updatedHero.coins + 50);

      final badgeId = 'badge_goal_${updatedGoal.id}';
      if (!updatedAchievements.any((a) => a.id == badgeId)) {
        final achievement = Achievement(
          id: badgeId,
          title: 'Goal Crusher: ${updatedGoal.title}',
          description:
              'Successfully reached target of ${CurrencyFormatter.formatMoney(updatedGoal.targetAmount)}!',
          icon: '🏆',
          unlockedAt: effectiveNow,
        );
        updatedAchievements.add(achievement);
        _repository?.unlockAchievement(achievement);
      }

      final alert = NotificationAlertFactory.createGoalMilestoneAlert(
        goal: updatedGoal,
        milestonePercent: 100,
        now: effectiveNow,
      );
      await notificationManager.dispatchAlert(alert: alert, now: effectiveNow);
    } else if (goal.targetAmount.paise > 0 &&
        goal.savedAmount.paise < (goal.targetAmount.paise * 0.5) &&
        updatedGoal.savedAmount.paise >= (goal.targetAmount.paise * 0.5)) {
      final alert = NotificationAlertFactory.createGoalMilestoneAlert(
        goal: updatedGoal,
        milestonePercent: 50,
        now: effectiveNow,
      );
      await notificationManager.dispatchAlert(alert: alert, now: effectiveNow);
    }

    state = state.copyWith(
      savingsGoals: updatedList,
      hero: updatedHero,
      achievements: updatedAchievements,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.saveSavingsGoal(updatedGoal);
      await repo.saveHeroState(updatedHero);
    }
  }

  /// Withdraws funds from a savings goal.
  Future<void> withdrawFromGoal({
    required String goalId,
    required Money amount,
  }) async {
    if (amount.paise <= 0) return;

    final index = state.savingsGoals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final goal = state.savingsGoals[index];
    final updatedGoal = goal.withdraw(amount);

    final updatedList = List<SavingsGoal>.from(state.savingsGoals);
    updatedList[index] = updatedGoal;

    state = state.copyWith(savingsGoals: updatedList);

    final repo = _repository;
    if (repo != null) {
      await repo.saveSavingsGoal(updatedGoal);
    }
  }

  /// Deleting a goal returns accumulated saved funds to general savings / discretionary pool.
  Future<void> deleteSavingsGoal(String goalId) async {
    final index = state.savingsGoals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final goal = state.savingsGoals[index];
    final returnedPaise = goal.savedAmount.paise;

    final updatedList = List<SavingsGoal>.from(state.savingsGoals)..removeAt(index);

    String? newAutoFlowId = state.autoFlowGoalId;
    if (newAutoFlowId == goalId) {
      newAutoFlowId = updatedList.isNotEmpty ? updatedList.first.id : null;
    }

    BudgetCycle updatedCycle = state.cycle;
    if (returnedPaise > 0) {
      updatedCycle = state.cycle.copyWith(
        savingsTargetAmount: Money.fromPaise(
          (state.cycle.savingsTargetAmount.paise - returnedPaise)
              .clamp(0, double.infinity)
              .toInt(),
        ),
      );
    }

    state = state.copyWith(
      savingsGoals: updatedList,
      autoFlowGoalId: newAutoFlowId,
      cycle: updatedCycle,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.deleteSavingsGoal(goalId);
      await repo.saveAutoFlowSettings(
        enabled: state.isAutoFlowSavingsEnabled,
        goalId: newAutoFlowId,
      );
    }
  }

  /// Sets primary goal for auto-flow.
  Future<void> setPrimaryGoal(String goalId) async {
    final updatedList = state.savingsGoals.map((g) {
      return g.copyWith(isPrimary: g.id == goalId);
    }).toList();

    state = state.copyWith(
      savingsGoals: updatedList,
      autoFlowGoalId: goalId,
    );

    final repo = _repository;
    if (repo != null) {
      for (final g in updatedList) {
        await repo.saveSavingsGoal(g);
      }
      await repo.saveAutoFlowSettings(
        enabled: state.isAutoFlowSavingsEnabled,
        goalId: goalId,
      );
    }
  }

  /// Toggles auto-flow of leftover daily savings into primary goal.
  Future<void> toggleAutoFlowSavings(bool enabled, {String? goalId}) async {
    final targetId = goalId ??
        state.autoFlowGoalId ??
        (state.savingsGoals.isNotEmpty ? state.savingsGoals.first.id : null);
    state = state.copyWith(
      isAutoFlowSavingsEnabled: enabled,
      autoFlowGoalId: targetId,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.saveAutoFlowSettings(
        enabled: enabled,
        goalId: targetId,
      );
    }
  }

  /// Processes auto-flow for an underspent day: leftover budget moves into chosen goal.
  Future<Money> processAutoFlowForUnderspentDay(int dayIndex) async {
    if (!state.isAutoFlowSavingsEnabled || state.savingsGoals.isEmpty) {
      return const Money.zero();
    }

    final targetId = state.autoFlowGoalId ??
        state.savingsGoals
            .firstWhere((g) => g.isPrimary, orElse: () => state.savingsGoals.first)
            .id;

    final idx = dayIndex - 1;
    if (idx < 0 || idx >= state.dailyBudgets.length) {
      return const Money.zero();
    }

    final dayBudget = state.dailyBudgets[idx];
    final surplusPaise =
        dayBudget.allocatedBudget.paise - dayBudget.actualSpent.paise;
    if (surplusPaise <= 0) return const Money.zero();

    final surplusMoney = Money.fromPaise(surplusPaise);
    await depositToGoal(goalId: targetId, amount: surplusMoney);
    return surplusMoney;
  }

  /// Privacy: Wipes all database tables, encryption keys, and resets state to fresh setup.
  Future<void> wipeAllData({LocalSecurityService? securityService}) async {
    final repo = _repository;
    if (repo != null) {
      await repo.wipeAllData();
    }
    if (securityService != null) {
      await securityService.wipeSecurityKeys();
    }
    state = _buildInitialState().copyWith(isOnboarded: false);
  }

  /// Completes initial onboarding setup, generating initial budget cycle and hero state.
  Future<void> completeOnboarding({
    required Money inHandSalary,
    required int paydayDay,
    required Money fixedExpenses,
    required Money savingsGoal,
    required String heroName,
    required HeroArchetype archetype,
    required bool isSeriousMode,
  }) async {
    _isOnboardingInProgressOrDone = true;
    final now = DateTime.now();
    final activeDates = CycleDateCalculator.computeActiveCycleDates(
      now: now,
      paydayDay: paydayDay,
    );
    final cycle = BudgetCycle(
      id: 'cycle_${activeDates.cycleYear}_${activeDates.cycleMonth}',
      startDate: activeDates.startDate,
      endDate: activeDates.endDate,
      totalDays: activeDates.totalDays,
      paydayDay: paydayDay,
      salaryReceivedDate: now,
      inHandSalary: inHandSalary,
      fixedExpensesTotal: fixedExpenses,
      savingsTargetAmount: savingsGoal,
    );

    final currentDay = cycle.currentDayIndex(now);
    final distributedBudgets =
        Money.distribute(cycle.discretionaryPool, cycle.totalDays);
    final List<DailyBudget> initialBudgets = [];
    for (int i = 0; i < cycle.totalDays; i++) {
      final date = cycle.startDate.add(Duration(days: i));
      final dayNumber = i + 1;
      final isPastBeforeJoin = dayNumber < currentDay;

      initialBudgets.add(
        DailyBudget(
          id: '${cycle.id}_day_$dayNumber',
          cycleId: cycle.id,
          date: date,
          dayIndex: dayNumber,
          allocatedBudget: distributedBudgets[i],
          actualSpent:
              isPastBeforeJoin ? distributedBudgets[i] : const Money.zero(),
          isClosed: isPastBeforeJoin,
        ),
      );
    }

    final targetRupees = savingsGoal.inWholeRupees > 0
        ? savingsGoal.inWholeRupees
        : cycle.discretionaryPool.inWholeRupees;

    final hero = HeroCharacter(
      name: heroName.trim().isEmpty ? 'Aero' : heroName.trim(),
      archetype: archetype,
      level: 1,
      currentXp: 0,
      maxXp: 100,
      currentHp: 100,
      maxHp: 100,
      coins: 50,
      streakDays: 1,
    );

    final quests = GamificationEngine.getStarterQuests();

    state = state.copyWith(
      cycle: cycle,
      dailyBudgets: initialBudgets,
      currentDayIndex: currentDay,
      transactions: const [],
      hero: hero,
      quests: quests,
      bossCurrentHp: targetRupees,
      bossMaxHp: targetRupees,
      isSeriousMode: isSeriousMode,
      isOnboarded: true,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.saveCycleAndBudgets(
        cycle: cycle,
        dailyBudgets: initialBudgets,
        hero: hero,
        quests: quests,
      );
    }
  }

  /// Sets the application UI locale language code ('en' or 'hi').
  void setLocale(String languageCode) {
    state = state.copyWith(languageCode: languageCode);
  }

  /// Exports an AES-encrypted backup ciphertext of the entire application state.
  Future<String> exportBackup({LocalSecurityService? securityService}) async {
    final sec = securityService ?? LocalSecurityService();
    return await BackupRestoreService.exportEncryptedBackup(
      state: state,
      securityService: sec,
    );
  }

  /// Restores state from an AES-encrypted backup ciphertext, merging incoming transactions
  /// with existing records using DataConflictResolver (Latest-Edit-Wins with zero duplicates).
  Future<BackupRestoreResult> restoreBackup(
    String encryptedData, {
    LocalSecurityService? securityService,
  }) async {
    final sec = securityService ?? LocalSecurityService();
    final result = await BackupRestoreService.restoreEncryptedBackup(
      encryptedData: encryptedData,
      currentState: state,
      securityService: sec,
    );

    state = result.restoredState;

    final repo = _repository;
    if (repo != null) {
      await repo.saveCycleAndBudgets(
        cycle: state.cycle,
        dailyBudgets: state.dailyBudgets,
        hero: state.hero,
        quests: state.quests,
      );
      // Persist transactions
      for (final tx in state.transactions) {
        await repo.recordTransaction(
          transaction: tx,
          rebalancedBudgets: state.dailyBudgets,
          hero: state.hero,
          quests: state.quests,
          newBossHp: state.bossCurrentHp,
        );
      }
    }

    return result;
  }
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final salaryQuestRepositoryProvider = Provider<SalaryQuestRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SalaryQuestRepository(db);
});

final salaryQuestProvider =
    StateNotifierProvider<SalaryQuestNotifier, SalaryQuestState>((ref) {
  final repository = ref.watch(salaryQuestRepositoryProvider);
  return SalaryQuestNotifier(repository: repository);
});
