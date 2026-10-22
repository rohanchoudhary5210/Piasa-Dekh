import 'dart:math';
import '../../../../core/models/money.dart';
import '../../../budget/domain/models/budget_cycle.dart';
import '../../../budget/domain/models/daily_budget.dart';
import '../../../budget/domain/services/budget_calculator.dart';
import '../../../budget/domain/services/cycle_date_calculator.dart';
import '../models/transaction.dart';

class RecomputeResult {
  final List<DailyBudget> budgets;
  final List<Transaction> updatedTransactions;
  final int bossHp;

  const RecomputeResult({
    required this.budgets,
    required this.updatedTransactions,
    required this.bossHp,
  });
}

class TransactionEventRecomputer {
  /// Recomputes all daily budgets, split reimbursement balances, and Boss HP
  /// from an event log of transactions from day 1 through the current day.
  ///
  /// This provides deterministic, idempotent event-sourcing: editing, deleting,
  /// or inserting any transaction recalculates all downstream allocations cleanly.
  static RecomputeResult recompute({
    required BudgetCycle cycle,
    required List<Transaction> transactions,
    required int currentDayIndex,
  }) {
    // 1. Update split pending reimbursements across the transactions list
    final updatedTxList = _updateSplitReimbursements(transactions);

    // 2. Generate pristine base budgets for the cycle
    var currentBudgets =
        BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

    // 3. Group transactions by day index
    final Map<int, List<Transaction>> txByDay = {};
    for (final tx in updatedTxList) {
      final dayIdx = CycleDateCalculator.getDayIndexForTimestamp(
        timestamp: tx.timestamp,
        cycleStartDate: cycle.startDate,
        totalDays: cycle.totalDays,
      );
      txByDay.putIfAbsent(dayIdx, () => []).add(tx);
    }

    // 4. Record net actual spent for days 1 through currentDayIndex
    final trackingStartDay = cycle.salaryReceivedDate != null
        ? cycle.currentDayIndex(cycle.salaryReceivedDate!)
        : 1;

    for (int day = 1; day <= cycle.totalDays; day++) {
      if (day > currentDayIndex) continue;

      final dayTxs = txByDay[day] ?? const [];
      final idx = day - 1;

      if (day < trackingStartDay && dayTxs.isEmpty) {
        // Untracked past day before mid-cycle onboarding:
        // Set actualSpent = allocatedBudget so balanceDelta is 0 and no phantom surplus distorts downstream days.
        currentBudgets[idx] = currentBudgets[idx].copyWith(
          actualSpent: currentBudgets[idx].allocatedBudget,
          isClosed: true,
        );
      } else {
        var netDayImpact = const Money.zero();
        for (final tx in dayTxs) {
          netDayImpact = netDayImpact + tx.netDailyBudgetImpact;
        }

        currentBudgets[idx] = currentBudgets[idx].copyWith(
          actualSpent: netDayImpact,
          isClosed: day < currentDayIndex,
        );
      }
    }

    // 5. Rebalance all downstream days (currentDayIndex + 1 .. N)
    // based on cumulative spending up to currentDayIndex
    if (currentDayIndex < cycle.totalDays) {
      currentBudgets = BudgetCalculator.rebalanceBudgets(
        cycle: cycle,
        currentBudgets: currentBudgets,
        currentDayIndex: currentDayIndex,
      );
    }

    // 6. Calculate Boss HP
    // Boss HP is tied to the monthly savings target.
    // Damage is dealt by saving (allocated budget > actual spent on elapsed days).
    // Boss heals when overspending (actual spent > allocated budget).
    final targetRupees = cycle.savingsTargetAmount.inWholeRupees;
    final bossMaxHp = targetRupees > 0 ? targetRupees : cycle.discretionaryPool.inWholeRupees;

    var netSavingsPaise = 0;
    for (int i = 0; i < currentDayIndex && i < currentBudgets.length; i++) {
      final b = currentBudgets[i];
      netSavingsPaise += (b.allocatedBudget.paise - b.actualSpent.paise);
    }
    final netSavingsRupees = (netSavingsPaise / 100).floor();
    final bossHp = max(0, bossMaxHp - netSavingsRupees).clamp(0, bossMaxHp);

    return RecomputeResult(
      budgets: currentBudgets,
      updatedTransactions: updatedTxList,
      bossHp: bossHp,
    );
  }

  /// Calculates and links split bill reimbursements:
  /// For every split bill parent, finds all reimbursement transactions that reference it,
  /// and updates its `pendingReimbursement` amount.
  static List<Transaction> _updateSplitReimbursements(
      List<Transaction> transactions) {
    // Map parent ID to sum of reimbursements
    final Map<String, Money> reimbursementsByParent = {};
    for (final tx in transactions) {
      if (tx.isReimbursement && tx.parentTransactionId != null) {
        final current =
            reimbursementsByParent[tx.parentTransactionId!] ?? const Money.zero();
        reimbursementsByParent[tx.parentTransactionId!] = current + tx.amount;
      }
    }

    return transactions.map((tx) {
      if (tx.type == TransactionType.splitShare && !tx.isReimbursement) {
        final totalPaid = tx.splitTotal ?? tx.amount;
        final myShare = tx.splitUserShare ?? tx.amount;
        final initialPending = totalPaid - myShare;

        final receivedReimbursements =
            reimbursementsByParent[tx.id] ?? const Money.zero();
        final currentPending = initialPending - receivedReimbursements;

        return tx.copyWith(
          splitTotal: totalPaid,
          splitUserShare: myShare,
          pendingReimbursement: currentPending.isNegative
              ? const Money.zero()
              : currentPending,
        );
      }
      return tx;
    }).toList();
  }
}
