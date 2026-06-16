import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/services/local_notification_service.dart';

void main() {
  test('本地通知服务只发送可投递的提醒记录', () async {
    final adapter = _FakeNotificationAdapter();
    final service = LocalNotificationService(adapter: adapter);
    final plan = ReminderDeliveryPlan(
      entries: <ReminderDeliveryEntry>[
        ReminderDeliveryEntry.ready(_reminder('起身活动一下')),
        ReminderDeliveryEntry.blockedByDnd(_reminder('先让眼睛休息一下')),
      ],
    );

    await service.initialize();
    await service.sendPlan(plan);

    expect(adapter.initializeCallCount, 1);
    expect(adapter.shownNotifications, hasLength(1));
    expect(adapter.shownNotifications.single.title, '起身活动一下');
    expect(adapter.shownNotifications.single.body, '已经久坐一段时间');
  });
}

ReminderRecord _reminder(String title) {
  return ReminderRecord(
    triggeredAt: DateTime(2026, 6, 16, 10),
    type: ReminderType.sedentaryBreak,
    title: title,
    message: '已经久坐一段时间',
    reasonSummary: '久坐偏长',
    actionSuggestion: '起来走走会更舒服一些',
    response: ReminderResponse.pending,
  );
}

class _FakeNotificationAdapter implements LocalNotificationAdapter {
  int initializeCallCount = 0;
  final List<_ShownNotification> shownNotifications = <_ShownNotification>[];

  @override
  Future<void> initialize() async {
    initializeCallCount += 1;
  }

  @override
  Future<bool> requestPermissions() async {
    return true;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    shownNotifications.add(
      _ShownNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }
}

class _ShownNotification {
  const _ShownNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String? payload;
}
