import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/reminder_category.dart';
import 'package:health_monitor/domain/notification/reminder_preferences.dart';
import 'package:health_monitor/storage/repositories/reminder_preferences_repository.dart';

void main() {
  test('InMemoryReminderPreferencesRepository 默认返回全开偏好', () async {
    final repository = InMemoryReminderPreferencesRepository();

    final preferences = await repository.read();

    expect(preferences, ReminderPreferences.defaults);
  });

  test('保存后再次读取应返回最新偏好', () async {
    final repository = InMemoryReminderPreferencesRepository();
    final next = ReminderPreferences.defaults
        .toggleCategory(ReminderCategory.nightUsage, false);

    await repository.save(next);
    final reloaded = await repository.read();

    expect(reloaded.isCategoryEnabled(ReminderCategory.nightUsage), isFalse);
    expect(reloaded.isCategoryEnabled(ReminderCategory.sedentary), isTrue);
  });

  test('保存总开关关闭后所有类别一并被关闭', () async {
    final repository = InMemoryReminderPreferencesRepository();

    await repository.save(
      ReminderPreferences.defaults.toggleMaster(false),
    );
    final reloaded = await repository.read();

    expect(reloaded.masterEnabled, isFalse);
    for (final category in ReminderCategory.values) {
      expect(reloaded.isCategoryEnabled(category), isFalse);
    }
  });
}
