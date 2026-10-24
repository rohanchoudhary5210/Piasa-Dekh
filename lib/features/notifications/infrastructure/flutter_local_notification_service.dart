import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:salary_quest/features/notifications/domain/services/notification_service_interface.dart';

class FlutterLocalNotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _timeZonesReady = false;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'salary_quest_alerts',
    'SalaryQuest Smart Alerts',
    channelDescription:
        'Notifications for daily budgets, streak preservation and savings targets',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'SalaryQuest Alert',
  );

  /// Loads the time-zone database and points `tz.local` at the device's zone.
  /// The device zone is matched by its current UTC offset (India -> Asia/Kolkata).
  void _ensureTimeZones() {
    if (_timeZonesReady) return;
    tzdata.initializeTimeZones();
    final deviceOffset = DateTime.now().timeZoneOffset;
    tz.Location? match;
    if (deviceOffset == const Duration(hours: 5, minutes: 30)) {
      match = tz.getLocation('Asia/Kolkata');
    } else {
      for (final location in tz.timeZoneDatabase.locations.values) {
        if (tz.TZDateTime.now(location).timeZoneOffset == deviceOffset) {
          match = location;
          break;
        }
      }
    }
    if (match != null) {
      tz.setLocalLocation(match);
    }
    _timeZonesReady = true;
  }

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      final result = await _plugin.initialize(settings: settings);
      _initialized = result ?? true;
      return _initialized;
    } catch (_) {
      // Graceful fallback when running in testing or non-mobile platforms
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImpl?.requestNotificationsPermission();
        return granted ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isPermissionGranted() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await androidImpl?.areNotificationsEnabled() ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: _androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (_) {}
  }

  @override
  Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      if (!_initialized) await initialize();
      _ensureTimeZones();
      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }
      const details = NotificationDetails(
        android: _androidDetails,
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: next,
        notificationDetails: details,
        // Inexact: no special "exact alarm" permission needed; may arrive a few minutes late.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Scheduling unavailable (tests / unsupported platform)
    }
  }

  @override
  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
