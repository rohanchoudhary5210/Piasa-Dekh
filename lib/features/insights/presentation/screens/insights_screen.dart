import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/insights/domain/services/insights_calculator.dart';
import 'package:salary_quest/features/insights/presentation/screens/archived_cycle_detail_screen.dart';
import 'package:salary_quest/features/insights/presentation/widgets/statement_export_sheet.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  final bool isEmbeddedTab;

  const InsightsScreen({
    super.key,
    this.isEmbeddedTab = false,
  });

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BudgetCycle>? _archivedCycles;
  bool _isLoadingCycles = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadArchivedCycles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadArchivedCycles() async {
    setState(() => _isLoadingCycles = true);
    try {
      final repo = ref.read(salaryQuestRepositoryProvider);
      final cycles = await repo.getArchivedCycles();
      if (mounted) {
        setState(() {
          _archivedCycles = cycles;
          _isLoadingCycles = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _archivedCycles = [];
          _isLoadingCycles = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryQuestProvider);
    final prediction = InsightsCalculator.calculateMonthEndPrediction(
      cycle: state.cycle,
      transactions: state.transactions,
      currentDayIndex: state.currentDayIndex,
    );

    final categoryBreakdown = InsightsCalculator.calculateCategoryBreakdown(
      transactions: state.transactions,
    );

    final weeklyPoints = InsightsCalculator.calculateWeeklySpending(
      cycle: state.cycle,
      dailyBudgets: state.dailyBudgets,
      currentDayIndex: state.currentDayIndex,
    );

    final savingsGrowth = InsightsCalculator.calculateSavingsGrowth(
      cycle: state.cycle,
      dailyBudgets: state.dailyBudgets,
      currentDayIndex: state.currentDayIndex,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isEmbeddedTab,
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Insights & Analytics',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.ios_share_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            tooltip: 'Export Statement',
            onPressed: () {
              final state = ref.read(salaryQuestProvider);
              StatementExportSheet.show(
                context,
                cycle: state.cycle,
                transactions: state.transactions,
                currentDayIndex: state.currentDayIndex,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.surfaceBorder.withValues(alpha: 0.5),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.manaPurple.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: AppColors.manaPurple.withValues(alpha: 0.6),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Analytics & Charts'),
                Tab(text: 'Past Cycle History'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Charts & Analytics
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Month-End Prediction Card
                _buildPredictionHeroCard(prediction, state.cycle),
                const SizedBox(height: 16),

                // 2. Spending by Category (Sleek Donut + Progress Tracks)
                _buildCategoryBreakdownCard(categoryBreakdown),
                const SizedBox(height: 16),

                // 3. Weekly Spending Bar Chart (7-day rhythm)
                _buildWeeklySpendingCard(
                  points: weeklyPoints,
                  allBudgets: state.dailyBudgets,
                  currentDayIndex: state.currentDayIndex,
                ),
                const SizedBox(height: 16),

                // 4. Cumulative Savings Growth Trajectory (Curved Bezier with Early-Cycle Guard)
                _buildSavingsGrowthCard(
                  points: savingsGrowth,
                  cycle: state.cycle,
                  prediction: prediction,
                  currentDayIndex: state.currentDayIndex,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Tab 2: Past Cycle History
          _buildCycleHistoryTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. SLEEK PREDICTION HERO CARD
  // ---------------------------------------------------------------------------
  Widget _buildPredictionHeroCard(MonthEndPrediction p, BudgetCycle cycle) {
    final targetPaise = cycle.savingsTargetAmount.paise;
    final progressRatio = targetPaise <= 0
        ? 1.0
        : (p.projectedSavings.paise / targetPaise).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (p.isOnTrack ? AppColors.safeGreen : AppColors.warningAmber)
              .withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (p.isOnTrack ? AppColors.safeGreen : AppColors.warningAmber)
                .withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (p.isOnTrack ? AppColors.safeGreen : AppColors.warningAmber)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.auto_graph_rounded,
                      size: 15,
                      color: p.isOnTrack ? AppColors.safeGreen : AppColors.warningAmber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MONTH-END PREDICTION',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (p.isOnTrack ? AppColors.safeGreen : AppColors.dangerRed)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (p.isOnTrack ? AppColors.safeGreen : AppColors.dangerRed)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: p.isOnTrack ? AppColors.safeGreen : AppColors.dangerRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p.isOnTrack ? 'On Track' : 'Pace Warning',
                      style: TextStyle(
                        color: p.isOnTrack ? AppColors.safeGreen : AppColors.dangerRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.formatMoney(p.projectedSavings),
              style: TextStyle(
                color: p.isOnTrack ? AppColors.safeGreen : AppColors.coinGold,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            p.paceMessage,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Progress bar towards target
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 5,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                p.isOnTrack ? AppColors.safeGreen : AppColors.warningAmber,
              ),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubStat(
                'Avg Daily Spend',
                CurrencyFormatter.formatMoney(p.averageDailySpend),
              ),
              _buildSubStat(
                'Spent So Far',
                CurrencyFormatter.formatMoney(p.totalDiscretionarySpentSoFar),
              ),
              _buildSubStat(
                'Days Remaining',
                '${p.daysRemaining} days',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. CUMULATIVE SAVINGS GROWTH TRAJECTORY (MULTI-LINE CURVE)
  // ---------------------------------------------------------------------------
  Widget _buildSavingsGrowthCard({
    required List<SavingsGrowthPoint> points,
    required BudgetCycle cycle,
    required MonthEndPrediction prediction,
    required int currentDayIndex,
  }) {
    final totalDays = max(1, cycle.totalDays);
    final targetRupees = cycle.savingsTargetAmount.inRupees;
    final projectedRupees = prediction.projectedSavings.inRupees;

    // Early-cycle guard: Prevents awkward single-line across empty chart on Day 1
    if (points.isEmpty || currentDayIndex < 2) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surfaceBorder.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.safeGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    size: 15,
                    color: AppColors.safeGreen,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Savings Trajectory',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Text(
                  'Day $currentDayIndex of $totalDays',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.coinGold,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Trajectory curve unlocks on Day 2 after daily rollover balances reconcile. Currently on pace for ₹${prediction.projectedSavings.inRupees.toStringAsFixed(0)} projected month-end savings.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 1. Planned Pace Line (Spans entire month from Day 0 to totalDays)
    final plannedSpots = <FlSpot>[];
    for (int d = 0; d <= totalDays; d++) {
      final planned = (targetRupees * d) / totalDays;
      plannedSpots.add(FlSpot(d.toDouble(), planned));
    }

    // 2. Actual Savings Spots (Baseline at Day 0, plus each completed day)
    final actualSpots = <FlSpot>[
      const FlSpot(0, 0),
    ];
    for (final p in points) {
      actualSpots.add(FlSpot(p.dayIndex.toDouble(), p.cumulativeSaved.inRupees));
    }
    if (points.isEmpty && currentDayIndex >= 1) {
      actualSpots.add(const FlSpot(1, 0));
    }

    // 3. Projected Continuation Line (From current day to totalDays)
    final projectedSpots = <FlSpot>[];
    if (currentDayIndex < totalDays && actualSpots.isNotEmpty) {
      final lastActual = actualSpots.last;
      projectedSpots.add(lastActual);
      projectedSpots.add(FlSpot(totalDays.toDouble(), projectedRupees));
    }

    final maxVal = max(
      targetRupees,
      max(
        projectedRupees,
        actualSpots.fold<double>(0.0, (m, s) => max(m, s.y)),
      ),
    );
    final chartMaxY = max(100.0, maxVal * 1.2);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.safeGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.show_chart_rounded,
                      size: 15,
                      color: AppColors.safeGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Savings Trajectory',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Text(
                'Day $currentDayIndex of $totalDays',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Actual cumulative savings compared against monthly target pace.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Sleek Legend
          Row(
            children: [
              _buildLegendPill(
                color: AppColors.safeGreen,
                label: 'Actual Saved',
                isDashed: false,
              ),
              const SizedBox(width: 10),
              _buildLegendPill(
                color: AppColors.xpBlue,
                label: 'Target Pace',
                isDashed: true,
              ),
              if (projectedSpots.isNotEmpty) ...[
                const SizedBox(width: 10),
                _buildLegendPill(
                  color: AppColors.coinGold,
                  label: 'Projected',
                  isDashed: true,
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: totalDays.toDouble(),
                minY: 0,
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMaxY / 4 > 0 ? chartMaxY / 4 : 100,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.surfaceBorder.withValues(alpha: 0.25),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const SizedBox.shrink();
                        return Text(
                          _compactCurrency(val),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (totalDays / 5).clamp(1.0, 10.0),
                      getTitlesWidget: (val, meta) {
                        final d = val.toInt();
                        if (d == 0 || d > totalDays) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'D$d',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceElevated,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isPlanned = spot.barIndex == 0;
                        final isActual = spot.barIndex == 1;
                        final label = isPlanned
                            ? 'Target Pace'
                            : (isActual ? 'Actual Saved' : 'Projected');
                        return LineTooltipItem(
                          '$label (Day ${spot.x.toInt()}):\n₹${spot.y.toStringAsFixed(0)}',
                          TextStyle(
                            color: isPlanned
                                ? AppColors.xpBlue
                                : (isActual ? AppColors.safeGreen : AppColors.coinGold),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // 1. Target Pace Line (Blue dashed)
                  LineChartBarData(
                    spots: plannedSpots,
                    isCurved: false,
                    color: AppColors.xpBlue.withValues(alpha: 0.7),
                    barWidth: 1.8,
                    dashArray: [5, 4],
                    dotData: const FlDotData(show: false),
                  ),

                  // 2. Actual Cumulative Savings Curve (Green curved with gradient fill)
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: AppColors.safeGreen,
                    barWidth: 2.8,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        // Highlight latest point (today)
                        return spot.x == actualSpots.last.x;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.safeGreen,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.safeGreen.withValues(alpha: 0.22),
                          AppColors.safeGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // 3. Projected Continuation Line (Gold dashed)
                  if (projectedSpots.isNotEmpty)
                    LineChartBarData(
                      spots: projectedSpots,
                      isCurved: false,
                      color: AppColors.coinGold.withValues(alpha: 0.8),
                      barWidth: 2,
                      dashArray: [4, 4],
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill({
    required Color color,
    required String label,
    required bool isDashed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.surfaceBorder.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. WEEKLY SPENDING BAR CHART (7-DAY CLEAN WINDOW)
  // ---------------------------------------------------------------------------
  Widget _buildWeeklySpendingCard({
    required List<DailySpendingPoint> points,
    required List<DailyBudget> allBudgets,
    required int currentDayIndex,
  }) {
    // Determine 7-day rolling window centered around today
    final windowBudgets = <DailyBudget>[];
    if (allBudgets.isNotEmpty) {
      final startIndex = max(0, min(currentDayIndex - 4, allBudgets.length - 7));
      final endIndex = min(allBudgets.length, startIndex + 7);
      windowBudgets.addAll(allBudgets.sublist(startIndex, endIndex));
    }

    final maxVal = windowBudgets.fold<double>(
      500.0,
      (prev, b) => max(prev, max(b.actualSpent.inRupees, b.allocatedBudget.inRupees)),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.manaPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      size: 15,
                      color: AppColors.manaPurple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Weekly Spending Pace',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const Text(
                '7-Day Window',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Solid bars: Discretionary spend • Outlines: Daily budget limit.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),

          if (windowBudgets.isEmpty)
            _buildEmptyChartState('No days logged in this cycle yet.')
          else
            SizedBox(
              height: 175,
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.25,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxVal / 3) > 0 ? maxVal / 3 : 100,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.surfaceBorder.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (val, meta) {
                          if (val == 0) return const SizedBox.shrink();
                          return Text(
                            _compactCurrency(val),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < windowBudgets.length) {
                            final b = windowBudgets[idx];
                            final isToday = b.dayIndex == currentDayIndex;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                isToday ? 'Today' : 'D${b.dayIndex}',
                                style: TextStyle(
                                  color: isToday
                                      ? AppColors.manaPurple
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight:
                                      isToday ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  barGroups: windowBudgets.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final b = entry.value;
                    final isOver = b.actualSpent > b.allocatedBudget;
                    final isToday = b.dayIndex == currentDayIndex;

                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: b.actualSpent.inRupees,
                          color: isOver
                              ? AppColors.dangerRed
                              : (isToday ? AppColors.manaPurple : AppColors.xpBlue),
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: b.allocatedBudget.inRupees,
                            color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. CATEGORY BREAKDOWN DONUT CHART
  // ---------------------------------------------------------------------------
  Widget _buildCategoryBreakdownCard(List<CategorySpending> categories) {
    final colors = [
      AppColors.xpBlue,
      AppColors.safeGreen,
      AppColors.coinGold,
      AppColors.manaPurple,
      const Color(0xFFF472B6), // Soft Pink
      const Color(0xFF2DD4BF), // Teal
      const Color(0xFFFB923C), // Orange
      AppColors.dangerRed,
    ];

    final grandTotalPaise =
        categories.fold<int>(0, (sum, c) => sum + c.totalSpent.paise);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.xpBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 15,
                  color: AppColors.xpBlue,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Spending by Category',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (categories.isEmpty)
            _buildEmptyChartState('No discretionary expenses logged yet.')
          else ...[
            SizedBox(
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: categories.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final cat = entry.value;
                        final col = colors[idx % colors.length];

                        return PieChartSectionData(
                          color: col,
                          value: cat.percentage,
                          showTitle: false,
                          radius: 14,
                        );
                      }).toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatMoney(
                          Money.fromPaise(grandTotalPaise),
                        ),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category rows with sleek progress bars
            Column(
              children: categories.asMap().entries.map((entry) {
                final idx = entry.key;
                final cat = entry.value;
                final col = colors[idx % colors.length];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: col,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${cat.category.iconSymbol} ${cat.category.displayName}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            CurrencyFormatter.formatMoney(cat.totalSpent),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: col.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${cat.percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: col,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (cat.percentage / 100.0).clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(col),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: PAST CYCLE HISTORY
  // ---------------------------------------------------------------------------
  Widget _buildCycleHistoryTab() {
    if (_isLoadingCycles) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.manaPurple),
      );
    }

    final cycles = _archivedCycles ?? [];

    if (cycles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.history_toggle_off_rounded,
                  size: 38,
                  color: AppColors.manaPurple,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Archived Cycles Yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your current active cycle is running. Once a monthly cycle concludes at payday, it will be automatically archived here for read-only historical inspection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cycles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cycle = cycles[index];
        final startStr = DateFormat('dd MMM yyyy').format(cycle.startDate);
        final endStr = DateFormat('dd MMM yyyy').format(cycle.endDate);

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final repo = ref.read(salaryQuestRepositoryProvider);
            final details = await repo.getCycleHistoryDetails(cycle.id);
            if (details != null && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArchivedCycleDetailScreen(
                    cycle: details.cycle,
                    budgets: details.budgets,
                    transactions: details.transactions,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surfaceBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.manaPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$startStr → $endStr',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Target: ${CurrencyFormatter.formatMoney(cycle.savingsTargetAmount)} • ${cycle.totalDays} Days',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted,
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyChartState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
      ),
    );
  }

  String _compactCurrency(double val) {
    if (val >= 10000000) {
      return '₹${(val / 10000000).toStringAsFixed(1)}Cr';
    } else if (val >= 100000) {
      return '₹${(val / 100000).toStringAsFixed(1)}L';
    } else if (val >= 1000) {
      return '₹${(val / 1000).toStringAsFixed(0)}k';
    } else {
      return '₹${val.toInt()}';
    }
  }
}
