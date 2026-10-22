import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// Main application title
  ///
  /// In en, this message translates to:
  /// **'SalaryQuest'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Gamified Daily Budget Engine'**
  String get tagline;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Master Your Daily Budget'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn your monthly salary into a clear, guilt-free daily spending limit and defeat the month-end boss.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @heroSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Hero'**
  String get heroSelectionTitle;

  /// No description provided for @heroSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your financial companion who gains XP and levels up as you save.'**
  String get heroSelectionSubtitle;

  /// No description provided for @heroNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Hero Name'**
  String get heroNameLabel;

  /// No description provided for @heroKnightName.
  ///
  /// In en, this message translates to:
  /// **'Aero the Knight'**
  String get heroKnightName;

  /// No description provided for @heroKnightDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced guardian of savings. High HP resilience against unexpected spikes.'**
  String get heroKnightDesc;

  /// No description provided for @heroMageName.
  ///
  /// In en, this message translates to:
  /// **'Lyra the Mage'**
  String get heroMageName;

  /// No description provided for @heroMageDesc.
  ///
  /// In en, this message translates to:
  /// **'Intellect-driven strategist. Earns bonus coins on consecutive under-spend streaks.'**
  String get heroMageDesc;

  /// No description provided for @heroRogueName.
  ///
  /// In en, this message translates to:
  /// **'Kael the Rogue'**
  String get heroRogueName;

  /// No description provided for @heroRogueDesc.
  ///
  /// In en, this message translates to:
  /// **'Agile tracker. Masters precision spending with streak shields.'**
  String get heroRogueDesc;

  /// No description provided for @salarySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary & Payday'**
  String get salarySetupTitle;

  /// No description provided for @salarySetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When does your money land, and how much is available to plan?'**
  String get salarySetupSubtitle;

  /// No description provided for @inHandSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly In-Hand Salary (₹)'**
  String get inHandSalaryLabel;

  /// No description provided for @inHandSalaryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 60000'**
  String get inHandSalaryHint;

  /// No description provided for @paydayDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Payday of the Month'**
  String get paydayDayLabel;

  /// No description provided for @paydayDayHint.
  ///
  /// In en, this message translates to:
  /// **'Day (1 - 31)'**
  String get paydayDayHint;

  /// No description provided for @fixedExpensesAndGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Commitments & Target'**
  String get fixedExpensesAndGoalTitle;

  /// No description provided for @fixedExpensesAndGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deduct your non-negotiable costs and target savings to calculate your daily discretionary pool.'**
  String get fixedExpensesAndGoalSubtitle;

  /// No description provided for @fixedExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed Expenses Total (₹)'**
  String get fixedExpensesLabel;

  /// No description provided for @fixedExpensesHint.
  ///
  /// In en, this message translates to:
  /// **'Rent, EMIs, Utilities (e.g. 25000)'**
  String get fixedExpensesHint;

  /// No description provided for @savingsTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Savings Target (₹)'**
  String get savingsTargetLabel;

  /// No description provided for @savingsTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Emergency fund / investments (e.g. 15000)'**
  String get savingsTargetHint;

  /// No description provided for @seriousModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Serious Mode'**
  String get seriousModeTitle;

  /// No description provided for @seriousModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Want a minimalist, distraction-free corporate dashboard? Toggle Serious Mode to hide RPG sprites, monsters, and game sounds while keeping precision daily budget smoothing.'**
  String get seriousModeSubtitle;

  /// No description provided for @seriousModeEnableLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable Serious Mode now'**
  String get seriousModeEnableLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @completeSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup & Enter Citadel'**
  String get completeSetupButton;

  /// No description provided for @errorSalaryZero.
  ///
  /// In en, this message translates to:
  /// **'Salary must be greater than ₹0'**
  String get errorSalaryZero;

  /// No description provided for @errorExpensesExceedSalary.
  ///
  /// In en, this message translates to:
  /// **'Fixed expenses + savings goal cannot exceed monthly salary'**
  String get errorExpensesExceedSalary;

  /// No description provided for @errorInvalidPayday.
  ///
  /// In en, this message translates to:
  /// **'Payday must be between 1 and 31'**
  String get errorInvalidPayday;

  /// No description provided for @errorHeroNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Hero name cannot be empty'**
  String get errorHeroNameEmpty;

  /// No description provided for @dailyBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Safe-to-Spend'**
  String get dailyBudgetLabel;

  /// No description provided for @spentTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent Today'**
  String get spentTodayLabel;

  /// No description provided for @remainingInPoolLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining Cycle Pool'**
  String get remainingInPoolLabel;

  /// No description provided for @daysRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Days Remaining'**
  String get daysRemainingLabel;

  /// No description provided for @seeAllTransactions.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAllTransactions;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Spend'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @saveAndRecompute.
  ///
  /// In en, this message translates to:
  /// **'Save & Recompute Budgets'**
  String get saveAndRecompute;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted & XP rolled back'**
  String get transactionDeleted;

  /// No description provided for @transactionRestored.
  ///
  /// In en, this message translates to:
  /// **'Transaction restored & budgets updated'**
  String get transactionRestored;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search merchant or description...'**
  String get searchPlaceholder;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterWeek.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get filterWeek;

  /// No description provided for @filterCycle.
  ///
  /// In en, this message translates to:
  /// **'Current Cycle'**
  String get filterCycle;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Found'**
  String get noTransactionsFound;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get categoryFood;

  /// No description provided for @categoryCommute.
  ///
  /// In en, this message translates to:
  /// **'Commute'**
  String get categoryCommute;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Fun & Gaming'**
  String get categoryEntertainment;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills & Utilities'**
  String get categoryBills;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health & Fitness'**
  String get categoryHealth;

  /// No description provided for @categoryMisc.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get categoryMisc;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Data Backup'**
  String get backupTitle;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export your entire financial trajectory into an AES-encrypted backup file or restore on a new device.'**
  String get backupSubtitle;

  /// No description provided for @exportBackupButton.
  ///
  /// In en, this message translates to:
  /// **'Export Encrypted Backup'**
  String get exportBackupButton;

  /// No description provided for @importBackupButton.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup File'**
  String get importBackupButton;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup created successfully!'**
  String get backupExportSuccess;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored and merged without duplicate records!'**
  String get backupImportSuccess;

  /// No description provided for @backupDecryptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Decryption failed: corrupted file or invalid security key'**
  String get backupDecryptionFailed;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language / भाषा'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी (Hindi)'**
  String get languageHindi;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
