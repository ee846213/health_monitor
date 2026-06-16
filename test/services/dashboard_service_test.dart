import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/dashboard_service.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('首页聚合服务能生成分数、环境快照与 AI 建议字段', () async {
    final insight = _fakeInsightSnapshot();
    final service = DashboardService(
      loadInsightSnapshot: ({
        required QueryWindow window,
        DateTime? referenceTime,
      }) async {
        return insight;
      },
      buildDailyAdvice: ({
        required DateTime referenceTime,
        required RuleInput input,
        required HealthInsightMetrics metrics,
        required List<RuleVerdict> verdicts,
        required EnvironmentOverview? environmentOverview,
      }) async {
        return const DailyAdviceBubble(
          text: '晚饭后散步 15 分钟会更稳。',
          source: DailyAdviceSource.fallback,
        );
      },
    );

    final snapshot = await service.build(
      referenceTime: DateTime(2026, 6, 16, 9),
    );

    expect(snapshot.healthScore.totalScore, 92);
    expect(snapshot.stepCard.goalSteps, 6000);
    expect(snapshot.environmentSnapshot.lightLabel, '舒适');
    expect(snapshot.dailyAdviceBubble.text, '晚饭后散步 15 分钟会更稳。');
  });
}

HealthInsightSnapshot _fakeInsightSnapshot() {
  final date = DateTime(2026, 6, 16, 9);
  final input = RuleInput(
    window: QueryWindow.recentDay(referenceTime: date),
    activitySamples: const [],
    locationSummaries: const [],
    noiseSamples: <NoiseSample>[
      NoiseSample(
        capturedAt: date,
        duration: const Duration(minutes: 10),
        decibel: 48,
        level: NoiseLevel.moderate,
      ),
    ],
    ambientLightSamples: <AmbientLightSample>[
      AmbientLightSample(
        capturedAt: date,
        duration: const Duration(minutes: 10),
        lux: 200,
        level: AmbientLightLevel.comfortable,
      ),
    ],
    usageSummaries: <DigitalUsageSummary>[
      DigitalUsageSummary(
        date: DateTime(2026, 6, 16),
        screenOnDuration: const Duration(minutes: 148),
        unlockCount: 30,
        nighttimeUsageDuration: const Duration(minutes: 20),
        focusSessionBreakCount: 4,
        topCategory: UsageCategory.productivity,
      ),
    ],
    dailyMetricsList: <DailyMetrics>[
      DailyMetrics(
        date: DateTime(2026, 6, 16),
        stepCount: 4860,
        sedentaryDuration: const Duration(minutes: 96),
        screenOnDuration: const Duration(minutes: 148),
        outdoorDuration: const Duration(minutes: 15),
        postureRiskCount: 0,
        highNoiseExposureDuration: Duration.zero,
      ),
    ],
    missingDimensions: const <String>[],
  );

  return HealthInsightSnapshot(
    input: input,
    verdicts: const <RuleVerdict>[
      RuleVerdict(
        dimension: 'activity',
        level: 'warning',
        summary: '活动偏少',
        detail: '中午前可以补一点步数。',
      ),
    ],
    metrics: const HealthInsightMetrics(
      stepCount: 4860,
      sedentaryMinutes: 96,
      screenMinutes: 148,
      outdoorMinutes: 15,
    ),
    environmentOverview: const EnvironmentOverview(
      headline: '环境整体平稳',
      detail: '当前环境读数整体平稳。',
      daytimeLightSummary: '舒适',
      nightNoiseSummary: '正常',
      primaryConcern: EnvironmentPrimaryConcern.none,
    ),
    screenUsageHabitSummary: null,
    generatedReminders: const [],
    reminderHistory: const [],
    hasRealData: true,
  );
}
