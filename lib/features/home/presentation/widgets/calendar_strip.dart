import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';

/// Flat Professional Luxury Date-Wise Budget Cycle Grid
class CalendarGridWidget extends StatelessWidget {
  final List<DailyBudget> budgets;
  final int currentDayIndex;
  final ValueChanged<DailyBudget>? onDayTapped;
  final VoidCallback? onChangePayday;
  final int? paydayDay;

  const CalendarGridWidget({
    super.key,
    required this.budgets,
    required this.currentDayIndex,
    this.onDayTapped,
    this.onChangePayday,
    this.paydayDay,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return const SizedBox.shrink();
    }

    final startDate = budgets.first.date;
    final endDate = budgets.last.date;
    final todayBudget = (currentDayIndex >= 1 && currentDayIndex <= budgets.length)
        ? budgets[currentDayIndex - 1]
        : budgets.first;

    final startStr = DateFormat('MMM d').format(startDate);
    final endStr = DateFormat('MMM d').format(endDate);
    final todayStr = DateFormat('d MMM').format(todayBudget.date);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Cycle Range & Payday Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.xpBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.xpBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'CYCLE CALENDAR',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$startStr – $endStr • Day $currentDayIndex of ${budgets.length}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onChangePayday,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        paydayDay != null ? 'Payday: ${paydayDay}th' : 'Today: $todayStr',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (onChangePayday != null) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.tune_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date-wise Grid (7 columns representing full weeks)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: budgets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final day = budgets[index];
              final isToday = day.dayIndex == currentDayIndex;
              final isPast = day.dayIndex < currentDayIndex;

              // Display month label if it's the 1st of month or first day of cycle
              final isMonthStart = index == 0 || day.date.day == 1;
              final monthLabel = DateFormat('MMM').format(day.date).toUpperCase();
              final weekdayLabel = DateFormat('E').format(day.date).toUpperCase();

              Color cellBg;
              Color borderCol;
              Color textCol;

              if (isToday) {
                cellBg = Colors.white;
                borderCol = Colors.white;
                textCol = Colors.black;
              } else if (isPast) {
                if (day.actualSpent.isZero) {
                  cellBg = AppColors.coinGold.withValues(alpha: 0.15);
                  borderCol = AppColors.coinGold.withValues(alpha: 0.5);
                  textCol = AppColors.coinGold;
                } else if (day.actualSpent <= day.allocatedBudget) {
                  cellBg = AppColors.safeGreenBg;
                  borderCol = AppColors.safeGreen.withValues(alpha: 0.5);
                  textCol = AppColors.safeGreen;
                } else {
                  cellBg = AppColors.dangerRedBg;
                  borderCol = AppColors.dangerRed.withValues(alpha: 0.5);
                  textCol = AppColors.dangerRed;
                }
              } else {
                cellBg = AppColors.surfaceElevated.withValues(alpha: 0.6);
                borderCol = AppColors.surfaceBorder.withValues(alpha: 0.5);
                textCol = AppColors.textMuted;
              }

              return InkWell(
                onTap: () {
                  if (onDayTapped != null) {
                    onDayTapped!(day);
                  } else {
                    final dateFull = DateFormat('EEE, d MMM').format(day.date);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$dateFull (Day ${day.dayIndex}): Budget ${CurrencyFormatter.formatMoney(day.allocatedBudget)} | Spent: ${CurrencyFormatter.formatMoney(day.actualSpent)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: cellBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: borderCol,
                      width: isToday ? 2.0 : 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Month label on 1st/start, or weekday abbreviation
                        Text(
                          isMonthStart ? monthLabel : weekdayLabel,
                          style: TextStyle(
                            color: isToday
                                ? Colors.black.withValues(alpha: 0.7)
                                : (isMonthStart
                                    ? AppColors.xpBlue
                                    : AppColors.textMuted),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 1),

                        // Actual calendar day number (e.g. 7, 8, 9... 31, 1, 2)
                        Text(
                          '${day.date.day}',
                          style: TextStyle(
                            color: textCol,
                            fontWeight: isToday ? FontWeight.w900 : FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),

                        // Today indicator badge
                        if (isToday)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          )
                        else if (isPast && day.actualSpent.isZero)
                          Container(
                            width: 3.5,
                            height: 3.5,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: const BoxDecoration(
                              color: AppColors.coinGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Sleek Legend
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 12,
            runSpacing: 6,
            children: [
              _legendItem(Colors.white, 'Today'),
              _legendItem(AppColors.safeGreen, 'Under Limit'),
              _legendItem(AppColors.coinGold, 'Zero Spend'),
              _legendItem(AppColors.dangerRed, 'Overspent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
