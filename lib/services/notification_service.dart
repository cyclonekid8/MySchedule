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
  Function(String)? _onUserFeedback;

  void setUserFeedbackCallback(Function(String) callback) {
    _onUserFeedback = callback;
  }

  void _showFeedback(String message) {
    if (_onUserFeedback != null) {
      _onUserFeedback!(message);
    }
  }

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
      _showFeedback("Initializing flutter_local_notifications...");

      // Initialize timezone
      tz.initializeTimeZones();
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Initialize plugin
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings, onDidReceiveNotificationResponse: (details) {});

      // Request Android 13+ notification permission
      _showFeedback("Requesting notification permission...");
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        _showFeedback(granted == true ? "Permission granted" : "Permission denied");

        // Create notification channel
        _showFeedback("Creating notification channel...");
        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            'activity_reminders',
            'Activity Reminders',
            description: 'Reminders for scheduled activities',
            importance: Importance.high,
          ),
        );
        _showFeedback("Notification channel created successfully");
        
        // Check and request exact alarm permission
        await _checkExactAlarmPermission();
      }

    } catch (e) {
      _showFeedback("Initialization failed: $e");
    }
  }

  Future<void> _checkExactAlarmPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final canSchedule = await androidImpl.canScheduleExactNotifications() ?? false;
      
      if (!canSchedule) {
        _showFeedback("Requesting exact alarm permission...");
        try {
          await androidImpl.requestExactAlarmsPermission();
          _showFeedback("Exact alarm permission requested");
        } catch (e) {
          _showFeedback("Failed to request exact alarm permission: $e");
        }
      } else {
        _showFeedback("Exact alarm permission already granted");
      }
    }
  }

  Future<void> scheduleActivityReminder(Activity activity) async {
    if (!activity.hasReminder) return;

    try {
      // Check exact alarm permission before scheduling
      final hasExactPermission = await ensureExactAlarmPermission();
      if (!hasExactPermission) {
        _showFeedback('Exact alarm permission denied - reminders may not be precise');
      }

      final reminderTime = activity.startTime.subtract(Duration(minutes: activity.reminderMinutesBefore));
      if (reminderTime.isBefore(DateTime.now()) && activity.repeat == RepeatType.none) {
        _showFeedback('Reminder time in past - skipping');
        return;
      }

      final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);
      final timeStr = DateFormat('HH:mm').format(reminderTime);
      final repeatDesc = _getRepeatDescription(activity.repeat);
      _showFeedback('Scheduling $repeatDesc reminder at $timeStr');

      const androidDetails = AndroidNotificationDetails(
        'activity_reminders',
        'Activity Reminders',
        channelDescription: 'Reminders for scheduled activities',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      final notifId = activity.id.hashCode.abs() % 100000;
      final repeatComponent = _getRepeatComponent(activity.repeat);

      await _plugin.zonedSchedule(
        notifId,
        'Activity Reminder',
        '${activity.title} starts in ${activity.reminderMinutesBefore} minutes',
        tzReminderTime,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: repeatComponent,
      );

      _showFeedback('Scheduled $repeatDesc reminder successfully (ID: $notifId)');
    } catch (e) {
      _showFeedback('Scheduling failed: $e');
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
          // Check again after request
          return await androidImpl.canScheduleExactNotifications() ?? false;
        } catch (e) {
          _showFeedback("Failed to request exact alarm permission: $e");
          return false;
        }
      }
      
      return canSchedule;
    }
    return false;
  }
}
