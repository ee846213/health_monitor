import 'package:health_monitor/domain/notification/reminder_category.dart';

/// 用户在「我的 → 提醒偏好」里维护的开关集合。
///
/// - [masterEnabled] 是总开关，关闭后所有类别都不会进入历史，也不会发送系统通知。
/// - [categoryEnabled] 是每个类别的细分开关，仅当 [masterEnabled] 为 true 时生效。
class ReminderPreferences {
  ReminderPreferences({
    required this.masterEnabled,
    required Map<ReminderCategory, bool> categoryEnabled,
  }) : categoryEnabled = Map<ReminderCategory, bool>.unmodifiable(
          <ReminderCategory, bool>{
            for (final category in ReminderCategory.values)
              category: categoryEnabled[category] ?? true,
          },
        );

  final bool masterEnabled;
  final Map<ReminderCategory, bool> categoryEnabled;

  /// 默认全部开启。
  ///
  /// 首次启动或仓储没有持久化记录时使用，保持与历史行为一致。
  static final ReminderPreferences defaults = ReminderPreferences(
    masterEnabled: true,
    categoryEnabled: <ReminderCategory, bool>{
      for (final category in ReminderCategory.values) category: true,
    },
  );

  bool isCategoryEnabled(ReminderCategory category) {
    if (!masterEnabled) {
      return false;
    }
    return categoryEnabled[category] ?? true;
  }

  /// 判断某条规则结论是否允许进入提醒链路。
  ///
  /// [reminderTypeKey] 为 [RuleVerdict.reminderType]；
  /// 当 key 无法识别为任何类别时按"未配置"处理，默认放行，
  /// 避免新规则上线时被偏好误屏蔽。
  bool isReminderTypeAllowed(String? reminderTypeKey) {
    if (!masterEnabled) {
      return false;
    }
    final category = reminderCategoryFromReminderTypeKey(reminderTypeKey);
    if (category == null) {
      return true;
    }
    return categoryEnabled[category] ?? true;
  }

  ReminderPreferences copyWith({
    bool? masterEnabled,
    Map<ReminderCategory, bool>? categoryEnabled,
  }) {
    return ReminderPreferences(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      categoryEnabled: categoryEnabled ?? this.categoryEnabled,
    );
  }

  ReminderPreferences toggleMaster(bool enabled) {
    if (enabled) {
      return copyWith(masterEnabled: true);
    }
    return copyWith(masterEnabled: false);
  }

  ReminderPreferences toggleCategory(ReminderCategory category, bool enabled) {
    final next = Map<ReminderCategory, bool>.from(categoryEnabled);
    next[category] = enabled;
    return copyWith(categoryEnabled: next);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReminderPreferences) return false;
    if (other.masterEnabled != masterEnabled) return false;
    for (final category in ReminderCategory.values) {
      if (other.categoryEnabled[category] != categoryEnabled[category]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    var hash = masterEnabled.hashCode;
    for (final category in ReminderCategory.values) {
      hash = hash ^ (categoryEnabled[category]?.hashCode ?? 0);
    }
    return hash;
  }
}
