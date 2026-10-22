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

  void updatePreferences(NotificationPreferences newPreferences) {
    preferences = newPreferences;
  }

  void clearHistory() {
    _dispatchedTimestamps.clear();
  }
}
