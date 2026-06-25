/// 提醒类别。
///
/// 与规则引擎产出的 `reminderType` key 一一对应，
/// 让"提醒偏好"开关可以根据 [RuleVerdict.reminderType] 精确过滤；
/// 同时也对应 Android 原生侧的安全提醒（移动看屏）。
enum ReminderCategory {
  sedentary,
  postureRisk,
  walkingScreen,
  nightUsage,
  noisyEnvironment,
}

extension ReminderCategoryX on ReminderCategory {
  /// 规则引擎使用的 reminderType key。
  ///
  /// 仅作为过滤匹配使用，不要写入提醒历史。
  String get reminderTypeKey {
    switch (this) {
      case ReminderCategory.sedentary:
        return 'sedentaryBreak';
      case ReminderCategory.postureRisk:
        return 'postureRisk';
      case ReminderCategory.walkingScreen:
        return 'walkingScreenRisk';
      case ReminderCategory.nightUsage:
        return 'nightUsage';
      case ReminderCategory.noisyEnvironment:
        return 'noisyEnvironment';
    }
  }

  /// 持久化与 method channel 序列化使用的稳定 key。
  String get storageKey {
    switch (this) {
      case ReminderCategory.sedentary:
        return 'sedentary';
      case ReminderCategory.postureRisk:
        return 'postureRisk';
      case ReminderCategory.walkingScreen:
        return 'walkingScreen';
      case ReminderCategory.nightUsage:
        return 'nightUsage';
      case ReminderCategory.noisyEnvironment:
        return 'noisyEnvironment';
    }
  }

  String get displayLabel {
    switch (this) {
      case ReminderCategory.sedentary:
        return '久坐提醒';
      case ReminderCategory.postureRisk:
        return '姿势风险提醒';
      case ReminderCategory.walkingScreen:
        return '移动看屏提醒';
      case ReminderCategory.nightUsage:
        return '夜间使用提醒';
      case ReminderCategory.noisyEnvironment:
        return '环境噪音提醒';
    }
  }
}

ReminderCategory? reminderCategoryFromReminderTypeKey(String? key) {
  if (key == null || key.isEmpty) {
    return null;
  }
  for (final category in ReminderCategory.values) {
    if (category.reminderTypeKey == key) {
      return category;
    }
  }
  return null;
}
