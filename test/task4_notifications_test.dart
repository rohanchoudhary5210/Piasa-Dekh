import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/notifications/domain/models/notification_preferences.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_alert_factory.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_manager.dart';
import 'package:salary_quest/features/notifications/domain/services/notification_policy_engine.dart';
import 'package:salary_quest/features/notifications/infrastructure/fake_notification_service.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

void main() {
  group('TASK 4: Notifications, Scheduling, Rate Limiting & Privacy Tests', () {
    late FakeNotificationService fakeService;
    late NotificationManager manager;

    setUp(() {
      fakeService = FakeNotificationService(permissionGranted: true);
      manager = NotificationManager(
        service: fakeService,
        preferences: const NotificationPreferences(),
      );
    });

    test('1. Master Off Switch: completely blocks all notification dispatches', () async {
      manager.updatePreferences(
        const NotificationPreferences(enabled: false),
      );

      final alert = NotificationAlertFactory.createCashReminderAlert(
        now: DateTime(2026, 10, 25, 20, 0),
      );

      final decision = await manager.dispatchAlert(
        alert: alert,
        now: DateTime(2026, 10, 25, 20, 0),
      );

      expect(decision.shouldSend, isFalse);
      expect(decision.reason, contains('disabled'));
      expect(fakeService.sentNotifications.isEmpty, isTrue,
          reason: 'Master off switch must prevent any notification delivery');
    });

    test('2. Rate Limiting: Enforces max 2 per day by default, and resets on the next day', () async {
      final day1Time1 = DateTime(2026, 10, 25, 10, 0);
      final day1Time2 = DateTime(2026, 10, 25, 14, 0);
      final day1Time3 = DateTime(2026, 10, 25, 16, 0);
      final day2Time1 = DateTime(2026, 10, 26, 9, 0);

      final todayBudget = DailyBudget(
        id: 'budget_1',
        cycleId: 'cycle_test',
        dayIndex: 1,
        date: DateTime(2026, 10, 25),
        allocatedBudget: Money.fromRupees(1000),
        actualSpent: Money.fromRupees(850),
      );

      final alert1 = NotificationAlertFactory.createBudget80Alert(
        todayBudget: todayBudget,
        now: day1Time1,
      );
      final alert2 = NotificationAlertFactory.createCashReminderAlert(
        now: day1Time2,
      );
      final alert3 = NotificationAlertFactory.createCashReminderAlert(
        now: day1Time3,
      );
      final alert4 = NotificationAlertFactory.createCashReminderAlert(
        now: day2Time1,
      );

      // Dispatch 1 on Day 1 -> Allowed
      final decision1 = await manager.dispatchAlert(alert: alert1, now: day1Time1);
      expect(decision1.shouldSend, isTrue);
      expect(fakeService.sentNotifications.length, equals(1));

      // Dispatch 2 on Day 1 -> Allowed (limit 2 reached)
      final decision2 = await manager.dispatchAlert(alert: alert2, now: day1Time2);
      expect(decision2.shouldSend, isTrue);
      expect(fakeService.sentNotifications.length, equals(2));

      // Dispatch 3 on Day 1 -> Rejected! (Exceeds 2/day)
      final decision3 = await manager.dispatchAlert(alert: alert3, now: day1Time3);
      expect(decision3.shouldSend, isFalse);
      expect(decision3.reason, contains('Daily limit reached'));
      expect(fakeService.sentNotifications.length, equals(2));

      // Dispatch 4 on Day 2 -> Allowed! (Counter reset on new day)
      final decision4 = await manager.dispatchAlert(alert: alert4, now: day2Time1);
      expect(decision4.shouldSend, isTrue);
      expect(fakeService.sentNotifications.length, equals(3));
    });

    test('3. User-Configurable Daily Cap: respects custom maxPerDay setting', () async {
      // Set custom limit of 3 alerts per day
      manager.updatePreferences(
        const NotificationPreferences(maxPerDay: 3),
      );

      final now = DateTime(2026, 10, 25, 12, 0);
      final alert = NotificationAlertFactory.createCashReminderAlert(now: now);

      expect((await manager.dispatchAlert(alert: alert, now: now)).shouldSend, isTrue);
      expect((await manager.dispatchAlert(alert: alert, now: now)).shouldSend, isTrue);
      expect((await manager.dispatchAlert(alert: alert, now: now)).shouldSend, isTrue);

      // 4th is rejected
      final decision4 = await manager.dispatchAlert(alert: alert, now: now);
      expect(decision4.shouldSend, isFalse);
      expect(decision4.reason, contains('Daily limit reached'));
    });

    test('4. Quiet Hours: suppresses notifications during overnight quiet hours window', () async {
      // Default quiet hours: 22:00 (10 PM) to 07:00 (7 AM)
      final alert = NotificationAlertFactory.createCashReminderAlert(
        now: DateTime(2026, 10, 25, 23, 0),
      );

      // 11:00 PM (23:00) -> Inside Quiet Hours -> Rejected
      final lateNightDecision = await manager.dispatchAlert(
        alert: alert,
        now: DateTime(2026, 10, 25, 23, 0),
      );
      expect(lateNightDecision.shouldSend, isFalse);
      expect(lateNightDecision.reason, contains('Quiet hours active'));

      // 5:30 AM (05:30) -> Inside Quiet Hours -> Rejected
      final earlyMorningDecision = await manager.dispatchAlert(
        alert: alert,
        now: DateTime(2026, 10, 26, 5, 30),
      );
      expect(earlyMorningDecision.shouldSend, isFalse);
      expect(earlyMorningDecision.reason, contains('Quiet hours active'));

      // 2:00 PM (14:00) -> Outside Quiet Hours -> Allowed
      final daytimeDecision = await manager.dispatchAlert(
        alert: alert,
        now: DateTime(2026, 10, 26, 14, 0),
      );
      expect(daytimeDecision.shouldSend, isTrue);
    });

    test('5. Lockscreen Amount Privacy: Masks exact financial figures unless user opts in', () {
      final todayBudget = DailyBudget(
        id: 'b_1',
        cycleId: 'c_1',
        dayIndex: 1,
        date: DateTime(2026, 10, 25),
        allocatedBudget: Money.fromRupees(1000),
        actualSpent: Money.fromRupees(850),
      );

      final now = DateTime(2026, 10, 25, 14, 0);
      final alert = NotificationAlertFactory.createBudget80Alert(
        todayBudget: todayBudget,
        now: now,
      );

      // Default: showAmountsOnLockScreen = false (Privacy Protected)
      final privateDecision = NotificationPolicyEngine.evaluate(
        alert: alert,
        preferences: const NotificationPreferences(showAmountsOnLockScreen: false),
        now: now,
        dispatchedTimestamps: const [],
      );

      expect(privateDecision.body, contains('80%'));
      expect(privateDecision.body, isNot(contains('₹850')),
          reason: 'Privacy setting must mask exact spent rupee amount');
      expect(privateDecision.body, isNot(contains('₹1000')),
          reason: 'Privacy setting must mask exact allocated rupee amount');

      // Opted-in: showAmountsOnLockScreen = true
      final publicDecision = NotificationPolicyEngine.evaluate(
        alert: alert,
        preferences: const NotificationPreferences(showAmountsOnLockScreen: true),
        now: now,
        dispatchedTimestamps: const [],
      );

      expect(publicDecision.body, contains('₹850'));
      expect(publicDecision.body, contains('₹1000'));
    });

    test('6. Alert Trigger: 80% daily budget warning dispatches when spending crosses threshold', () async {
      final notifier = SalaryQuestNotifier(notificationService: fakeService);

      // Today's budget is around ₹1500 (from 45,000 / 30)
      final initialAllocated = notifier.state.todayBudget.allocatedBudget;
      final targetSpend = Money.fromPaise((initialAllocated.paise * 0.85).toInt());

      // Spend 85% of today's budget
      await notifier.addTransaction(
        amount: targetSpend,
        title: 'Dinner Gathering',
        category: TransactionCategory.food,
        customTimestamp: DateTime(2026, 10, 25, 13, 0),
      );

      // Verify notification was dispatched
      expect(fakeService.sentNotifications.length, equals(1));
      final sent = fakeService.sentNotifications.first;
      expect(sent.id, equals(NotificationAlertFactory.idBudget80));
      expect(sent.title, contains('Daily Budget Warning'));
    });

    test('7. Alert Trigger: Evening Streak Protection reminds user if no transactions logged', () async {
      final notifier = SalaryQuestNotifier(notificationService: fakeService);

      // Hero has a 4-day streak and 0 transactions logged today
      expect(notifier.state.transactions.isEmpty, isTrue);
      expect(notifier.state.hero.streakDays, equals(4));

      // Trigger evening streak check at 19:30 (7:30 PM)
      final decision = await notifier.checkEveningStreakAlert(
        now: DateTime(2026, 10, 25, 19, 30),
      );

      expect(decision, isNotNull);
      expect(decision!.shouldSend, isTrue);
      expect(fakeService.sentNotifications.length, equals(1));
      expect(fakeService.sentNotifications.first.title, contains('Streak Protection'));

      // If an expense is logged today, streak is not at risk
      await notifier.addTransaction(
        amount: Money.fromRupees(100),
        title: 'Chai',
        category: TransactionCategory.food,
        customTimestamp: DateTime(2026, 10, 25, 19, 45),
      );

      final decisionAfterLog = await notifier.checkEveningStreakAlert(
        now: DateTime(2026, 10, 25, 20, 0),
      );
      expect(decisionAfterLog, isNull,
          reason: 'User already logged today; streak is safe');
    });

    test('8. Alert Trigger: End-of-Day Cash Reminder dispatches cleanly', () async {
      final notifier = SalaryQuestNotifier(notificationService: fakeService);

      final decision = await notifier.checkCashReminderAlert(
        now: DateTime(2026, 10, 25, 21, 0),
      );

      expect(decision.shouldSend, isTrue);
      expect(fakeService.sentNotifications.length, equals(1));
      expect(fakeService.sentNotifications.first.title, contains('Cash Reminder'));
    });

    test('9. Alert Trigger: Savings Goal Milestone alerts at 50% and 100%', () async {
      final notifier = SalaryQuestNotifier(notificationService: fakeService);
      final daytime = DateTime(2026, 10, 25, 14, 0);

      // Create a ₹10,000 goal
      final goal = await notifier.createSavingsGoal(
        title: 'Goa Trip',
        targetAmount: Money.fromRupees(10000),
      );

      // Deposit ₹5,000 (crosses 50% milestone at daytime)
      await notifier.depositToGoal(
        goalId: goal.id,
        amount: Money.fromRupees(5000),
        customTimestamp: daytime,
      );

      expect(fakeService.sentNotifications.length, equals(1));
      expect(fakeService.sentNotifications.first.title, contains('50%'));

      // Deposit another ₹5,000 (reaches 100% completion)
      await notifier.depositToGoal(
        goalId: goal.id,
        amount: Money.fromRupees(5000),
        customTimestamp: daytime.add(const Duration(minutes: 10)),
      );

      expect(fakeService.sentNotifications.length, equals(2));
      expect(fakeService.sentNotifications.last.title, contains('Completed'));
    });

    test('10. Android 13+ Permission Denied: app continues executing seamlessly', () async {
      final deniedService = FakeNotificationService(permissionGranted: false);
      final deniedManager = NotificationManager(service: deniedService);

      final granted = await deniedManager.requestPermission();
      expect(granted, isFalse);

      final alert = NotificationAlertFactory.createCashReminderAlert(
        now: DateTime(2026, 10, 25, 14, 0),
      );

      // Dispatches without throwing or crashing
      final decision = await deniedManager.dispatchAlert(
        alert: alert,
        now: DateTime(2026, 10, 25, 14, 0),
      );
      expect(decision.shouldSend, isTrue);

      // Fake service drops delivery because permission is denied
      expect(deniedService.sentNotifications.isEmpty, isTrue);
    });
  });
}
