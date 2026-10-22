import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_validation_exception.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_date_calculator.dart';
import 'package:salary_quest/features/budget/domain/services/rollover_strategy.dart';

class BudgetCycle {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int paydayDay;
  final DateTime? salaryReceivedDate;
  final Money inHandSalary;
  final Money fixedExpensesTotal;
  final Money savingsTargetAmount;
  final RolloverStrategy rolloverStrategy;

  const BudgetCycle({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.paydayDay = 1,
    this.salaryReceivedDate,
    required this.inHandSalary,
    required this.fixedExpensesTotal,
    required this.savingsTargetAmount,
    this.rolloverStrategy = const DynamicSmoothingStrategy(),
  });

  /// Factory creating a cycle with validated inputs and dynamically computed dates.
  /// Throws [BudgetValidationException] if validation fails.
  factory BudgetCycle.createValidated({
    required String id,
    required int year,
    required int month,
    required int paydayDay,
    DateTime? salaryReceivedDate,
    required Money inHandSalary,
    required Money fixedExpensesTotal,
    required Money savingsTargetAmount,
    RolloverStrategy rolloverStrategy = const DynamicSmoothingStrategy(),
  }) {
    // 1. Validation: Salary must be > 0
    if (inHandSalary.paise <= 0) {
      throw const BudgetValidationException(
        'Monthly in-hand salary must be greater than zero.',
      );
    }

    // 2. Validation: Fixed expenses + savings goal must not exceed salary
    final commitments = fixedExpensesTotal + savingsTargetAmount;
    if (commitments > inHandSalary) {
      throw BudgetValidationException(
        'Fixed expenses (${fixedExpensesTotal.format()}) + savings goal (${savingsTargetAmount.format()}) = ${commitments.format()}, which exceeds your in-hand salary of ${inHandSalary.format()}.',
      );
    }

    final cycleDates = CycleDateCalculator.computeCycleDates(
      year: year,
      month: month,
      paydayDay: paydayDay,
      salaryReceivedDate: salaryReceivedDate,
    );

    return BudgetCycle(
      id: id,
      startDate: cycleDates.startDate,
      endDate: cycleDates.endDate,
      totalDays: cycleDates.totalDays,
      paydayDay: paydayDay,
      salaryReceivedDate: salaryReceivedDate,
      inHandSalary: inHandSalary,
      fixedExpensesTotal: fixedExpensesTotal,
      savingsTargetAmount: savingsTargetAmount,
      rolloverStrategy: rolloverStrategy,
    );
  }

  /// The net amount available for everyday discretionary spending over the cycle
  Money get discretionaryPool {
    final poolPaise =
        inHandSalary.paise - fixedExpensesTotal.paise - savingsTargetAmount.paise;
    return poolPaise > 0 ? Money.fromPaise(poolPaise) : const Money.zero();
  }

  /// Initial daily budget assuming equal split across totalDays
  Money get baseDailyBudget {
    if (totalDays <= 0) return const Money.zero();
    return Money.fromPaise(discretionaryPool.paise ~/ totalDays);
  }

  /// Current day index (1 to totalDays) relative to cycle start date
  int currentDayIndex(DateTime now) {
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedStart =
        DateTime(startDate.year, startDate.month, startDate.day);
    final diff = normalizedNow.difference(normalizedStart).inDays + 1;
    if (diff < 1) return 1;
    if (diff > totalDays) return totalDays;
    return diff;
  }

  /// Checks if this cycle configuration is valid without throwing.
  static String? validateInputs({
    required Money inHandSalary,
    required Money fixedExpenses,
    required Money savingsTarget,
  }) {
    if (inHandSalary.paise <= 0) {
      return 'Salary must be greater than zero.';
    }
    final commitments = fixedExpenses + savingsTarget;
    if (commitments > inHandSalary) {
      return 'Fixed expenses + savings (${commitments.format()}) exceed salary (${inHandSalary.format()}).';
    }
    return null;
  }

  BudgetCycle copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    int? paydayDay,
    DateTime? salaryReceivedDate,
    Money? inHandSalary,
    Money? fixedExpensesTotal,
    Money? savingsTargetAmount,
    RolloverStrategy? rolloverStrategy,
  }) {
    return BudgetCycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      paydayDay: paydayDay ?? this.paydayDay,
      salaryReceivedDate: salaryReceivedDate ?? this.salaryReceivedDate,
      inHandSalary: inHandSalary ?? this.inHandSalary,
      fixedExpensesTotal: fixedExpensesTotal ?? this.fixedExpensesTotal,
      savingsTargetAmount: savingsTargetAmount ?? this.savingsTargetAmount,
      rolloverStrategy: rolloverStrategy ?? this.rolloverStrategy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'paydayDay': paydayDay,
      'salaryReceivedDate': salaryReceivedDate?.toIso8601String(),
      'inHandSalaryPaise': inHandSalary.paise,
      'fixedExpensesTotalPaise': fixedExpensesTotal.paise,
      'savingsTargetAmountPaise': savingsTargetAmount.paise,
    };
  }

  factory BudgetCycle.fromJson(Map<String, dynamic> json) {
    return BudgetCycle(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDays: json['totalDays'] as int,
      paydayDay: json['paydayDay'] as int? ?? 1,
      salaryReceivedDate: json['salaryReceivedDate'] != null
          ? DateTime.parse(json['salaryReceivedDate'] as String)
          : null,
      inHandSalary: Money.fromPaise(json['inHandSalaryPaise'] as int),
      fixedExpensesTotal:
          Money.fromPaise(json['fixedExpensesTotalPaise'] as int),
      savingsTargetAmount:
          Money.fromPaise(json['savingsTargetAmountPaise'] as int),
      rolloverStrategy: const DynamicSmoothingStrategy(),
    );
  }
}
