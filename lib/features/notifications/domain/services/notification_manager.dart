import 'package:salary_quest/features/notifications/domain/models/notification_alert.dart';
import 'package:salary_quest/features/notifications/domain/models/notification_preferences.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_policy_engine.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_service_interface.dart';

class NotificationManager {
  final INotificationService _service;
  NotificationPreferences preferences;
  final List<DateTime> _dispatchedTimestamps = [];

  NotificationManager({
    required INotificationService service,
    this.preferences = const NotificationPreferences(),
  }) : _service = service;

  List<DateTime> get dispatchedTimestamps => List.unmodifiable(_dispatchedTimestamps);

  Future<bool> initialize() async {
    return await _service.initialize();
  }

  Future<bool> requestPermission() async {
    return await _service.requestPermission();
  }

  Future<bool> isPermissionGranted() async {
    return await _service.isPermissionGranted();
  }

  /// Evaluates policy and dispatches the alert if allowed.
  /// Returns [NotificationDecision] indicating whether it was sent or rejected.
  Future<NotificationDecision> dispatchAlert({
    required NotificationAlert alert,
    DateTime? now,
  }) async {
    final currentTimestamp = now ?? DateTime.now();

    final decision = NotificationPolicyEngine.evaluate(
      alert: alert,
      preferences: preferences,
      now: currentTimestamp,
      dispatchedTimestamps: _dispatchedTimestamps,
    );

    if (decision.shouldSend) {
      await _service.showNotification(
        id: alert.id,
        title: decision.title!,
        body: decision.body!,
      );
      _dispatchedTimestamps.add(currentTimestamp);
    }

    return decision;
  }

  static const int idDailyLogReminder = 2001;
  static const int idDailyCashReminder = 2002;
  static const int dailyLogReminderHour = 20;
  static const int dailyLogReminderMinute = 30;
  static const int dailyCashReminderHour = 21;
  static const int dailyCashReminderMinute = 15;

  /// (Re)schedules the repeating daily reminders according to current preferences.
  /// These fire even when the app is closed. Reminders falling inside quiet
  /// hours are not scheduled.
  Future<void> syncDailyReminders() async {
    try {
      if (!preferences.enabled) {
        await _service.cancel(idDailyLogReminder);
        await _service.cancel(idDailyCashReminder);
        return;
      }

      if (preferences.streakAtRiskAlertEnabled &&
          !preferences.isQuietHour(dailyLogReminderHour)) {
        await _service.scheduleDailyNotification(
          id: idDailyLogReminder,
          hour: dailyLogReminderHour,
          minute: dailyLogReminderMinute,
          title: '🔥 Keep your streak alive',
          body: 'Log today\'s spends in SalaryQuest before midnight to protect your streak.',
        );
      } else {
        await _service.cancel(idDailyLogReminder);
      }

      if (preferences.cashReminderEnabled &&
          !preferences.isQuietHour(dailyCashReminderHour)) {
        await _service.scheduleDailyNotification(
          id: idDailyCashReminder,
          hour: dailyCashReminderHour,
          minute: dailyCashReminderMinute,
          title: '📝 Any cash spends today?',
          body: 'Paid with cash or offline today? Add it now so your daily budget stays accurate.',
        );
      } else {
        await _service.cancel(idDailyCashReminder);
      }
    } catch (_) {
      // Never let reminder scheduling break the app
    }
  }

  Future<void> cancelAll() async {
    try {
      await _service.cancelAll();
    } catch (_) {}
  }

  void updatePreferences(NotificationPreferences newPreferences) {
    preferences = newPreferences;
  }

  void clearHistory() {
    _dispatchedTimestamps.clear();
  }
}
