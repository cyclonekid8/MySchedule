import 'package:flutter/material.dart';
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

  /// Check if exact alarms are permitted (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    final canSchedule = await android.canScheduleExactNotifications();
    return canSchedule ?? true;
  }

  /// Request exact alarm permission by opening system settings
  Future<void> requestExactAlarmPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestExactAlarmsPermission();
    }
  }

  /// Show a dialog prompting user to enable exact alarms, returns true if granted
  Future<bool> ensureExactAlarmPermission(BuildContext context) async {
    final canSchedule = await canScheduleExactAlarms();
    if (canSchedule) return true;

    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666688);
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Enable Alarms & Reminders',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
          content: Text(
            'MySchedule needs the "Alarms & Reminders" permission to send you timely activity reminders. '
            'You\'ll be taken to the system settings to enable it.',
            style: TextStyle(color: subColor, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Not Now', style: TextStyle(color: subColor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings',
                style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await requestExactAlarmPermission();
      // Check again after user returns from settings
      return await canScheduleExactAlarms();
    }
    return false;
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

    // Try exact first, fall back to inexact if not permitted
    final canExact = await canScheduleExactAlarms();
    await _plugin.zonedSchedule(
      notifId,
      '⏰ ${activity.title}',
      'Starting in ${activity.reminderMinutesBefore} minutes · ${activity.category.label}',
      tzReminderTime,
      details,
      androidScheduleMode: canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle,
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
