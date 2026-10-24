import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

/// Flat Professional Luxury Recent Transactions Bento Card
class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String transactionId)? onDelete;
  final Function(String parentTransactionId)? onReimburseSplit;
  final Function(Transaction tx)? onEdit;
  final VoidCallback? onViewAll;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.onDelete,
    this.onReimburseSplit,
    this.onEdit,
    this.onViewAll,
  });

  static IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant_rounded;
      case TransactionCategory.transport:
        return Icons.directions_subway_rounded;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.bills:
        return Icons.receipt_long_outlined;
      case TransactionCategory.entertainment:
        return Icons.sports_esports_outlined;
      case TransactionCategory.health:
        return Icons.local_hospital_outlined;
      case TransactionCategory.groceries:
        return Icons.local_grocery_store_outlined;
      case TransactionCategory.other:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 24,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No expenses logged yet today',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Keep it up for a Zero-Spend bonus, or tap below to log.',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECENT ACTIVITY',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              if (onViewAll != null)
                InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See All (${transactions.length})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  '${transactions.length} items',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.take(5).length,
            separatorBuilder: (_, __) => const Divider(
              color: AppColors.surfaceBorder,
              height: 16,
            ),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final timeStr = DateFormat('hh:mm a').format(tx.timestamp);

              final isPositiveCredit = tx.type == TransactionType.refund ||
                  (tx.type == TransactionType.splitShare && tx.isReimbursement);
              final isNeutral = !tx.type.affectsDailyBudget || tx.isFixedExpense;

              final Color amountColor = isNeutral
                  ? AppColors.textSecondary
                  : isPositiveCredit
                      ? AppColors.safeGreen
                      : AppColors.textPrimary;

              final String signPrefix = isNeutral
                  ? '±'
                  : isPositiveCredit
                      ? '+'
                      : '-';

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onEdit != null ? () => onEdit!(tx) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _getCategoryIcon(tx.category),
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tx.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (tx.isFixedExpense) ...[
                              const SizedBox(width: 6),
                              _buildTag('Fixed', AppColors.xpBlue),
                            ] else if (tx.type == TransactionType.splitShare) ...[
                              const SizedBox(width: 6),
                              _buildTag(
                                tx.isReimbursement
                                    ? 'Reimbursement'
                                    : (tx.pendingReimbursement != null &&
                                            tx.pendingReimbursement!.paise > 0)
                                        ? 'Pending: ${CurrencyFormatter.formatMoney(tx.pendingReimbursement!)}'
                                        : 'Split Settled',
                                AppColors.coinGold,
                              ),
                            ] else if (tx.type != TransactionType.expense) ...[
                              const SizedBox(width: 6),
                              _buildTag(
                                  tx.type.displayName, AppColors.textSecondary),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tx.category.displayName} • $timeStr',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$signPrefix${CurrencyFormatter.formatMoney(tx.amount)}',
                        style: TextStyle(
                          color: amountColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (isNeutral)
                        const Text(
                          'discretionary neutral',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                      onPressed: () => onDelete!(tx.id),
                    ),
                ],
              ),
            ),
          ),
        );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
