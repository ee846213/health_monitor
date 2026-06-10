import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';

/// 数字生活规则：评估屏幕使用时长与解锁频率。
///
/// 核心逻辑：
/// - 总屏幕时长超过阈值 -> 过度使用警告
/// - 解锁次数异常 -> 碎片化关注警告
class UsageRule implements HealthRule {
  const UsageRule();

  /// 单日屏幕时长阈值（分钟），超过此值视为过度使用。
  static const double screenTimeWarningMinutes = 240;

  /// 单日解锁次数阈值，超过此值视为碎片化使用。
  static const int unlockCountWarningThreshold = 60;

  @override
  String get name => '数字生活规则';

  @override
  String get dimension => 'usage';

  @override
  List<RuleVerdict> evaluate(RuleInput input) {
    final verdicts = <RuleVerdict>[];

    if (!input.isDimensionAvailable('digital_usage')) {
      return verdicts;
    }

    // 屏幕时长判定。
    if (input.totalScreenMinutes >= screenTimeWarningMinutes) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'concern',
        summary: '屏幕使用时间过长',
        detail: '窗口内累计屏幕使用 ${input.totalScreenMinutes.round()} 分钟，超过建议的 ${screenTimeWarningMinutes.round()} 分钟。',
        shouldRemind: true,
        reminderTitle: '该放下手机了',
        reminderMessage: '你今天的屏幕使用时间较长，让眼睛休息 10 分钟吧。',
        reminderType: 'nightUsage',
      ));
    } else {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'normal',
        summary: '屏幕使用时间正常',
        detail: '窗口内屏幕使用 ${input.totalScreenMinutes.round()} 分钟，在健康范围内。',
      ));
    }

    // 解锁次数判定。
    if (input.totalUnlockCount >= unlockCountWarningThreshold) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'warning',
        summary: '解锁频繁',
        detail: '窗口内解锁 ${input.totalUnlockCount} 次，超过 ${unlockCountWarningThreshold} 次阈值，碎片化关注可能影响专注力。',
      ));
    }

    return verdicts;
  }
}
