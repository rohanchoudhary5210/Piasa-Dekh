abstract class INotificationService {
  Future<bool> initialize();
  Future<bool> requestPermission();
  Future<bool> isPermissionGranted();
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Schedules a notification that repeats every day at [hour]:[minute]
  /// device-local time, even when the app is closed.
  Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  });
  Future<void> cancel(int id);
  Future<void> cancelAll();
}
