import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/overview/providers/overview_metric_trend_provider.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

void main() {
  test('首页迷你趋势应由真实历史和当前快照生成', () async {
    final referenceDate = DateTime(2026, 6, 22, 16, 42);
    final container = ProviderContainer(
      overrides: <Override>[
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) => _readyData(referenceDate),
        ),
        sharedMetricsRepo.overrideWithValue(
          InMemoryMetricsRepository(
            metrics: <DailyMetrics>[
              _metrics(DateTime(2026, 6, 20), steps: 1000, sedentary: 30),
              _metrics(DateTime(2026, 6, 21), steps: 3000, sedentary: 60),
            ],
          ),
        ),
        sharedUsageRepo.overrideWithValue(
          InMemoryUsageSummaryRepository(
            summaries: <DigitalUsageSummary>[
              _usage(DateTime(2026, 6, 20), 60),
              _usage(DateTime(2026, 6, 21), 120),
            ],
          ),
        ),
        sharedNoiseRepo.overrideWithValue(
          InMemoryNoiseSampleRepository(
            samples: <NoiseSample>[
              _noise(DateTime(2026, 6, 20, 12), 40),
              _noise(DateTime(2026, 6, 21, 12), 50),
              _noise(DateTime(2026, 6, 22, 12), 60),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final trend = await container.read(overviewMetricTrendDataProvider.future);

    expect(trend.activity, <double>[0, 0.4, 1]);
    expect(trend.posture, <double>[0, 0.45454545454545453, 1]);
    expect(trend.digital, <double>[0, 0.6818181818181818, 1]);
    expect(trend.noise, <double>[0, 0.5, 1]);
  });

  test('没有历史时只使用真实当前值，不补造趋势曲线', () async {
    final referenceDate = DateTime(2026, 6, 22, 16, 42);
    final container = ProviderContainer(
      overrides: <Override>[
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) => _readyData(referenceDate),
        ),
        sharedMetricsRepo.overrideWithValue(
          InMemoryMetricsRepository(metrics: const <DailyMetrics>[]),
        ),
        sharedUsageRepo.overrideWithValue(
          InMemoryUsageSummaryRepository(
            summaries: const <DigitalUsageSummary>[],
          ),
        ),
        sharedNoiseRepo.overrideWithValue(
          InMemoryNoiseSampleRepository(samples: const <NoiseSample>[]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final trend = await container.read(overviewMetricTrendDataProvider.future);

    expect(trend.activity, <double>[0.5]);
    expect(trend.posture, <double>[0.5]);
    expect(trend.digital, <double>[0.5]);
    expect(trend.noise, isEmpty);
  });
}

OverviewReadyData _readyData(DateTime generatedAt) {
  return OverviewReadyData(
    dashboard: DashboardSnapshot(
      generatedAt: generatedAt,
      healthScore: const HealthScoreBreakdown(
        stepScore: 80,
        sedentaryScore: 70,
        screenScore: 75,
        totalScore: 76,
      ),
      stepCard: const DashboardStepCard(
        currentSteps: 6000,
        goalSteps: 6000,
        achievementPercent: 100,
      ),
      sedentaryCard: const DashboardSedentaryCard(
        totalMinutes: 96,
        longestSingleMinutes: 42,
      ),
      screenCard: const DashboardScreenCard(
        totalMinutes: 148,
        yesterdayDeltaMinutes: 28,
        changeDirection: DashboardChangeDirection.up,
      ),
      environmentSnapshot: const DashboardEnvironmentSnapshot(
        lightLabel: '舒适',
        noiseLabel: '正常',
      ),
      dailyAdviceBubble: const DailyAdviceBubble(
        text: '保持当前节奏。',
        source: DailyAdviceSource.fallback,
      ),
      hasRealData: true,
    ),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
    missingDimensions: const <String>[],
    reminders: const [],
    preciseDetectionNotice: null,
  );
}

DailyMetrics _metrics(
  DateTime date, {
  required int steps,
  required int sedentary,
}) {
  return DailyMetrics(
    date: date,
    stepCount: steps,
    sedentaryDuration: Duration(minutes: sedentary),
    screenOnDuration: Duration.zero,
    outdoorDuration: Duration.zero,
    postureRiskCount: 0,
    highNoiseExposureDuration: Duration.zero,
  );
}

DigitalUsageSummary _usage(DateTime date, int minutes) {
  return DigitalUsageSummary(
    date: date,
    screenOnDuration: Duration(minutes: minutes),
    unlockCount: 0,
    nighttimeUsageDuration: Duration.zero,
    focusSessionBreakCount: 0,
    topCategory: UsageCategory.unknown,
  );
}

NoiseSample _noise(DateTime capturedAt, double decibel) {
  return NoiseSample(
    capturedAt: capturedAt,
    duration: const Duration(minutes: 5),
    decibel: decibel,
    level: NoiseLevel.moderate,
  );
}
