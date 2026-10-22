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
  Future<void> cancel(int id);
  Future<void> cancelAll();
}
