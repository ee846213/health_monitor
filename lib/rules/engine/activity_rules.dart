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

    final nonStationaryRatio = input.confidentActivitySamples.isNotEmpty
        ? input.confidentActivitySamples
                .where((ActivitySample sample) => sample.type != ActivityType.stationary)
                .length /
            input.confidentActivitySamples.length
        : 0;
    final latestSedentarySegment = input.sedentarySegments.isEmpty
        ? null
        : input.sedentarySegments.last;
    final totalSedentaryMinutes = input.totalSedentaryMinutes > 0
        ? input.totalSedentaryMinutes
        : input.sedentarySegments.fold<double>(
            0,
            (double total, SedentaryActivitySegment segment) =>
                total + segment.duration.inMinutes,
          );

    if (latestSedentarySegment != null &&
        latestSedentarySegment.duration >= const Duration(minutes: 60)) {
      verdicts.add(RuleVerdict(
        dimension: 'activity',
        level: 'concern',
        summary: '活动量偏低',
        detail:
            '最近一次有效久坐已经持续 ${latestSedentarySegment.duration.inMinutes} 分钟，建议尽快起身活动一下。',
        shouldRemind: true,
        reminderTitle: '该起来活动一下了',
        reminderMessage: '你已经连续静坐较长时间，起身走动 5 分钟有助于减轻久坐风险。',
        reminderType: 'sedentaryBreak',
      ));
    } else if (input.confidentActivitySamples.length < 3 &&
        input.totalSedentaryMinutes <= 0) {
      verdicts.add(RuleVerdict(
        dimension: 'activity',
        level: 'normal',
        summary: '活动数据不足',
        detail:
            '活动样本数不足（${input.confidentActivitySamples.length}），尚无法可靠判断连续久坐风险。',
      ));
    } else {
      verdicts.add(RuleVerdict(
        dimension: 'activity',
        level: 'normal',
        summary: '活动水平正常',
        detail:
            '当前累计久坐约 ${totalSedentaryMinutes.round()} 分钟，非静止样本占比 ${(nonStationaryRatio * 100).round()}%，活动水平暂时稳定。',
      ));
    }

    // 步数不足判定。
    if (input.totalSteps > 0 && input.totalSteps < 5000) {
      verdicts.add(RuleVerdict(
        dimension: 'activity',
        level: 'warning',
        summary: '步数不足',
        detail: '窗口内累计步数 ${input.totalSteps} 步，低于每日建议的 5000 步。',
      ));
    }

    return verdicts;
  }
}
