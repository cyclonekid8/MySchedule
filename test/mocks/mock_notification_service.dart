import 'package:myschedule/models/activity.dart';
import 'package:myschedule/services/notification_service.dart';

class MockNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleActivityReminder(Activity activity) async {}

  @override
  Future<void> cancelActivityReminder(String activityId) async {}

  @override
  Future<void> cancelAll() async {}
}
