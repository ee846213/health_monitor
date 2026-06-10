import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';

/// 环境规则：评估噪音暴露水平。
///
/// 核心逻辑：
/// - 平均噪音分贝 >= 70 -> 高噪音暴露
/// - 平均噪音分贝 >= 55 -> 中噪音提醒
class EnvironmentRule implements HealthRule {
  const EnvironmentRule();

  /// 高噪音暴露阈值（dB）。
  static const double highNoiseDb = 70;

  /// 中噪音提醒阈值（dB）。
  static const double moderateNoiseDb = 55;

  @override
  String get name => '环境规则';

  @override
  String get dimension => 'environment';

  @override
  List<RuleVerdict> evaluate(RuleInput input) {
    final verdicts = <RuleVerdict>[];

    if (!input.isDimensionAvailable('noise')) {
      return verdicts;
    }

    if (input.averageNoiseDb >= highNoiseDb) {
      verdicts.add(RuleVerdict(
        dimension: 'environment',
        level: 'concern',
        summary: '高噪音环境',
        detail: '近期平均噪音 ${input.averageNoiseDb.toStringAsFixed(1)} dB，超过安全阈值 ${highNoiseDb.toStringAsFixed(0)} dB。长时间暴露可能造成听力损伤。',
        shouldRemind: true,
        reminderTitle: '当前环境噪音较大',
        reminderMessage: '检测到环境噪音偏高，长时间暴露可能损伤听力，建议转移至安静环境。',
        reminderType: 'noisyEnvironment',
      ));
    } else if (input.averageNoiseDb >= moderateNoiseDb) {
      verdicts.add(RuleVerdict(
        dimension: 'environment',
        level: 'warning',
        summary: '环境噪音偏高',
        detail: '近期平均噪音 ${input.averageNoiseDb.toStringAsFixed(1)} dB，处于中等偏高水平。',
      ));
    } else {
      verdicts.add(RuleVerdict(
        dimension: 'environment',
        level: 'normal',
        summary: '环境噪音正常',
        detail: '近期平均噪音 ${input.averageNoiseDb.toStringAsFixed(1)} dB，处于安全范围。',
      ));
    }

    return verdicts;
  }
}
