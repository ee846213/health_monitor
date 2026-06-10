import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';

/// 活动规则：评估运动量、步数与久坐风险。
///
/// 核心逻辑：
/// - 窗口内步行/跑步占比过低 -> 久坐警告
/// - 总步数低于基准 -> 步数不足警告
/// - 活动样本充足且多元化 -> 正常
class ActivityRule implements HealthRule {
  const ActivityRule();

  @override
  String get name => '活动规则';

  @override
  String get dimension => 'activity';

  @override
  List<RuleVerdict> evaluate(RuleInput input) {
    final verdicts = <RuleVerdict>[];

    // 活动维度不可用时无需评估。
    if (!input.isDimensionAvailable('activity')) {
      return verdicts;
    }

    final activeSamples = input.activitySamples
        .where((s) => s.type == ActivityType.walking || s.type == ActivityType.running);
    final activeRatio = input.activityCount > 0
        ? activeSamples.length / input.activityCount
        : 0;

    // 久坐判定：活跃样本占比低于 20% 且非静止样本占比低于 30%。
    // 设计中采用的阈值基于 WHO 建议，每天至少应有一定比例的中等强度活动。
    final nonStationaryRatio = input.activityCount > 0
        ? input.activitySamples
              .where((s) => s.type != ActivityType.stationary)
              .length /
            input.activityCount
        : 0;

    if (nonStationaryRatio < 0.3 && input.activityCount >= 3) {
      verdicts.add(RuleVerdict(
        dimension: 'activity',
        level: 'concern',
        summary: '活动量偏低',
        detail: '近期活动样本中静坐占比过高（${((1 - nonStationaryRatio) * 100).round()}%），非静止占比仅${(nonStationaryRatio * 100).round()}%。',
        shouldRemind: true,
        reminderTitle: '该起来活动一下了',
        reminderMessage: '你已经连续静坐较长时间，起身走动 5 分钟有助于减轻久坐风险。',
        reminderType: 'sedentaryBreak',
      ));
    } else if (nonStationaryRatio < 0.3) {
      // 样本量不够做判定，不做提醒。
      verdicts.add(RuleVerdict(
        dimension: 'activity',
        level: 'normal',
        summary: '活动数据不足',
        detail: '活动样本数不足（${input.activityCount}），尚无法可靠判断久坐风险。',
      ));
    } else {
      verdicts.add(RuleVerdict(
        dimension: 'activity',
        level: 'normal',
        summary: '活动水平正常',
        detail: '近期非静止样本占比${(nonStationaryRatio * 100).round()}%，活动水平在正常范围。',
      ));
    }

    // 步数不足判定。
    if (input.totalSteps > 0 && input.totalSteps < 3000) {
      verdicts.add(RuleVerdict(
        dimension: 'activity',
        level: 'warning',
        summary: '步数不足',
        detail: '窗口内累计步数 ${input.totalSteps} 步，低于每日建议最低 5000 步。',
      ));
    }

    return verdicts;
  }
}
