import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';

void main() {
  ReminderRecord fakeReminder(String title) {
    return ReminderRecord(
      triggeredAt: DateTime(2026, 6, 16, 10, 0),
      type: ReminderType.sedentaryBreak,
      title: title,
      message: '$title message',
      reasonSummary: '$title reason',
      actionSuggestion: '$title action',
      response: ReminderResponse.pending,
    );
  }

  test('提醒投递计划能区分可发送与被拦截记录', () {
    final ready = ReminderDeliveryEntry.ready(fakeReminder('walk'));
    final blocked = ReminderDeliveryEntry.blockedByDnd(fakeReminder('screen'));

    final plan = ReminderDeliveryPlan(
      entries: <ReminderDeliveryEntry>[ready, blocked],
    );

    expect(plan.readyRecords.map((item) => item.title), <String>['walk']);
    expect(plan.blockedRecords.single.reason, DeliveryBlockReason.doNotDisturb);
  });
}
