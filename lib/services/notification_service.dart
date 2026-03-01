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
      }
      
    } catch (e) {
      _showFeedback("Initialization failed: $e");
    }
  }

  Future<void> scheduleActivityReminder(Activity activity) async {
    if (!activity.hasReminder) return;

    try {
      final reminderTime = activity.startTime.subtract(Duration(minutes: activity.reminderMinutesBefore));
      if (reminderTime.isBefore(DateTime.now())) {
        _showFeedback('Reminder time in past - skipping');
        return;
      }

      final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);
      final timeStr = DateFormat('HH:mm').format(reminderTime);
      _showFeedback('Scheduling reminder at $timeStr');

      const androidDetails = AndroidNotificationDetails(
        'activity_reminders',
        'Activity Reminders',
        channelDescription: 'Reminders for scheduled activities',
        importance: Importance.high,
        priority: Priority.high,
      );

      final notifId = activity.id.hashCode.abs() % 100000;

      await _plugin.zonedSchedule(
        notifId,
        'Activity Reminder',
        '${activity.title} starts in ${activity.reminderMinutesBefore} minutes',
        tzReminderTime,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      _showFeedback('Scheduled successfully (ID: $notifId)');
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

  Future<bool> ensureExactAlarmPermission(BuildContext context) async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      return await androidImpl.canScheduleExactNotifications() ?? false;
    }
    return false;
  }
}
