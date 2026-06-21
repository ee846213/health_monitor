import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/trend_analysis_service.dart';
import 'package:health_monitor/storage/repositories/ambient_light_sample_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

void main() {
  test('趋势聚合服务能输出 7 个点并默认返回步数趋势', () async {
    final service = TrendAnalysisService(
      metricsRepository: InMemoryMetricsRepository(
        metrics: _sevenDayMetrics(),
      ),
      usageRepository:
          InMemoryUsageSummaryRepository(summaries: _sevenDayUsage()),
      ambientLightRepository: InMemoryAmbientLightSampleRepository(
        samples: _sevenDayLight(),
      ),
      noiseRepository: InMemoryNoiseSampleRepository(samples: _sevenDayNoise()),
    );

    final snapshot = await service.build(
      referenceTime: DateTime(2026, 6, 16, 9),
    );

    expect(snapshot.selectedTab, TrendTab.steps);
    expect(snapshot.points.length, 7);
    expect(snapshot.insightText, contains('6000'));
  });

  test('没有环境样本时不应把缺失数据计算成 100 分', () async {
    final service = TrendAnalysisService(
      metricsRepository: InMemoryMetricsRepository(metrics: const []),
      usageRepository: InMemoryUsageSummaryRepository(summaries: const []),
      ambientLightRepository:
          InMemoryAmbientLightSampleRepository(samples: const []),
      noiseRepository: InMemoryNoiseSampleRepository(samples: const []),
    );

    final snapshot = await service.build(
      referenceTime: DateTime(2026, 6, 16, 9),
      selectedTab: TrendTab.environment,
    );

    expect(snapshot.points, hasLength(7));
    expect(snapshot.points.every((TrendPoint point) => !point.hasData), isTrue);
    expect(snapshot.emptyStateText, contains('还没有采集到'));
    expect(snapshot.insightText, contains('真实'));
  });

  test('环境趋势只对有真实样本的日期生成分数', () async {
    final service = TrendAnalysisService(
      metricsRepository: InMemoryMetricsRepository(metrics: const []),
      usageRepository: InMemoryUsageSummaryRepository(summaries: const []),
      ambientLightRepository: InMemoryAmbientLightSampleRepository(
        samples: <AmbientLightSample>[
          AmbientLightSample(
            capturedAt: DateTime(2026, 6, 15, 22),
            duration: const Duration(minutes: 20),
            lux: 3,
            level: AmbientLightLevel.dark,
          ),
        ],
      ),
      noiseRepository: InMemoryNoiseSampleRepository(
        samples: <NoiseSample>[
          NoiseSample(
            capturedAt: DateTime(2026, 6, 15, 22),
            duration: const Duration(minutes: 10),
            decibel: 75,
            level: NoiseLevel.loud,
          ),
        ],
      ),
    );

    final snapshot = await service.build(
      referenceTime: DateTime(2026, 6, 16, 9),
      selectedTab: TrendTab.environment,
    );

    expect(
      snapshot.points.where((TrendPoint point) => point.hasData),
      hasLength(1),
    );
    expect(snapshot.points[5].value, 70);
    expect(snapshot.emptyStateText, isNull);
  });

  test('30 天范围按周聚合并保留范围信息', () async {
    final service = TrendAnalysisService(
      metricsRepository: InMemoryMetricsRepository(
        metrics: _sevenDayMetrics(),
      ),
      usageRepository: InMemoryUsageSummaryRepository(summaries: const []),
      ambientLightRepository:
          InMemoryAmbientLightSampleRepository(samples: const []),
      noiseRepository: InMemoryNoiseSampleRepository(samples: const []),
    );

    final snapshot = await service.build(
      referenceTime: DateTime(2026, 6, 16, 9),
      range: TrendRange.days30,
    );

    expect(snapshot.range, TrendRange.days30);
    expect(snapshot.aggregation, TrendAggregation.week);
    expect(snapshot.points, hasLength(5));
    expect(snapshot.points.where((point) => point.hasData), isNotEmpty);
  });
}

List<DailyMetrics> _sevenDayMetrics() {
  return List<DailyMetrics>.generate(7, (index) {
    final date = DateTime(2026, 6, 10 + index);
    return DailyMetrics(
      date: date,
      stepCount: 4200 + index * 400,
      sedentaryDuration: Duration(minutes: 90 + index * 10),
      screenOnDuration: Duration(minutes: 120 + index * 15),
      outdoorDuration: Duration(minutes: 20 + index * 3),
      postureRiskCount: index.isEven ? 1 : 0,
      highNoiseExposureDuration: Duration(minutes: 5 + index),
    );
  });
}

List<DigitalUsageSummary> _sevenDayUsage() {
  return List<DigitalUsageSummary>.generate(7, (index) {
    return DigitalUsageSummary(
      date: DateTime(2026, 6, 10 + index),
      screenOnDuration: Duration(minutes: 120 + index * 15),
      unlockCount: 20 + index,
      nighttimeUsageDuration: Duration(minutes: 15 + index * 5),
      focusSessionBreakCount: 2 + index,
      topCategory: UsageCategory.tools,
    );
  });
}

List<AmbientLightSample> _sevenDayLight() {
  return List<AmbientLightSample>.generate(7, (index) {
    final level =
        index.isEven ? AmbientLightLevel.comfortable : AmbientLightLevel.bright;
    return AmbientLightSample(
      capturedAt: DateTime(2026, 6, 10 + index, 9),
      duration: const Duration(minutes: 20),
      lux: level == AmbientLightLevel.bright ? 1200 : 200,
      level: level,
    );
  });
}

List<NoiseSample> _sevenDayNoise() {
  return List<NoiseSample>.generate(7, (index) {
    final level = index % 3 == 0 ? NoiseLevel.loud : NoiseLevel.moderate;
    return NoiseSample(
      capturedAt: DateTime(2026, 6, 10 + index, 21),
      duration: const Duration(minutes: 15),
      decibel: level == NoiseLevel.loud ? 72 : 48,
      level: level,
    );
  });
}
