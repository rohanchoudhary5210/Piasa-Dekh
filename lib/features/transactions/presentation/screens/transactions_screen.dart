import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/presentation/widgets/edit_transaction_sheet.dart';
import 'package:salary_quest/features/insights/presentation/widgets/statement_export_sheet.dart';

enum DateFilterOption {
  all('All'),
  today('Today'),
  last7Days('Last 7 Days'),
  thisCycle('This Cycle');

  final String label;
  const DateFilterOption(this.label);
}

class TransactionsScreen extends ConsumerStatefulWidget {
  final bool isEmbeddedTab;

  const TransactionsScreen({
    super.key,
    this.isEmbeddedTab = false,
  });

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionCategory? _selectedCategory;
  TransactionType? _selectedType;
  DateFilterOption _selectedDateFilter = DateFilterOption.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filterTransactions(
    List<Transaction> allTransactions,
    DateTime cycleStart,
    DateTime cycleEnd,
  ) {
    final now = DateTime.now();

    return allTransactions.where((tx) {
      // 1. Text search filter
      if (_searchQuery.isNotEmpty) {
        final titleMatch = tx.title.toLowerCase().contains(_searchQuery);
        final categoryMatch =
            tx.category.displayName.toLowerCase().contains(_searchQuery);
        if (!titleMatch && !categoryMatch) return false;
      }

      // 2. Category filter
      if (_selectedCategory != null && tx.category != _selectedCategory) {
        return false;
      }

      // 3. Type filter
      if (_selectedType != null && tx.type != _selectedType) {
        return false;
      }

      // 4. Date filter
      switch (_selectedDateFilter) {
        case DateFilterOption.all:
          break;
        case DateFilterOption.today:
          if (tx.timestamp.year != now.year ||
              tx.timestamp.month != now.month ||
              tx.timestamp.day != now.day) {
            return false;
          }
          break;
        case DateFilterOption.last7Days:
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          if (tx.timestamp.isBefore(sevenDaysAgo)) {
            return false;
          }
          break;
        case DateFilterOption.thisCycle:
          if (tx.timestamp.isBefore(cycleStart) ||
              tx.timestamp.isAfter(cycleEnd.add(const Duration(days: 1)))) {
            return false;
          }
          break;
      }

      return true;
    }).toList();
  }

  Future<void> _handleDelete(Transaction tx) async {
    final deleted = await ref
        .read(salaryQuestProvider.notifier)
        .deleteTransaction(tx.id);

    if (!mounted || deleted == null) return;

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
  }

