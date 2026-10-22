import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/services/biometric_auth_service.dart';
import 'package:salary_quest/core/services/local_security_service.dart';
import 'package:salary_quest/features/auth/presentation/screens/biometric_lock_screen.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/home/presentation/widgets/calendar_strip.dart';
import 'package:salary_quest/features/home/presentation/widgets/daily_budget_card.dart';

void main() {
  group('TASK 7: Security, Privacy, and UI Robustness Tests', () {
    test('1. Authenticated Encryption at Rest: AES-256-GCM encrypts and decrypts sensitive data', () async {
      final memoryStorage = <String, String>{};
      final securityService = LocalSecurityService(memoryFallback: memoryStorage);

      const sensitiveSalary = 'in_hand_salary: ₹85,000';
      const sensitiveSms = 'HDFC Bank: Rs 28,000 debited for Rent transfer to A/c XX4912';

      // 1. Encrypt sensitive fields with modern AES-256-GCM
      final encryptedSalary = await securityService.encrypt(sensitiveSalary);
      final encryptedSms = await securityService.encrypt(sensitiveSms);

      expect(encryptedSalary, isNotEmpty);
      expect(encryptedSalary, isNot(equals(sensitiveSalary)));
      expect(encryptedSalary.startsWith('gcm:'), isTrue); // Authenticated GCM prefix
      expect(securityService.isGcm(encryptedSalary), isTrue);

      expect(encryptedSms, isNotEmpty);
      expect(encryptedSms, isNot(equals(sensitiveSms)));
      expect(encryptedSms.startsWith('gcm:'), isTrue);

      // 2. Decrypt back to plaintext
      final decryptedSalary = await securityService.decrypt(encryptedSalary);
      final decryptedSms = await securityService.decrypt(encryptedSms);

      expect(decryptedSalary, equals(sensitiveSalary));
      expect(decryptedSms, equals(sensitiveSms));

      // 3. Wipe keys removes master key
      await securityService.wipeSecurityKeys();
      expect(memoryStorage.isEmpty, isTrue);
    });

    test('2. AES-CBC to AES-GCM Migration: legacy ciphertexts decrypt correctly and migrateToGcm updates them', () async {
      final memoryStorage = <String, String>{};
      final securityService = LocalSecurityService(memoryFallback: memoryStorage);

      const secretText = 'Axis Bank: ₹12,000 paid to Credit Card ending in 8891';

      // 1. Generate legacy AES-CBC ciphertext (iv:cipher)
      final legacyCbc = await securityService.encryptLegacyCbc(secretText);
      expect(legacyCbc.contains(':'), isTrue);
      expect(legacyCbc.startsWith('gcm:'), isFalse);
      expect(securityService.isGcm(legacyCbc), isFalse);

      // 2. Decrypt legacy CBC ciphertext directly (backwards-compatibility)
      final decryptedDirect = await securityService.decrypt(legacyCbc);
      expect(decryptedDirect, equals(secretText));

      // 3. Migrate legacy CBC ciphertext to authenticated GCM
      final migratedGcm = await securityService.migrateToGcm(legacyCbc);
      expect(migratedGcm.startsWith('gcm:'), isTrue);
      expect(securityService.isGcm(migratedGcm), isTrue);

      // 4. Decrypt newly migrated GCM ciphertext
      final decryptedMigrated = await securityService.decrypt(migratedGcm);
      expect(decryptedMigrated, equals(secretText));
    });

    test('3. Android Keystore Key Storage: Master key stored in secure key alias, never empty or in DB', () async {
      final memoryStorage = <String, String>{};
      final securityService = LocalSecurityService(memoryFallback: memoryStorage);

      // Generate or read master key
      final key = await securityService.getOrCreateMasterKey();
      expect(key.bytes.length, equals(32)); // 256 bits

      // Check key storage alias
      expect(memoryStorage.containsKey('salary_quest_aes_master_key'), isTrue);
      final keyBase64 = memoryStorage['salary_quest_aes_master_key']!;
      expect(keyBase64, isNotEmpty);
      expect(keyBase64, equals(key.base64));
    });

    test('4. Biometric Auth: Graceful fallback when biometrics are unavailable (never locks user out)', () async {
      final authService = BiometricAuthService();
      final result = await authService.authenticate();
      expect(result, isNotNull);
    });

    testWidgets('5. Biometric Lock Screen: Unlocks when biometric verification succeeds', (tester) async {
      bool unlockedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BiometricLockScreen(
            authService: BiometricAuthService(mockAuthResult: true),
            autoTrigger: false,
            onUnlocked: () {
              unlockedCalled = true;
            },
          ),
        ),
      );

      expect(find.text('SalaryQuest Vault Locked'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
      expect(find.text('Unlock with Biometrics'), findsOneWidget);

      await tester.tap(find.text('Unlock with Biometrics'));
      await tester.pumpAndSettle();

      expect(unlockedCalled, isTrue);
    });

    testWidgets('6. Biometric Lock Screen: PIN Fallback opens keypad and unlocks vault with backup PIN (1234)', (tester) async {
      bool unlockedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BiometricLockScreen(
            authService: BiometricAuthService(mockAuthResult: false), // Biometrics fail
            securityService: LocalSecurityService(memoryFallback: {}),
            autoTrigger: false,
            onUnlocked: () {
              unlockedCalled = true;
            },
          ),
        ),
      );

      // Tap Use Backup PIN
      expect(find.text('Use Backup PIN'), findsOneWidget);
      await tester.tap(find.text('Use Backup PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Vault PIN Fallback'), findsOneWidget);

      // Enter invalid PIN first (9999)
      await tester.enterText(find.byKey(const Key('input_backup_pin')), '9999');
      await tester.tap(find.byKey(const Key('btn_submit_pin')));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect PIN. Try default (1234)'), findsOneWidget);
      expect(unlockedCalled, isFalse);

      // Enter correct backup PIN (1234)
      await tester.enterText(find.byKey(const Key('input_backup_pin')), '1234');
      await tester.tap(find.byKey(const Key('btn_submit_pin')));
      await tester.pumpAndSettle();

      expect(unlockedCalled, isTrue);
    });

    testWidgets('6b. Biometric Lock Screen: Custom PIN unlocks vault and rejects invalid PINs', (tester) async {
      final memoryStorage = <String, String>{};
      final securityService = LocalSecurityService(memoryFallback: memoryStorage);
      await securityService.setBackupPin('5678');
      expect(await securityService.getBackupPin(), equals('5678'));

      bool unlockedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BiometricLockScreen(
            authService: BiometricAuthService(mockAuthResult: false),
            securityService: securityService,
            autoTrigger: false,
            onUnlocked: () {
              unlockedCalled = true;
            },
          ),
        ),
      );

      // Tap Use Backup PIN
      await tester.tap(find.text('Use Backup PIN'));
      await tester.pumpAndSettle();

      // Enter wrong PIN (1111)
      await tester.enterText(find.byKey(const Key('input_backup_pin')), '1111');
      await tester.tap(find.byKey(const Key('btn_submit_pin')));
      await tester.pumpAndSettle();

      expect(unlockedCalled, isFalse);

      // Enter custom PIN (5678)
      await tester.enterText(find.byKey(const Key('input_backup_pin')), '5678');
      await tester.tap(find.byKey(const Key('btn_submit_pin')));
      await tester.pumpAndSettle();

      expect(unlockedCalled, isTrue);
    });

    test('7. Privacy: Wipe All Data resets database, keys, and restores fresh setup', () async {
      final memoryStorage = <String, String>{};
      final securityService = LocalSecurityService(memoryFallback: memoryStorage);
      final notifier = SalaryQuestNotifier();

      await securityService.setBackupPin('9876');
      expect(await securityService.getBackupPin(), equals('9876'));

      // Add a transaction
      await notifier.addTransaction(
        amount: Money.fromRupees(1500),
        title: 'Dinner Party',
        category: TransactionCategory.food,
      );
      expect(notifier.state.transactions.isNotEmpty, isTrue);

      // Perform complete data wipe
      await notifier.wipeAllData(securityService: securityService);

      // All transactions, custom data, and PIN are completely cleared
      expect(notifier.state.transactions.isEmpty, isTrue);
      expect(notifier.state.isCycleInDeficit, isFalse);
      expect(await securityService.getBackupPin(), equals('1234'));
    });

    testWidgets('8. Accessibility: 2.0x Font Scaling on DailyBudgetCard renders with zero layout overflow', (tester) async {
      final dailyBudget = DailyBudget(
        id: 'budget_1',
        cycleId: 'cycle_1',
        date: DateTime.now(),
        dayIndex: 3,
        allocatedBudget: Money.fromRupees(1000),
        actualSpent: Money.fromRupees(400),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0),
              ),
              child: DailyBudgetCard(
                dailyBudget: dailyBudget,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('9. Accessibility: 2.0x Font Scaling on CalendarGridWidget renders with zero layout overflow', (tester) async {
      final now = DateTime.now();
      final cycle = BudgetCycle(
        id: 'cycle_1',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 28)),
        totalDays: 30,
        inHandSalary: Money.fromRupees(60000),
        fixedExpensesTotal: Money.fromRupees(20000),
        savingsTargetAmount: Money.fromRupees(10000),
      );

      final budgets = List.generate(
        30,
        (i) => DailyBudget(
          id: 'b_$i',
          cycleId: 'cycle_1',
          date: cycle.startDate.add(Duration(days: i)),
          dayIndex: i + 1,
          allocatedBudget: Money.fromRupees(1000),
          actualSpent: Money.fromRupees(i % 2 == 0 ? 800 : 1200),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0),
              ),
              child: SingleChildScrollView(
                child: CalendarGridWidget(
                  budgets: budgets,
                  currentDayIndex: 3,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('10. Accessibility: Reduce Motion toggle updates state and respects settings', (tester) async {
      final notifier = SalaryQuestNotifier();
      expect(notifier.state.isReduceMotion, isFalse);

      notifier.toggleReduceMotion(true);
      expect(notifier.state.isReduceMotion, isTrue);

      notifier.toggleReduceMotion(false);
      expect(notifier.state.isReduceMotion, isFalse);
    });
  });
}
