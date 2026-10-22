import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/savings_goals/domain/models/savings_goal.dart';

class SavingsGoalsScreen extends ConsumerStatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  ConsumerState<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends ConsumerState<SavingsGoalsScreen> {
  void _openCreateGoalSheet() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime? selectedDeadline;
    String selectedIcon = '🎯';
    bool makePrimary = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Savings Goal',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Icon',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: ['🎯', '💻', '🚗', '✈️', '🏠', '📱', '💍', '🛡️']
                        .map((icon) {
                      final isSelected = icon == selectedIcon;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedIcon = icon),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.manaPurple.withValues(alpha: 0.3)
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.manaPurple
                                  : AppColors.surfaceBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Text(icon, style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      hintText: 'e.g. New Laptop, Emergency Fund',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Target Amount (₹)',
                      hintText: 'e.g. 50000',
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(color: AppColors.coinGold),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month_rounded,
                              size: 18, color: AppColors.xpBlue),
                          label: Text(
                            selectedDeadline == null
                                ? 'Set Deadline (Optional)'
                                : 'Deadline: ${DateFormat('dd MMM yyyy').format(selectedDeadline!)}',
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate:
                                  DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) {
                              setSheetState(() => selectedDeadline = picked);
                            }
                          },
                        ),
                      ),
                      if (selectedDeadline != null)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: AppColors.dangerRed, size: 18),
                          onPressed: () =>
                              setSheetState(() => selectedDeadline = null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: makePrimary,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.manaPurple,
                    title: const Text(
                      'Set as primary auto-flow target',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                    ),
                    onChanged: (val) =>
                        setSheetState(() => makePrimary = val ?? false),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.manaPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        final parsed = Money.tryParse(amountCtrl.text);

                        if (title.isEmpty || parsed == null || parsed.paise <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid title and target amount'),
                              backgroundColor: AppColors.dangerRed,
                            ),
                          );
                          return;
                        }

                        ref.read(salaryQuestProvider.notifier).createSavingsGoal(
                              title: title,
                              targetAmount: parsed,
                              deadline: selectedDeadline,
                              icon: selectedIcon,
                              isPrimary: makePrimary,
                            );

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎯 Goal "$title" created!'),
                            backgroundColor: AppColors.safeGreen,
                          ),
                        );
                      },
                      child: const Text(
                        'Create Goal',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDepositWithdrawDialog(SavingsGoal goal, bool isDeposit) {
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isDeposit ? 'Add Money to ${goal.title}' : 'Withdraw from ${goal.title}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDeposit
                  ? 'Currently saved: ${CurrencyFormatter.formatMoney(goal.savedAmount)} / ${CurrencyFormatter.formatMoney(goal.targetAmount)}'
                  : 'Currently saved: ${CurrencyFormatter.formatMoney(goal.savedAmount)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: AppColors.coinGold),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDeposit ? AppColors.safeGreen : AppColors.manaPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final parsed = Money.tryParse(amountCtrl.text);
              if (parsed == null || parsed.paise <= 0) {
                return;
              }

              if (isDeposit) {
                ref
                    .read(salaryQuestProvider.notifier)
                    .depositToGoal(goalId: goal.id, amount: parsed);
              } else {
                ref
                    .read(salaryQuestProvider.notifier)
                    .withdrawFromGoal(goalId: goal.id, amount: parsed);
              }

              Navigator.pop(ctx);
            },
            child: Text(isDeposit ? 'Add' : 'Withdraw',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGoal(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Goal?',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        content: Text(
          goal.savedAmount.paise > 0
              ? 'Are you sure you want to delete "${goal.title}"? The accumulated ${CurrencyFormatter.formatMoney(goal.savedAmount)} will be returned to your general discretionary savings.'
              : 'Are you sure you want to delete "${goal.title}"?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Goal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ref
                  .read(salaryQuestProvider.notifier)
                  .deleteSavingsGoal(goal.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Deleted "${goal.title}". ${goal.savedAmount.paise > 0 ? "Returned ${CurrencyFormatter.formatMoney(goal.savedAmount)} to general savings." : ""}'),
                  backgroundColor: AppColors.surfaceElevated,
                ),
              );
            },
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryQuestProvider);
    final goals = state.savingsGoals;

    int totalSavedPaise = 0;
    int totalTargetPaise = 0;
    for (final g in goals) {
      totalSavedPaise += g.savedAmount.paise;
      totalTargetPaise += g.targetAmount.paise;
    }
    final totalSaved = Money.fromPaise(totalSavedPaise);
    final totalTarget = Money.fromPaise(totalTargetPaise);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '🎯 Savings Goals',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.manaPurple, size: 26),
            onPressed: _openCreateGoalSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Savings Vault Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceElevated, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL SAVINGS IN GOALS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CurrencyFormatter.formatMoney(totalSaved),
                      style: const TextStyle(
                        color: AppColors.safeGreen,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Across ${goals.length} active ${goals.length == 1 ? "goal" : "goals"} (Target: ${CurrencyFormatter.formatMoney(totalTarget)})',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Auto-flow Leftover Savings Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: state.isAutoFlowSavingsEnabled
                      ? AppColors.manaPurple.withValues(alpha: 0.5)
                      : AppColors.surfaceBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Text('🌊', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Auto-Flow Leftover Spends',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: state.isAutoFlowSavingsEnabled,
                        activeTrackColor: AppColors.manaPurple,
                        onChanged: goals.isEmpty
                            ? null
                            : (val) {
                                ref
                                    .read(salaryQuestProvider.notifier)
                                    .toggleAutoFlowSavings(val);
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    goals.isEmpty
                        ? 'Create a savings goal below to enable auto-flowing leftover daily budget.'
                        : 'When enabled, unspent daily budget at the end of the day automatically flows into your primary goal.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Goals Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Goals',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16, color: AppColors.manaPurple),
                  label: const Text(
                    'New Goal',
                    style: TextStyle(
                      color: AppColors.manaPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: _openCreateGoalSheet,
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (goals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    const Text(
                      'No Savings Goals Yet',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Set a goal for an emergency fund, travel, or gadget to level up your wealth.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create First Goal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.manaPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _openCreateGoalSheet,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final isPrimary = goal.isPrimary ||
                      (state.autoFlowGoalId != null &&
                          state.autoFlowGoalId == goal.id);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: goal.isCompleted
                            ? AppColors.safeGreen.withValues(alpha: 0.6)
                            : isPrimary
                                ? AppColors.manaPurple.withValues(alpha: 0.5)
                                : AppColors.surfaceBorder,
                        width: goal.isCompleted || isPrimary ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                goal.icon,
                                style: const TextStyle(fontSize: 22),
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
                                          goal.title,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      if (goal.isCompleted) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.safeGreen
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'DONE 🎉',
                                            style: TextStyle(
                                              color: AppColors.safeGreen,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ] else if (isPrimary) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.manaPurple
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Auto-Flow Target',
                                            style: TextStyle(
                                              color: AppColors.manaPurple,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    goal.deadline != null
                                        ? 'Deadline: ${DateFormat('dd MMM yyyy').format(goal.deadline!)}'
                                        : 'No deadline set',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded,
                                  color: AppColors.textSecondary, size: 20),
                              color: AppColors.surfaceElevated,
                              onSelected: (val) {
                                if (val == 'primary') {
                                  ref
                                      .read(salaryQuestProvider.notifier)
                                      .setPrimaryGoal(goal.id);
                                } else if (val == 'delete') {
                                  _confirmDeleteGoal(goal);
                                }
                              },
                              itemBuilder: (ctx) => [
                                if (!isPrimary)
                                  const PopupMenuItem(
                                    value: 'primary',
                                    child: Row(
                                      children: [
                                        Icon(Icons.star_rounded,
                                            color: AppColors.coinGold, size: 18),
                                        SizedBox(width: 8),
                                        Text('Set as Auto-Flow Target',
                                            style: TextStyle(
                                                color: AppColors.textPrimary)),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded,
                                          color: AppColors.dangerRed, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete Goal',
                                          style: TextStyle(
                                              color: AppColors.dangerRed)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: goal.progressRatio,
                            minHeight: 10,
                            backgroundColor: AppColors.surfaceElevated,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goal.isCompleted
                                  ? AppColors.safeGreen
                                  : AppColors.coinGold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${CurrencyFormatter.formatMoney(goal.savedAmount)} / ${CurrencyFormatter.formatMoney(goal.targetAmount)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${goal.progressPercent}%',
                              style: TextStyle(
                                color: goal.isCompleted
                                    ? AppColors.safeGreen
                                    : AppColors.coinGold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.add_rounded,
                                    size: 16, color: AppColors.safeGreen),
                                label: const Text('Add Money',
                                    style: TextStyle(
                                        color: AppColors.safeGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: AppColors.safeGreen
                                          .withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () =>
                                    _showDepositWithdrawDialog(goal, true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.remove_rounded,
                                    size: 16, color: AppColors.manaPurple),
                                label: const Text('Withdraw',
                                    style: TextStyle(
                                        color: AppColors.manaPurple,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: AppColors.manaPurple
                                          .withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: goal.savedAmount.paise <= 0
                                    ? null
                                    : () =>
                                        _showDepositWithdrawDialog(goal, false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
