import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/activity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  DateTimeComponents? _getRepeatComponent(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.daily:
        return DateTimeComponents.time;
      case RepeatType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepeatType.none:
        return null;
    }
  }

  String _getRepeatDescription(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.daily:
        return "daily";
      case RepeatType.weekly:
        return "weekly";
      case RepeatType.monthly:
        return "monthly";
      case RepeatType.none:
        return "once";
    }
  }

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings, onDidReceiveNotificationResponse: (details) {});

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();

        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            'activity_reminders',
            'Activity Reminders',
            description: 'Reminders for scheduled activities',
            importance: Importance.high,
          ),
        );
        
        await _checkExactAlarmPermission();
      }

    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> _checkExactAlarmPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final canSchedule = await androidImpl.canScheduleExactNotifications() ?? false;
      
      if (!canSchedule) {
        try {
          await androidImpl.requestExactAlarmsPermission();
        } catch (e) {
          // Silent error handling
        }
      }
    }
  }

  Future<void> scheduleActivityReminder(Activity activity) async {
    try {
      final hasExactPermission = await ensureExactAlarmPermission();

      // Schedule start notification (always)
      await _scheduleStartNotification(activity);

      // Schedule reminder notification (if enabled)
      if (activity.hasReminder) {
        await _scheduleReminderNotification(activity);
      }

    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> _scheduleStartNotification(Activity activity) async {
    final startTime = activity.startTime;
    if (startTime.isBefore(DateTime.now()) && activity.repeat == RepeatType.none) {
      return;
    }

    final tzStartTime = tz.TZDateTime.from(startTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'activity_reminders',
      'Activity Reminders',
      channelDescription: 'Activity start notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    final startNotifId = (activity.id.hashCode.abs() % 100000) + 50000; // Offset for start notifications
    final repeatComponent = _getRepeatComponent(activity.repeat);

    await _plugin.zonedSchedule(
      startNotifId,
      '🚀 Activity Starting',
      '${activity.title} is starting now!',
      tzStartTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatComponent,
    );
  }

  Future<void> _scheduleReminderNotification(Activity activity) async {
    final reminderTime = activity.startTime.subtract(Duration(minutes: activity.reminderMinutesBefore));
    if (reminderTime.isBefore(DateTime.now()) && activity.repeat == RepeatType.none) {
      return;
    }

    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'activity_reminders',
      'Activity Reminders',
      channelDescription: 'Reminders for scheduled activities',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    final reminderNotifId = activity.id.hashCode.abs() % 100000; // Original reminder ID
    final repeatComponent = _getRepeatComponent(activity.repeat);

    await _plugin.zonedSchedule(
      reminderNotifId,
      '⏰ Activity Reminder',
      '${activity.title} starts in ${activity.reminderMinutesBefore} minutes',
      tzReminderTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatComponent,
    );
  }
  }

  Future<void> cancelActivityReminder(String activityId) async {
    final notifId = activityId.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<bool> ensureExactAlarmPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final canSchedule = await androidImpl.canScheduleExactNotifications() ?? false;
      
      if (!canSchedule) {
        try {
          await androidImpl.requestExactAlarmsPermission();
          return await androidImpl.canScheduleExactNotifications() ?? false;
        } catch (e) {
          return false;
        }
      }
      
      return canSchedule;
    }
    return false;
  }
}