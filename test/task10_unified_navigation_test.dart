import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/services/budget_calculator.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/home/presentation/screens/home_screen.dart';
import 'package:salary_quest/features/notifications/infrastructure/fake_notification_service.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/presentation/widgets/edit_transaction_sheet.dart';

BudgetCycle _createTestCycle() => BudgetCycle.createValidated(
      id: 'cycle_nav_test',
      year: 2026,
      month: 10,
      paydayDay: 25,
      inHandSalary: Money.fromRupees(60000),
      fixedExpensesTotal: Money.fromRupees(20000),
      savingsTargetAmount: Money.fromRupees(10000),
    );

void main() {
  testWidgets('Unified Navigation Shell switches between all 5 tabs and in-dashboard buttons work flawlessly',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final cycle = _createTestCycle();
    final dailyBudgets =
        BudgetCalculator.generateInitialCycleBudgets(cycle: cycle);

    final initialTx = Transaction(
      id: 'tx_nav_1',
      cycleId: cycle.id,
      amount: Money.fromRupees(250),
      title: 'Coffee House',
      category: TransactionCategory.food,
      timestamp: DateTime.now(),
      type: TransactionType.expense,
    );

    final notifier = SalaryQuestNotifier(
      notificationService: FakeNotificationService(),
    );
    notifier.state = notifier.state.copyWith(
      cycle: cycle,
      dailyBudgets: dailyBudgets,
      transactions: [initialTx],
      currentDayIndex: 1,
      isOnboarded: true,
      hero: const HeroCharacter(
        name: 'Aero',
        currentHp: 80,
        streakDays: 3,
        coins: 120,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          salaryQuestProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initially on Dashboard tab
    expect(find.text('SALARYQUEST'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // 2. Switch to Activity tab (index 1) via Bottom Navigation Bar
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // 3. Switch to Insights tab (index 2) via Bottom Navigation Bar
    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Insights & Analytics'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // 4. Switch to Goals tab (index 3) via Bottom Navigation Bar
    await tester.tap(find.text('Goals'));
    await tester.pumpAndSettle();
    expect(find.text('🎯 Savings Goals'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // 5. Switch to Settings tab (index 4) via Bottom Navigation Bar
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Treasury & Cycle Settings'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // 6. Switch back to Dashboard tab (index 0)
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('SALARYQUEST'), findsOneWidget);
    expect(find.text('LOG EXPENSE'), findsOneWidget);

    // 7. Test in-screen navigation: Tapping "See All" in Recent Activity switches to Activity tab
    await tester.scrollUntilVisible(
      find.text('See All (1)'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('See All (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsOneWidget);

    // Go back to dashboard
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    // 8. Test in-screen navigation: Tapping Forecast Bento card switches to Insights tab
    await tester.tap(find.text('FORECAST'));
    await tester.pumpAndSettle();
    expect(find.text('Insights & Analytics'), findsOneWidget);

    // Go back to dashboard
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    // 9. Test in-screen action: Tapping on recent transaction opens EditTransactionSheet
    await tester.scrollUntilVisible(
      find.text('Coffee House'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Coffee House'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTransactionSheet), findsOneWidget);
    expect(find.text('Edit Transaction'), findsOneWidget);
  });
}
