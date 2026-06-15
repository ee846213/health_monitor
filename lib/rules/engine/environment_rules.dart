import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';

/// 环境规则：结合白天光照与夜间噪音，输出更场景化的提醒。
class EnvironmentRule implements HealthRule {
  const EnvironmentRule();

  static const int nightNoiseConcernMinutes = 30;
  static const int daytimeDarkWarningMinutes = 60;

  @override
  String get name => '环境规则';

  @override
  String get dimension => 'environment';

  @override
  List<RuleVerdict> evaluate(RuleInput input) {
    final verdicts = <RuleVerdict>[];

    final hasNoise = input.isDimensionAvailable('noise');
    final hasLight = input.isDimensionAvailable('light');
    if (!hasNoise && !hasLight) {
      return verdicts;
    }

    final daytimeDarkMinutes = input.daytimeDarkLightDuration().inMinutes;
    final daytimeComfortableMinutes =
        input.daytimeComfortableLightDuration().inMinutes;
    final daytimeBrightMinutes = input.daytimeBrightLightDuration().inMinutes;
    final nightLoudMinutes = input.nightLoudNoiseDuration().inMinutes;
    final nightModerateMinutes = input.nightModerateNoiseDuration().inMinutes;

    final daytimeLightSummary = hasLight
        ? '白天过暗 $daytimeDarkMinutes 分钟，舒适 '
            '$daytimeComfortableMinutes 分钟，明亮 $daytimeBrightMinutes 分钟。'
        : '当前没有可用的真实光照数据。';
    final nightNoiseSummary = hasNoise
        ? '夜间嘈杂 $nightLoudMinutes 分钟，普通波动 '
            '$nightModerateMinutes 分钟。'
        : '当前没有可用的噪音数据。';

    if (nightLoudMinutes >= nightNoiseConcernMinutes) {
      verdicts.add(
        RuleVerdict(
          dimension: 'environment',
          level: 'concern',
          summary: '夜间环境偏嘈杂',
          detail: '$nightNoiseSummary ${hasLight ? daytimeLightSummary : ''}'
              .trim(),
          shouldRemind: true,
          reminderTitle: '当前环境噪音较大',
          reminderMessage: '检测到夜间环境噪音偏高，建议先切换到更安静的空间。',
          reminderType: 'noisyEnvironment',
        ),
      );
    } else if (daytimeDarkMinutes >= daytimeDarkWarningMinutes) {
      verdicts.add(
        RuleVerdict(
          dimension: 'environment',
          level: 'warning',
          summary: '白天光线偏暗',
          detail: '$daytimeLightSummary ${hasNoise ? nightNoiseSummary : ''}'
              .trim(),
        ),
      );
    } else {
      verdicts.add(
        RuleVerdict(
          dimension: 'environment',
          level: 'normal',
          summary: '环境整体平稳',
          detail: '$daytimeLightSummary $nightNoiseSummary',
        ),
      );
    }

    return verdicts;
  }
}
