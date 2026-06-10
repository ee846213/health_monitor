import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/rules/input/rule_input_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

Duration ms(int minutes) => Duration(minutes: minutes);

void main() {
  group('RuleInput', () {
    test('全量输入 isFullInput 为 true', () {
      final input = RuleInput(
        window: QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 10)),
        activitySamples: const <ActivitySample>[],
        locationSummaries: const <LocationSummary>[],
        noiseSamples: const <NoiseSample>[],
        usageSummaries: const <DigitalUsageSummary>[],
        dailyMetricsList: const <DailyMetrics>[],
        missingDimensions: const <String>[],
      );
      expect(input.isFullInput, isTrue);
      expect(input.isDegraded, isFalse);
    });

    test('降级输入 isDegraded 为 true', () {
      final input = RuleInput(
        window: QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 10)),
        activitySamples: const <ActivitySample>[],
        locationSummaries: const <LocationSummary>[],
        noiseSamples: const <NoiseSample>[],
        usageSummaries: const <DigitalUsageSummary>[],
        dailyMetricsList: const <DailyMetrics>[],
        missingDimensions: const <String>['location'],
      );
      expect(input.isDegraded, isTrue);
    });

    test('averageNoiseDb 正确计算平均值', () {
      final now = DateTime(2026, 6, 10);
      final input = RuleInput(
        window: QueryWindow.recentDay(referenceTime: now),
        activitySamples: const <ActivitySample>[],
        locationSummaries: const <LocationSummary>[],
        noiseSamples: <NoiseSample>[
          NoiseSample(capturedAt: now, duration: ms(1), decibel: 60, level: NoiseLevel.loud),
          NoiseSample(capturedAt: now, duration: ms(1), decibel: 40, level: NoiseLevel.quiet),
        ],
        usageSummaries: const <DigitalUsageSummary>[],
        dailyMetricsList: const <DailyMetrics>[],
        missingDimensions: const <String>[],
      );
      expect(input.averageNoiseDb, 50);
    });

    test('全静止样本 stationaryRatio 为 1', () {
      final now = DateTime(2026, 6, 10);
      final sample = ActivitySample(capturedAt: now, duration: ms(30), type: ActivityType.stationary, confidence: 0.9, stepCount: 0, source: MotionSampleSource.sensorFusion);
      final input = RuleInput(
        window: QueryWindow.recentDay(referenceTime: now),
        activitySamples: <ActivitySample>[sample, sample],
        locationSummaries: const <LocationSummary>[],
        noiseSamples: const <NoiseSample>[],
        usageSummaries: const <DigitalUsageSummary>[],
        dailyMetricsList: const <DailyMetrics>[],
        missingDimensions: const <String>[],
      );
      expect(input.stationaryRatio, 1.0);
    });

    test('totalScreenMinutes 与 totalUnlockCount 合计正确', () {
      final input = RuleInput(
        window: QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 10)),
        activitySamples: const <ActivitySample>[],
        locationSummaries: const <LocationSummary>[],
        noiseSamples: const <NoiseSample>[],
        usageSummaries: <DigitalUsageSummary>[
          DigitalUsageSummary(date: DateTime(2026, 6, 9), screenOnDuration: ms(120), unlockCount: 30, nighttimeUsageDuration: ms(0), focusSessionBreakCount: 0, topCategory: UsageCategory.unknown),
          DigitalUsageSummary(date: DateTime(2026, 6, 10), screenOnDuration: ms(80), unlockCount: 45, nighttimeUsageDuration: ms(0), focusSessionBreakCount: 0, topCategory: UsageCategory.unknown),
        ],
        dailyMetricsList: const <DailyMetrics>[],
        missingDimensions: const <String>[],
      );
      expect(input.totalScreenMinutes, 200);
      expect(input.totalUnlockCount, 75);
    });

    test('isDimensionAvailable 判断维度可用性', () {
      final now = DateTime(2026, 6, 10);
      final sample = ActivitySample(capturedAt: now, duration: ms(15), type: ActivityType.walking, confidence: 0.7, stepCount: 1200, source: MotionSampleSource.platformActivity);
      final input = RuleInput(
        window: QueryWindow.recentDay(referenceTime: now),
        activitySamples: <ActivitySample>[sample],
        locationSummaries: const <LocationSummary>[],
        noiseSamples: const <NoiseSample>[],
        usageSummaries: const <DigitalUsageSummary>[],
        dailyMetricsList: const <DailyMetrics>[],
        missingDimensions: const <String>['noise'],
      );
      expect(input.isDimensionAvailable('activity'), isTrue);
      expect(input.isDimensionAvailable('location'), isFalse);
      expect(input.isDimensionAvailable('noise'), isFalse);
    });
  });

  group('RuleInputService', () {
    final now = DateTime(2026, 6, 10, 12, 0);
    final window = QueryWindow.recentDay(referenceTime: now);

    test('所有仓储有数据时构建全量输入', () async {
      final activitySample = ActivitySample(capturedAt: now.subtract(ms(360)), duration: ms(30), type: ActivityType.walking, confidence: 0.9, stepCount: 2000, source: MotionSampleSource.sensorFusion);
      final noiseSample = NoiseSample(capturedAt: now.subtract(ms(60)), duration: ms(1), decibel: 55, level: NoiseLevel.moderate);
      final locationSummary = LocationSummary(date: DateTime(2026, 6, 10), distanceMeters: 5000, outdoorDuration: ms(45), visitCount: 3, commuteCount: 1);
      final usageSummary = DigitalUsageSummary(date: DateTime(2026, 6, 10), screenOnDuration: ms(90), unlockCount: 25, nighttimeUsageDuration: ms(0), focusSessionBreakCount: 0, topCategory: UsageCategory.unknown);
      final dailyMetrics = DailyMetrics(date: DateTime(2026, 6, 10), stepCount: 5000, sedentaryDuration: ms(180), screenOnDuration: ms(90), outdoorDuration: ms(20), postureRiskCount: 2, highNoiseExposureDuration: ms(30));

      final service = RuleInputService(
        activityRepository: InMemoryActivityRepository(samples: <ActivitySample>[activitySample]),
        locationRepository: InMemoryLocationSummaryRepository(summaries: <LocationSummary>[locationSummary]),
        noiseRepository: InMemoryNoiseSampleRepository(samples: <NoiseSample>[noiseSample]),
        usageRepository: InMemoryUsageSummaryRepository(summaries: <DigitalUsageSummary>[usageSummary]),
        metricsRepository: InMemoryMetricsRepository(metrics: <DailyMetrics>[dailyMetrics]),
      );

      final input = await service.buildInput(window: window);
      expect(input.isFullInput, isTrue);
      expect(input.activitySamples.length, 1);
      expect(input.averageNoiseDb, 55);
      expect(input.totalScreenMinutes, 90);
    });

    test('禁用维度不被查询', () async {
      final service = RuleInputService(
        activityRepository: InMemoryActivityRepository(samples: const <ActivitySample>[]),
        locationRepository: InMemoryLocationSummaryRepository(summaries: const <LocationSummary>[]),
        noiseRepository: InMemoryNoiseSampleRepository(samples: const <NoiseSample>[]),
        usageRepository: InMemoryUsageSummaryRepository(summaries: const <DigitalUsageSummary>[]),
        metricsRepository: InMemoryMetricsRepository(metrics: const <DailyMetrics>[]),
      );

      final input = await service.buildInput(window: window, disabledDimensions: const <String>['location', 'noise']);

      expect(input.missingDimensions, contains('location'));
      expect(input.missingDimensions, contains('noise'));
      expect(input.locationSummaries, isEmpty);
      expect(input.noiseSamples, isEmpty);
    });

    test('空仓储自动标记缺失维度', () async {
      final service = RuleInputService(
        activityRepository: InMemoryActivityRepository(samples: const <ActivitySample>[]),
        locationRepository: InMemoryLocationSummaryRepository(summaries: const <LocationSummary>[]),
        noiseRepository: InMemoryNoiseSampleRepository(samples: const <NoiseSample>[]),
        usageRepository: InMemoryUsageSummaryRepository(summaries: const <DigitalUsageSummary>[]),
        metricsRepository: InMemoryMetricsRepository(metrics: const <DailyMetrics>[]),
      );

      final input = await service.buildInput(window: window);
      expect(input.isDegraded, isTrue);
      expect(input.missingDimensions, contains('activity'));
      expect(input.missingDimensions, contains('location'));
      expect(input.missingDimensions, contains('digital_usage'));
      expect(input.missingDimensions, contains('daily_metrics'));
    });
  });
}

