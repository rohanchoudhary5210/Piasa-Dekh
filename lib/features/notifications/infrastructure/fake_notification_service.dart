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

class ScheduledNotificationRecord {
  final int id;
  final int hour;
  final int minute;
  final String title;
  final String body;

  const ScheduledNotificationRecord({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });
}

class FakeNotificationService implements INotificationService {
  bool permissionGranted;
  bool isInitialized = false;
  final List<SentNotificationRecord> sentNotifications = [];
  final Map<int, ScheduledNotificationRecord> scheduledNotifications = {};

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
  Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    scheduledNotifications[id] = ScheduledNotificationRecord(
      id: id,
      hour: hour,
      minute: minute,
      title: title,
      body: body,
    );
  }

  @override
  Future<void> cancel(int id) async {
    sentNotifications.removeWhere((n) => n.id == id);
    scheduledNotifications.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    sentNotifications.clear();
    scheduledNotifications.clear();
  }
}
