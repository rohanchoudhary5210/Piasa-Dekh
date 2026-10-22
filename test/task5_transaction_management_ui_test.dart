import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:salary_quest/features/transactions/presentation/widgets/edit_transaction_sheet.dart';

void main() {
  Widget buildTestableWidget(Widget child, SalaryQuestNotifier notifier) {
    return ProviderScope(
      overrides: [
        salaryQuestProvider.overrideWith((ref) => notifier),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('TASK 5: Transaction Management UI, Search, Filter, Edit, Undo & L10n', () {
    late SalaryQuestNotifier notifier;
    late Transaction tx1;
    late Transaction tx2;
    late Transaction tx3;
    late Transaction txHindi;
    late Transaction txLong;

    setUp(() {
      notifier = SalaryQuestNotifier();

      final now = DateTime(2026, 10, 25, 12, 0);

      tx1 = Transaction(
        id: 'tx_1',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(200),
        title: 'Swiggy Biryani',
        category: TransactionCategory.food,
        timestamp: now,
        earnedXp: 15,
        type: TransactionType.expense,
      );

      tx2 = Transaction(
        id: 'tx_2',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(80),
        title: 'Delhi Metro',
        category: TransactionCategory.transport,
        timestamp: now.subtract(const Duration(hours: 1)),
        earnedXp: 15,
        type: TransactionType.expense,
      );

      tx3 = Transaction(
        id: 'tx_3',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(1500),
        title: 'Electricity Bill',
        category: TransactionCategory.bills,
        timestamp: now.subtract(const Duration(hours: 3)),
        earnedXp: 0,
        isFixedExpense: true,
        type: TransactionType.expense,
      );

      txHindi = Transaction(
        id: 'tx_hindi',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(350),
        title: 'किराना स्टोर (दूध और ब्रेड)',
        category: TransactionCategory.groceries,
        timestamp: now.subtract(const Duration(hours: 4)),
        earnedXp: 15,
        type: TransactionType.expense,
      );

      txLong = Transaction(
        id: 'tx_long',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(450),
        title: 'Shree Ganesh Wholesale Supermarket Private Limited Electronic City Branch Bengaluru',
        category: TransactionCategory.shopping,
        timestamp: now.subtract(const Duration(hours: 5)),
        earnedXp: 0,
        type: TransactionType.expense,
      );

      notifier.state = notifier.state.copyWith(
        transactions: [tx1, tx2, tx3, txHindi, txLong],
      );
    });

    testWidgets('1. Search Filter: Typing query filters transactions by merchant title & Hindi text',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TransactionsScreen(), notifier));
      await tester.pumpAndSettle();

      // Initially all 5 transactions are visible
      expect(find.text('Swiggy Biryani'), findsOneWidget);
      expect(find.text('Delhi Metro'), findsOneWidget);
      expect(find.text('Electricity Bill'), findsOneWidget);
      expect(find.text('किराना स्टोर (दूध और ब्रेड)'), findsOneWidget);

      // Search for 'Swiggy'
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Swiggy');
      await tester.pumpAndSettle();

      expect(find.text('Swiggy Biryani'), findsOneWidget);
      expect(find.text('Delhi Metro'), findsNothing);
      expect(find.text('Electricity Bill'), findsNothing);

      // Search for Hindi term 'किराना'
      await tester.enterText(searchField, 'किराना');
      await tester.pumpAndSettle();

      expect(find.text('किराना स्टोर (दूध और ब्रेड)'), findsOneWidget);
      expect(find.text('Swiggy Biryani'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      expect(find.text('Swiggy Biryani'), findsOneWidget);
      expect(find.text('Delhi Metro'), findsOneWidget);
    });

    testWidgets('2. Category Filter: filters transactions matching chosen category',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TransactionsScreen(), notifier));
      await tester.pumpAndSettle();

      // Tap on Category dropdown filter chip
      await tester.tap(find.text('🏷️ Category'));
      await tester.pumpAndSettle();

      // Select 'Food & Dining'
      await tester.tap(find.text('🍔 Food & Dining').last);
      await tester.pumpAndSettle();

      // Only Swiggy Biryani is visible
      expect(find.text('Swiggy Biryani'), findsOneWidget);
      expect(find.text('Delhi Metro'), findsNothing);
      expect(find.text('Electricity Bill'), findsNothing);
    });

    testWidgets('3. Edit & Recategorize: updates merchant, amount and recomputes budget',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TransactionsScreen(), notifier));
      await tester.pumpAndSettle();

      // Tap Swiggy Biryani to open Edit Sheet
      await tester.tap(find.text('Swiggy Biryani'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaction'), findsOneWidget);

      // Change amount to 450
      final amountField = find.widgetWithText(TextField, '200');
      await tester.enterText(amountField, '450');

      // Change category to Entertainment (displayed as "Fun & Gaming")
      await tester.tap(find.textContaining('Fun & Gaming'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.ensureVisible(find.text('Save & Recompute Budgets'));
      await tester.tap(find.text('Save & Recompute Budgets'));
      await tester.pumpAndSettle();

      // Verify transaction was edited
      final updated = notifier.state.transactions.firstWhere((t) => t.id == 'tx_1');
      expect(updated.amount, equals(Money.fromRupees(450)));
      expect(updated.category, equals(TransactionCategory.entertainment));

      // Budgets recomputed
      expect(notifier.state.transactions.length, equals(5));
    });

    testWidgets('4. Delete with Undo SnackBar: deletes transaction, reverts XP and restores on Undo',
        (tester) async {
      final initialXp = notifier.state.hero.currentXp;

      await tester.pumpWidget(buildTestableWidget(const TransactionsScreen(), notifier));
      await tester.pumpAndSettle();

      expect(find.text('Swiggy Biryani'), findsOneWidget);

      // Swipe to dismiss 'Swiggy Biryani'
      await tester.drag(find.text('Swiggy Biryani'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verified deleted from UI and state
      expect(find.text('Swiggy Biryani'), findsNothing);
      expect(notifier.state.transactions.any((t) => t.id == 'tx_1'), isFalse);
      expect(notifier.state.hero.currentXp, equals(initialXp - 15),
          reason: 'Deleting transaction reverts its 15 XP');

      // SnackBar with UNDO action is displayed
      expect(find.text('UNDO'), findsOneWidget);

      // Tap UNDO
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      // Transaction is restored
      expect(find.text('Swiggy Biryani'), findsOneWidget);
      expect(notifier.state.transactions.any((t) => t.id == 'tx_1'), isTrue);
      expect(notifier.state.hero.currentXp, equals(initialXp),
          reason: 'Undo must restore the reverted XP');
    });

    testWidgets('5. Long merchant title & Hindi text renders with ellipsis and zero crash',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TransactionsScreen(), notifier));
      await tester.pumpAndSettle();

      // Verify both Hindi text and long merchant names render smoothly
      expect(find.text('किराना स्टोर (दूध और ब्रेड)'), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('6. Accessibility: 2.0x Font Scaling on TransactionsScreen renders with zero overflow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            salaryQuestProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(2.0),
              ),
              child: TransactionsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'TransactionsScreen must not overflow at 2.0x font scaling');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('7. Accessibility: 2.0x Font Scaling on EditTransactionSheet renders with zero overflow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2.0),
                ),
                child: EditTransactionSheet(
                  transaction: tx1,
                  onSave: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'EditTransactionSheet must not overflow at 2.0x font scaling');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
