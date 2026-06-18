import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/repositories/ambient_light_sample_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

class TrendAnalysisService {
  TrendAnalysisService({
    required MetricsRepository metricsRepository,
    required UsageSummaryRepository usageRepository,
    required AmbientLightSampleRepository ambientLightRepository,
    required NoiseSampleRepository noiseRepository,
  })  : _metricsRepository = metricsRepository,
        _usageRepository = usageRepository,
        _ambientLightRepository = ambientLightRepository,
        _noiseRepository = noiseRepository;

  final MetricsRepository _metricsRepository;
  final UsageSummaryRepository _usageRepository;
  final AmbientLightSampleRepository _ambientLightRepository;
  final NoiseSampleRepository _noiseRepository;

  Future<TrendSnapshot> build({
    required DateTime referenceTime,
    TrendTab selectedTab = TrendTab.steps,
  }) async {
    final dates = List<DateTime>.generate(
      7,
      (index) => DateTime(
        referenceTime.year,
        referenceTime.month,
        referenceTime.day,
      ).subtract(Duration(days: 6 - index)),
    );
    final metrics = await _metricsRepository.listRecentDays(
      7,
      referenceDate: referenceTime,
    );
    final usageByDate = <String, DigitalUsageSummary?>{};
    for (final date in dates) {
      usageByDate[_dayKey(date)] = await _usageRepository.getByDate(date);
    }
    final lightSamples = await _ambientLightRepository.listByWindow(
      QueryWindow.recentCalendarDays(7, referenceDate: referenceTime),
    );
    final noiseSamples = await _noiseRepository.listByWindow(
      QueryWindow.recentCalendarDays(7, referenceDate: referenceTime),
    );

    final points = dates.map((date) {
      final value = _valueForTab(
        selectedTab: selectedTab,
        date: date,
        metrics: metrics,
        usageByDate: usageByDate,
        lightSamples: lightSamples,
        noiseSamples: noiseSamples,
      );
      return TrendPoint(
        label: '${date.month}/${date.day}',
        value: value.value,
        hasData: value.hasData,
      );
    }).toList(growable: false);
    final availablePoints = points
        .where((TrendPoint point) => point.hasData)
        .toList(growable: false);
    final hasAnyData = availablePoints.isNotEmpty;

    return TrendSnapshot(
      generatedAt: referenceTime,
      selectedTab: selectedTab,
      title: _titleForTab(selectedTab),
      unitLabel: _unitForTab(selectedTab),
      points: points,
      insightText: hasAnyData
          ? _insightForTab(selectedTab, availablePoints)
          : _emptyInsightForTab(selectedTab),
      emptyStateText: hasAnyData ? null : _emptyStateForTab(selectedTab),
    );
  }
}

class _TrendValue {
  const _TrendValue({
    required this.value,
    required this.hasData,
  });

  final num value;
  final bool hasData;
}

_TrendValue _valueForTab({
  required TrendTab selectedTab,
  required DateTime date,
  required List<DailyMetrics> metrics,
  required Map<String, DigitalUsageSummary?> usageByDate,
  required List<AmbientLightSample> lightSamples,
  required List<NoiseSample> noiseSamples,
}) {
  final dateKey = _dayKey(date);
  final dayMetrics = metrics
      .where((item) => _dayKey(item.date) == dateKey)
      .toList(growable: false);
  switch (selectedTab) {
    case TrendTab.steps:
      return _TrendValue(
        value: dayMetrics.fold<int>(0, (sum, item) => sum + item.stepCount),
        hasData: dayMetrics.isNotEmpty,
      );
    case TrendTab.sedentary:
      return _TrendValue(
        value: dayMetrics.fold<int>(
          0,
          (sum, item) => sum + item.sedentaryDuration.inMinutes,
        ),
        hasData: dayMetrics.isNotEmpty,
      );
    case TrendTab.screen:
      final usage = usageByDate[dateKey];
      return _TrendValue(
        value: usage?.screenOnDuration.inMinutes ?? 0,
        hasData: usage != null,
      );
    case TrendTab.environment:
      final dayLightSamples = lightSamples
          .where((item) => _dayKey(item.capturedAt) == dateKey)
          .toList(growable: false);
      final dayNoiseSamples = noiseSamples
          .where((item) => _dayKey(item.capturedAt) == dateKey)
          .toList(growable: false);
      return _TrendValue(
        value: _environmentScoreForDate(
          lightSamples: dayLightSamples,
          noiseSamples: dayNoiseSamples,
        ),
        hasData: dayLightSamples.isNotEmpty || dayNoiseSamples.isNotEmpty,
      );
  }
}

String _titleForTab(TrendTab tab) {
  switch (tab) {
    case TrendTab.steps:
      return '近 7 天步数趋势';
    case TrendTab.sedentary:
      return '近 7 天久坐趋势';
    case TrendTab.screen:
      return '近 7 天屏幕趋势';
    case TrendTab.environment:
      return '近 7 天环境趋势';
  }
}

String _unitForTab(TrendTab tab) {
  switch (tab) {
    case TrendTab.steps:
      return '步';
    case TrendTab.sedentary:
    case TrendTab.screen:
      return '分钟';
    case TrendTab.environment:
      return '分';
  }
}

String _insightForTab(TrendTab tab, List<TrendPoint> points) {
  switch (tab) {
    case TrendTab.steps:
      final aboveGoalDays = points.where((item) => item.value >= 6000).length;
      return '过去一周你有 $aboveGoalDays 天步数超过 6000，继续保持这个节奏。';
    case TrendTab.sedentary:
      final highest = points.fold<num>(
        0,
        (current, item) => item.value > current ? item.value : current,
      );
      return '过去一周久坐最高达到 ${highest.round()} 分钟，长时间静坐的日子值得重点关注。';
    case TrendTab.screen:
      final latest = points.isEmpty ? 0 : points.last.value.round();
      return '最近一天亮屏约 $latest 分钟，趋势页会继续帮你观察是否在收敛。';
    case TrendTab.environment:
      final latest = points.isEmpty ? 0 : points.last.value.round();
      return '最近一天环境健康分约 $latest 分，光照和噪音的组合会继续纳入观察。';
  }
}

String _emptyStateForTab(TrendTab tab) {
  if (tab == TrendTab.environment) {
    return '最近 7 天还没有采集到环境光照或噪音数据，暂不生成环境健康分。';
  }
  return '最近 7 天还没有足够的可展示数据。';
}

String _emptyInsightForTab(TrendTab tab) {
  if (tab == TrendTab.environment) {
    return '采集到真实的光照或噪音样本后，这里会生成环境趋势洞察。';
  }
  return '采集到真实数据后，这里会生成对应的趋势洞察。';
}

int _environmentScoreForDate({
  required List<AmbientLightSample> lightSamples,
  required List<NoiseSample> noiseSamples,
}) {
  final darkMinutes = lightSamples
      .where((item) => item.level == AmbientLightLevel.dark)
      .fold<int>(0, (sum, item) => sum + item.duration.inMinutes);
  final loudMinutes = noiseSamples
      .where((item) => item.level == NoiseLevel.loud)
      .fold<int>(0, (sum, item) => sum + item.duration.inMinutes);

  final score = 100 - (darkMinutes.clamp(0, 60)) - loudMinutes.clamp(0, 40);
  return score.clamp(0, 100);
}

String _dayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
