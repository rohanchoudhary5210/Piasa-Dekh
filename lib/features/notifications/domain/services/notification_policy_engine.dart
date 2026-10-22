import 'package:salary_quest/features/notifications/domain/models/notification_alert.dart';
import 'package:salary_quest/features/notifications/domain/models/notification_preferences.dart';

class NotificationDecision {
  final bool shouldSend;
  final String? reason;
  final String? title;
  final String? body;

  const NotificationDecision({
    required this.shouldSend,
    this.reason,
    this.title,
    this.body,
  });

  const NotificationDecision.reject(this.reason)
      : shouldSend = false,
        title = null,
        body = null;
}

class NotificationPolicyEngine {
  NotificationPolicyEngine._();

  /// Evaluates whether an alert can be dispatched under the given preferences,
  /// current timestamp, and history of alerts delivered today.
  static NotificationDecision evaluate({
    required NotificationAlert alert,
    required NotificationPreferences preferences,
    required DateTime now,
    required List<DateTime> dispatchedTimestamps,
  }) {
    // 1. Master Switch check
    if (!preferences.enabled) {
      return const NotificationDecision.reject('Notifications disabled by master switch.');
    }

    // 2. Alert category toggle check
    switch (alert.type) {
      case NotificationAlertType.budget80Used:
        if (!preferences.budget80AlertEnabled) {
          return const NotificationDecision.reject('80% budget alert is disabled in settings.');
        }
        break;
      case NotificationAlertType.streakAtRisk:
        if (!preferences.streakAtRiskAlertEnabled) {
          return const NotificationDecision.reject('Streak risk alert is disabled in settings.');
        }
        break;
      case NotificationAlertType.endOfDayCash:
        if (!preferences.cashReminderEnabled) {
          return const NotificationDecision.reject('End-of-day cash reminder is disabled in settings.');
        }
        break;
      case NotificationAlertType.goalMilestone:
        if (!preferences.goalMilestonesEnabled) {
          return const NotificationDecision.reject('Goal milestone alerts are disabled in settings.');
        }
        break;
    }

    // 3. Quiet Hours check
    if (preferences.isQuietHour(now.hour)) {
      return NotificationDecision.reject(
        'Quiet hours active (${preferences.quietHoursStartHour}:00 - ${preferences.quietHoursEndHour}:00).',
      );
    }

    // 4. Daily Limit check (only count notifications dispatched on the same calendar day)
    final sameDayDispatches = dispatchedTimestamps.where((dt) =>
        dt.year == now.year && dt.month == now.month && dt.day == now.day).length;

    if (sameDayDispatches >= preferences.maxPerDay) {
      return NotificationDecision.reject(
        'Daily limit reached ($sameDayDispatches/${preferences.maxPerDay} alerts sent today).',
      );
    }

    // 5. Amount privacy check on Lockscreen
    final effectiveBody = alert.getEffectiveBody(
      showExactAmounts: preferences.showAmountsOnLockScreen,
    );

    return NotificationDecision(
      shouldSend: true,
      title: alert.title,
      body: effectiveBody,
    );
  }
}
