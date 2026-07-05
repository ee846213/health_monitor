import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';

abstract class LocalNotificationAdapter {
  Future<void> initialize();

  Future<bool> requestPermissions();

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
}

class LocalNotificationService {
  LocalNotificationService({
    LocalNotificationAdapter? adapter,
  }) : _adapter = adapter ?? FlutterLocalNotificationAdapter();

  final LocalNotificationAdapter _adapter;
  var _nextNotificationId = 1;

  Future<void> initialize() {
    return _adapter.initialize();
  }

  Future<bool> requestPermissions() {
    return _adapter.requestPermissions();
  }

  Future<void> sendPlan(ReminderDeliveryPlan plan) async {
    for (final record in plan.readyRecords) {
      await _adapter.show(
        id: _nextNotificationId++,
        title: record.title,
        body: record.message,
        payload: record.type.name,
      );
    }
  }
}

class FlutterLocalNotificationAdapter implements LocalNotificationAdapter {
  FlutterLocalNotificationAdapter({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  var _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('ic_stat_health_monitor');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final plugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await plugin?.requestNotificationsPermission() ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final plugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await plugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final plugin = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      return await plugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    return true;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'health_monitor_reminders',
        '健康提醒',
        channelDescription: '用于发送健康监测应用的本地提醒',
        icon: 'ic_stat_health_monitor',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
