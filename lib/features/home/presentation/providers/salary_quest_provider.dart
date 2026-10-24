import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:salary_quest/core/database/app_database.dart';
import 'package:salary_quest/core/database/database_failure_exception.dart';
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

  /// True while saved data is being loaded from the database at startup.
  final bool isLoading;

  /// Set when the saved data could not be loaded (the app must not fall back to demo data).
  final String? loadError;

  /// One-time message summarising what happened at day/month change
  /// (streak, HP, auto-claimed quest rewards, new cycle). Shown once by the home screen.
  final String? dailySummary;

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
    this.isLoading = false,
    this.loadError,
    this.dailySummary,
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
    bool? isLoading,
    String? loadError,
    bool clearLoadError = false,
    String? dailySummary,
    bool clearDailySummary = false,
    bool clearAutoFlowGoalId = false,
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
      autoFlowGoalId: clearAutoFlowGoalId
          ? null
          : (autoFlowGoalId ?? this.autoFlowGoalId),
      achievements: achievements ?? this.achievements,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      languageCode: languageCode ?? this.languageCode,
      isLoading: isLoading ?? this.isLoading,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      dailySummary:
          clearDailySummary ? null : (dailySummary ?? this.dailySummary),
    );
  }
}

class SalaryQuestNotifier extends StateNotifier<SalaryQuestState> {
  final SalaryQuestRepository? _repository;
  DateTime? _lastKnownDeviceTimestamp;
  late final NotificationManager notificationManager;
  bool _isOnboardingInProgressOrDone = false;
  bool _maintenanceRunning = false;

  /// Hard cap on how many cycles are rolled forward in one go (app unused for 2 years).
  static const int _maxCycleRollovers = 24;

