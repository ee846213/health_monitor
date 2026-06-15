import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';

/// 姿势风险规则：当前先使用久坐片段和日级姿势风险计数做判断。
class PostureRule implements HealthRule {
  const PostureRule();

  @override
  String get name => '姿势风险规则';

  @override
  String get dimension => 'posture';

  @override
  List<RuleVerdict> evaluate(RuleInput input) {
    final verdicts = <RuleVerdict>[];

    if (!input.isDimensionAvailable('activity')) {
      return verdicts;
    }

    final postureRiskCount = input.dailyMetricsList.isNotEmpty
        ? input.dailyMetricsList.fold<int>(
            0,
            (int total, metrics) => total + metrics.postureRiskCount,
          )
        : input.sedentarySegments
            .where(
              (SedentaryActivitySegment segment) =>
                  segment.duration >= const Duration(minutes: 30),
            )
            .length;

    if (postureRiskCount >= 2) {
      verdicts.add(RuleVerdict(
        dimension: 'posture',
        level: 'concern',
        summary: '久坐风险',
        detail:
            '检测到 $postureRiskCount 次长时间静止或姿势风险片段（单次 >= 30 分钟），可能伴随低头或不良坐姿。',
        shouldRemind: true,
        reminderTitle: '换个姿势',
        reminderMessage: '你已在同一姿势保持较长时间，起身活动一下、调整坐姿有助于缓解脊柱压力。',
        reminderType: 'postureRisk',
      ));
    } else {
      verdicts.add(RuleVerdict(
        dimension: 'posture',
        level: 'normal',
        summary: '姿势风险正常',
        detail: '近期未检测到异常姿势模式。',
      ));
    }

    return verdicts;
  }
}
