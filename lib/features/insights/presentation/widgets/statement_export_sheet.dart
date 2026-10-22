import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/services/statement_export_service.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

/// Luxury Modal for Exporting Statements (CSV, Text Report, File Save)
class StatementExportSheet extends StatefulWidget {
  final BudgetCycle cycle;
  final List<Transaction> transactions;
  final int currentDayIndex;

  const StatementExportSheet({
    super.key,
    required this.cycle,
    required this.transactions,
    required this.currentDayIndex,
  });

  static Future<void> show(
    BuildContext context, {
    required BudgetCycle cycle,
    required List<Transaction> transactions,
    required int currentDayIndex,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatementExportSheet(
        cycle: cycle,
        transactions: transactions,
        currentDayIndex: currentDayIndex,
      ),
    );
  }

  @override
  State<StatementExportSheet> createState() => _StatementExportSheetState();
}

class _StatementExportSheetState extends State<StatementExportSheet> {
  bool _isSavingFile = false;
  String? _savedFilePath;

  Future<void> _copyCsv() async {
    final csv = StatementExportService.generateCsv(
      cycle: widget.cycle,
      transactions: widget.transactions,
    );
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 CSV copied to clipboard! Ready to paste in Excel / Sheets.'),
        backgroundColor: AppColors.safeGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _copySummary() async {
    final summary = StatementExportService.generateSummaryText(
      cycle: widget.cycle,
      transactions: widget.transactions,
      currentDayIndex: widget.currentDayIndex,
    );
    await Clipboard.setData(ClipboardData(text: summary));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📝 Summary report copied to clipboard!'),
        backgroundColor: AppColors.safeGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveCsvFile() async {
    setState(() => _isSavingFile = true);
    try {
      final path = await StatementExportService.exportCsvFile(
        cycle: widget.cycle,
        transactions: widget.transactions,
      );
      if (!mounted) return;
      setState(() {
        _isSavingFile = false;
        _savedFilePath = path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💾 Saved to: $path'),
          backgroundColor: AppColors.safeGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingFile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save file: $e'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cyclePeriod =
        '${DateFormat('dd MMM').format(widget.cycle.startDate)} - ${DateFormat('dd MMM yyyy').format(widget.cycle.endDate)}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.xpBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.ios_share_rounded,
                    size: 22,
                    color: AppColors.xpBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Export Statement',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$cyclePeriod • ${widget.transactions.length} transactions',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Option 1: Copy CSV
            _buildActionTile(
              icon: Icons.table_chart_rounded,
              iconColor: AppColors.safeGreen,
              title: 'Copy CSV to Clipboard',
              subtitle: 'Full raw dataset for Google Sheets, Microsoft Excel, or Numbers.',
              onTap: _copyCsv,
            ),
            const SizedBox(height: 12),

            // Option 2: Copy Summary Text
            _buildActionTile(
              icon: Icons.assignment_outlined,
              iconColor: AppColors.coinGold,
              title: 'Copy Text Summary',
              subtitle: 'Formatted clean summary for WhatsApp, Telegram, or personal notes.',
              onTap: _copySummary,
            ),
            const SizedBox(height: 12),

            // Option 3: Save CSV File to Storage
            _buildActionTile(
              icon: Icons.download_done_rounded,
              iconColor: AppColors.manaPurple,
              title: _isSavingFile ? 'Saving File...' : 'Save CSV to Device Storage',
              subtitle: _savedFilePath != null
                  ? 'Saved: $_savedFilePath'
                  : 'Writes an offline .csv file to your app documents folder.',
              isLoading: _isSavingFile,
              onTap: _isSavingFile ? null : _saveCsvFile,
            ),
            const SizedBox(height: 20),

            // Dismiss
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.surfaceBorder.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
