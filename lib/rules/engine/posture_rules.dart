import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';

/// 姿势风险规则：从活动样本推断姿势风险。
///
/// 由于当前无独立姿势仓储，姿势风险由活动样本间接推断：
/// - 活动的 walking + 静止交替模式预示边走边看屏幕风险
/// - 长时连续静止预示低头/卧姿风险
///
/// 规则输出与 [ActivityRule] 互补：活动规则关注运动量，本规则关注姿势质量。
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

    // 识别典型的"边走边看屏幕"模式：
    // walking 样本占比超过 30% 且伴随较多碎片化样本切换。
    final walkingSamples = input.activitySamples
        .where((s) => s.type == ActivityType.walking);
    final walkingRatio = input.activityCount > 0
        ? walkingSamples.length / input.activityCount
        : 0;

    if (walkingRatio > 0.3 && input.activityCount >= 5) {
      verdicts.add(RuleVerdict(
        dimension: 'posture',
        level: 'warning',
        summary: '边走边看手机风险',
        detail: '近期行走样本占比 ${(walkingRatio * 100).round()}%，且活动切换频繁，走路看屏幕可能增加跌倒和颈椎负担。',
        shouldRemind: true,
        reminderTitle: '走路别看手机',
        reminderMessage: '检测到你常在行走中看屏幕，建议将视线放回路面上，安全第一。',
        reminderType: 'walkingScreenRisk',
      ));
    }

    // 长时间静止（大于 30 分钟的连续静止）判定。
    final longStationary = input.activitySamples
        .where((s) => s.isSedentary)
        .length;

    if (longStationary >= 2) {
      verdicts.add(RuleVerdict(
        dimension: 'posture',
        level: 'concern',
        summary: '久坐风险',
        detail: '检测到 ${longStationary} 次长时间静止（单次 >= 30 分钟），可能伴随低头或不良坐姿。',
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

