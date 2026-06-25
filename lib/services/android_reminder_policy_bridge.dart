import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/domain/notification/reminder_category.dart';
import 'package:health_monitor/domain/notification/reminder_preferences.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

/// 把 Flutter 侧的提醒偏好与勿扰窗口同步给 Android 原生 SharedPreferences，
/// 使 `AndroidWalkingScreenRiskNotifier` 在 Flutter isolate 不在线时也能做出一致判断。
class AndroidReminderPolicyBridge {
  AndroidReminderPolicyBridge({
    PlatformBridgeService? platformBridgeService,
  }) : _platformBridgeService =
            platformBridgeService ?? PlatformBridgeService();

  final PlatformBridgeService _platformBridgeService;

  static const String _methodUpdate = 'android.reminder.updatePolicy';

  Future<void> updatePolicy({
    required ReminderPreferences reminderPreferences,
    required NotificationPreference notificationPreference,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _platformBridgeService.methodChannel.invokeMethod<bool>(
        _methodUpdate,
        <String, Object?>{
          'masterEnabled': reminderPreferences.masterEnabled,
          'walkingScreenEnabled':
              reminderPreferences.isCategoryEnabled(ReminderCategory.walkingScreen),
          'dndEnabled': notificationPreference.enabled,
          'dndStartMinutes': notificationPreference.startHour * 60 +
              notificationPreference.startMinute,
          'dndEndMinutes': notificationPreference.endHour * 60 +
              notificationPreference.endMinute,
        },
      );
    } on MissingPluginException {
      // 单测或非 Android 宿主下没有对应实现，保持静默以避免污染日志。
    } on PlatformException {
      // 原生侧若未实现该 method，对前台投递不构成影响，这里同样按降级处理。
    }
  }
}
