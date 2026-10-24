import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_validation_exception.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:salary_quest/core/services/local_security_service.dart';
import 'package:salary_quest/features/transactions/presentation/widgets/sms_tracking_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final bool isEmbeddedTab;

  const SettingsScreen({
    super.key,
    this.isEmbeddedTab = false,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _salaryController;
  late TextEditingController _fixedController;
  late TextEditingController _savingsController;
  late TextEditingController _paydayController;
  bool _isSavingsPercentage = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(salaryQuestProvider);
    _salaryController = TextEditingController(
      text: state.cycle.inHandSalary.inWholeRupees.toString(),
    );
    _fixedController = TextEditingController(
      text: state.cycle.fixedExpensesTotal.inWholeRupees.toString(),
    );
    _savingsController = TextEditingController(
      text: state.cycle.savingsTargetAmount.inWholeRupees.toString(),
    );
    _paydayController = TextEditingController(
      text: state.cycle.paydayDay.toString(),
    );
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _fixedController.dispose();
    _savingsController.dispose();
    _paydayController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final s = Money.tryParse(_salaryController.text);
    final f = Money.tryParse(_fixedController.text);
    final p = int.tryParse(_paydayController.text) ?? 25;

    if (s == null || f == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numeric amounts'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    Money savingsTarget;
    if (_isSavingsPercentage) {
      final pct = double.tryParse(_savingsController.text) ?? 20.0;
      savingsTarget = s * (pct / 100.0);
    } else {
      savingsTarget = Money.tryParse(_savingsController.text) ?? const Money.zero();
    }

    try {
      ref.read(salaryQuestProvider.notifier).updateSalarySetup(
            inHandSalary: s,
            fixedExpenses: f,
            savingsTarget: savingsTarget,
            paydayDay: p,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Settings saved! Future days rebalanced smoothly.'),
          backgroundColor: AppColors.safeGreen,
        ),
      );
      if (!widget.isEmbeddedTab && Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    } on BudgetValidationException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ${e.message}'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  void _showChangePinDialog(BuildContext context) {
    final pinController = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.pin_outlined, color: AppColors.manaPurple),
                SizedBox(width: 8),
                Text('Set Custom Backup PIN',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter a 4-digit backup PIN to unlock SalaryQuest when biometrics fail:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('input_change_pin'),
                  controller: pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    errorText: error,
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
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                key: const Key('btn_save_pin'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.manaPurple),
                onPressed: () async {
                  final entered = pinController.text.trim();
                  if (entered.length == 4 && int.tryParse(entered) != null) {
                    await LocalSecurityService().setBackupPin(entered);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Backup PIN updated successfully!'),
                          backgroundColor: AppColors.safeGreen,
                        ),
                      );
                    }
                  } else {
                    setDialogState(() {
                      error = 'Please enter exactly 4 numeric digits';
                    });
                  }
                },
                child: const Text('Save PIN'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExtraIncomeDialog() {
    final amountCtrl = TextEditingController();
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('💰', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text('Add Extra Income / Bonus',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Source (e.g. Diwali Bonus, Freelance)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.manaPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final amount = Money.tryParse(amountCtrl.text);
                if (amount != null && amount.paise > 0) {
                  ref.read(salaryQuestProvider.notifier).addExtraIncome(
                        amount: amount,
                        sourceTitle: titleCtrl.text.trim(),
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '🎉 Added ${amount.format()} to treasury! Future daily budgets increased.'),
                      backgroundColor: AppColors.safeGreen,
                    ),
                  );
                }
              },
              child: const Text('Add to Pool'),
            ),
          ],
        );
      },
    );
  }

  void _pickLateSalaryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.manaPurple,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(salaryQuestProvider.notifier).markSalaryReceivedDate(picked);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Salary arrival date marked: ${DateFormat('MMM d, yyyy').format(picked)}. Cycle length updated.'),
          backgroundColor: AppColors.manaPurple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salaryQuestProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isEmbeddedTab,
        title: const Text('Treasury & Cycle Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isClockManipulated) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.warningAmber.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time_filled_rounded,
                        color: AppColors.warningAmber),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Device clock anomaly detected. XP and Coins rewards are paused until clock aligns with normal progression.',
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.surfaceBorder.withValues(alpha: 0.6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.manaPurple, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mid-Cycle Policy: Historical days (Days 1 to ${state.currentDayIndex - 1}) retain their actual spend and allocated budgets. Changes apply exclusively to remaining days.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'PAYDAY & INCOME',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Monthly In-Hand Salary',
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: AppColors.textPrimary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _paydayController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Payday Date (1 to 31)',
                helperText: 'Cycle anchors on this date every month',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'OBLIGATIONS & SAVINGS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _fixedController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Fixed Expenses (Rent, EMI, Bills)',
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: AppColors.textPrimary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _savingsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: _isSavingsPercentage
                          ? 'Savings Goal (%)'
                          : 'Savings Goal (₹)',
                      prefixText: _isSavingsPercentage ? '' : '₹ ',
                      suffixText: _isSavingsPercentage ? '%' : '',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ToggleButtons(
                  isSelected: [!_isSavingsPercentage, _isSavingsPercentage],
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: AppColors.manaPurple,
                  color: AppColors.textSecondary,
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('₹')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('%')),
                  ],
                  onPressed: (index) {
                    setState(() {
                      _isSavingsPercentage = index == 1;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'CYCLE ACTIONS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showExtraIncomeDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.coinGold,
                      side: const BorderSide(color: AppColors.coinGold),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_card_rounded, size: 18),
                    label: const Text('Add Bonus / Income'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickLateSalaryDate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.xpBlue,
                      side: const BorderSide(color: AppColors.xpBlue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.event_available_rounded, size: 18),
                    label: const Text('Mark Late Salary'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'EXPERIENCE MODE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            Material(
              color: AppColors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: ref.watch(salaryQuestProvider).isSeriousMode,
                    activeTrackColor: AppColors.manaPurple,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Serious Mode (Minimalist)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Hides the pet hero, XP, coins, and boss battle. Shows a clean budget dashboard. All gamification still computes in the background.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onChanged: (val) {
                      ref
                          .read(salaryQuestProvider.notifier)
                          .toggleSeriousMode(val);
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  SwitchListTile(
                    value: ref.watch(salaryQuestProvider).isBiometricLockEnabled,
                    activeTrackColor: AppColors.manaPurple,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Biometric App Lock',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Require Fingerprint, Face ID or device PIN on app launch.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onChanged: (val) {
                      ref
                          .read(salaryQuestProvider.notifier)
                          .toggleBiometricLock(val);
                    },
                  ),
                  if (ref.watch(salaryQuestProvider).isBiometricLockEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.pin_outlined, size: 16, color: AppColors.xpBlue),
                              label: const Text(
                                'Change PIN',
                                style: TextStyle(color: AppColors.xpBlue, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.xpBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _showChangePinDialog(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.fingerprint_rounded, size: 16, color: AppColors.manaPurple),
                              label: const Text(
                                'Lock & Test',
                                style: TextStyle(color: AppColors.manaPurple, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.manaPurple),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                ref.read(salaryQuestProvider.notifier).setAuthenticated(false);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  SwitchListTile(
                    value: ref.watch(salaryQuestProvider).isReduceMotion,
                    activeTrackColor: AppColors.manaPurple,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Reduce Motion (Accessibility)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Replaces bouncy scroll physics and character jumps with subtle static transitions.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onChanged: (val) {
                      ref
                          .read(salaryQuestProvider.notifier)
                          .toggleReduceMotion(val);
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Smart Alerts & Quiet Hours',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      ref.watch(salaryQuestProvider).notificationsEnabled
                          ? 'Enabled (${ref.watch(salaryQuestProvider).maxNotificationsPerDay}/day, 80% budget warning, streak protection)'
                          : 'All notifications muted.',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Automated Bank SMS Ingestion',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Auto-track bank & UPI SMS, sync inbox, or test parser.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const SmsTrackingSheet(),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Language / भाषा',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      ref.watch(salaryQuestProvider).languageCode == 'hi'
                          ? 'हिंदी (Hindi)'
                          : 'English',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.language, color: AppColors.textSecondary),
                    onTap: () => _showLanguageDialog(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'DATA BACKUP & RESTORE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: AppColors.surfaceElevated,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.safeGreen),
                    title: const Text('Export Encrypted Backup',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Generate an AES-encrypted backup of cycles & transactions',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    onTap: () => _handleExportBackup(context, ref),
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_download_outlined, color: AppColors.xpBlue),
                    title: const Text('Restore from Encrypted Backup',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Merge backup records using Latest-Edit-Wins conflict resolution',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    onTap: () => _handleRestoreBackup(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'PRIVACY & SECURITY',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text(
                        'Wipe All Data?',
                        style: TextStyle(
                          color: AppColors.dangerRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        'This will permanently delete all your salary cycles, transactions, daily budgets, hero progress, and secure encryption keys from this device.\n\nThis action cannot be undone.',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ref.read(salaryQuestProvider.notifier).wipeAllData();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🗑️ All data and encryption keys wiped clean.'),
                                  backgroundColor: AppColors.dangerRed,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dangerRed,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Wipe & Reset'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_forever_rounded, color: AppColors.dangerRed, size: 20),
                label: const Text(
                  'Wipe All Data & Reset',
                  style: TextStyle(
                    color: AppColors.dangerRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.dangerRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.manaPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save & Rebalance Cycle',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Select Language / भाषा चुनें',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(salaryQuestProvider.notifier).setLocale('en');
              Navigator.pop(ctx);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('English',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(salaryQuestProvider.notifier).setLocale('hi');
              Navigator.pop(ctx);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('हिंदी (Hindi)',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExportBackup(BuildContext context, WidgetRef ref) async {
    final password = await _askBackupPassword(context);
    if (password == null || !context.mounted) return;

    try {
      final encryptedData = await ref
          .read(salaryQuestProvider.notifier)
          .exportBackup(password: password);
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.shield_rounded, color: AppColors.safeGreen),
              SizedBox(width: 8),
              Expanded(
                child: Text('Encrypted Backup Ready',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy this backup and keep it somewhere safe (e.g. email it to yourself or save it in Notes). '
                'You can restore it on any phone with your backup password.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: SelectableText(
                  encryptedData,
                  maxLines: 4,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Without the password this backup cannot be opened — not even by us.',
                style: TextStyle(color: AppColors.warningAmber, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy Backup'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.safeGreen),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: encryptedData));
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔒 Backup copied. Paste it somewhere safe now.'),
                      backgroundColor: AppColors.safeGreen,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup export failed: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  /// Asks for a backup password (entered twice). Returns null if cancelled.
  Future<String?> _askBackupPassword(BuildContext context) {
    final pwController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Set Backup Password',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This password locks your backup. You will need it to restore on this or a new phone.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pwController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Password (min 6 characters)'),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(labelText: 'Repeat password', errorText: error),
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
                final pw = pwController.text;
                if (pw.length < 6) {
                  setDialogState(() => error = 'Use at least 6 characters.');
                  return;
                }
                if (pw != confirmController.text) {
                  setDialogState(() => error = 'Passwords do not match.');
                  return;
                }
                Navigator.pop(ctx, pw);
              },
              child: const Text('Create Backup'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRestoreBackup(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Restore Encrypted Backup',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your AES-encrypted ciphertext below. Records will be merged seamlessly without creating duplicates.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Paste your backup here...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Backup password',
                helperText: 'Leave empty only for old backups made without a password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.manaPurple),
            onPressed: () async {
              final text = controller.text.trim();
              final password = passwordController.text;
              if (text.isEmpty) return;
              Navigator.pop(ctx);

              try {
                final result = await ref
                    .read(salaryQuestProvider.notifier)
                    .restoreBackup(text, password: password);
                // Bring an older backup up to today (new days / new cycle)
                await ref.read(salaryQuestProvider.notifier).catchUpOnResume();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ Restored! ${result.totalTransactions} transactions active (${result.mergedFromBackupCount} merged from backup).',
                      ),
                      backgroundColor: AppColors.safeGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restore failed: $e'),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Decrypt & Restore'),
          ),
        ],
      ),
    );
  }
}
