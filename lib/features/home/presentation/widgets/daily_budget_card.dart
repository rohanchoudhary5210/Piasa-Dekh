import 'package:flutter/material.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';

/// Flat Professional Bento Hero Card for Today's Discretionary Budget
class DailyBudgetCard extends StatelessWidget {
  final DailyBudget dailyBudget;

  const DailyBudgetCard({super.key, required this.dailyBudget});

  @override
  Widget build(BuildContext context) {
    final remaining = dailyBudget.remainingBudget;
    final spentRatio = dailyBudget.spentRatio.clamp(0.0, 1.0);
    final isOverspent = remaining.isNegative;

    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    if (isOverspent) {
      statusColor = AppColors.dangerRed;
      statusTitle = 'Over Daily Limit';
      statusIcon = Icons.warning_amber_rounded;
    } else if (spentRatio >= 0.8) {
      statusColor = AppColors.warningAmber;
      statusTitle = '80% Mana Consumed';
      statusIcon = Icons.hourglass_bottom_rounded;
    } else {
      statusColor = AppColors.safeGreen;
      statusTitle = 'Safe Zone';
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOverspent
              ? AppColors.dangerRed.withValues(alpha: 0.4)
              : AppColors.surfaceBorder,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.manaPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.manaPurple,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "TODAY'S DAILY MANA",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        statusTitle,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isOverspent
                        ? '-${CurrencyFormatter.formatMoney(remaining.abs())}'
                        : CurrencyFormatter.formatMoney(remaining),
                    style: TextStyle(
                      color: isOverspent
                          ? AppColors.dangerRed
                          : AppColors.textPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isOverspent ? 'overspent' : 'remaining',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: spentRatio,
              minHeight: 5,
              backgroundColor: const Color(0xFF222228),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverspent
                    ? AppColors.dangerRed
                    : (spentRatio >= 0.8
                        ? AppColors.warningAmber
                        : AppColors.safeGreen),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Spent: ${CurrencyFormatter.formatMoney(dailyBudget.actualSpent)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Limit: ${CurrencyFormatter.formatMoney(dailyBudget.allocatedBudget)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
