import 'package:salary_quest/core/models/money.dart';

class SavingsGoal {
  final String id;
  final String title;
  final Money targetAmount;
  final Money savedAmount;
  final String icon;
  final bool isPrimary;
  final DateTime? deadline;
  final bool isCompleted;

  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = const Money.zero(),
    this.icon = '🎯',
    this.isPrimary = false,
    this.deadline,
    this.isCompleted = false,
  });

  /// Ratio from 0.0 to 1.0 of progress towards target amount.
  double get progressRatio {
    if (targetAmount.paise <= 0) return 1.0;
    return (savedAmount.paise / targetAmount.paise).clamp(0.0, 1.0);
  }

  /// Percentage 0 to 100.
  int get progressPercent => (progressRatio * 100).toInt();

  /// Remaining amount needed to reach target.
  Money get remainingAmount {
    if (savedAmount >= targetAmount) return const Money.zero();
    return targetAmount - savedAmount;
  }

  /// Whether saved amount meets or exceeds target.
  bool get isTargetReached => savedAmount.paise >= targetAmount.paise;

  SavingsGoal copyWith({
    String? id,
    String? title,
    Money? targetAmount,
    Money? savedAmount,
    String? icon,
    bool? isPrimary,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      icon: icon ?? this.icon,
      isPrimary: isPrimary ?? this.isPrimary,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Returns a new goal with deposited money (amounts stored strictly as int paise).
  SavingsGoal deposit(Money amount) {
    if (amount.paise <= 0) return this;
    final newSaved = savedAmount + amount;
    final reached = newSaved.paise >= targetAmount.paise;
    return copyWith(
      savedAmount: newSaved,
      isCompleted: reached ? true : isCompleted,
    );
  }

  /// Returns a new goal with withdrawn money (never drops below 0).
  SavingsGoal withdraw(Money amount) {
    if (amount.paise <= 0) return this;
    final newPaise = (savedAmount.paise - amount.paise).clamp(0, double.infinity).toInt();
    final newSaved = Money.fromPaise(newPaise);
    return copyWith(
      savedAmount: newSaved,
      isCompleted: newSaved.paise >= targetAmount.paise,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmountPaise': targetAmount.paise,
      'savedAmountPaise': savedAmount.paise,
      'icon': icon,
      'isPrimary': isPrimary,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: Money.fromPaise(json['targetAmountPaise'] as int? ?? 0),
      savedAmount: Money.fromPaise(json['savedAmountPaise'] as int? ?? 0),
      icon: json['icon'] as String? ?? '🎯',
      isPrimary: json['isPrimary'] as bool? ?? false,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          targetAmount == other.targetAmount &&
          savedAmount == other.savedAmount &&
          icon == other.icon &&
          isPrimary == other.isPrimary &&
          deadline == other.deadline &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      targetAmount.hashCode ^
      savedAmount.hashCode ^
      icon.hashCode ^
      isPrimary.hashCode ^
      deadline.hashCode ^
      isCompleted.hashCode;
}
