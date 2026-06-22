import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

class OverviewMetricTrendData {
  const OverviewMetricTrendData({
    this.activity = const <double>[],
    this.posture = const <double>[],
    this.noise = const <double>[],
    this.digital = const <double>[],
  });

  final List<double> activity;
  final List<double> posture;
  final List<double> noise;
  final List<double> digital;

  List<double> valuesFor(DailyRhythmDimension dimension) {
    return switch (dimension) {
      DailyRhythmDimension.activity => activity,
      DailyRhythmDimension.posture => posture,
      DailyRhythmDimension.noise => noise,
      DailyRhythmDimension.digital => digital,
    };
  }
}

final overviewMetricTrendDataProvider =
    FutureProvider<OverviewMetricTrendData>((Ref ref) async {
  ref.watch(dataCollectorMetricsRevisionProvider);
  ref.watch(dataCollectorEnvironmentRevisionProvider);
  ref.watch(dataCollectorUsageRevisionProvider);

  final readyData = ref.watch(overviewReadyDataStateProvider);
  if (readyData == null) {
    return const OverviewMetricTrendData();
  }

  final dashboard = readyData.dashboard;
  final referenceDate = dashboard.generatedAt;
  final dateKeys = DateKey.recentDays(
    7,
    referenceDate: referenceDate,
  );
  final metricsRepository = ref.watch(sharedMetricsRepo);
  final usageRepository = ref.watch(sharedUsageRepo);
  final noiseRepository = ref.watch(sharedNoiseRepo);

  final metrics = await metricsRepository.listRecentDays(
    7,
    referenceDate: referenceDate,
  );
  final usage = await usageRepository.listByWindow(
    QueryWindow.recentCalendarDays(
      7,
      referenceDate: referenceDate,
    ),
  );
  final noiseSamples = await noiseRepository.listByWindow(
    QueryWindow.recentCalendarDays(
      7,
      referenceDate: referenceDate,
    ),
  );

  final stepsByDate = <String, num>{
    for (final item in metrics) DateKey.fromDate(item.date): item.stepCount,
  };
  final sedentaryByDate = <String, num>{
    for (final item in metrics)
      DateKey.fromDate(item.date): item.sedentaryDuration.inMinutes,
  };
  final screenByDate = <String, num>{
    for (final item in usage)
      DateKey.fromDate(item.date): item.screenOnDuration.inMinutes,
  };
  final noiseTotalsByDate = <String, double>{};
  final noiseCountsByDate = <String, int>{};
  for (final sample in noiseSamples) {
    final key = DateKey.fromDate(sample.capturedAt);
    noiseTotalsByDate[key] = (noiseTotalsByDate[key] ?? 0) + sample.decibel;
    noiseCountsByDate[key] = (noiseCountsByDate[key] ?? 0) + 1;
  }
  final noiseByDate = <String, num>{
    for (final entry in noiseTotalsByDate.entries)
      entry.key: entry.value / noiseCountsByDate[entry.key]!,
  };

  final todayKey = DateKey.fromDate(referenceDate);
  if (dashboard.hasRealData) {
    // 首页聚合快照通常比日汇总落库更及时，因此今天的末端点优先使用当前卡片值。
    // 这只替换真实的“今天”数据，不补造过去日期，避免画出不存在的趋势。
    stepsByDate[todayKey] = dashboard.stepCard.currentSteps;
    sedentaryByDate[todayKey] = dashboard.sedentaryCard.totalMinutes;
    if (!readyData.missingDimensions.any((item) => item.contains('屏幕'))) {
      screenByDate[todayKey] = dashboard.screenCard.totalMinutes;
    }
  }

  return OverviewMetricTrendData(
    activity: normalizeOverviewTrendValues(
      _orderedValues(dateKeys, stepsByDate),
    ),
    posture: normalizeOverviewTrendValues(
      _orderedValues(dateKeys, sedentaryByDate),
    ),
    noise: normalizeOverviewTrendValues(
      _orderedValues(dateKeys, noiseByDate),
    ),
    digital: normalizeOverviewTrendValues(
      _orderedValues(dateKeys, screenByDate),
    ),
  );
});

List<num> _orderedValues(
  List<String> dateKeys,
  Map<String, num> valuesByDate,
) {
  return <num>[
    for (final key in dateKeys)
      if (valuesByDate.containsKey(key)) valuesByDate[key]!,
  ];
}

List<double> normalizeOverviewTrendValues(List<num> values) {
  if (values.isEmpty) {
    return const <double>[];
  }
  if (values.length == 1) {
    return const <double>[0.5];
  }

  var minimum = values.first.toDouble();
  var maximum = minimum;
  for (final value in values.skip(1)) {
    final number = value.toDouble();
    if (number < minimum) {
      minimum = number;
    }
    if (number > maximum) {
      maximum = number;
    }
  }
  if (maximum == minimum) {
    return List<double>.filled(values.length, 0.5, growable: false);
  }

  final range = maximum - minimum;
  return values
      .map((value) => (value.toDouble() - minimum) / range)
      .toList(growable: false);
}
