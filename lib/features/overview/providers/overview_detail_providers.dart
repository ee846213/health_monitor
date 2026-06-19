import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

class OverviewStepTrendPoint {
  const OverviewStepTrendPoint({
    required this.date,
    required this.steps,
    required this.isToday,
  });

  final DateTime date;
  final int steps;
  final bool isToday;

  String get label => isToday ? '今天' : '${date.month}/${date.day}';
}

class OverviewStepDetailSnapshot {
  const OverviewStepDetailSnapshot({
    required this.goalSteps,
    required this.todaySteps,
    required this.todayProgress,
    required this.points,
  });

  final int goalSteps;
  final int todaySteps;
  final double todayProgress;
  final List<OverviewStepTrendPoint> points;
}

class OverviewSedentarySegmentSnapshot {
  const OverviewSedentarySegmentSnapshot({
    required this.startedAt,
    required this.endedAt,
    required this.duration,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;

  String get timeLabel => '${_clockLabel(startedAt)} - ${_clockLabel(endedAt)}';
}

class OverviewSedentaryDetailSnapshot {
  const OverviewSedentaryDetailSnapshot({
    required this.totalDuration,
    required this.longestDuration,
    required this.segments,
  });

  final Duration totalDuration;
  final Duration longestDuration;
  final List<OverviewSedentarySegmentSnapshot> segments;
}

class OverviewScreenUsageBucket {
  const OverviewScreenUsageBucket({
    required this.label,
    required this.duration,
    required this.subtitle,
  });

  final String label;
  final Duration duration;
  final String subtitle;
}

class OverviewScreenDetailSnapshot {
  const OverviewScreenDetailSnapshot({
    required this.todaySummary,
    required this.yesterdaySummary,
    required this.totalDuration,
    required this.deltaMinutes,
    required this.buckets,
    required this.sourceLabel,
    required this.qualityLabel,
  });

  final DigitalUsageSummary? todaySummary;
  final DigitalUsageSummary? yesterdaySummary;
  final Duration totalDuration;
  final int deltaMinutes;
  final List<OverviewScreenUsageBucket> buckets;
  final String sourceLabel;
  final String? qualityLabel;
}

final overviewStepDetailProvider =
    FutureProvider<OverviewStepDetailSnapshot>((Ref ref) async {
  ref.watch(dataCollectorMetricsRevisionProvider);
  final repository = ref.watch(metricsRepositoryProvider);
  final now = DateTime.now();
  final todayKey = DateKey.fromDate(now);
  final metrics = await repository.listRecentDays(
    7,
    referenceDate: now,
  );
  final metricsByKey = <String, int>{
    for (final item in metrics) DateKey.fromDate(item.date): item.stepCount,
  };
  final dashboardTodaySteps =
      ref.watch(overviewDashboardSnapshotProvider)?.stepCard.currentSteps;

  final points = <OverviewStepTrendPoint>[];
  for (var offset = 6; offset >= 0; offset -= 1) {
    final date = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: offset),
    );
    final key = DateKey.fromDate(date);
    points.add(
      OverviewStepTrendPoint(
        date: date,
        steps: key == todayKey && dashboardTodaySteps != null
            ? dashboardTodaySteps
            : metricsByKey[key] ?? 0,
        isToday: key == todayKey,
      ),
    );
  }

  final todaySteps = points.isEmpty ? 0 : points.last.steps;
  const goalSteps = 6000;
  return OverviewStepDetailSnapshot(
    goalSteps: goalSteps,
    todaySteps: todaySteps,
    todayProgress: goalSteps == 0 ? 0 : todaySteps / goalSteps,
    points: points,
  );
});

final overviewSedentaryDetailProvider =
    FutureProvider<OverviewSedentaryDetailSnapshot>((Ref ref) async {
  ref.watch(dataCollectorMetricsRevisionProvider);
  final repository = ref.watch(activityRepositoryProvider);
  final now = DateTime.now();
  final samples = await repository.listByWindow(
    QueryWindow.calendarDay(referenceDate: now),
  );
  final input = RuleInput(
    window: QueryWindow.calendarDay(referenceDate: now),
    activitySamples: samples,
    locationSummaries: const <LocationSummary>[],
    noiseSamples: const <NoiseSample>[],
    ambientLightSamples: const <AmbientLightSample>[],
    usageSummaries: const <DigitalUsageSummary>[],
    dailyMetricsList: const <DailyMetrics>[],
    missingDimensions: const <String>[],
  );
  final segments = input.sedentarySegments
      .map(
        (SedentaryActivitySegment segment) => OverviewSedentarySegmentSnapshot(
          startedAt: segment.startedAt,
          endedAt: segment.endedAt,
          duration: segment.duration,
        ),
      )
      .toList(growable: false);

  final totalDuration = segments.fold<Duration>(
    Duration.zero,
    (Duration total, OverviewSedentarySegmentSnapshot segment) =>
        total + segment.duration,
  );
  final longestDuration = segments.fold<Duration>(
    Duration.zero,
    (Duration longest, OverviewSedentarySegmentSnapshot segment) =>
        segment.duration > longest ? segment.duration : longest,
  );

  return OverviewSedentaryDetailSnapshot(
    totalDuration: totalDuration,
    longestDuration: longestDuration,
    segments: segments,
  );
});

final overviewScreenDetailProvider =
    FutureProvider<OverviewScreenDetailSnapshot>((Ref ref) async {
  ref.watch(dataCollectorUsageRevisionProvider);
  final repository = ref.watch(usageSummaryRepositoryProvider);
  final now = DateTime.now();
  final todaySummary = await repository.getByDate(now);
  final yesterdaySummary = await repository.getByDate(
    now.subtract(const Duration(days: 1)),
  );
  final totalDuration = todaySummary?.screenOnDuration ?? Duration.zero;
  final nightDuration = todaySummary?.nighttimeUsageDuration ?? Duration.zero;
  final dayDuration = totalDuration > nightDuration
      ? totalDuration - nightDuration
      : Duration.zero;
  final deltaMinutes = totalDuration.inMinutes -
      (yesterdaySummary?.screenOnDuration.inMinutes ?? 0);

  return OverviewScreenDetailSnapshot(
    todaySummary: todaySummary,
    yesterdaySummary: yesterdaySummary,
    totalDuration: totalDuration,
    deltaMinutes: deltaMinutes,
    buckets: <OverviewScreenUsageBucket>[
      OverviewScreenUsageBucket(
        label: '白天',
        duration: dayDuration,
        subtitle: '06:00 - 22:00',
      ),
      OverviewScreenUsageBucket(
        label: '夜间',
        duration: nightDuration,
        subtitle: '22:00 - 06:00',
      ),
    ],
    sourceLabel: switch (todaySummary?.source) {
      DigitalUsageSource.androidUsageStats => '系统 Usage Stats',
      DigitalUsageSource.lifecycleAlternative => '生命周期替代指标',
      null => '暂无数据源',
    },
    qualityLabel: switch (todaySummary?.completeness) {
      UsageDataCompleteness.full => null,
      UsageDataCompleteness.partialGap => '部分时段有缺口，已按可用摘要生成',
      UsageDataCompleteness.degraded => '当前为降级口径，使用替代指标展示',
      null => null,
    },
  );
});

String _clockLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
