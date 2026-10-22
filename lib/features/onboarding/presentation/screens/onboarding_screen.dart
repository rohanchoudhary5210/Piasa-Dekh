import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/services/native_sms_service.dart';
import 'package:salary_quest/core/utils/currency_formatter.dart';
import 'package:salary_quest/features/budget/domain/models/budget_validation_exception.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_date_calculator.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/home/presentation/screens/home_screen.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/sms_parser_service.dart';
import 'package:salary_quest/features/transactions/presentation/widgets/sms_permission_rationale_sheet.dart';
import 'package:salary_quest/l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;
  final bool promptSmsPermissionOnOpen;

  const OnboardingScreen({
    super.key,
    this.onCompleted,
    this.promptSmsPermissionOnOpen = true,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Aero');
  final _salaryController = TextEditingController(text: '60000');
  final _paydayController = TextEditingController(text: '7');
  final _fixedExpensesController = TextEditingController(text: '0');
  final _savingsGoalController = TextEditingController(text: '0');

  HeroArchetype _selectedArchetype = HeroArchetype.knight;
  bool _isSeriousMode = false;
  bool _autoTrackSms = true;
  final NativeSmsService _smsService = NativeSmsService();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptSmsPermissionIfFirstLaunch();
    });
  }

  Future<void> _promptSmsPermissionIfFirstLaunch() async {
    // Avoid interrupting automated unit/widget tests
    if (!widget.promptSmsPermissionOnOpen ||
        widget.onCompleted != null ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    try {
      final hasPerm = await _smsService.checkPermission();
      if (!hasPerm && mounted) {
        final granted = await SmsPermissionRationaleSheet.show(
          context,
          smsService: _smsService,
        );
        if (mounted) {
          setState(() {
            _autoTrackSms = granted;
          });
          if (granted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⚡ SMS Auto-Tracking enabled! Transactions will sync automatically.',
                ),
                backgroundColor: AppColors.safeGreen,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    _paydayController.dispose();
    _fixedExpensesController.dispose();
    _savingsGoalController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _errorMessage = null);

    final l10n = AppLocalizations.of(context);

    final heroName = _nameController.text.trim();
    if (heroName.isEmpty) {
      setState(() => _errorMessage = l10n?.errorHeroNameEmpty ?? 'Hero name cannot be empty');
      return;
    }

    final salaryParsed = Money.tryParse(_salaryController.text.trim());
    if (salaryParsed == null || salaryParsed.paise <= 0) {
      setState(() => _errorMessage = l10n?.errorSalaryZero ?? 'Salary must be greater than ₹0');
      return;
    }

    final paydayParsed = int.tryParse(_paydayController.text.trim());
    if (paydayParsed == null || paydayParsed < 1 || paydayParsed > 31) {
      setState(() => _errorMessage = l10n?.errorInvalidPayday ?? 'Payday must be between 1 and 31');
      return;
    }

    final fixedExpensesParsed =
        Money.tryParse(_fixedExpensesController.text.trim()) ?? const Money.zero();
    final savingsGoalParsed =
        Money.tryParse(_savingsGoalController.text.trim()) ?? const Money.zero();

    final commitments = fixedExpensesParsed + savingsGoalParsed;
    if (commitments > salaryParsed) {
      setState(() => _errorMessage = l10n?.errorExpensesExceedSalary ??
          'Fixed expenses + savings goal cannot exceed monthly salary');
      return;
    }

    try {
      await ref.read(salaryQuestProvider.notifier).completeOnboarding(
            inHandSalary: salaryParsed,
            paydayDay: paydayParsed,
            fixedExpenses: fixedExpensesParsed,
            savingsGoal: savingsGoalParsed,
            heroName: heroName,
            archetype: _selectedArchetype,
            isSeriousMode: _isSeriousMode,
          );

      if (widget.onCompleted != null) {
        widget.onCompleted!();
        return;
      }

      // Real app runtime: Auto-Track Bank SMS from today (12:00 AM midnight onwards)
      int syncedCount = 0;
      if (_autoTrackSms) {
        try {
          if (!mounted) return;
          final hasPerm = await _smsService.checkPermission();
          bool granted = hasPerm;
          if (!hasPerm && mounted) {
            granted = await SmsPermissionRationaleSheet.show(
              context,
              smsService: _smsService,
            );
          }
          if (granted) {
            final todayMessages = await _smsService.syncTodayBankSms();
            for (final parsed in todayMessages) {
              if (parsed.amount != null) {
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
                syncedCount++;
              }
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        if (syncedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚡ Auto-tracked $syncedCount bank transactions from today (since 12:00 AM)!',
              ),
              backgroundColor: AppColors.safeGreen,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on BudgetValidationException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Setup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.appTitle ?? 'SalaryQuest',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome header
                Text(
                  l10n?.onboardingWelcomeTitle ?? 'Master Your Daily Budget',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n?.onboardingWelcomeSubtitle ??
                      'Turn your monthly salary into a clear, guilt-free daily spending limit.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Validation error banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.dangerRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // SECTION 1: HERO SELECTION
                _buildSectionCard(
                  title: l10n?.heroSelectionTitle ?? 'Choose Your Hero',
                  subtitle: l10n?.heroSelectionSubtitle ??
                      'Select your financial companion who gains XP and levels up.',
                  children: [
                    TextFormField(
                      key: const Key('input_hero_name'),
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: l10n?.heroNameLabel ?? 'Hero Name',
                        prefixIcon: const Icon(Icons.shield_outlined, color: AppColors.xpBlue),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildArchetypeTile(
                      archetype: HeroArchetype.knight,
                      name: l10n?.heroKnightName ?? 'Aero the Knight',
                      desc: l10n?.heroKnightDesc ??
                          'Balanced guardian of savings. High HP resilience.',
                      icon: '🛡️',
                    ),
                    const SizedBox(height: 8),
                    _buildArchetypeTile(
                      archetype: HeroArchetype.dragon,
                      name: 'Fafnir the Dragon',
                      desc: 'Treasure hoarder. Accumulates bonus coins on consecutive streaks.',
                      icon: '🐉',
                    ),
                    const SizedBox(height: 8),
                    _buildArchetypeTile(
                      archetype: HeroArchetype.cyberCat,
                      name: 'Katsu the CyberCat',
                      desc: 'Agile neon tracker. Masters precision spending with streak shields.',
                      icon: '🐾',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // SECTION 2: SALARY & PAYDAY
                _buildSectionCard(
                  title: l10n?.salarySetupTitle ?? 'Monthly Salary & Payday',
                  subtitle: l10n?.salarySetupSubtitle ??
                      'When does your money land, and how much is available to plan?',
                  children: [
                    TextFormField(
                      key: const Key('input_salary'),
                      controller: _salaryController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: l10n?.inHandSalaryLabel ?? 'Monthly In-Hand Salary (₹)',
                        hintText: l10n?.inHandSalaryHint ?? 'e.g. 60000',
                        prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.manaPurple),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [25000, 40000, 60000, 80000, 100000].map((amt) {
                        final currentVal = int.tryParse(_salaryController.text.trim());
                        final isSelected = currentVal == amt;
                        final label = amt >= 100000 ? '₹${amt ~/ 100000}L' : '₹${amt ~/ 1000}k';
                        return ActionChip(
                          label: Text(label),
                          backgroundColor: isSelected ? AppColors.manaPurple : AppColors.surfaceElevated,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 11,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.manaPurple : AppColors.surfaceBorder,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onPressed: () {
                            setState(() {
                              _salaryController.text = amt.toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('input_payday'),
                      controller: _paydayController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: l10n?.paydayDayLabel ?? 'Payday of the Month',
                        hintText: l10n?.paydayDayHint ?? 'Day (1 - 31)',
                        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.xpBlue),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [1, 5, 7, 10, 15, 20, 25, 30].map((d) {
                        final currentVal = int.tryParse(_paydayController.text.trim());
                        final isSelected = currentVal == d;
                        final label = d == 1
                            ? '1st (Full Month)'
                            : d == 7
                                ? '7th (Default)'
                                : '$d${d == 1 ? "st" : d == 2 ? "nd" : d == 3 ? "rd" : "th"}';
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: Colors.white,
                          backgroundColor: AppColors.surfaceElevated,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 11,
                          ),
                          side: BorderSide(
                            color: isSelected ? Colors.white : AppColors.surfaceBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _paydayController.text = d.toString();
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    _buildMidCyclePreview(),
                  ],
                ),
                const SizedBox(height: 16),

                // SECTION 3: FIXED EXPENSES & SAVINGS GOAL
                _buildSectionCard(
                  title: l10n?.fixedExpensesAndGoalTitle ?? 'Commitments & Target',
                  subtitle: l10n?.fixedExpensesAndGoalSubtitle ??
                      'Deduct non-negotiable costs and target savings for your daily pool.',
                  children: [
                    TextFormField(
                      key: const Key('input_fixed_expenses'),
                      controller: _fixedExpensesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: l10n?.fixedExpensesLabel ?? 'Fixed Expenses Total (₹)',
                        hintText: l10n?.fixedExpensesHint ?? 'Rent, EMIs, Bills (e.g. 25000)',
                        prefixIcon: const Icon(Icons.receipt_long, color: AppColors.dangerRed),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [0, 10000, 20000, 30000].map((amt) {
                        final currentVal = int.tryParse(_fixedExpensesController.text.trim()) ?? 0;
                        final isSelected = currentVal == amt;
                        final label = amt == 0 ? '₹0 (None)' : '₹${amt ~/ 1000}k';
                        return ActionChip(
                          label: Text(label),
                          backgroundColor: isSelected ? AppColors.dangerRed : AppColors.surfaceElevated,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 10.5,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.dangerRed : AppColors.surfaceBorder,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onPressed: () {
                            setState(() {
                              _fixedExpensesController.text = amt.toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('input_savings_goal'),
                      controller: _savingsGoalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: l10n?.savingsTargetLabel ?? 'Monthly Savings Target (₹)',
                        hintText: l10n?.savingsTargetHint ?? 'Emergency fund / goals (e.g. 15000)',
                        prefixIcon: const Icon(Icons.savings, color: AppColors.safeGreen),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [0, 5000, 10000, 20000].map((amt) {
                        final currentVal = int.tryParse(_savingsGoalController.text.trim()) ?? 0;
                        final isSelected = currentVal == amt;
                        final label = amt == 0 ? '₹0 (None)' : '₹${amt ~/ 1000}k';
                        return ActionChip(
                          label: Text(label),
                          backgroundColor: isSelected ? AppColors.safeGreen : AppColors.surfaceElevated,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 10.5,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.safeGreen : AppColors.surfaceBorder,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onPressed: () {
                            setState(() {
                              _savingsGoalController.text = amt.toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // SECTION 4: SERIOUS MODE
                _buildSectionCard(
                  title: l10n?.seriousModeTitle ?? 'Serious Mode',
                  subtitle: l10n?.seriousModeSubtitle ??
                      'Want a minimalist corporate dashboard? Toggle Serious Mode to hide RPG sprites.',
                  children: [
                    Material(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile(
                        value: _isSeriousMode,
                        activeTrackColor: AppColors.manaPurple,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                        title: Text(
                          l10n?.seriousModeEnableLabel ?? 'Enable Serious Mode now',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Replaces hero avatar and monsters with sleek minimalist financial cards. Can be toggled anytime in Settings.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                        onChanged: (val) => setState(() => _isSeriousMode = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // SECTION 5: AUTOMATED SMS EXPENSE TRACKING
                _buildSectionCard(
                  title: 'SMS Auto-Tracking',
                  subtitle:
                      'Sync today\'s bank messages and track every new spend in real time.',
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.safeGreenBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.mark_email_read_outlined,
                              color: AppColors.safeGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Auto-Track Bank SMS from Today (12:00 AM)',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Automatically reads today\'s bank debit messages received since midnight and tracks all new expenses until your next salary date.',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            key: const Key('switch_auto_sms'),
                            value: _autoTrackSms,
                            activeThumbColor: AppColors.safeGreen,
                            onChanged: (val) =>
                                setState(() => _autoTrackSms = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SUBMIT BUTTON
                ElevatedButton(
                  key: const Key('btn_complete_setup'),
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.manaPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n?.completeSetupButton ?? 'Complete Setup & Enter Citadel',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildArchetypeTile({
    required HeroArchetype archetype,
    required String name,
    required String desc,
    required String icon,
  }) {
    final isSelected = _selectedArchetype == archetype;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedArchetype = archetype;
          if (_nameController.text.isEmpty ||
              _nameController.text == 'Aero' ||
              _nameController.text == 'Fafnir' ||
              _nameController.text == 'Katsu') {
            _nameController.text = archetype == HeroArchetype.knight
                ? 'Aero'
                : (archetype == HeroArchetype.dragon ? 'Fafnir' : 'Katsu');
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.manaPurple.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.manaPurple : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.safeGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMidCyclePreview() {
    final now = DateTime.now();
    final payday = int.tryParse(_paydayController.text.trim()) ?? 7;
    final clampedPayday = payday.clamp(1, 31);
    final active = CycleDateCalculator.computeActiveCycleDates(
      now: now,
      paydayDay: clampedPayday,
    );
    final remainingDays = active.endDate.difference(now).inDays + 1;
    final startStr = DateFormat('MMM d').format(active.startDate);
    final endStr = DateFormat('MMM d').format(active.endDate);
    final todayStr = DateFormat('MMM d').format(now);

    final salary = Money.tryParse(_salaryController.text.trim()) ?? Money.fromRupees(60000);
    final fixed = Money.tryParse(_fixedExpensesController.text.trim()) ?? const Money.zero();
    final savings = Money.tryParse(_savingsGoalController.text.trim()) ?? const Money.zero();
    final commitments = fixed + savings;
    final pool = salary > commitments ? salary - commitments : const Money.zero();
    final dailyMana = active.totalDays > 0 ? Money.fromPaise(pool.paise ~/ active.totalDays) : const Money.zero();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.manaPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.manaPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 16, color: AppColors.manaPurple),
                  const SizedBox(width: 6),
                  Text(
                    'CYCLE: $startStr – $endStr',
                    style: const TextStyle(
                      color: AppColors.manaPurple,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.manaPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$remainingDays days left',
                  style: const TextStyle(
                    color: AppColors.manaPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TODAY'S DAILY MANA",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatMoney(dailyMana),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.safeGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.safeGreen, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Today ($todayStr): Active tracking begins today across these $remainingDays days until next payday ($endStr). All bank SMS from 12:00 AM today will be synced.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