  SalaryQuestNotifier({
    SalaryQuestRepository? repository,
    INotificationService? notificationService,
  })  : _repository = repository,
        super(_buildInitialState(isLoading: repository != null)) {
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
      if (!mounted) return;

      if (savedState != null && !_isOnboardingInProgressOrDone) {
        state = savedState.copyWith(
          isAuthenticated: !savedState.isBiometricLockEnabled,
          isOnboarded: true,
          isLoading: true, // keep the splash up until today's numbers are ready
          clearLoadError: true,
        );
        notificationManager.updatePreferences(savedState.notificationPreferences);

        final savedTs =
            await repo.readPreference(SalaryQuestRepository.kvLastKnownTimestamp);
        _lastKnownDeviceTimestamp =
            savedTs != null ? DateTime.tryParse(savedTs) : null;

        await runDailyMaintenance();
        if (!mounted) return;
        state = state.copyWith(isLoading: false);
        await _initNotifications();
      } else {
        // First launch on this device: show onboarding (unless it already started).
        state = state.copyWith(
          isOnboarded: _isOnboardingInProgressOrDone ? state.isOnboarded : false,
          isLoading: false,
          clearLoadError: true,
        );
      }
    } catch (e) {
      // Never silently fall back to demo data: surface the error so the user can retry.
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        loadError: e is DatabaseFailureException ? e.userMessage : e.toString(),
      );
    }
  }

  /// Retries loading saved data after a startup failure.
  Future<void> retryLoad() async {
    state = state.copyWith(isLoading: true, clearLoadError: true);
    await _initPersistenceAndCatchUp();
  }

  Future<void> _initNotifications() async {
    try {
      await notificationManager.initialize();
      await notificationManager.syncDailyReminders();
    } catch (_) {}
  }

  /// Clears the one-time day/month summary after the UI has shown it.
  void clearDailySummary() {
    if (state.dailySummary != null) {
      state = state.copyWith(clearDailySummary: true);
    }
  }

  // ---------------------------------------------------------------------------
  // DAY & MONTH ROLLOVER
  // ---------------------------------------------------------------------------

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Reads the "last fully processed day" cursor for the active cycle.
  /// Returns null when there is no cursor for this cycle yet.
  Future<int?> _readDayCursor(String cycleId) async {
    final repo = _repository;
    if (repo == null) return _memoryCursor[cycleId];
    final raw = await repo.readPreference(SalaryQuestRepository.kvDayCursor);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['cycleId'] != cycleId) return null;
      return json['day'] as int?;
    } catch (_) {
      return null;
    }
  }

  final Map<String, int> _memoryCursor = {};

  Future<void> _writeDayCursor(String cycleId, int day) async {
    _memoryCursor
      ..clear()
      ..[cycleId] = day;
    final repo = _repository;
    if (repo == null) return;
    await repo.savePreference(
      SalaryQuestRepository.kvDayCursor,
      jsonEncode({'cycleId': cycleId, 'day': day}),
    );
  }

  String? _memoryQuestsDate;

  Future<String?> _readQuestsDate() async {
    final repo = _repository;
    if (repo == null) return _memoryQuestsDate;
    return repo.readPreference(SalaryQuestRepository.kvQuestsDate);
  }

  Future<void> _writeQuestsDate(DateTime day) async {
    _memoryQuestsDate = _dateKey(day);
    final repo = _repository;
    if (repo == null) return;
    await repo.savePreference(
        SalaryQuestRepository.kvQuestsDate, _dateKey(day));
  }

  Future<void> _rememberDeviceTimestamp(DateTime ts) async {
    _lastKnownDeviceTimestamp = ts;
    final repo = _repository;
    if (repo == null) return;
    try {
      await repo.savePreference(
          SalaryQuestRepository.kvLastKnownTimestamp, ts.toIso8601String());
    } catch (_) {}
  }

  /// Runs everything that must happen when days pass:
  /// 1. If the salary cycle has ended, closes it, sweeps leftover money into the
  ///    primary savings goal (when auto-flow is on), archives it and starts the next cycle.
  /// 2. For every day that finished since the last run: updates the streak and hero HP
  ///    once per day, and auto-claims that day's completed quests.
  /// 3. Gives the user fresh daily quests for today.
  /// Safe to call repeatedly (app start, resume, after a payday change).
  Future<void> runDailyMaintenance({DateTime? now}) async {
    if (_maintenanceRunning || !state.isOnboarded) return;
    _maintenanceRunning = true;
    try {
      final current = now ?? DateTime.now();
      final today = _dateOnly(current);
      final summary = <String>[];

      // Device-clock integrity: if the clock jumped backwards, skip rewards this run.
      final clockTampered = ClockIntegrityService.isClockManipulated(
        currentTimestamp: current,
        lastKnownTimestamp: _lastKnownDeviceTimestamp,
      );
      if (clockTampered) {
        // Skip rewards for this run, but accept the new clock so a genuinely
        // corrected clock can never lock the user out of new days.
        state = state.copyWith(isClockManipulated: true);
        await _rememberDeviceTimestamp(current);
        return;
      }

      final questsDate = await _readQuestsDate();
      final savedCursor = await _readDayCursor(state.cycle.id);
      int cursor;
      if (savedCursor != null) {
        cursor = savedCursor;
      } else {
        // No cursor yet (fresh install or upgrade): treat days before today as done,
        // so we never retro-actively punish/reward old days.
        cursor = state.cycle.currentDayIndex(current) - 1;
        if (today.isAfter(_dateOnly(state.cycle.endDate))) {
          cursor = state.cycle.totalDays;
        }
      }

      // 1. Cycle rollover(s)
      var rollovers = 0;
      while (today.isAfter(_dateOnly(state.cycle.endDate)) &&
          rollovers < _maxCycleRollovers) {
        _processClosedDays(
          fromDay: cursor + 1,
          toDay: state.cycle.totalDays,
          questsDate: questsDate,
          summary: summary,
        );
        await _startNextCycle(now: current, summary: summary);
        cursor = 0;
        rollovers++;
      }

      // 2. Close finished days of the active cycle
      final todayIndex = state.cycle.currentDayIndex(current);
      if (todayIndex - 1 > cursor) {
        _processClosedDays(
          fromDay: cursor + 1,
          toDay: todayIndex - 1,
          questsDate: questsDate,
          summary: summary,
        );
      }
      cursor = todayIndex - 1;

      // 3. Recompute budgets for today
      final recompute = TransactionEventRecomputer.recompute(
        cycle: state.cycle,
        transactions: state.transactions,
        currentDayIndex: todayIndex,
      );
      state = state.copyWith(
        currentDayIndex: todayIndex,
        dailyBudgets: recompute.budgets,
        transactions: recompute.updatedTransactions,
        bossCurrentHp: recompute.bossHp,
        bossMaxHp: SalaryQuestRepository.defaultBossHpFor(state.cycle),
        isClockManipulated: false,
      );

      // 4. Fresh quests for a new day
      if (questsDate != _dateKey(today)) {
        var freshQuests = GamificationEngine.getStarterQuests().toList();
        final recovery = state.quests
            .where((q) => q.type == QuestType.freshStartRecovery && !q.isClaimed);
        if (recovery.isNotEmpty) {
          freshQuests = [
            recovery.first.copyWith(progressValue: 0.0, isCompleted: false),
            ...freshQuests,
          ];
        }
        state = state.copyWith(quests: freshQuests);
        await _writeQuestsDate(today);
      }
      evaluateConsecutiveOverspends();
      _evaluateAchievements();

      await _writeDayCursor(state.cycle.id, cursor);
      await _rememberDeviceTimestamp(current);
      await _persistCurrentCycle();

      if (summary.isNotEmpty) {
        state = state.copyWith(dailySummary: summary.join('\n'));
      }
    } catch (_) {
      // Maintenance must never crash the app; it will run again on next resume.
    } finally {
      _maintenanceRunning = false;
    }
  }

  /// Applies once-per-day effects for closed days [fromDay]..[toDay] of the active cycle.
  void _processClosedDays({
    required int fromDay,
    required int toDay,
    required String? questsDate,
    required List<String> summary,
  }) {
    if (toDay < fromDay) return;
    final cycle = state.cycle;
    final recompute = TransactionEventRecomputer.recompute(
      cycle: cycle,
      transactions: state.transactions,
      currentDayIndex: (toDay + 1).clamp(1, cycle.totalDays),
    );
    final budgets = recompute.budgets;
    final trackingStartDay = cycle.salaryReceivedDate != null
        ? cycle.currentDayIndex(cycle.salaryReceivedDate!)
        : 1;

    var hero = state.hero;
    var quests = state.quests;
    final startHp = hero.currentHp;
    var underBudgetDays = 0;
    var overBudgetDays = 0;
    var questXp = 0;
    var questCoins = 0;

    for (int day = fromDay; day <= toDay; day++) {
      final idx = day - 1;
      if (idx < 0 || idx >= budgets.length) continue;
      if (day < trackingStartDay) continue; // before the user joined
      final b = budgets[idx];

      final hadExpense = state.transactions.any((t) =>
          t.type == TransactionType.expense &&
          !t.isFixedExpense &&
          CycleDateCalculator.getDayIndexForTimestamp(
                timestamp: t.timestamp,
                cycleStartDate: cycle.startDate,
                totalDays: cycle.totalDays,
              ) ==
              day);

      final underBudget = b.actualSpent <= b.allocatedBudget;
      if (underBudget) {
        underBudgetDays++;
      } else {
        overBudgetDays++;
      }

      hero = GamificationEngine.evaluateDailyStreak(
        hero: hero,
        actualSpent: b.actualSpent,
        allocatedBudget: b.allocatedBudget,
      );
      hero = GamificationEngine.evaluateDailyHealthImpact(
        hero: hero,
        spentRatio: b.spentRatio,
      );

      // Quests belong to the calendar day they were issued on
      if (questsDate != null && questsDate == _dateKey(b.date)) {
        quests = quests.map((q) {
          if (q.isClaimed) return q;
          var completed = q.isCompleted;
          switch (q.type) {
            case QuestType.spendUnderAmount:
            case QuestType.freshStartRecovery:
              completed = completed || underBudget;
              break;
            case QuestType.noSpendDay:
              completed = completed || (!hadExpense && b.actualSpent.paise <= 0);
              break;
            case QuestType.logExpense:
            case QuestType.reviewDay:
              break;
          }
          if (!completed) return q;
          // Auto-claim so rewards are never lost at midnight
          final coins = GamificationEngine.calculateQuestCoinReward(hero, q.rewardCoins);
          hero = GamificationEngine.awardXp(hero, q.rewardXp);
          hero = hero.copyWith(
            coins: hero.coins + coins,
            currentHp: (hero.currentHp + q.rewardHp).clamp(0, hero.maxHp),
          );
          questXp += q.rewardXp;
          questCoins += coins;
          return q.copyWith(progressValue: 1.0, isCompleted: true, isClaimed: true);
        }).toList();
      }
    }

    final daysCount = underBudgetDays + overBudgetDays;
    if (daysCount > 0) {
      final hpDelta = hero.currentHp - startHp;
      final dayWord = daysCount == 1 ? 'Yesterday' : 'Last $daysCount days';
      final parts = <String>[
        overBudgetDays == 0
            ? '$dayWord: under budget ✅'
            : '$dayWord: $overBudgetDays over budget ⚠️',
        '🔥 Streak ${hero.streakDays}',
        if (hpDelta != 0) '❤️ HP ${hpDelta > 0 ? '+' : ''}$hpDelta',
        if (questXp > 0) '🎁 Quests +$questXp XP, +$questCoins coins',
      ];
      summary.add(parts.join(' • '));
    }

    state = state.copyWith(hero: hero, quests: quests);
  }

  /// Closes the finished cycle and opens the next one (same salary setup).
  Future<void> _startNextCycle({
    required DateTime now,
    required List<String> summary,
  }) async {
    final old = state.cycle;
    final repo = _repository;

    // Final numbers for the finished cycle
    final finalRecompute = TransactionEventRecomputer.recompute(
      cycle: old,
      transactions: state.transactions,
      currentDayIndex: old.totalDays,
    );
    final closedBudgets = finalRecompute.budgets
        .map((b) => b.copyWith(isClosed: true))
        .toList();
    final leftover = old.discretionaryPool - state.totalDiscretionarySpent;

    // Boss result for the finished cycle
    var hero = state.hero;
    if (finalRecompute.bossHp <= 0) {
      hero = GamificationEngine.awardXp(hero, 500);
      hero = hero.copyWith(coins: hero.coins + 200);
      summary.add('🏆 Boss defeated last cycle! +500 XP, +200 coins');
    }
    // A fresh streak shield every cycle
    hero = hero.copyWith(streakShieldAvailable: true);

    if (repo != null) {
      await repo.saveCycleAndBudgets(
        cycle: old,
        dailyBudgets: closedBudgets,
        hero: hero,
        quests: state.quests,
        bossCurrentHp: finalRecompute.bossHp,
        bossMaxHp: SalaryQuestRepository.defaultBossHpFor(old),
      );
      await repo.archiveCycle(old.id);
    }

    // Next cycle starts the day after the old one ended
    // Calendar arithmetic (not Duration) so daylight-saving changes can't shift the date
    final nextStart =
        DateTime(old.endDate.year, old.endDate.month, old.endDate.day + 1);
    final dates = CycleDateCalculator.computeCycleDates(
      year: nextStart.year,
      month: nextStart.month,
      paydayDay: old.paydayDay,
    );
    final newCycle = BudgetCycle(
      id: 'cycle_${nextStart.year}_${nextStart.month}_${old.paydayDay}_${now.millisecondsSinceEpoch}',
      startDate: nextStart,
      endDate: dates.endDate,
      totalDays: dates.endDate.difference(nextStart).inDays + 1,
      paydayDay: old.paydayDay,
      inHandSalary: old.inHandSalary,
      fixedExpensesTotal: old.fixedExpensesTotal,
      savingsTargetAmount: old.savingsTargetAmount,
      rolloverStrategy: old.rolloverStrategy,
    );
    final newBudgets =
        BudgetCalculator.generateInitialCycleBudgets(cycle: newCycle);
    final bossHp = SalaryQuestRepository.defaultBossHpFor(newCycle);

    state = state.copyWith(
      cycle: newCycle,
      dailyBudgets: newBudgets,
      currentDayIndex: newCycle.currentDayIndex(now),
      transactions: const [],
      hero: hero,
      bossCurrentHp: bossHp,
      bossMaxHp: bossHp,
    );

    summary.add(
        '📅 New salary cycle started: ${CurrencyFormatter.formatMoney(newCycle.baseDailyBudget)}/day');

    // Month-end auto-flow: leftover discretionary money goes to the primary goal
    if (state.isAutoFlowSavingsEnabled &&
        state.savingsGoals.isNotEmpty &&
        leftover.isPositive) {
      final targetId = state.autoFlowGoalId ??
          state.savingsGoals
              .firstWhere((g) => g.isPrimary,
                  orElse: () => state.savingsGoals.first)
              .id;
      if (state.savingsGoals.any((g) => g.id == targetId)) {
        await depositToGoal(goalId: targetId, amount: leftover);
        summary.add(
            '💰 ${CurrencyFormatter.formatMoney(leftover)} left over last cycle moved to your savings goal');
      }
    }

    await _writeDayCursor(newCycle.id, 0);
    await _persistCurrentCycle();
  }

  /// Saves the active cycle, budgets, hero, quests and boss HP in one transaction.
  Future<void> _persistCurrentCycle() async {
    final repo = _repository;
    if (repo == null) return;
    await repo.saveCycleAndBudgets(
      cycle: state.cycle,
      dailyBudgets: state.dailyBudgets,
      hero: state.hero,
      quests: state.quests,
      bossCurrentHp: state.bossCurrentHp,
      bossMaxHp: state.bossMaxHp,
    );
  }

  static SalaryQuestState _buildInitialState({bool isLoading = false}) {
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
      isLoading: isLoading,
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

    // 3. Clock integrity check.
    // Compares the *device clock* with the last time we saw it. Back-dated entries
    // (bank SMS that arrived while the app was closed, manual past entries) are
    // legitimate and must not be flagged as tampering.
    final deviceNow = DateTime.now();
    final isTampered = ClockIntegrityService.isClockManipulated(
      currentTimestamp: deviceNow,
      lastKnownTimestamp: _lastKnownDeviceTimestamp,
    );
    // Remember the latest clock reading. After a backwards jump this entry earns
    // no XP, but later entries are judged against the corrected clock.
    final last = _lastKnownDeviceTimestamp;
    if (isTampered || last == null || deviceNow.isAfter(last)) {
      await _rememberDeviceTimestamp(deviceNow);
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

    // 6. Gamification updates.
    // Hero HP and streak are evaluated once per day when the day closes
    // (see runDailyMaintenance) — not on every transaction.
    var updatedHero = state.hero;
    if (earnedXp > 0) {
      updatedHero = GamificationEngine.awardXp(updatedHero, earnedXp);
    }

    final isTodayTx = targetDayIndex == state.currentDayIndex;
    final updatedQuests = state.quests.map((quest) {
      if (quest.type == QuestType.logExpense &&
          !quest.isCompleted &&
          isTodayTx &&
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
    final original =
        state.transactions.where((t) => t.id == updatedTx.id).toList();
    var effectiveTx = updatedTx;
    var updatedHero = state.hero;
    // Logging XP is only for discretionary expenses: take it back if the edit
    // turned this entry into something else (fixed bill, income, transfer...).
    final stillEarnsXp =
        updatedTx.type == TransactionType.expense && !updatedTx.isFixedExpense;
    if (original.isNotEmpty && original.first.earnedXp > 0 && !stillEarnsXp) {
      updatedHero =
          GamificationEngine.revertXp(updatedHero, original.first.earnedXp);
      effectiveTx = updatedTx.copyWith(earnedXp: 0);
    }

    final updatedTxList = state.transactions.map((t) {
      return t.id == effectiveTx.id ? effectiveTx : t;
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
      hero: updatedHero,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.recordTransaction(
        transaction: effectiveTx,
        rebalancedBudgets: recompute.budgets,
        hero: updatedHero,
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

    final updatedCycle = state.cycle.copyWith(
      inHandSalary: state.cycle.inHandSalary + amount,
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

    // Same event-sourced recompute used everywhere else, so budgets and Boss HP stay consistent
    final recompute = TransactionEventRecomputer.recompute(
      cycle: updatedCycle,
      transactions: updatedTxList,
      currentDayIndex: state.currentDayIndex,
    );

    state = state.copyWith(
      cycle: updatedCycle,
      dailyBudgets: recompute.budgets,
      transactions: recompute.updatedTransactions,
      bossCurrentHp: recompute.bossHp,
      bossMaxHp: SalaryQuestRepository.defaultBossHpFor(updatedCycle),
    );

    final repo = _repository;
    if (repo != null) {
      await _persistCurrentCycle();
      await repo.upsertTransactions([incomeTx]);
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

    final effectiveReceived = salaryReceivedDate ?? state.cycle.salaryReceivedDate;
    final receivedChanged = salaryReceivedDate != null &&
        salaryReceivedDate != state.cycle.salaryReceivedDate;

    if (paydayChanged || receivedChanged) {
      // Cycle dates change: close the old cycle record and open a new one,
      // carrying over every transaction that falls inside the new dates.
      final activeDates = CycleDateCalculator.computeActiveCycleDates(
        now: now,
        paydayDay: effectivePayday,
        salaryReceivedDate: paydayChanged ? salaryReceivedDate : effectiveReceived,
      );

      final oldCycle = state.cycle;
      final newCycle = BudgetCycle(
        id: 'cycle_${activeDates.cycleYear}_${activeDates.cycleMonth}_${effectivePayday}_${now.millisecondsSinceEpoch}',
        startDate: activeDates.startDate,
        endDate: activeDates.endDate,
        totalDays: activeDates.totalDays,
        paydayDay: effectivePayday,
        salaryReceivedDate: paydayChanged ? salaryReceivedDate : effectiveReceived,
        inHandSalary: inHandSalary,
        fixedExpensesTotal: fixedExpenses,
        savingsTargetAmount: savingsTarget,
        rolloverStrategy: oldCycle.rolloverStrategy,
      );

      final newStart = _dateOnly(newCycle.startDate);
      final carried = state.transactions
          .where((t) => !_dateOnly(t.timestamp).isBefore(newStart))
          .map((t) => t.copyWith(cycleId: newCycle.id))
          .toList();
      final newCurrentDay = newCycle.currentDayIndex(now);

      final recompute = TransactionEventRecomputer.recompute(
        cycle: newCycle,
        transactions: carried,
        currentDayIndex: newCurrentDay,
      );

      state = state.copyWith(
        cycle: newCycle,
        dailyBudgets: recompute.budgets,
        transactions: recompute.updatedTransactions,
        currentDayIndex: newCurrentDay,
        bossMaxHp: SalaryQuestRepository.defaultBossHpFor(newCycle),
        bossCurrentHp: recompute.bossHp,
      );

      final repo = _repository;
      if (repo != null) {
        await repo.archiveCycle(oldCycle.id);
        await _persistCurrentCycle();
        await repo.upsertTransactions(recompute.updatedTransactions);
      }
      await _writeDayCursor(newCycle.id, newCurrentDay - 1);
      return;
    }

    final result = CycleManagerService.recalculateMidCycle(
      currentCycle: state.cycle,
      currentBudgets: state.dailyBudgets,
      currentDayIndex: state.currentDayIndex,
      newSalary: inHandSalary,
      newFixedExpenses: fixedExpenses,
      newSavingsTarget: savingsTarget,
    );

    final currentDay = result.updatedCycle.currentDayIndex(now);
    final recompute = TransactionEventRecomputer.recompute(
      cycle: result.updatedCycle,
      transactions: state.transactions,
      currentDayIndex: currentDay,
    );

    state = state.copyWith(
      cycle: result.updatedCycle,
      currentDayIndex: currentDay,
      dailyBudgets: result.updatedBudgets,
      bossMaxHp: SalaryQuestRepository.defaultBossHpFor(result.updatedCycle),
      bossCurrentHp: recompute.bossHp,
    );

    await _persistCurrentCycle();
  }

  Future<void> markSalaryReceivedDate(DateTime date) async {
    await updateSalarySetup(
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

      await _persistCurrentCycle();
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
    final repo = _repository;
    if (repo != null) {
      try {
        await repo.saveNotificationPreferences(prefs);
      } catch (_) {}
      await notificationManager.syncDailyReminders();
    }
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

  /// Catches up missed days, midnight rollover and payday rollover when
  /// returning from background.
  Future<void> catchUpOnResume() async {
    await runDailyMaintenance();
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
  /// (Normally this happens automatically on payday via [runDailyMaintenance].)
  Future<void> advanceToNextCycle({
    required int nextMonth,
    required int nextYear,
  }) async {
    final repo = _repository;
    if (repo != null) {
      await _persistCurrentCycle();
      await repo.archiveCycle(state.cycle.id);
    }

    final newCycle = BudgetCycle.createValidated(
      id: 'cycle_${nextYear}_${nextMonth}_${state.cycle.paydayDay}_${DateTime.now().millisecondsSinceEpoch}',
      year: nextYear,
      month: nextMonth,
      paydayDay: state.cycle.paydayDay,
      inHandSalary: state.cycle.inHandSalary,
      fixedExpensesTotal: state.cycle.fixedExpensesTotal,
      savingsTargetAmount: state.cycle.savingsTargetAmount,
    );

    final newBudgets =
        BudgetCalculator.generateInitialCycleBudgets(cycle: newCycle);
    final targetRupees = SalaryQuestRepository.defaultBossHpFor(newCycle);

    state = state.copyWith(
      cycle: newCycle,
      dailyBudgets: newBudgets,
      currentDayIndex: 1,
      transactions: const [],
      bossCurrentHp: targetRupees,
      bossMaxHp: targetRupees,
      hero: state.hero.copyWith(streakShieldAvailable: true),
    );

    await _persistCurrentCycle();
    await _writeDayCursor(newCycle.id, 0);
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
      clearAutoFlowGoalId: newAutoFlowId == null,
      cycle: updatedCycle,
    );

    final repo = _repository;
    if (repo != null) {
      await repo.deleteSavingsGoal(goalId);
      await repo.saveAutoFlowSettings(
        enabled: state.isAutoFlowSavingsEnabled,
        goalId: newAutoFlowId,
      );
      if (returnedPaise > 0) {
        await _persistCurrentCycle();
      }
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
    await notificationManager.cancelAll();
    notificationManager.clearHistory();
    _memoryCursor.clear();
    _memoryQuestsDate = null;
    _lastKnownDeviceTimestamp = null;
    _isOnboardingInProgressOrDone = false;
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
      id: 'cycle_${activeDates.cycleYear}_${activeDates.cycleMonth}_${paydayDay}_${now.millisecondsSinceEpoch}',
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
      isLoading: false,
    );

    final repo = _repository;
    if (repo != null) {
      await _persistCurrentCycle();
      await repo.saveSeriousMode(isSeriousMode);
      await repo.savePreference(
          SalaryQuestRepository.kvLanguage, state.languageCode);
    }
    // Days before joining are never evaluated; today's quests start now.
    await _writeDayCursor(cycle.id, currentDay - 1);
    await _writeQuestsDate(now);
    await _rememberDeviceTimestamp(now);
    if (repo != null) {
      await _initNotifications();
    }
  }

  /// Sets the application UI locale language code ('en' or 'hi').
  void setLocale(String languageCode) {
    state = state.copyWith(languageCode: languageCode);
    _repository?.savePreference(SalaryQuestRepository.kvLanguage, languageCode);
  }

  /// Exports an AES-encrypted backup ciphertext of the entire application state.
  Future<String> exportBackup({
    LocalSecurityService? securityService,
    String? password,
  }) async {
    final sec = securityService ?? LocalSecurityService();
    return await BackupRestoreService.exportEncryptedBackup(
      state: state,
      securityService: sec,
      password: password,
    );
  }

  /// Restores state from an AES-encrypted backup ciphertext, merging incoming transactions
  /// with existing records using DataConflictResolver (Latest-Edit-Wins with zero duplicates).
  /// Password-protected backups (made with a password) can be restored on any phone.
  Future<BackupRestoreResult> restoreBackup(
    String encryptedData, {
    LocalSecurityService? securityService,
    String? password,
  }) async {
    final sec = securityService ?? LocalSecurityService();
    final previousCycleId = state.cycle.id;
    final result = await BackupRestoreService.restoreEncryptedBackup(
      encryptedData: encryptedData,
      currentState: state,
      securityService: sec,
      password: password,
    );

    final restoredCycleId = result.restoredState.cycle.id;
    final normalizedTransactions = result.restoredState.transactions
        .map((t) => t.cycleId == restoredCycleId
            ? t
            : t.copyWith(cycleId: restoredCycleId))
        .toList();

    state = result.restoredState.copyWith(
      transactions: normalizedTransactions,
      isLoading: false,
      clearLoadError: true,
    );
    _isOnboardingInProgressOrDone = true;

    final repo = _repository;
    if (repo != null) {
      if (previousCycleId != restoredCycleId) {
        await repo.archiveCycle(previousCycleId);
      }
      await _persistCurrentCycle();
      await repo.upsertTransactions(normalizedTransactions);
      for (final goal in state.savingsGoals) {
        await repo.saveSavingsGoal(goal);
      }
      for (final achievement in state.achievements) {
        await repo.unlockAchievement(achievement);
      }
      await repo.saveSeriousMode(state.isSeriousMode);
      await repo.saveReducedMotion(state.isReduceMotion);
      await repo.saveAutoFlowSettings(
        enabled: state.isAutoFlowSavingsEnabled,
        goalId: state.autoFlowGoalId,
      );
      await repo.savePreference(
          SalaryQuestRepository.kvLanguage, state.languageCode);
    }

    // Note: the caller should run [catchUpOnResume] afterwards to bring an older
    // backup up to today (close finished days / start a new cycle if needed).
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
