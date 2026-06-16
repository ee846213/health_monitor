import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';

void main() {
  test('跨午夜勿扰时段能正确命中前后半段时间', () {
    const preference = NotificationPreference(
      enabled: true,
      startHour: 22,
      startMinute: 30,
      endHour: 7,
      endMinute: 0,
    );

    expect(preference.isWithinWindow(DateTime(2026, 6, 16, 23, 45)), isTrue);
    expect(preference.isWithinWindow(DateTime(2026, 6, 17, 6, 45)), isTrue);
    expect(preference.isWithinWindow(DateTime(2026, 6, 17, 9, 0)), isFalse);
  });

  test('NotificationPreference 应暴露格式化时间并支持 copyWith', () {
    const preference = NotificationPreference(
      enabled: true,
      startHour: 22,
      startMinute: 5,
      endHour: 7,
      endMinute: 30,
    );

    final updated = preference.copyWith(enabled: false, endMinute: 45);

    expect(preference.startLabel, '22:05');
    expect(preference.endLabel, '07:30');
    expect(updated.enabled, isFalse);
    expect(updated.endMinute, 45);
    expect(updated.startLabel, '22:05');
  });
}
