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
  static const int unlockCountWarningThreshold = 40;

  /// 单日专注中断次数阈值。
  static const int focusSessionBreakWarningThreshold = 12;

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

    if (input.totalScreenMinutes >= screenTimeWarningMinutes) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'concern',
        summary: '屏幕使用时间过长',
        detail: '窗口内累计屏幕使用 ${input.totalScreenMinutes.round()} 分钟，超过建议的 ${screenTimeWarningMinutes.round()} 分钟。',
      ));
    } else {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'normal',
        summary: '屏幕使用时间正常',
        detail: '窗口内屏幕使用 ${input.totalScreenMinutes.round()} 分钟，在健康范围内。',
      ));
    }

    if (input.totalNightScreenMinutes >= 60) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'concern',
        summary: '夜间看屏偏多',
        detail:
            '22 点后的累计亮屏时间已经达到 ${input.totalNightScreenMinutes.round()} 分钟，建议尽早进入低刺激状态。',
        shouldRemind: true,
        reminderTitle: '该放下手机了',
        reminderMessage: '你今晚看屏时间有点久，先让眼睛休息一下吧。',
        reminderType: 'nightUsage',
      ));
    }

    if (input.totalUnlockCount >= unlockCountWarningThreshold ||
        input.totalFocusSessionBreakCount >= focusSessionBreakWarningThreshold) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'warning',
        summary: '解锁频繁',
        detail:
            '窗口内解锁 ${input.totalUnlockCount} 次、专注中断 ${input.totalFocusSessionBreakCount} 次，碎片化查看可能影响专注力。',
      ));
    }

    return verdicts;
  }
}
