import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/trend_analysis_service.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

void main() {
  test('趋势聚合服务能输出 7 个点并默认返回步数趋势', () async {
    final service = TrendAnalysisService(
      metricsRepository: InMemoryMetricsRepository(
        metrics: _sevenDayMetrics(),
      ),
      usageRepository:
          InMemoryUsageSummaryRepository(summaries: _sevenDayUsage()),
    );

    final snapshot = await service.build(
      referenceTime: DateTime(2026, 6, 16, 9),
    );

    expect(snapshot.selectedTab, TrendTab.steps);
    expect(snapshot.points.length, 7);
    expect(snapshot.insightText, contains('6000'));
  });

  test('30 天范围按日返回完整点位', () async {
    final service = TrendAnalysisService(
      metricsRepository: InMemoryMetricsRepository(
        metrics: _sevenDayMetrics(),
      ),
      usageRepository: InMemoryUsageSummaryRepository(summaries: const []),
    );

    final snapshot = await service.build(
      referenceTime: DateTime(2026, 6, 16, 9),
      range: TrendRange.days30,
    );

    expect(snapshot.range, TrendRange.days30);
    expect(snapshot.points.length, 30);
    expect(snapshot.aggregation, TrendAggregation.day);
  });
}

List<DailyMetrics> _sevenDayMetrics() {
  return List<DailyMetrics>.generate(7, (int index) {
    final date = DateTime(2026, 6, 10 + index);
    return DailyMetrics(
      date: date,
      stepCount: 4000 + index * 300,
      sedentaryDuration: Duration(minutes: 90 + index * 5),
      screenOnDuration: Duration(minutes: 120 + index * 10),
      outdoorDuration: Duration.zero,
      postureRiskCount: 0,
      highNoiseExposureDuration: Duration.zero,
    );
  });
}

List<DigitalUsageSummary> _sevenDayUsage() {
  return List<DigitalUsageSummary>.generate(7, (int index) {
    return DigitalUsageSummary(
      date: DateTime(2026, 6, 10 + index),
      screenOnDuration: Duration(minutes: 120 + index * 10),
      unlockCount: 20,
      nighttimeUsageDuration: const Duration(minutes: 20),
      focusSessionBreakCount: 2,
      topCategory: UsageCategory.social,
      viewCount: 20,
    );
  });
}
