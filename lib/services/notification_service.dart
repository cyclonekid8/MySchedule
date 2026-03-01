import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../models/activity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

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
      _showFeedback("Initializing awesome notifications...");
      
      // Initialize awesome notifications with channel
      await AwesomeNotifications().initialize(
        'resource://drawable/ic_launcher', // App icon
        [
          NotificationChannel(
            channelKey: 'activity_reminders',
            channelName: 'Activity Reminders',
            channelDescription: 'Reminders for scheduled activities',
            defaultColor: const Color(0xFF6C63FF),
            ledColor: Colors.blue,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          ),
        ],
      );

      _showFeedback("Notification channel created successfully");

      // Request permissions
      await _requestPermissions();
      
    } catch (e) {
      _showFeedback("Initialization failed: $e");
    }
  }

  Future<void> _requestPermissions() async {
    try {
      _showFeedback("Requesting notification permissions...");
      
      // Request basic notification permission
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      if (isAllowed) {
        _showFeedback("Notification permission granted");
        
        // Request exact alarm permission for precise timing
        final List<NotificationPermission> permissions = [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.PreciseAlarms, // Important for Samsung devices
        ];

        await AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: permissions,
        );
        
        _showFeedback("All permissions requested");
      } else {
        _showFeedback("Notification permission denied");
      }
    } catch (e) {
      _showFeedback("Permission request failed: $e");
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      return await AwesomeNotifications().isNotificationAllowed();
    } catch (e) {
      return false;
    }
  }

  Future<void> scheduleActivityReminder(Activity activity) async {
    if (!activity.hasReminder) return;

    try {
      final reminderTime = activity.startTime.subtract(
        Duration(minutes: activity.reminderMinutesBefore),
      );
      
      if (reminderTime.isBefore(DateTime.now())) {
        _showFeedback('⚠️ Skipping ${activity.title} - reminder time in past');
        return;
      }

      final notifId = activity.id.hashCode.abs() % 100000;
      
      _showFeedback('📅 Scheduling ${activity.title} reminder for ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notifId,
          channelKey: 'activity_reminders',
          title: '⏰ Activity Reminder',
          body: '${activity.title} starts in ${activity.reminderMinutesBefore} minutes',
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          criticalAlert: true, // Important for Samsung devices
        ),
        schedule: NotificationCalendar.fromDate(
          date: reminderTime,
          allowWhileIdle: true, // Critical for Samsung battery optimization
          preciseAlarm: true,   // Ensures exact timing
        ),
      );
      
      _showFeedback('✅ Notification scheduled (ID: $notifId)');
      
    } catch (e) {
      _showFeedback('❌ Scheduling failed: $e');
    }
  }

  Future<void> cancelActivityReminder(String activityId) async {
    try {
      final notifId = activityId.hashCode.abs() % 100000;
      await AwesomeNotifications().cancel(notifId);
    } catch (e) {
      _showFeedback('Cancel reminder failed: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await AwesomeNotifications().cancelAll();
    } catch (e) {
      _showFeedback('Cancel all notifications failed: $e');
    }
  }

  Future<bool> ensureExactAlarmPermission(BuildContext context) async {
    // awesome_notifications handles this automatically with PreciseAlarms permission
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Set up notification action listeners (optional)
  static Future<void> initializeActionListeners() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
      onNotificationCreatedMethod: onNotificationCreated,
      onNotificationDisplayedMethod: onNotificationDisplayed,
      onDismissActionReceivedMethod: onDismissActionReceived,
    );
  }

  static Future<void> onActionReceived(ReceivedAction receivedAction) async {
    // Handle notification tap
    print('Notification tapped: ${receivedAction.title}');
  }

  static Future<void> onNotificationCreated(ReceivedNotification receivedNotification) async {
    print('Notification created: ${receivedNotification.title}');
  }

  static Future<void> onNotificationDisplayed(ReceivedNotification receivedNotification) async {
    print('Notification displayed: ${receivedNotification.title}');
  }

  static Future<void> onDismissActionReceived(ReceivedAction receivedAction) async {
    print('Notification dismissed: ${receivedAction.title}');
  }
}