  /// Records money a friend paid back for a split bill.
  Future<void> _handleMarkPaidBack(Transaction tx) async {
    final pending = tx.pendingReimbursement ?? const Money.zero();
    final controller =
        TextEditingController(text: pending.inRupees.toStringAsFixed(0));

    final amount = await showDialog<Money>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Money paid back',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How much did you get back for "${tx.title}"? (${CurrencyFormatter.formatMoney(pending)} pending)',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(prefixText: '₹ '),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = Money.tryParse(controller.text.trim());
              if (parsed == null || !parsed.isPositive) return;
              Navigator.pop(ctx, parsed > pending ? pending : parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (amount == null || !mounted) return;
    try {
      await ref.read(salaryQuestProvider.notifier).recordSplitReimbursement(
            parentTransactionId: tx.id,
            reimbursementAmount: amount,
            note: 'Paid back: ${tx.title}',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${CurrencyFormatter.formatMoney(amount)} paid back recorded'),
          backgroundColor: AppColors.safeGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not record: $e'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  void _handleEdit(Transaction tx) {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryQuestProvider);
    final filtered = _filterTransactions(
      state.transactions,
      state.cycle.startDate,
      state.cycle.endDate,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isEmbeddedTab,
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Export Statement',
            onPressed: () {
              StatementExportSheet.show(
                context,
                cycle: state.cycle,
                transactions: state.transactions,
                currentDayIndex: state.currentDayIndex,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Clear Filters',
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedCategory = null;
                _selectedType = null;
                _selectedDateFilter = DateFilterOption.all;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  style:
                      const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search merchant, note, किराना...',
                    hintStyle:
                        const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Horizontal Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Date filter menu chip
                      PopupMenuButton<DateFilterOption>(
                        initialValue: _selectedDateFilter,
                        color: AppColors.surfaceElevated,
                        onSelected: (val) =>
                            setState(() => _selectedDateFilter = val),
                        itemBuilder: (ctx) => DateFilterOption.values
                            .map((opt) => PopupMenuItem(
                                  value: opt,
                                  child: Text(
                                    opt.label,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary),
                                  ),
                                ))
                            .toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedDateFilter != DateFilterOption.all
                                ? AppColors.manaPurple
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color:
                                    _selectedDateFilter != DateFilterOption.all
                                        ? Colors.white
                                        : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedDateFilter.label,
                                style: TextStyle(
                                  color: _selectedDateFilter !=
                                          DateFilterOption.all
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  size: 16, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Category filter menu chip
                      PopupMenuButton<TransactionCategory?>(
                        initialValue: _selectedCategory,
                        color: AppColors.surfaceElevated,
                        onSelected: (val) =>
                            setState(() => _selectedCategory = val),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: null,
                            child: Text('All Categories',
                                style:
                                    TextStyle(color: AppColors.textPrimary)),
                          ),
                          ...TransactionCategory.values.map(
                            (c) => PopupMenuItem(
                              value: c,
                              child: Text(
                                '${c.iconSymbol} ${c.displayName}',
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedCategory != null
                                ? AppColors.manaPurple
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedCategory == null
                                    ? '🏷️ Category'
                                    : '${_selectedCategory!.iconSymbol} ${_selectedCategory!.displayName}',
                                style: TextStyle(
                                  color: _selectedCategory != null
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  size: 16, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Type filter menu chip
                      PopupMenuButton<TransactionType?>(
                        initialValue: _selectedType,
                        color: AppColors.surfaceElevated,
                        onSelected: (val) =>
                            setState(() => _selectedType = val),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: null,
                            child: Text('All Types',
                                style:
                                    TextStyle(color: AppColors.textPrimary)),
                          ),
                          ...TransactionType.values.map(
                            (t) => PopupMenuItem(
                              value: t,
                              child: Text(
                                t.displayName,
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedType != null
                                ? AppColors.manaPurple
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedType == null
                                    ? '⚙️ Type'
                                    : _selectedType!.displayName,
                                style: TextStyle(
                                  color: _selectedType != null
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  size: 16, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Count and Status Summary Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  '${filtered.length} of ${state.transactions.length} Transactions',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Tap to Edit • Swipe to Delete',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Transactions List View
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return _buildDismissibleTransactionTile(tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleTransactionTile(Transaction tx) {
    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.dangerRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
      ),
      onDismissed: (_) => _handleDelete(tx),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleEdit(tx),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tx.category.iconSymbol,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),

                // Title, Category & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tx.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (tx.isFixedExpense) ...[
                            const SizedBox(width: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _buildTag('Fixed', AppColors.xpBlue),
                            ),
                          ] else if (tx.type == TransactionType.splitShare) ...[
                            const SizedBox(width: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _buildTag('Split', AppColors.coinGold),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.category.displayName} • ${DateFormat('dd MMM, hh:mm a').format(tx.timestamp)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      if (tx.type == TransactionType.splitShare &&
                          !tx.isReimbursement &&
                          (tx.pendingReimbursement?.isPositive ?? false))
                        GestureDetector(
                          key: Key('btn_mark_paid_back_${tx.id}'),
                          onTap: () => _handleMarkPaidBack(tx),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${CurrencyFormatter.formatMoney(tx.pendingReimbursement!)} pending • Tap to mark paid back',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.coinGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Amount
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatSignedAmount(tx),
                          style: TextStyle(
                            color: _resolveAmountColor(tx),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!tx.type.affectsDailyBudget || tx.isFixedExpense)
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '0 daily pool',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text(
              'No Transactions Found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your search terms or clearing active category and date filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.manaPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCategory = null;
                  _selectedType = null;
                  _selectedDateFilter = DateFilterOption.all;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _resolveAmountColor(Transaction tx) {
    if (!tx.type.affectsDailyBudget || tx.isFixedExpense) {
      return AppColors.textSecondary;
    }
    if (tx.type == TransactionType.refund ||
        (tx.type == TransactionType.splitShare && tx.isReimbursement)) {
      return AppColors.safeGreen;
    }
    return AppColors.dangerRed;
  }

  String _formatSignedAmount(Transaction tx) {
    if (!tx.type.affectsDailyBudget || tx.isFixedExpense) {
      return '±${CurrencyFormatter.formatMoney(tx.amount)}';
    }
    if (tx.type == TransactionType.refund ||
        (tx.type == TransactionType.splitShare && tx.isReimbursement)) {
      return '+${CurrencyFormatter.formatMoney(tx.amount)}';
    }
    return '-${CurrencyFormatter.formatMoney(tx.amount)}';
  }
}
