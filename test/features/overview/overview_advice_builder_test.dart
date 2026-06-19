import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/features/overview/overview_advice_builder.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/health_insight_service.dart';

void main() {
  test('首页降级建议优先围绕步数与久坐输出', () {
    final advice = buildDashboardFallbackAdvice(
      metrics: const HealthInsightMetrics(
        stepCount: 3200,
        sedentaryMinutes: 180,
        screenMinutes: 90,
        outdoorMinutes: 12,
      ),
      verdicts: const <RuleVerdict>[
        RuleVerdict(
          dimension: 'posture',
          level: 'warning',
          summary: '姿势风险偏高',
          detail: '坐姿需要调整。',
        ),
      ],
      environmentOverview: null,
    );

    expect(advice, contains('步数'));
    expect(advice, contains('久坐'));
  });

  test('首页降级建议会在环境噪音异常时优先提示噪音', () {
    final advice = buildDashboardFallbackAdvice(
      metrics: const HealthInsightMetrics(
        stepCount: 7800,
        sedentaryMinutes: 60,
        screenMinutes: 110,
        outdoorMinutes: 20,
      ),
      verdicts: const <RuleVerdict>[],
      environmentOverview: const EnvironmentOverview(
        headline: '夜间环境偏嘈杂',
        detail: '夜间连续嘈杂时段偏长。',
        daytimeLightSummary: '白天舒适',
        nightNoiseSummary: '夜间嘈杂 48 分钟',
        primaryConcern: EnvironmentPrimaryConcern.highNoise,
      ),
    );

    expect(advice, contains('噪音'));
  });
}
