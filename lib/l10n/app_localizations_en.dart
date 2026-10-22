// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SalaryQuest';

  @override
  String get tagline => 'Gamified Daily Budget Engine';

  @override
  String get onboardingWelcomeTitle => 'Master Your Daily Budget';

  @override
  String get onboardingWelcomeSubtitle =>
      'Turn your monthly salary into a clear, guilt-free daily spending limit and defeat the month-end boss.';

  @override
  String get heroSelectionTitle => 'Choose Your Hero';

  @override
  String get heroSelectionSubtitle =>
      'Select your financial companion who gains XP and levels up as you save.';

  @override
  String get heroNameLabel => 'Hero Name';

  @override
  String get heroKnightName => 'Aero the Knight';

  @override
  String get heroKnightDesc =>
      'Balanced guardian of savings. High HP resilience against unexpected spikes.';

  @override
  String get heroMageName => 'Lyra the Mage';

  @override
  String get heroMageDesc =>
      'Intellect-driven strategist. Earns bonus coins on consecutive under-spend streaks.';

  @override
  String get heroRogueName => 'Kael the Rogue';

  @override
  String get heroRogueDesc =>
      'Agile tracker. Masters precision spending with streak shields.';

  @override
  String get salarySetupTitle => 'Monthly Salary & Payday';

  @override
  String get salarySetupSubtitle =>
      'When does your money land, and how much is available to plan?';

  @override
  String get inHandSalaryLabel => 'Monthly In-Hand Salary (₹)';

  @override
  String get inHandSalaryHint => 'e.g. 60000';

  @override
  String get paydayDayLabel => 'Payday of the Month';

  @override
  String get paydayDayHint => 'Day (1 - 31)';

  @override
  String get fixedExpensesAndGoalTitle => 'Commitments & Target';

  @override
  String get fixedExpensesAndGoalSubtitle =>
      'Deduct your non-negotiable costs and target savings to calculate your daily discretionary pool.';

  @override
  String get fixedExpensesLabel => 'Fixed Expenses Total (₹)';

  @override
  String get fixedExpensesHint => 'Rent, EMIs, Utilities (e.g. 25000)';

  @override
  String get savingsTargetLabel => 'Monthly Savings Target (₹)';

  @override
  String get savingsTargetHint => 'Emergency fund / investments (e.g. 15000)';

  @override
  String get seriousModeTitle => 'Serious Mode';

  @override
  String get seriousModeSubtitle =>
      'Want a minimalist, distraction-free corporate dashboard? Toggle Serious Mode to hide RPG sprites, monsters, and game sounds while keeping precision daily budget smoothing.';

  @override
  String get seriousModeEnableLabel => 'Enable Serious Mode now';

  @override
  String get continueButton => 'Continue';

  @override
  String get completeSetupButton => 'Complete Setup & Enter Citadel';

  @override
  String get errorSalaryZero => 'Salary must be greater than ₹0';

  @override
  String get errorExpensesExceedSalary =>
      'Fixed expenses + savings goal cannot exceed monthly salary';

  @override
  String get errorInvalidPayday => 'Payday must be between 1 and 31';

  @override
  String get errorHeroNameEmpty => 'Hero name cannot be empty';

  @override
  String get dailyBudgetLabel => 'Today\'s Safe-to-Spend';

  @override
  String get spentTodayLabel => 'Spent Today';

  @override
  String get remainingInPoolLabel => 'Remaining Cycle Pool';

  @override
  String get daysRemainingLabel => 'Days Remaining';

  @override
  String get seeAllTransactions => 'See All';

  @override
  String get addTransaction => 'Add Spend';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get saveAndRecompute => 'Save & Recompute Budgets';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get undo => 'Undo';

  @override
  String get transactionDeleted => 'Transaction deleted & XP rolled back';

  @override
  String get transactionRestored => 'Transaction restored & budgets updated';

  @override
  String get searchPlaceholder => 'Search merchant or description...';

  @override
  String get filterAll => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String get filterWeek => '7 Days';

  @override
  String get filterCycle => 'Current Cycle';

  @override
  String get noTransactionsFound => 'No Transactions Found';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get categoryFood => 'Food & Dining';

  @override
  String get categoryCommute => 'Commute';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryEntertainment => 'Fun & Gaming';

  @override
  String get categoryBills => 'Bills & Utilities';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHealth => 'Health & Fitness';

  @override
  String get categoryMisc => 'Misc';

  @override
  String get backupTitle => 'Encrypted Data Backup';

  @override
  String get backupSubtitle =>
      'Export your entire financial trajectory into an AES-encrypted backup file or restore on a new device.';

  @override
  String get exportBackupButton => 'Export Encrypted Backup';

  @override
  String get importBackupButton => 'Restore from Backup File';

  @override
  String get backupExportSuccess => 'Encrypted backup created successfully!';

  @override
  String get backupImportSuccess =>
      'Data restored and merged without duplicate records!';

  @override
  String get backupDecryptionFailed =>
      'Decryption failed: corrupted file or invalid security key';

  @override
  String get settingsLanguage => 'Language / भाषा';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी (Hindi)';
}
