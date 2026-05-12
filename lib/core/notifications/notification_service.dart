import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 0;
  static bool _tzInitialized = false;

  /// Initialize the notification plugin + tz database. Must run before any
  /// schedule/cancel call. Called from `main.dart`.
  static Future<void> initialize() async {
    _initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);
  }

  static void _initializeTimeZones() {
    if (_tzInitialized) return;
    tzdata.initializeTimeZones();
    // We don't have a native plugin to detect the device timezone, so we
    // rely on the local DateTime offset. zonedSchedule treats a TZDateTime
    // built from `tz.local` as the device's wall clock, which is what we want
    // for a daily-reading reminder.
    _tzInitialized = true;
  }

  /// Request notification permissions on the platforms that need an explicit
  /// prompt. Returns true if the user granted (or if the platform doesn't
  /// require an explicit grant).
  static Future<bool> requestPermission() async {
    final iOS = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      // Best-effort exact-alarm request — fine if the user denies, the
      // scheduler will fall back to inexact delivery.
      await android.requestExactAlarmsPermission();
      return granted ?? true;
    }
    return true;
  }

  /// Schedule a daily reminder at the given local time-of-day. If a previous
  /// reminder exists it's replaced. The reminder repeats indefinitely.
  static Future<void> scheduleDailyReminder({
    int hour = 20,
    int minute = 0,
    String title = 'Time to read',
    String body = 'Your daily reading streak is waiting',
  }) async {
    _initializeTimeZones();

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reading Reminder',
      channelDescription: 'Reminds you to read every day at your chosen time.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final firstFire = _nextInstanceOf(hour, minute);

    try {
      await _plugin.zonedSchedule(
        _dailyReminderId,
        title,
        body,
        firstFire,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Some Android OEMs / API levels reject exact alarms even when the
      // permission is granted. Fall back to a periodic daily notification
      // so the user still gets reminded — just without an exact time-of-day.
      debugPrint('zonedSchedule failed, falling back to periodicallyShow: $e');
      await _plugin.periodicallyShow(
        _dailyReminderId,
        title,
        body,
        RepeatInterval.daily,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Cancel any scheduled reminders.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
