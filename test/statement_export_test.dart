import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/core/services/statement_export_service.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BudgetCycle cycle;
  late List<Transaction> transactions;

  setUp(() {
    cycle = BudgetCycle(
      id: 'cycle_test_2026',
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 31),
      totalDays: 31,
      paydayDay: 1,
      inHandSalary: Money.fromRupees(60000),
      savingsTargetAmount: Money.fromRupees(15000),
      fixedExpensesTotal: Money.fromRupees(15000),
    );

    transactions = [
      Transaction(
        id: 'tx_1',
        cycleId: 'cycle_test_2026',
        amount: Money.fromRupees(450),
        title: 'Swiggy, Food Delivery',
        category: TransactionCategory.food,
        timestamp: DateTime(2026, 10, 5, 13, 30),
        type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx_2',
        cycleId: 'cycle_test_2026',
        amount: Money.fromRupees(499),
        title: 'Netflix AutoPay',
        category: TransactionCategory.entertainment,
        timestamp: DateTime(2026, 10, 10, 9, 0),
        type: TransactionType.expense,
      ),
      Transaction(
        id: 'tx_3',
        cycleId: 'cycle_test_2026',
        amount: Money.fromRupees(100),
        title: 'Swiggy Refund',
        category: TransactionCategory.food,
        timestamp: DateTime(2026, 10, 12, 11, 0),
        type: TransactionType.refund,
      ),
    ];
  });

  test('StatementExportService generates valid RFC CSV string', () {
    final csv = StatementExportService.generateCsv(
      cycle: cycle,
      transactions: transactions,
    );

    expect(csv, contains('Transaction ID,Date,Time,Merchant / Title,Category,Type,Amount (INR),Source,Dedupe Key'));
    // Commas in merchant title must be wrapped in quotes
    expect(csv, contains('"Swiggy, Food Delivery"'));
    expect(csv, contains('450.00'));
    expect(csv, contains('Netflix AutoPay'));
    expect(csv, contains('Fun & Gaming'));
    expect(csv, contains('Refund'));
  });

  test('StatementExportService generates clean text summary', () {
    final summary = StatementExportService.generateSummaryText(
      cycle: cycle,
      transactions: transactions,
      currentDayIndex: 15,
    );

    expect(summary, contains('SALARYQUEST CYCLE STATEMENT'));
    expect(summary, contains('₹60000'));
    expect(summary, contains('₹15000'));
    expect(summary, contains('₹30000'));
    expect(summary, contains('• Food & Dining'));
    expect(summary, contains('• Fun & Gaming'));
  });
}
