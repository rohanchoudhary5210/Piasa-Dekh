import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/services/native_sms_service.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/sms_parser_service.dart';
import 'package:salary_quest/features/transactions/presentation/widgets/sms_permission_rationale_sheet.dart';

/// Flat Professional Luxury Modal for Bank SMS Auto-Tracking & Ingestion
class SmsTrackingSheet extends ConsumerStatefulWidget {
  const SmsTrackingSheet({super.key});

  @override
  ConsumerState<SmsTrackingSheet> createState() => _SmsTrackingSheetState();
}

class _SmsTrackingSheetState extends ConsumerState<SmsTrackingSheet> {
  final NativeSmsService _smsService = NativeSmsService();
  final TextEditingController _testSmsController = TextEditingController();
  final SmsParserService _parser = SmsParserService();

  bool _hasPermission = false;
  bool _isChecking = true;
  bool _isSyncing = false;
  ParsedSmsResult? _testResult;

  final List<String> _sampleSmsPresets = [
    'HDFC Bank: Rs 450.00 debited from A/c XX4912 for Swiggy UPI on 25-OCT-26.',
    'SBI: Rs 1,250.00 spent on your Debit Card ending 8812 at Big Bazaar.',
    'ICICI Bank: INR 80 debited for Delhi Metro Rail payment. Avail Bal: Rs 42,000.',
    'Axis Bank: Rs 2,500.00 credited to A/c XX3301 towards Salary / Reimbursement.',
    'ALERT: Your OTP for NetBanking login is 894120. Valid for 10 mins. Do NOT share.',
  ];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _testSmsController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final granted = await _smsService.checkPermission();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
        _isChecking = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final granted = await SmsPermissionRationaleSheet.show(
      context,
      smsService: _smsService,
    );
    if (mounted) {
      setState(() => _hasPermission = granted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'SMS Auto-Tracking Permission Granted!'
                : 'Permission not granted. You can test SMS manually below.',
          ),
          backgroundColor:
              granted ? AppColors.safeGreen : AppColors.warningAmber,
        ),
      );
    }
  }

  Future<void> _syncCurrentCycle() async {
    if (!_hasPermission) {
      await _requestPermission();
      if (!_hasPermission) return;
    }

    final cycle = ref.read(salaryQuestProvider).cycle;
    setState(() => _isSyncing = true);

    // Sync from cycle.startDate (e.g. 7th) to today
    final results = await _smsService.syncBankSmsSince(cycle.startDate, limit: 150);
    int importedCount = 0;

    for (final parsed in results) {
      if (parsed.amount != null && parsed.isFinancial && !parsed.isIgnored) {
        try {
          await ref.read(salaryQuestProvider.notifier).addTransaction(
                amount: parsed.amount!,
                title: parsed.cleanedMerchant,
                category: parsed.inferredCategory,
                customTimestamp: parsed.timestamp,
                source: TransactionSource.smsAuto,
                explicitDedupeKey: parsed.dedupeKey,
                type: parsed.type == ParsedSmsType.credit
                    ? TransactionType.refund
                    : TransactionType.expense,
              );
          importedCount++;
        } catch (_) {
          // Skip duplicates silently
        }
      }
    }

    if (mounted) {
      setState(() => _isSyncing = false);
      final startStr = DateFormat('d MMM').format(cycle.startDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            importedCount > 0
                ? 'Synced $importedCount transactions from current salary cycle (since $startStr)!'
                : 'Cycle up-to-date: No new transactions found since $startStr.',
          ),
          backgroundColor: AppColors.safeGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _syncTodayOnly() async {
    if (!_hasPermission) {
      await _requestPermission();
      if (!_hasPermission) return;
    }

    setState(() => _isSyncing = true);
    final results = await _smsService.syncTodayBankSms();
    int importedCount = 0;

    for (final parsed in results) {
      if (parsed.amount != null && parsed.isFinancial && !parsed.isIgnored) {
        try {
          await ref.read(salaryQuestProvider.notifier).addTransaction(
                amount: parsed.amount!,
                title: parsed.cleanedMerchant,
                category: parsed.inferredCategory,
                customTimestamp: parsed.timestamp,
                source: TransactionSource.smsAuto,
                explicitDedupeKey: parsed.dedupeKey,
                type: parsed.type == ParsedSmsType.credit
                    ? TransactionType.refund
                    : TransactionType.expense,
              );
          importedCount++;
        } catch (_) {
          // Skip duplicates silently
        }
      }
    }

    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            importedCount > 0
                ? 'Synced $importedCount transactions from today (since 12:00 AM)!'
                : 'Today\'s messages up-to-date: No new transactions found.',
          ),
          backgroundColor: AppColors.safeGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _parseTestSms(String text) {
    if (text.trim().isEmpty) return;
    final result = _parser.parse(sender: 'BANK_SMS', body: text.trim());
    setState(() => _testResult = result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.safeGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 18,
                        color: AppColors.safeGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'SMS AUTO-TRACKING',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: (_hasPermission
                            ? AppColors.safeGreen
                            : AppColors.warningAmber)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (_hasPermission
                              ? AppColors.safeGreen
                              : AppColors.warningAmber)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _isChecking
                        ? 'Checking...'
                        : (_hasPermission ? 'ACTIVE' : 'ACTION NEEDED'),
                    style: TextStyle(
                      color: _hasPermission
                          ? AppColors.safeGreen
                          : AppColors.warningAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Text(
              'SalaryQuest automatically intercepts official Indian Bank & UPI SMS alerts, extracts the exact spend, cleans the merchant name, and updates your daily budget with zero manual typing.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Permission / Sync Controls
            if (!_hasPermission) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.security_rounded,
                      size: 18, color: Colors.black),
                  label: const Text(
                    'ENABLE SMS AUTO-TRACKING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSyncing ? null : _syncInbox,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 4,
                  ),
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.sync_rounded,
                          size: 18, color: Colors.black),
                  label: Text(
                    _isSyncing ? 'SCANNING INBOX...' : 'SYNC RECENT BANK SMS (7 DAYS)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            const Divider(color: AppColors.surfaceBorder, height: 28),

            // Live Parser Test Box
            const Text(
              'TEST SMS PARSER LIVE',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sampleSmsPresets.map((preset) {
                  final label = preset.startsWith('HDFC')
                      ? 'HDFC'
                      : preset.startsWith('SBI')
                          ? 'SBI'
                          : preset.startsWith('ICICI')
                              ? 'ICICI'
                              : preset.startsWith('Axis')
                                  ? 'Axis (Credit)'
                                  : 'OTP (Ignore)';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.surfaceElevated,
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        _testSmsController.text = preset;
                        _parseTestSms(preset);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _testSmsController,
              onChanged: _parseTestSms,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Paste any bank SMS here to test parser...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),

            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _testResult!.isFinancial && !_testResult!.isIgnored
                        ? AppColors.safeGreen.withValues(alpha: 0.4)
                        : AppColors.surfaceBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _testResult!.isIgnored
                              ? 'IGNORED (${_testResult!.type.name.toUpperCase()})'
                              : 'PARSED AS ${_testResult!.type.name.toUpperCase()}',
                          style: TextStyle(
                            color: _testResult!.isIgnored
                                ? AppColors.warningAmber
                                : AppColors.safeGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (_testResult!.amount != null)
                          Text(
                            CurrencyFormatter.formatMoney(_testResult!.amount!),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Merchant: ${_testResult!.cleanedMerchant}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_testResult!.ignoreReason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _testResult!.ignoreReason!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (_testResult!.isFinancial && !_testResult!.isIgnored && _testResult!.amount != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(salaryQuestProvider.notifier)
                                .addTransaction(
                                  amount: _testResult!.amount!,
                                  title: _testResult!.cleanedMerchant,
                                  category: _testResult!.inferredCategory,
                                  customTimestamp: _testResult!.timestamp,
                                  source: TransactionSource.smsAuto,
                                  explicitDedupeKey: _testResult!.dedupeKey,
                                  type: _testResult!.type == ParsedSmsType.credit
                                      ? TransactionType.refund
                                      : TransactionType.expense,
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Test Transaction Logged! (+15 XP)'),
                                  backgroundColor: AppColors.safeGreen,
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.safeGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Text(
                            'CONFIRM & LOG THIS EXPENSE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
