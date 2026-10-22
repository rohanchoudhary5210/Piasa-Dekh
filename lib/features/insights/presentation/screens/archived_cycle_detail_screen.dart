import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/home/presentation/widgets/calendar_strip.dart';
import 'package:salary_quest/features/home/presentation/widgets/recent_transactions_list.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

class ArchivedCycleDetailScreen extends StatelessWidget {
  final BudgetCycle cycle;
  final List<DailyBudget> budgets;
  final List<Transaction> transactions;

  const ArchivedCycleDetailScreen({
    super.key,
    required this.cycle,
    required this.budgets,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final startStr = DateFormat('dd MMM yyyy').format(cycle.startDate);
    final endStr = DateFormat('dd MMM yyyy').format(cycle.endDate);

    int totalSpentPaise = 0;
    for (final tx in transactions) {
      if (!tx.type.affectsDailyBudget || tx.isFixedExpense) continue;
      if (tx.type == TransactionType.refund ||
          (tx.type == TransactionType.splitShare && tx.isReimbursement)) {
        totalSpentPaise -= tx.amount.paise;
      } else {
        totalSpentPaise += tx.amount.paise;
      }
    }

    final totalSpent = Money.fromPaise(totalSpentPaise > 0 ? totalSpentPaise : 0);
    final netSavedPaise = cycle.discretionaryPool.paise - totalSpent.paise;
    final netSaved = Money.fromPaise(netSavedPaise > 0 ? netSavedPaise : 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '📜 Cycle Archive (Read-Only)',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Read-Only Warning Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.coinGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.coinGold.withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, color: AppColors.coinGold, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Historical Record: This cycle is closed and immutable.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cycle Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$startStr  →  $endStr',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cycle.totalDays} Total Days • Payday: Day ${cycle.paydayDay}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Salary In-Hand', cycle.inHandSalary, AppColors.textPrimary),
                      _buildMetric('Fixed Expenses', cycle.fixedExpensesTotal, AppColors.xpBlue),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Discretionary Spent', totalSpent, AppColors.dangerRed),
                      _buildMetric('Surplus Saved', netSaved, AppColors.safeGreen),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cycle Calendar Grid (Read-Only)
            CalendarGridWidget(
              budgets: budgets,
              currentDayIndex: cycle.totalDays + 1, // All days rendered as closed/past
            ),
            const SizedBox(height: 20),

            // Transactions History (Read-Only: onDelete is null)
            RecentTransactionsList(
              transactions: transactions,
              onDelete: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, Money amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            CurrencyFormatter.formatMoney(amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
