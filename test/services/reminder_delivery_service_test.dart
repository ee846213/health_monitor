import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/services/reminder_delivery_service.dart';
import 'package:health_monitor/storage/repositories/notification_preference_repository.dart';

void main() {
  test('提醒投递服务在勿扰时段内拦截发送，在非勿扰时段内放行', () async {
    final service = ReminderDeliveryService(
      notificationPreferenceRepository: InMemoryNotificationPreferenceRepository(
        initialValue: const NotificationPreference(
          enabled: true,
          startHour: 22,
          startMinute: 30,
          endHour: 7,
          endMinute: 0,
        ),
      ),
      notificationPermissionReader: () async => PermissionGrantStatus.granted,
    );
    final reminder = ReminderRecord.fromVerdict(
      verdict: const RuleVerdict(
        dimension: 'activity',
        level: 'warning',
        summary: '起身活动一下',
        detail: '已经久坐一段时间',
        shouldRemind: true,
        reminderType: 'sedentaryBreak',
      ),
      now: DateTime(2026, 6, 16, 23),
    );

    final blocked = await service.buildPlan(
      records: <ReminderRecord>[reminder],
      referenceTime: DateTime(2026, 6, 16, 23),
    );
    final ready = await service.buildPlan(
      records: <ReminderRecord>[reminder],
      referenceTime: DateTime(2026, 6, 16, 21),
    );

    expect(blocked.entries.single.reason, DeliveryBlockReason.doNotDisturb);
    expect(ready.readyRecords, hasLength(1));
  });

  test('提醒投递服务在通知权限缺失时保留记录但不发送', () async {
    final service = ReminderDeliveryService(
      notificationPreferenceRepository: InMemoryNotificationPreferenceRepository(
        initialValue: const NotificationPreference(
          enabled: false,
          startHour: 22,
          startMinute: 30,
          endHour: 7,
          endMinute: 0,
        ),
      ),
      notificationPermissionReader: () async => PermissionGrantStatus.denied,
    );
    final reminder = ReminderRecord.fromVerdict(
      verdict: const RuleVerdict(
        dimension: 'digital_usage',
        level: 'warning',
        summary: '先让眼睛休息一下',
        detail: '最近这段时间亮屏偏长',
        shouldRemind: true,
        reminderType: 'nightUsage',
      ),
      now: DateTime(2026, 6, 16, 20),
    );

    final plan = await service.buildPlan(
      records: <ReminderRecord>[reminder],
      referenceTime: DateTime(2026, 6, 16, 20),
    );

    expect(plan.readyRecords, isEmpty);
    expect(
      plan.blockedRecords.single.reason,
      DeliveryBlockReason.notificationPermissionDenied,
    );
  });
}
