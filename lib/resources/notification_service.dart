import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The morning nudge: one notification a day listing who needs a message.
///
/// Everything happens on the phone — there is no server and no SMS bill.
/// The app works out the list whenever it is open and books tomorrow
/// morning's notification with what it found, so the reminder still shows
/// up even if the app is not opened that day.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyDigestId = 1001;
  static const String _channelId = 'daily_reminders';

  /// Hour of the morning the reminder arrives, on a 24-hour clock.
  static const int reminderHour = 9;

  bool _ready = false;

  /// True once the phone has been set up to show notifications. Everything
  /// else quietly does nothing until then, so a phone that refuses
  /// notifications never breaks the rest of the app.
  bool get isReady => _ready;

  /// Called once at startup. Safe to call again; it only sets up once.
  Future<void> init({
    void Function(String? payload)? onTapped,
  }) async {
    if (_ready) return;
    // Nothing here runs on desktop or web, and the gym app only ships to
    // phones, so the whole thing is skipped elsewhere.
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    try {
      tz_data.initializeTimeZones();
      // The device's own clock decides when 9am is; there is no server to
      // disagree with it.
      tz.setLocalLocation(tz.local);

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            // Asked for separately below, so the very first launch is not
            // two permission popups at once.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) =>
            onTapped?.call(response.payload),
      );
      _ready = true;
    } catch (_) {
      // A phone that will not set up notifications is not a reason to stop
      // the app from running.
      _ready = false;
    }
  }

  /// Asks for permission to show notifications. Android 12 and below grant
  /// it automatically; Android 13+ and iOS show a prompt once.
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Books (or re-books) the 9am reminder with [headline] as its message.
  ///
  /// Scheduled loosely rather than to the exact second: a reminder that
  /// arrives at 9:05 is just as useful, and exact alarms need a special
  /// permission that app stores question.
  Future<void> scheduleDailyDigest({
    required String headline,
    int memberCount = 0,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _dailyDigestId);
      if (headline.trim().isEmpty) return;

      await _plugin.zonedSchedule(
        id: _dailyDigestId,
        title: 'Today at the gym',
        body: headline,
        scheduledDate: _nextReminderTime(),
        payload: 'reminders',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // Without this the notification fires once and never again.
        matchDateTimeComponents: DateTimeComponents.time,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Daily reminders',
            channelDescription:
                'Birthdays and memberships that need attention today.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (_) {
      // Scheduling is a convenience; the reminders screen still works.
    }
  }

  /// Stops the daily reminder, for when the owner turns it off.
  Future<void> cancelDailyDigest() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _dailyDigestId);
    } catch (_) {
      // Nothing to do: there was no reminder booked.
    }
  }

  /// The next 9am. If it is already past 9 today, tomorrow's.
  static tz.TZDateTime _nextReminderTime() {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderHour,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }
}
