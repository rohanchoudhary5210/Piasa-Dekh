import 'package:salary_quest/features/notifications/domain/services/notification_service_interface.dart';

class SentNotificationRecord {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;

  const SentNotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
  });
}

class FakeNotificationService implements INotificationService {
  bool permissionGranted;
  bool isInitialized = false;
  final List<SentNotificationRecord> sentNotifications = [];

  FakeNotificationService({this.permissionGranted = true});

  @override
  Future<bool> initialize() async {
    isInitialized = true;
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    return permissionGranted;
  }

  @override
  Future<bool> isPermissionGranted() async {
    return permissionGranted;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!permissionGranted) return;
    sentNotifications.add(
      SentNotificationRecord(
        id: id,
        title: title,
        body: body,
        payload: payload,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    sentNotifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> cancelAll() async {
    sentNotifications.clear();
  }
}
