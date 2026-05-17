import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _i = NotificationService._();
  factory NotificationService() => _i;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'task_reminders';
  static const _channelName = 'Task Reminders';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );

    // Request Android 13+ notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleReminder({
    required int id,
    required String taskTitle,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    // Convert local DateTime → UTC so it fires at the correct absolute moment
    // regardless of device timezone setting.
    final tzUtcTime = tz.TZDateTime.from(scheduledTime.toUtc(), tz.UTC);

    await _plugin.zonedSchedule(
      id,
      '⏰ Task Reminder',
      taskTitle,
      tzUtcTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Scheduled reminders for your to-do tasks',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(taskTitle),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  // Deterministic int ID from task UUID, within int32 safe range
  int idFromTaskId(String taskId) => taskId.hashCode.abs() % 2147483647;
}
