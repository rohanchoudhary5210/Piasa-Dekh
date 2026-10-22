import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/database/app_database.dart';
import 'package:salary_quest/core/database/salary_quest_repository.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/services/backup_restore_service.dart';
import 'package:salary_quest/core/services/local_security_service.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:salary_quest/features/savings_goals/domain/models/savings_goal.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;
  late SalaryQuestRepository repository;
  late LocalSecurityService securityService;
  late SalaryQuestNotifier notifier;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = SalaryQuestRepository(db);
    final memoryFallback = <String, String>{};
    securityService = LocalSecurityService(memoryFallback: memoryFallback);
    notifier = SalaryQuestNotifier(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildLocalizedApp({
    required Widget child,
    Locale locale = const Locale('en'),
    SalaryQuestNotifier? customNotifier,
  }) {
    return ProviderScope(
      overrides: [
        salaryQuestProvider.overrideWith((ref) => customNotifier ?? notifier),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('TASK 6: Onboarding Form & Validation Tests', () {
    testWidgets('1. Salary Validation: Rejects ₹0 or negative salary with clear error',
        (tester) async {
      await tester.pumpWidget(buildLocalizedApp(child: const OnboardingScreen()));
      await tester.pumpAndSettle();

      // Enter 0 salary
      await tester.enterText(find.byKey(const Key('input_salary')), '0');

      // Tap Complete Setup
      await tester.ensureVisible(find.byKey(const Key('btn_complete_setup')));
      await tester.tap(find.byKey(const Key('btn_complete_setup')));
      await tester.pumpAndSettle();

      // Clear validation error displayed
      expect(find.text('Salary must be greater than ₹0'), findsOneWidget);
    });

    testWidgets('2. Commitments Validation: Rejects fixed expenses + savings > salary',
        (tester) async {
      await tester.pumpWidget(buildLocalizedApp(child: const OnboardingScreen()));
      await tester.pumpAndSettle();

      // Salary 50,000, Fixed 40,000, Savings 20,000 (Total 60,000 > 50,000)
      await tester.enterText(find.byKey(const Key('input_salary')), '50000');
      await tester.enterText(find.byKey(const Key('input_fixed_expenses')), '40000');
      await tester.enterText(find.byKey(const Key('input_savings_goal')), '20000');

      // Tap Complete Setup
      await tester.ensureVisible(find.byKey(const Key('btn_complete_setup')));
      await tester.tap(find.byKey(const Key('btn_complete_setup')));
      await tester.pumpAndSettle();

      // Clear validation error displayed
      expect(
        find.text('Fixed expenses + savings goal cannot exceed monthly salary'),
        findsOneWidget,
      );
    });

    testWidgets('3. Payday Validation: Rejects invalid payday (day > 31 or < 1)',
        (tester) async {
      await tester.pumpWidget(buildLocalizedApp(child: const OnboardingScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('input_payday')), '35');

      await tester.ensureVisible(find.byKey(const Key('btn_complete_setup')));
      await tester.tap(find.byKey(const Key('btn_complete_setup')));
      await tester.pumpAndSettle();

      expect(find.text('Payday must be between 1 and 31'), findsOneWidget);
    });

    testWidgets('4. Hero Name Validation: Rejects empty hero name',
        (tester) async {
      await tester.pumpWidget(buildLocalizedApp(child: const OnboardingScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('input_hero_name')), '   ');

      await tester.ensureVisible(find.byKey(const Key('btn_complete_setup')));
      await tester.tap(find.byKey(const Key('btn_complete_setup')));
      await tester.pumpAndSettle();

      expect(find.text('Hero name cannot be empty'), findsOneWidget);
    });

    testWidgets('5. Successful Onboarding: creates cycle, sets hero, and marks isOnboarded: true',
        (tester) async {
      bool onboardingDone = false;
      await tester.pumpWidget(
        buildLocalizedApp(
          child: OnboardingScreen(onCompleted: () => onboardingDone = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('input_hero_name')), 'Valkyrie');

      // Choose Dragon archetype
      await tester.tap(find.text('Fafnir the Dragon'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('input_salary')), '80000');
      await tester.enterText(find.byKey(const Key('input_payday')), '1');
      await tester.enterText(find.byKey(const Key('input_fixed_expenses')), '30000');
      await tester.enterText(find.byKey(const Key('input_savings_goal')), '20000');

      // Toggle Serious Mode
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.byKey(const Key('btn_complete_setup')));
      await tester.tap(find.byKey(const Key('btn_complete_setup')));
      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      expect(onboardingDone, isTrue);

      final state = notifier.state;
      expect(state.isOnboarded, isTrue);
      expect(state.isSeriousMode, isTrue);
      expect(state.hero.archetype, equals(HeroArchetype.dragon));
      expect(state.cycle.inHandSalary, equals(Money.fromRupees(80000)));
      expect(state.cycle.fixedExpensesTotal, equals(Money.fromRupees(30000)));
      expect(state.cycle.savingsTargetAmount, equals(Money.fromRupees(20000)));
      expect(state.cycle.paydayDay, equals(1));
      expect(state.dailyBudgets, isNotEmpty);
    });
  });

  group('TASK 6: English & Hindi Localization Tests (ARB)', () {
    testWidgets('6. English Locale renders correct localized English strings',
        (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          child: const OnboardingScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Master Your Daily Budget'), findsOneWidget);
      expect(find.text('Choose Your Hero'), findsOneWidget);
      expect(find.text('Monthly Salary & Payday'), findsOneWidget);
      expect(find.text('Complete Setup & Enter Citadel'), findsOneWidget);
    });

    testWidgets('7. Hindi Locale renders natural Devanagari Hindi strings',
        (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          child: const OnboardingScreen(),
          locale: const Locale('hi'),
        ),
      );
      await tester.pumpAndSettle();

      // Localized Hindi headings and buttons
      expect(find.text('सैलरीक्वेस्ट'), findsOneWidget);
      expect(find.text('दैनिक बजट पर नियंत्रण पाएं'), findsOneWidget);
      expect(find.text('अपना हीरो चुनें'), findsOneWidget);
      expect(find.text('मासिक सैलरी और पे-डे'), findsOneWidget);
      expect(find.text('सेटअप पूरा करें और प्रवेश करें'), findsOneWidget);
    });

    test('8. Language toggle updates notifier state and languageCode', () {
      expect(notifier.state.languageCode, equals('en'));
      notifier.setLocale('hi');
      expect(notifier.state.languageCode, equals('hi'));
      notifier.setLocale('en');
      expect(notifier.state.languageCode, equals('en'));
    });
  });

  group('TASK 6: Encrypted Backup & Restore with DataConflictResolver Tests', () {
    test('9. Encrypted export generates non-empty AES ciphertext containing IV separator',
        () async {
      final encrypted = await notifier.exportBackup(securityService: securityService);

      expect(encrypted, isNotEmpty);
      expect(encrypted.contains(':'), isTrue); // iv:ciphertext
      expect(encrypted, isNot(contains('Aero'))); // verified not plaintext
    });

    test('10. Tampered or corrupted backup ciphertext throws BackupDecryptionException',
        () async {
      const tampered = 'bad_iv:corrupted_cipher_data_xyz_123';

      expect(
        () async => await notifier.restoreBackup(tampered, securityService: securityService),
        throwsA(isA<BackupDecryptionException>()),
      );
    });

    test('11. Restore on Empty DB: Restores cycles, budgets, hero progress, and all transactions',
        () async {
      // 1. Setup a populated source state with 3 transactions and a savings goal
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_source',
        year: 2026,
        month: 10,
        paydayDay: 25,
        inHandSalary: Money.fromRupees(75000),
        fixedExpensesTotal: Money.fromRupees(25000),
        savingsTargetAmount: Money.fromRupees(20000),
      );

      final initialBudgets =
          BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

      final t1 = Transaction(
        id: 'tx_backup_1',
        cycleId: cycle.id,
        amount: Money.fromRupees(500),
        title: 'Swiggy Dinner',
        category: TransactionCategory.food,
        timestamp: DateTime(2026, 10, 5, 20, 0),
        earnedXp: 15,
        earnedCoins: 5,
      );

      final t2 = Transaction(
        id: 'tx_backup_2',
        cycleId: cycle.id,
        amount: Money.fromRupees(150),
        title: 'Metro Smart Card',
        category: TransactionCategory.transport,
        timestamp: DateTime(2026, 10, 6, 9, 30),
        earnedXp: 15,
        earnedCoins: 5,
      );

      const hero = HeroCharacter(
        name: 'Aero Knight',
        archetype: HeroArchetype.knight,
        level: 4,
        currentXp: 320,
        coins: 180,
        streakDays: 7,
      );

      final goal = SavingsGoal(
        id: 'goal_macbook',
        title: 'MacBook M3 Fund',
        targetAmount: Money.fromRupees(120000),
        savedAmount: Money.fromRupees(35000),
      );

      final sourceState = notifier.state.copyWith(
        cycle: cycle,
        dailyBudgets: initialBudgets,
        transactions: [t1, t2],
        hero: hero,
        savingsGoals: [goal],
        isSeriousMode: true,
      );

      // Export from source
      final backupCiphertext = await BackupRestoreService.exportEncryptedBackup(
        state: sourceState,
        securityService: securityService,
      );

      // 2. Prepare an empty destination state (0 transactions)
      final emptyDb = AppDatabase(NativeDatabase.memory());
      final emptyRepo = SalaryQuestRepository(emptyDb);
      final destNotifier = SalaryQuestNotifier(repository: emptyRepo);
      // Reset transactions to empty
      destNotifier.state = destNotifier.state.copyWith(transactions: const []);

      // 3. Restore encrypted backup into empty state
      final result = await destNotifier.restoreBackup(
        backupCiphertext,
        securityService: securityService,
      );

      expect(result.totalTransactions, equals(2));
      expect(result.mergedFromBackupCount, equals(2));
      expect(destNotifier.state.transactions.length, equals(2));
      expect(destNotifier.state.transactions.map((t) => t.id),
          containsAll(['tx_backup_1', 'tx_backup_2']));
      expect(destNotifier.state.hero.level, equals(4));
      expect(destNotifier.state.hero.coins, equals(180));
      expect(destNotifier.state.savingsGoals.first.title, equals('MacBook M3 Fund'));
      expect(destNotifier.state.isSeriousMode, isTrue);

      await emptyDb.close();
    });

    test('12. Restore on DB with Overlapping Data: Latest-Edit-Wins & Zero Duplicates',
        () async {
      // Local state has tx_1 recorded at 10:00 AM
      final localTx1 = Transaction(
        id: 'tx_shared_1',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(200),
        title: 'Grocery Store Initial',
        category: TransactionCategory.groceries,
        timestamp: DateTime(2026, 10, 10, 10, 0),
        dedupeKey: 'dedupe_grocery_100',
      );

      final localTx2 = Transaction(
        id: 'tx_local_only',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(300),
        title: 'Local Only Coffee',
        category: TransactionCategory.food,
        timestamp: DateTime(2026, 10, 10, 11, 0),
      );

      notifier.state = notifier.state.copyWith(
        transactions: [localTx1, localTx2],
      );

      // Backup payload has:
      // - tx_shared_1 with updated amount 450 at 12:00 PM (later timestamp -> Latest-Edit-Wins!)
      // - tx_backup_only (new transaction)
      final backupTx1Updated = Transaction(
        id: 'tx_shared_1',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(450), // updated amount
        title: 'Grocery Store Edited Later',
        category: TransactionCategory.groceries,
        timestamp: DateTime(2026, 10, 10, 12, 0), // later timestamp
        dedupeKey: 'dedupe_grocery_100',
      );

      final backupTxNew = Transaction(
        id: 'tx_backup_only',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(800),
        title: 'Book Purchase',
        category: TransactionCategory.entertainment,
        timestamp: DateTime(2026, 10, 10, 14, 0),
      );

      final exportPayloadState = notifier.state.copyWith(
        transactions: [backupTx1Updated, backupTxNew],
      );

      final backupCiphertext = await BackupRestoreService.exportEncryptedBackup(
        state: exportPayloadState,
        securityService: securityService,
      );

      // Restore onto the local database
      final result = await notifier.restoreBackup(
        backupCiphertext,
        securityService: securityService,
      );

      // Result should have exactly 3 unique transactions (tx_shared_1, tx_local_only, tx_backup_only)
      // Zero duplicate entries for tx_shared_1!
      expect(result.totalTransactions, equals(3));
      expect(notifier.state.transactions.length, equals(3));

      // Latest-Edit-Wins: tx_shared_1 must have amount 450 and updated title
      final mergedTx1 = notifier.state.transactions.firstWhere((t) => t.id == 'tx_shared_1');
      expect(mergedTx1.amount, equals(Money.fromRupees(450)));
      expect(mergedTx1.title, equals('Grocery Store Edited Later'));

      // Local only transaction preserved
      expect(
        notifier.state.transactions.any((t) => t.id == 'tx_local_only'),
        isTrue,
      );

      // Backup only transaction added
      expect(
        notifier.state.transactions.any((t) => t.id == 'tx_backup_only'),
        isTrue,
      );
    });
  });
}
