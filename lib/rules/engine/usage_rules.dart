import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';

/// 数字生活规则组：更强调“查看节奏”和“夜间使用”。
class UsageRule implements HealthRule {
  const UsageRule();

  static const double frequentCheckingWarningThreshold = 40;
  static const double denseActivationWarningThreshold = 12;
  static const double lateNightReminderMinutes = 60;
  static const double lateNightWarningMinutes = 30;

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

    if (input.averageDailyNightScreenMinutes >= lateNightReminderMinutes) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'concern',
        summary: '深夜屏幕使用偏长',
        detail:
            '最近平均每天夜间使用 ${input.averageDailyNightScreenMinutes.round()} 分钟，已经明显挤占休息窗口。',
        shouldRemind: true,
        reminderTitle: '今晚该慢下来一点',
        reminderMessage: '夜间看屏有点久了，先把节奏放慢，给睡前留一点缓冲。',
        reminderType: 'nightUsage',
      ));
    } else if (input.averageDailyNightScreenMinutes >=
        lateNightWarningMinutes) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'warning',
        summary: '夜间看屏开始偏多',
        detail:
            '最近平均每天夜间使用 ${input.averageDailyNightScreenMinutes.round()} 分钟，可以更早进入低刺激状态。',
      ));
    }

    if (input.averageDailyViewCount >= frequentCheckingWarningThreshold) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'warning',
        summary: '查看频率偏高',
        detail:
            '最近平均每天查看 ${input.averageDailyViewCount.round()} 次，节奏有些碎；原始解锁次数约为 ${input.totalUnlockCount} 次。',
      ));
    }

    if (input.averageDailyFocusSessionBreakCount >=
        denseActivationWarningThreshold) {
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'warning',
        summary: '时段激活偏密',
        detail:
            '最近平均每天出现 ${input.averageDailyFocusSessionBreakCount.round()} 次短间隔再次查看，容易打断连续专注。',
      ));
    }

    if (verdicts.isEmpty) {
      final longestMinutes = input.longestContinuousUsageMinutes;
      final longestDetail = longestMinutes > 0
          ? '最长连续使用约 $longestMinutes 分钟。'
          : '当前未看到明显的高频查看或深夜使用。';
      verdicts.add(RuleVerdict(
        dimension: 'usage',
        level: 'normal',
        summary: '屏幕使用习惯整体平稳',
        detail: longestDetail,
      ));
    }

    return verdicts;
  }
}
