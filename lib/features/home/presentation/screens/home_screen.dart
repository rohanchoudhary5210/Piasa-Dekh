import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/constants/app_theme.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/home/presentation/widgets/hero_character_card.dart';
import 'package:salary_quest/features/home/presentation/widgets/daily_budget_card.dart';
import 'package:salary_quest/features/home/presentation/widgets/calendar_strip.dart';
import 'package:salary_quest/features/home/presentation/widgets/quests_card.dart';
import 'package:salary_quest/features/home/presentation/widgets/recent_transactions_list.dart';
import 'package:salary_quest/features/home/presentation/widgets/add_transaction_sheet.dart';
import 'package:salary_quest/features/transactions/presentation/widgets/edit_transaction_sheet.dart';
import 'package:salary_quest/features/settings/presentation/screens/settings_screen.dart';
import 'package:salary_quest/features/savings_goals/presentation/screens/savings_goals_screen.dart';
import 'package:salary_quest/features/insights/presentation/screens/insights_screen.dart';
import 'package:salary_quest/features/insights/domain/services/insights_calculator.dart';
import 'package:salary_quest/features/gamification/presentation/screens/boss_battle_screen.dart';
import 'package:salary_quest/features/gamification/presentation/screens/badges_screen.dart';
import 'package:salary_quest/features/gamification/presentation/screens/coin_shop_screen.dart';
import 'package:salary_quest/features/transactions/domain/models/duplicate_transaction_exception.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/sms_parser_service.dart';
import 'package:salary_quest/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:salary_quest/features/transactions/presentation/widgets/sms_tracking_sheet.dart';
import 'package:salary_quest/core/services/native_sms_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final AppLifecycleListener _lifecycleListener;
  final NativeSmsService _smsService = NativeSmsService();
  Timer? _midnightTimer;
  int _currentTabIndex = 0;

  void _handleEditTransaction(Transaction tx) {
    EditTransactionSheet.show(
      context,
      transaction: tx,
      onSave: (updated) {
        ref.read(salaryQuestProvider.notifier).editTransaction(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction updated & daily budgets rebalanced'),
            backgroundColor: AppColors.safeGreen,
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  /// Fires just after midnight while the app stays open, so the new day
  /// (streak, quests, payday rollover) starts without needing to reopen the app.
  void _scheduleMidnightTick() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 5);
    _midnightTimer = Timer(nextMidnight.difference(now), () async {
      if (!mounted) return;
      await ref.read(salaryQuestProvider.notifier).catchUpOnResume();
      _scheduleMidnightTick();
    });
  }

  @override
  void initState() {
    super.initState();
    // Vault locking is handled app-wide by AppLockGate (covers every screen).
    // Here we only catch up on days / SMS when the app comes back.
    _lifecycleListener = AppLifecycleListener(
      onResume: _handleAppResume,
    );
    _scheduleMidnightTick();

    // Automated Native SMS Ingestion
    _smsService.startListening(
      onTransactionDetected: (parsed) async {
        if (!mounted) return;

        // Feedback for Mandate Revocation / Cancellation
        if (parsed.isMandateRevoked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ℹ️ UPI Mandate Cancelled: ${parsed.cleanedMerchant}',
              ),
              backgroundColor: AppColors.manaPurple,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }

        if (parsed.amount == null) return;

        // Incoming money that is not a refund (salary, friend transfer, interest)
        // is NOT spending and must not reduce today's spent amount.
        if (parsed.type == ParsedSmsType.credit && !parsed.isRefundCredit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                parsed.isSalaryCredit
                    ? '💼 Salary credit of ${CurrencyFormatter.formatMoney(parsed.amount!)} detected. Your budget already plans for your salary.'
                    : 'ℹ️ ${CurrencyFormatter.formatMoney(parsed.amount!)} received — not counted as spending. Add it as extra income in Settings if you want to spend it.',
              ),
              backgroundColor: AppColors.manaPurple,
              duration: const Duration(seconds: 5),
            ),
          );
          return;
        }

        try {
          await ref.read(salaryQuestProvider.notifier).addTransaction(
                amount: parsed.amount!,
                title: parsed.cleanedMerchant,
                category: parsed.inferredCategory,
                customTimestamp: parsed.timestamp,
                source: TransactionSource.smsAuto,
                explicitDedupeKey: parsed.dedupeKey,
                type: parsed.type == ParsedSmsType.credit
                    ? TransactionType.refund
                    : TransactionType.expense,
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  parsed.isRefundCredit
                      ? '↩️ Refund tracked: ${CurrencyFormatter.formatMoney(parsed.amount!)} from ${parsed.cleanedMerchant}'
                      : '⚡ Auto-Tracked: ${CurrencyFormatter.formatMoney(parsed.amount!)} at ${parsed.cleanedMerchant} [${parsed.inferredCategory.displayName}]',
                ),
                backgroundColor: AppColors.safeGreen,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (_) {}
      },
    );

    // Instant catch-up on app launch for bank SMS missed while app was closed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDailySummaryIfAny();
      _catchUpMissedSmsOnOpen();
    });
  }

  bool _isCatchingUpSms = false;

  /// Catch-up scan for bank SMS that arrived while the app was closed or dormant.
  Future<void> _catchUpMissedSmsOnOpen() async {
    if (_isCatchingUpSms) return;
    _isCatchingUpSms = true;

    try {
      final hasPerm = await _smsService.checkPermission();
      if (!hasPerm) {
        _isCatchingUpSms = false;
        return;
      }

      final state = ref.read(salaryQuestProvider);
      final cycle = state.cycle;
      final now = DateTime.now();

      final smsTransactions = state.transactions
          .where((t) => t.source == TransactionSource.smsAuto && t.cycleId == cycle.id)
          .toList();

      DateTime scanSince;
      if (smsTransactions.isNotEmpty) {
        final latestTs = smsTransactions
            .map((t) => t.timestamp)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        scanSince = latestTs.subtract(const Duration(minutes: 2));
      } else {
        scanSince = DateTime(now.year, now.month, now.day);
      }

      if (scanSince.isBefore(cycle.startDate)) {
        scanSince = cycle.startDate;
      }

      final missedList = await _smsService.syncBankSmsSince(scanSince, limit: 100);
      int imported = 0;

      for (final parsed in missedList) {
        // Only spending and refunds affect the budget; salary / money received is skipped.
        final affectsBudget = parsed.type == ParsedSmsType.debit ||
            parsed.isRefundCredit;
        if (affectsBudget &&
            parsed.isFinancial &&
            !parsed.isIgnored &&
            parsed.amount != null) {
          try {
            await ref.read(salaryQuestProvider.notifier).addTransaction(
                  amount: parsed.amount!,
                  title: parsed.cleanedMerchant,
                  category: parsed.inferredCategory,
                  customTimestamp: parsed.timestamp,
                  source: TransactionSource.smsAuto,
                  explicitDedupeKey: parsed.dedupeKey,
                  type: parsed.type == ParsedSmsType.credit
                      ? TransactionType.refund
                      : TransactionType.expense,
                );
            imported++;
          } catch (_) {
            // Duplicate or already recorded - safely skipped
          }
        }
      }

      if (mounted && imported > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚡ Instant Sync: $imported new transaction${imported > 1 ? 's' : ''} auto-updated!',
            ),
            backgroundColor: AppColors.safeGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      // Gracefully ignore
    } finally {
      _isCatchingUpSms = false;
    }
  }

  Future<void> _handleAppResume() async {
    await ref.read(salaryQuestProvider.notifier).catchUpOnResume();
    _scheduleMidnightTick();
    _catchUpMissedSmsOnOpen();
  }

  /// Shows the one-time "what happened since yesterday" message
  /// (streak, HP, auto-claimed quests, new salary cycle).
  void _showDailySummaryIfAny() {
    if (!mounted) return;
    final summary = ref.read(salaryQuestProvider).dailySummary;
    if (summary == null || summary.isEmpty) return;
    ref.read(salaryQuestProvider.notifier).clearDailySummary();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(summary),
        backgroundColor: AppColors.surfaceElevated,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _smsService.stopListening();
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _openSmsTrackingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SmsTrackingSheet(),
    );
  }

  void _openAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AddTransactionSheet(
          onAdd: ({
            required amount,
            required title,
            required category,
            type = TransactionType.expense,
            isFixedExpense = false,
            splitTotal,
            splitUserShare,
          }) async {
            try {
              await ref.read(salaryQuestProvider.notifier).addTransaction(
                    amount: amount,
                    title: title,
                    category: category,
                    type: type,
                    isFixedExpense: isFixedExpense,
                    splitTotal: splitTotal,
                    splitUserShare: splitUserShare,
                  );
            } on DuplicateTransactionException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message),
                    backgroundColor: AppColors.dangerRed,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryQuestProvider);
    final accent = AppTheme.accentFor(state.hero.themeId);

    // Day/month change summaries can arrive at any time (resume, midnight tick)
    ref.listen<String?>(
      salaryQuestProvider.select((s) => s.dailySummary),
      (previous, next) {
        if (next != null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _showDailySummaryIfAny());
        }
      },
    );

    final todayBudget = state.todayBudget;
    final bossHpRatio =
        (state.bossCurrentHp / (state.bossMaxHp <= 0 ? 1 : state.bossMaxHp))
            .clamp(0.0, 1.0);

    final prediction = InsightsCalculator.calculateMonthEndPrediction(
      cycle: state.cycle,
      transactions: state.transactions,
      currentDayIndex: state.currentDayIndex,
    );

    final startStr = DateFormat('MMM d').format(state.cycle.startDate);
    final endStr = DateFormat('MMM d').format(state.cycle.endDate);
    final reduceMotion =
        state.isReduceMotion || MediaQuery.of(context).disableAnimations;

    return PopScope(
      canPop: _currentTabIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentTabIndex != 0) {
          setState(() => _currentTabIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildDashboardView(
              context,
              state,
              accent,
              startStr,
              endStr,
              todayBudget,
              bossHpRatio,
              prediction,
              reduceMotion,
            ),
            const TransactionsScreen(isEmbeddedTab: true),
            const InsightsScreen(isEmbeddedTab: true),
            const SavingsGoalsScreen(isEmbeddedTab: true),
            const SettingsScreen(isEmbeddedTab: true),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: (_currentTabIndex == 0 || _currentTabIndex == 1)
            ? FloatingActionButton.extended(
                key: const Key('btn_log_expense'),
                onPressed: () => _openAddTransactionSheet(context),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 6,
                icon: const Icon(Icons.add_rounded, color: Colors.black, size: 22),
                label: const Text(
                  'LOG EXPENSE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              )
            : null,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.manaPurple.withValues(alpha: 0.22),
            selectedIndex: _currentTabIndex,
            height: 64,
            elevation: 0,
            onDestinationSelected: (index) {
              setState(() => _currentTabIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.manaPurple, size: 22),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.manaPurple, size: 22),
                label: 'Activity',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_graph_outlined, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.auto_graph_rounded, color: AppColors.manaPurple, size: 22),
                label: 'Insights',
              ),
              NavigationDestination(
                icon: Icon(Icons.flag_outlined, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.flag_rounded, color: AppColors.manaPurple, size: 22),
                label: 'Goals',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.tune_rounded, color: AppColors.manaPurple, size: 22),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardView(
    BuildContext context,
    SalaryQuestState state,
    Color accent,
    String startStr,
    String endStr,
    DailyBudget todayBudget,
    double bossHpRatio,
    MonthEndPrediction prediction,
    bool reduceMotion,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALARYQUEST',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 16,
                color: accent,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '$startStr – $endStr • Day ${state.currentDayIndex}/${state.cycle.totalDays}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          _buildAppBarAction(
            icon: Icons.mark_email_read_outlined,
            tooltip: 'SMS Auto-Tracking',
            onTap: () => _openSmsTrackingSheet(context),
          ),
          const SizedBox(width: 8),
          _buildAppBarAction(
            icon: Icons.auto_graph_rounded,
            tooltip: 'Financial Insights',
            onTap: () {
              setState(() => _currentTabIndex = 2);
            },
          ),
          const SizedBox(width: 8),
          _buildAppBarAction(
            icon: Icons.flag_outlined,
            tooltip: 'Savings Goals',
            onTap: () {
              setState(() => _currentTabIndex = 3);
            },
          ),
          const SizedBox(width: 8),
          _buildAppBarAction(
            icon: Icons.tune_rounded,
            tooltip: 'Settings',
            onTap: () {
              setState(() => _currentTabIndex = 4);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: reduceMotion
              ? const ClampingScrollPhysics()
              : const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deficit / Debt Warning Banner if user spent entire pool
              if (state.isCycleInDeficit) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.dangerRed.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: AppColors.dangerRed, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Treasury Deficit Alert!',
                              style: TextStyle(
                                color: AppColors.dangerRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'You have exceeded the discretionary pool by ${CurrencyFormatter.formatMoney(state.cycleDebt)}. Remaining daily budgets are ₹0 until next payday.',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 1. HERO BENTO TILE: Today's Daily Mana
              DailyBudgetCard(dailyBudget: todayBudget),
              const SizedBox(height: 12),

              // 2. TWO-COLUMN BENTO ROW: Forecast & Boss / Commitments
              Row(
                children: [
                  // Left Bento Tile: Forecast
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() => _currentTabIndex = 2);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'FORECAST',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 15,
                                  color: prediction.isOnTrack
                                      ? AppColors.safeGreen
                                      : AppColors.warningAmber,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.formatMoney(
                                    prediction.projectedSavings),
                                style: TextStyle(
                                  color: prediction.isOnTrack
                                      ? AppColors.safeGreen
                                      : AppColors.coinGold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prediction.isOnTrack
                                  ? 'Target on track'
                                  : 'Pace warning',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right Bento Tile: Monthly Boss (or Days Left in Serious Mode)
                  Expanded(
                    child: state.isSeriousMode
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'CYCLE PACE',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Icon(Icons.calendar_today_rounded,
                                        size: 14, color: AppColors.xpBlue),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${prediction.daysRemaining} days left',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Target: ${CurrencyFormatter.formatMoney(state.cycle.savingsTargetAmount)}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BossBattleScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'TITAN BOSS',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 15,
                                        color: AppColors.manaPurple,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(bossHpRatio * 100).toInt()}% HP',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const Text(
                                        'Stage 1',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: bossHpRatio,
                                      minHeight: 4,
                                      backgroundColor: const Color(0xFF222228),
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Quick Game Navigation (Shop & Badges)
              if (!state.isSeriousMode) ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CoinShopScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.toll_rounded,
                                size: 16,
                                color: AppColors.coinGold,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Shop (${state.hero.coins})',
                                    style: const TextStyle(
                                      color: AppColors.coinGold,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BadgesScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.military_tech_outlined,
                                size: 16,
                                color: AppColors.xpBlue,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Hall of Valor',
                                    style: TextStyle(
                                      color: AppColors.xpBlue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Hero Character Card
                HeroCharacterCard(
                  hero: state.hero,
                  onRepairStreak: () {
                    try {
                      ref
                          .read(salaryQuestProvider.notifier)
                          .repairStreakWithCoins();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '🛡️ Streak Shield Activated! Streak restored.'),
                          backgroundColor: AppColors.coinGold,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: AppColors.dangerRed,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 14),

              // Dynamic Budget Cycle Heat Matrix (28 to 31 days)
              CalendarGridWidget(
                budgets: state.dailyBudgets,
                currentDayIndex: state.currentDayIndex,
                paydayDay: state.cycle.paydayDay,
                onChangePayday: () => _showQuickPaydayPicker(context),
                onDayTapped: (day) {
                  final dateStr = DateFormat('EEE, d MMM').format(day.date);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$dateStr (Day ${day.dayIndex}): Budget ${CurrencyFormatter.formatMoney(day.allocatedBudget)} | Spent: ${CurrencyFormatter.formatMoney(day.actualSpent)}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Daily Quests Card (Hidden in Serious Mode)
              if (!state.isSeriousMode) ...[
                DailyQuestsCard(
                  quests: state.quests,
                  onClaimQuest: (questId) {
                    ref
                        .read(salaryQuestProvider.notifier)
                        .claimQuestReward(questId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('🎉 Quest Reward Claimed! Coins & XP awarded.'),
                        backgroundColor: AppColors.coinGold,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
              ],

              // Recent Transactions
              RecentTransactionsList(
                transactions: state.transactions,
                onViewAll: () {
                  setState(() => _currentTabIndex = 1);
                },
                onEdit: (tx) => _handleEditTransaction(tx),
                onDelete: (id) async {
                  final deleted = await ref
                      .read(salaryQuestProvider.notifier)
                      .deleteTransaction(id);
                  if (!context.mounted || deleted == null) return;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted "${deleted.title}"'),
                      backgroundColor: AppColors.surfaceElevated,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: AppColors.xpBlue,
                        onPressed: () {
                          ref
                              .read(salaryQuestProvider.notifier)
                              .restoreDeletedTransaction(deleted);
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.surfaceBorder,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  void _showQuickPaydayPicker(BuildContext context) {
    final state = ref.read(salaryQuestProvider);
    int selectedDay = state.cycle.paydayDay;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SELECT SALARY PAYDAY',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose your monthly salary date (e.g. 7th, or 1st for calendar month). The budget cycle and calendar grid will refresh automatically.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [1, 5, 7, 10, 15, 20, 25, 30].map((d) {
                      final isSelected = selectedDay == d;
                      final label = d == 1
                          ? '1st (Full Month)'
                          : d == 7
                              ? '7th (Default)'
                              : '$d${d == 1 ? "st" : d == 2 ? "nd" : d == 3 ? "rd" : "th"}';
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: Colors.white,
                        backgroundColor: AppColors.surfaceElevated,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSelected ? Colors.white : AppColors.surfaceBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() => selectedDay = d);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref
                            .read(salaryQuestProvider.notifier)
                            .updateSalarySetup(
                              inHandSalary: state.cycle.inHandSalary,
                              fixedExpenses: state.cycle.fixedExpensesTotal,
                              savingsTarget: state.cycle.savingsTargetAmount,
                              paydayDay: selectedDay,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Payday updated to ${selectedDay}th! Cycle calendar refreshed.',
                              ),
                              backgroundColor: AppColors.safeGreen,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'APPLY & REFRESH CALENDAR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
