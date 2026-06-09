import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';

void main() {
  test('每日指标应输出首页优先关注项', () {
    final metrics = DailyMetrics(
      date: DateTime(2026, 6, 9),
      stepCount: 2680,
      sedentaryDuration: const Duration(hours: 8, minutes: 20),
      screenOnDuration: const Duration(hours: 5, minutes: 10),
      outdoorDuration: const Duration(minutes: 12),
      postureRiskCount: 4,
      highNoiseExposureDuration: const Duration(minutes: 0),
    );

    expect(
      metrics.primaryConcerns,
      <DailyConcern>[
        DailyConcern.sedentary,
        DailyConcern.lowActivity,
        DailyConcern.screenOveruse,
      ],
    );
  });

  test('低风险每日指标应可判断为状态稳定', () {
    final metrics = DailyMetrics(
      date: DateTime(2026, 6, 9),
      stepCount: 8600,
      sedentaryDuration: const Duration(hours: 3, minutes: 40),
      screenOnDuration: const Duration(hours: 1, minutes: 50),
      outdoorDuration: const Duration(minutes: 45),
      postureRiskCount: 0,
      highNoiseExposureDuration: const Duration(minutes: 0),
    );

    expect(metrics.primaryConcerns, isEmpty);
    expect(metrics.isStableDay, isTrue);
  });
}
