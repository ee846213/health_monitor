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

    final points = dates
        .map(
          (date) => TrendPoint(
            label: '${date.month}/${date.day}',
            value: _valueForTab(
              selectedTab: selectedTab,
              date: date,
              metrics: metrics,
              usageByDate: usageByDate,
              lightSamples: lightSamples,
              noiseSamples: noiseSamples,
            ),
          ),
        )
        .toList(growable: false);

    return TrendSnapshot(
      generatedAt: referenceTime,
      selectedTab: selectedTab,
      title: _titleForTab(selectedTab),
      unitLabel: _unitForTab(selectedTab),
      points: points,
      insightText: _insightForTab(selectedTab, points),
      emptyStateText:
          points.every((item) => item.value == 0) ? '最近 7 天还没有足够的可展示数据。' : null,
    );
  }
}

num _valueForTab({
  required TrendTab selectedTab,
  required DateTime date,
  required List<DailyMetrics> metrics,
  required Map<String, DigitalUsageSummary?> usageByDate,
  required List<AmbientLightSample> lightSamples,
  required List<NoiseSample> noiseSamples,
}) {
  final dateKey = _dayKey(date);
  final dayMetrics = metrics.where((item) => _dayKey(item.date) == dateKey);
  switch (selectedTab) {
    case TrendTab.steps:
      return dayMetrics.fold<int>(0, (sum, item) => sum + item.stepCount);
    case TrendTab.sedentary:
      return dayMetrics.fold<int>(
        0,
        (sum, item) => sum + item.sedentaryDuration.inMinutes,
      );
    case TrendTab.screen:
      return usageByDate[dateKey]?.screenOnDuration.inMinutes ?? 0;
    case TrendTab.environment:
      return _environmentScoreForDate(
        dateKey: dateKey,
        lightSamples: lightSamples,
        noiseSamples: noiseSamples,
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

int _environmentScoreForDate({
  required String dateKey,
  required List<AmbientLightSample> lightSamples,
  required List<NoiseSample> noiseSamples,
}) {
  final darkMinutes = lightSamples
      .where(
        (item) =>
            _dayKey(item.capturedAt) == dateKey &&
            item.level == AmbientLightLevel.dark,
      )
      .fold<int>(0, (sum, item) => sum + item.duration.inMinutes);
  final loudMinutes = noiseSamples
      .where(
        (item) =>
            _dayKey(item.capturedAt) == dateKey &&
            item.level == NoiseLevel.loud,
      )
      .fold<int>(0, (sum, item) => sum + item.duration.inMinutes);

  final score = 100 - (darkMinutes.clamp(0, 60)) - loudMinutes.clamp(0, 40);
  return score.clamp(0, 100);
}

String _dayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
