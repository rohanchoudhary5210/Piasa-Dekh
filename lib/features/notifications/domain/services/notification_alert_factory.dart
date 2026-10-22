import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/notifications/domain/models/notification_alert.dart';
import 'package:salary_quest/features/savings_goals/domain/models/savings_goal.dart';

class NotificationAlertFactory {
  NotificationAlertFactory._();

  static const int idBudget80 = 1001;
  static const int idStreakAtRisk = 1002;
  static const int idCashReminder = 1003;
  static const int idGoalMilestone = 1004;

  /// Creates an alert for when 80% of today's daily budget is consumed
  static NotificationAlert createBudget80Alert({
    required DailyBudget todayBudget,
    required DateTime now,
  }) {
    final spentRupees = todayBudget.actualSpent.inWholeRupees;
    final allocatedRupees = todayBudget.allocatedBudget.inWholeRupees;

    return NotificationAlert(
      id: idBudget80,
      type: NotificationAlertType.budget80Used,
      title: '⚠️ Daily Budget Warning',
      bodyWithAmounts:
          'You have spent ₹$spentRupees of your ₹$allocatedRupees daily budget (80%+ consumed).',
      bodyMasked:
          'You have used over 80% of today\'s daily budget. Review your remaining discretionary balance.',
      timestamp: now,
    );
  }

  /// Creates an alert in the evening when streak is at risk
  static NotificationAlert createStreakAtRiskAlert({
    required HeroCharacter hero,
    required DateTime now,
  }) {
    final streak = hero.streakDays;
    return NotificationAlert(
      id: idStreakAtRisk,
      type: NotificationAlertType.streakAtRisk,
      title: '🔥 Streak Protection Alert',
      bodyWithAmounts:
          'Your $streak-day budget streak is at risk! Log your expenses or verify a zero-spend day.',
      bodyMasked:
          'Your active budget streak is at risk! Open SalaryQuest to maintain your record.',
      timestamp: now,
    );
  }

  /// Creates the end-of-day cash reminder
  static NotificationAlert createCashReminderAlert({required DateTime now}) {
    return NotificationAlert(
      id: idCashReminder,
      type: NotificationAlertType.endOfDayCash,
      title: '📝 End-of-Day Cash Reminder',
      bodyWithAmounts:
          'Did you pay with cash or offline today? Add your cash spends before day close.',
      bodyMasked:
          'Add any unrecorded cash expenses to keep your daily budget accurate.',
      timestamp: now,
    );
  }

  /// Creates an alert when a savings goal reaches a milestone (e.g. 50% or 100%)
  static NotificationAlert createGoalMilestoneAlert({
    required SavingsGoal goal,
    required int milestonePercent,
    required DateTime now,
  }) {
    final savedRupees = goal.savedAmount.inWholeRupees;
    final targetRupees = goal.targetAmount.inWholeRupees;

    return NotificationAlert(
      id: idGoalMilestone + goal.id.hashCode.abs() % 1000,
      type: NotificationAlertType.goalMilestone,
      title: milestonePercent >= 100
          ? '🎉 Savings Goal Completed!'
          : '🎯 Goal Milestone: $milestonePercent%',
      bodyWithAmounts: milestonePercent >= 100
          ? 'Incredible! You reached your full ₹$targetRupees target for "${goal.title}"!'
          : 'Great momentum! You saved ₹$savedRupees of ₹$targetRupees on "${goal.title}" ($milestonePercent%).',
      bodyMasked: milestonePercent >= 100
          ? 'Incredible! You successfully completed your savings goal "${goal.title}"!'
          : 'Great momentum! You reached the $milestonePercent% milestone on "${goal.title}".',
      timestamp: now,
    );
  }
}
