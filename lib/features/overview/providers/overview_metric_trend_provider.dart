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
    this.digital = const <double>[],
  });

  final List<double> activity;
  final List<double> posture;
  final List<double> digital;

  List<double> valuesFor(DailyRhythmDimension dimension) {
    return switch (dimension) {
      DailyRhythmDimension.activity => activity,
      DailyRhythmDimension.posture => posture,
      DailyRhythmDimension.noise => const <double>[],
      DailyRhythmDimension.digital => digital,
    };
  }
}

final overviewMetricTrendDataProvider =
    FutureProvider<OverviewMetricTrendData>((Ref ref) async {
  ref.watch(dataCollectorMetricsRevisionProvider);
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

  final todayKey = DateKey.fromDate(referenceDate);
  if (dashboard.hasRealData) {
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
