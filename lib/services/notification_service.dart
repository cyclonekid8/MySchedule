import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/activity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleActivityReminder(Activity activity) async {
    if (!activity.hasReminder) return;

    final reminderTime = activity.startTime.subtract(
      Duration(minutes: activity.reminderMinutesBefore),
    );

    if (reminderTime.isBefore(DateTime.now())) return;

    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'activity_reminders',
      'Activity Reminders',
      channelDescription: 'Reminders for scheduled activities',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    final notifId = activity.id.hashCode.abs() % 100000;

    await _plugin.zonedSchedule(
      notifId,
      '⏰ ${activity.title}',
      'Starting in ${activity.reminderMinutesBefore} minutes · ${activity.category.label}',
      tzReminderTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelActivityReminder(String activityId) async {
    final notifId = activityId.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
