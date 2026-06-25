import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/reminder_category.dart';
import 'package:health_monitor/domain/notification/reminder_preferences.dart';

void main() {
  test('默认偏好下所有类别都允许投递', () {
    final preferences = ReminderPreferences.defaults;

    for (final category in ReminderCategory.values) {
      expect(preferences.isCategoryEnabled(category), isTrue);
      expect(
        preferences.isReminderTypeAllowed(category.reminderTypeKey),
        isTrue,
      );
    }
  });

  test('总开关关闭后所有类别都被屏蔽', () {
    final preferences = ReminderPreferences.defaults.toggleMaster(false);

    for (final category in ReminderCategory.values) {
      expect(preferences.isCategoryEnabled(category), isFalse);
      expect(
        preferences.isReminderTypeAllowed(category.reminderTypeKey),
        isFalse,
      );
    }
  });

  test('类别开关只影响对应 reminderType', () {
    final preferences = ReminderPreferences.defaults.toggleCategory(
      ReminderCategory.nightUsage,
      false,
    );

    expect(preferences.isReminderTypeAllowed('nightUsage'), isFalse);
    expect(preferences.isReminderTypeAllowed('sedentaryBreak'), isTrue);
    expect(preferences.isReminderTypeAllowed('walkingScreenRisk'), isTrue);
  });

  test('未知 reminderType 按未配置处理：总开关开则放行', () {
    final preferences = ReminderPreferences.defaults;

    expect(preferences.isReminderTypeAllowed('unknownType'), isTrue);
    expect(preferences.isReminderTypeAllowed(null), isTrue);
  });

  test('未知 reminderType 在总开关关闭后被屏蔽', () {
    final preferences = ReminderPreferences.defaults.toggleMaster(false);

    expect(preferences.isReminderTypeAllowed('unknownType'), isFalse);
  });

  test('reminderCategoryFromReminderTypeKey 能正确匹配规则 key', () {
    expect(
      reminderCategoryFromReminderTypeKey('sedentaryBreak'),
      ReminderCategory.sedentary,
    );
    expect(
      reminderCategoryFromReminderTypeKey('walkingScreenRisk'),
      ReminderCategory.walkingScreen,
    );
    expect(
      reminderCategoryFromReminderTypeKey('unknown'),
      isNull,
    );
    expect(reminderCategoryFromReminderTypeKey(null), isNull);
  });
}
