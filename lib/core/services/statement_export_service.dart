import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

/// Offline Statement & CSV Exporter for SalaryQuest Cycles
class StatementExportService {
  /// Generates a standardized RFC-4180 compliant CSV string of transactions.
  static String generateCsv({
    required BudgetCycle cycle,
    required List<Transaction> transactions,
  }) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln(
      'Transaction ID,Date,Time,Merchant / Title,Category,Type,Amount (INR),Source,Dedupe Key',
    );

    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    for (final tx in sorted) {
      final dateStr = dateFormat.format(tx.timestamp);
      final timeStr = timeFormat.format(tx.timestamp);
      final safeTitle = _escapeCsv(tx.title);
      final catName = _escapeCsv(tx.category.displayName);
      final typeName = _escapeCsv(tx.type.displayName);
      final amountRupees = tx.amount.inRupees.toStringAsFixed(2);
      final sourceName = _escapeCsv(tx.source.name);
      final dedupe = _escapeCsv(tx.dedupeKey ?? '');

      buffer.writeln(
        '${tx.id},$dateStr,$timeStr,$safeTitle,$catName,$typeName,$amountRupees,$sourceName,$dedupe',
      );
    }

    return buffer.toString();
  }

  /// Generates a human-readable text summary suitable for WhatsApp, Notes, or Email.
  static String generateSummaryText({
    required BudgetCycle cycle,
    required List<Transaction> transactions,
    required int currentDayIndex,
  }) {
    final startStr = DateFormat('dd MMM yyyy').format(cycle.startDate);
    final endStr = DateFormat('dd MMM yyyy').format(cycle.endDate);

    final totalSpentPaise = transactions
        .where((t) => t.type.affectsDailyBudget && t.type != TransactionType.refund)
        .fold<int>(0, (sum, t) => sum + t.amount.paise);

    final totalRefundsPaise = transactions
        .where((t) => t.type == TransactionType.refund)
        .fold<int>(0, (sum, t) => sum + t.amount.paise);

    final netSpentRupees = (totalSpentPaise - totalRefundsPaise) / 100.0;
    final discretionaryRupees = cycle.discretionaryPool.inRupees;
    final remainingPoolRupees = discretionaryRupees - netSpentRupees;

    // Category breakdown
    final categoryTotals = <TransactionCategory, int>{};
    for (final tx in transactions) {
      if (tx.type.affectsDailyBudget && tx.type != TransactionType.refund) {
        categoryTotals[tx.category] =
            (categoryTotals[tx.category] ?? 0) + tx.amount.paise;
      }
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📊 SALARYQUEST CYCLE STATEMENT');
    buffer.writeln('Period: $startStr - $endStr');
    buffer.writeln('Day: $currentDayIndex of ${cycle.totalDays}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('💰 Monthly Salary:    ₹${cycle.inHandSalary.inRupees.toStringAsFixed(0)}');
    buffer.writeln('🎯 Savings Target:    ₹${cycle.savingsTargetAmount.inRupees.toStringAsFixed(0)}');
    buffer.writeln('🛡️ Fixed Commitments: ₹${cycle.fixedExpensesTotal.inRupees.toStringAsFixed(0)}');
    buffer.writeln('🛒 Discretionary Pool: ₹${discretionaryRupees.toStringAsFixed(0)}');
    buffer.writeln('─────────────────────────────────');
    buffer.writeln('📈 SPENDING SUMMARY');
    buffer.writeln('• Total Discretionary Spent: ₹${netSpentRupees.toStringAsFixed(0)}');
    buffer.writeln('• Remaining Mana Pool:       ₹${remainingPoolRupees.toStringAsFixed(0)}');
    buffer.writeln('• Logged Transactions:       ${transactions.length}');
    buffer.writeln('─────────────────────────────────');

    if (sortedCategories.isNotEmpty) {
      buffer.writeln('🏷️ CATEGORY BREAKDOWN');
      for (final entry in sortedCategories) {
        final catRupees = entry.value / 100.0;
        final pct = totalSpentPaise > 0
            ? ((entry.value / totalSpentPaise) * 100).toStringAsFixed(0)
            : '0';
        buffer.writeln(
          '• ${entry.key.displayName}: ₹${catRupees.toStringAsFixed(0)} ($pct%)',
        );
      }
      buffer.writeln('─────────────────────────────────');
    }

    buffer.writeln('Generated 100% on-device by SalaryQuest');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return buffer.toString();
  }

  /// Writes CSV to the device's application documents directory and returns the absolute path.
  static Future<String> exportCsvFile({
    required BudgetCycle cycle,
    required List<Transaction> transactions,
  }) async {
    final csvContent = generateCsv(
      cycle: cycle,
      transactions: transactions,
    );
    final directory = await getApplicationDocumentsDirectory();
    final cleanCycleId = cycle.id.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final filePath = '${directory.path}/salaryquest_statement_$cleanCycleId.csv';
    final file = File(filePath);
    await file.writeAsString(csvContent, flush: true);
    return filePath;
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
