import 'package:health_monitor/domain/notification/reminder_category.dart';
import 'package:health_monitor/domain/notification/reminder_preferences.dart';
import 'package:isar/isar.dart';

part 'reminder_preferences_record.g.dart';

/// 提醒偏好持久化记录。
///
/// 单行记录，固定使用 id = 1。
/// 新字段在历史数据库上读取时默认 true，保持与无配置时一致的行为。
@collection
class ReminderPreferencesRecord {
  Id id = 1;
  late bool masterEnabled;
  late bool sedentaryEnabled;
  late bool postureRiskEnabled;
  late bool walkingScreenEnabled;
  late bool nightUsageEnabled;
  late bool noisyEnvironmentEnabled;

  static ReminderPreferencesRecord fromDomain(ReminderPreferences preferences) {
    return ReminderPreferencesRecord()
      ..masterEnabled = preferences.masterEnabled
      ..sedentaryEnabled =
          preferences.categoryEnabled[ReminderCategory.sedentary] ?? true
      ..postureRiskEnabled =
          preferences.categoryEnabled[ReminderCategory.postureRisk] ?? true
      ..walkingScreenEnabled =
          preferences.categoryEnabled[ReminderCategory.walkingScreen] ?? true
      ..nightUsageEnabled =
          preferences.categoryEnabled[ReminderCategory.nightUsage] ?? true
      ..noisyEnvironmentEnabled =
          preferences.categoryEnabled[ReminderCategory.noisyEnvironment] ??
              true;
  }

  ReminderPreferences toDomain() {
    return ReminderPreferences(
      masterEnabled: masterEnabled,
      categoryEnabled: <ReminderCategory, bool>{
        ReminderCategory.sedentary: sedentaryEnabled,
        ReminderCategory.postureRisk: postureRiskEnabled,
        ReminderCategory.walkingScreen: walkingScreenEnabled,
        ReminderCategory.nightUsage: nightUsageEnabled,
        ReminderCategory.noisyEnvironment: noisyEnvironmentEnabled,
      },
    );
  }
}
