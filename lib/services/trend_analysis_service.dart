import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

class TrendAnalysisService {
  TrendAnalysisService({
    required MetricsRepository metricsRepository,
    required UsageSummaryRepository usageRepository,
  })  : _metricsRepository = metricsRepository,
        _usageRepository = usageRepository;

  final MetricsRepository _metricsRepository;
  final UsageSummaryRepository _usageRepository;

  Future<TrendSnapshot> build({
    required DateTime referenceTime,
    TrendTab selectedTab = TrendTab.steps,
    TrendRange range = TrendRange.days7,
  }) async {
    final dates = List<DateTime>.generate(
      range.dayCount,
      (index) => DateTime(
        referenceTime.year,
        referenceTime.month,
        referenceTime.day,
      ).subtract(Duration(days: range.dayCount - 1 - index)),
    );
    final window = QueryWindow.recentCalendarDays(
      range.dayCount,
      referenceDate: referenceTime,
    );
    var metrics = const <DailyMetrics>[];
    var usageByDate = <String, DigitalUsageSummary?>{};
    switch (selectedTab) {
      case TrendTab.steps:
      case TrendTab.sedentary:
        metrics = await _metricsRepository.listRecentDays(
          range.dayCount,
          referenceDate: referenceTime,
        );
        break;
      case TrendTab.screen:
        final usage = await _usageRepository.listByWindow(window);
        usageByDate = <String, DigitalUsageSummary?>{
          for (final summary in usage) _dayKey(summary.date): summary,
        };
        break;
    }

    final dailyPoints = dates.map((date) {
      final value = _valueForTab(
        selectedTab: selectedTab,
        date: date,
        metrics: metrics,
        usageByDate: usageByDate,
      );
      return TrendPoint(
        label: '${date.month}/${date.day}',
        value: value,
      );
    }).toList(growable: false);
    final points = dailyPoints;
    final hasAnyData = points.any((TrendPoint point) => point.value > 0);

    return TrendSnapshot(
      generatedAt: referenceTime,
      selectedTab: selectedTab,
      range: range,
      aggregation: TrendAggregation.day,
      dataQuality: hasAnyData
          ? TrendDataQuality.complete
          : TrendDataQuality.empty,
      defaultSelectedIndex: points.isEmpty ? null : points.length - 1,
      title: '${range.label}${_titleForTab(selectedTab)}',
      unitLabel: _unitForTab(selectedTab),
      points: points,
      insightText: hasAnyData
          ? _insightForTab(selectedTab, points, range)
          : _emptyInsightForTab(selectedTab),
      emptyStateText: hasAnyData ? null : _emptyStateForTab(selectedTab),
    );
  }
}

num _valueForTab({
  required TrendTab selectedTab,
  required DateTime date,
  required List<DailyMetrics> metrics,
  required Map<String, DigitalUsageSummary?> usageByDate,
}) {
  final dateKey = _dayKey(date);
  final dayMetrics = metrics
      .where((item) => _dayKey(item.date) == dateKey)
      .toList(growable: false);
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
  }
}

String _titleForTab(TrendTab tab) {
  switch (tab) {
    case TrendTab.steps:
      return '活动趋势';
    case TrendTab.sedentary:
      return '姿势趋势';
    case TrendTab.screen:
      return '屏幕趋势';
  }
}

String _unitForTab(TrendTab tab) {
  switch (tab) {
    case TrendTab.steps:
      return '步';
    case TrendTab.sedentary:
    case TrendTab.screen:
      return '分钟';
  }
}

String _insightForTab(
  TrendTab tab,
  List<TrendPoint> points,
  TrendRange range,
) {
  final windowLabel = range == TrendRange.days7 ? '过去一周' : '近 30 天';
  switch (tab) {
    case TrendTab.steps:
      final aboveGoalDays = points.where((item) => item.value >= 6000).length;
      return '$windowLabel你有 $aboveGoalDays 天步数超过 6000，继续保持这个节奏。';
    case TrendTab.sedentary:
      final highest = points.fold<num>(
        0,
        (current, item) => item.value > current ? item.value : current,
      );
      return '$windowLabel久坐最高达到 ${highest.round()} 分钟，长时间静坐的日子值得重点关注。';
    case TrendTab.screen:
      final latest = points.isEmpty ? 0 : points.last.value.round();
      return '最近一天亮屏约 $latest 分钟，趋势页会继续帮你观察是否在收敛。';
  }
}

String _emptyStateForTab(TrendTab tab) {
  return '所选范围还没有足够的可展示数据。';
}

String _emptyInsightForTab(TrendTab tab) {
  return '采集到真实数据后，这里会生成对应的趋势洞察。';
}

String _dayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
