import 'package:health_monitor/core/logging/app_logger.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';

/// 诊断日志器：记录采集、后台、规则、权限四类关键事件。
class DiagnosticsLogger {
  const DiagnosticsLogger();

  /// 记录后台采集状态变更。
  void logCaptureState(BackgroundCaptureState state) {
    AppLogger.instance.info('capture', state.label, <String, Object?>{
      'status': state.status.name,
      'reason': state.reason,
    });
  }

  /// 记录后台链路状态（来自宿主平台的状态快照）。
  void logBackgroundLink(String platform, String summary, bool isRunning) {
    AppLogger.instance.info('background', '[$platform] $summary', <String, Object?>{
      'platform': platform,
      'isRunning': isRunning,
    });
  }

  /// 记录规则引擎输出。
  void logRuleOutput(List<RuleVerdict> verdicts) {
    for (final v in verdicts) {
      final level = v.shouldRemind ? LogLevel.warning : LogLevel.info;
      AppLogger.instance.log(level, 'rule.$v.dimension', v.summary, <String, Object?>{
        'level': v.level,
        'shouldRemind': v.shouldRemind,
        'reminderType': v.reminderType,
      });
    }
  }

  /// 记录权限变化事件。
  void logPermissionChange(PermissionType type, String fromStatus, String toStatus) {
    AppLogger.instance.warning('permission', '${type.name}: $fromStatus -> $toStatus', <String, Object?>{
      'type': type.name,
      'from': fromStatus,
      'to': toStatus,
    });
  }
}