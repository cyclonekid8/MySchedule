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
    _onUserFeedback?.call(message);
  }

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      _showFeedback('Timezone set to: \${tz.local.name}');
    } catch (e) {
      _showFeedback('Could not set local timezone: \$e');
    }
    
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings, onDidReceiveNotificationResponse: (details) {});
    
    try {
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    } catch (e) {
      _showFeedback('Permission request failed: \$e');
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return true;
      final canSchedule = await android.canScheduleExactNotifications();
      return canSchedule ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<void> scheduleActivityReminder(Activity activity) async {
    if (!activity.hasReminder) return;
    
    final reminderTime = activity.startTime.subtract(Duration(minutes: activity.reminderMinutesBefore));
    if (reminderTime.isBefore(DateTime.now())) return;

    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);
    final timeStr = DateFormat('HH:mm').format(reminderTime);
    _showFeedback('📅 Scheduling \${activity.title} reminder at \$timeStr');

    const androidDetails = AndroidNotificationDetails(
      'activity_reminders',
      'Activity Reminders',
      channelDescription: 'Reminders for scheduled activities',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notifId = activity.id.hashCode.abs() % 100000;
    final canExact = await canScheduleExactAlarms();

    await _plugin.zonedSchedule(
      notifId,
      '⏰ \${activity.title}',
      'Starting in \${activity.reminderMinutesBefore} minutes · \${activity.category.label}',
      tzReminderTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: canExact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    _showFeedback('✅ Scheduled (ID: \$notifId, \${canExact ? 'exact' : 'inexact'})');
  }

  Future<void> cancelActivityReminder(String activityId) async {
    final notifId = activityId.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<bool> ensureExactAlarmPermission(BuildContext context) async {
    return await canScheduleExactAlarms();
  }
}
