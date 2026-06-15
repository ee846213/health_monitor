import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('日指标中的系统步数应直接参与规则输入口径', () {
    final input = RuleInput(
      window: QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 10)),
      activitySamples: const [],
      locationSummaries: const [],
      noiseSamples: const [],
      usageSummaries: const [],
      dailyMetricsList: <DailyMetrics>[
        DailyMetrics(
          date: DateTime(2026, 6, 10),
          stepCount: 3210,
          sedentaryDuration: Duration.zero,
          screenOnDuration: Duration.zero,
          outdoorDuration: Duration.zero,
          postureRiskCount: 0,
          highNoiseExposureDuration: Duration.zero,
        ),
      ],
      missingDimensions: const [],
    );

    expect(input.totalSteps, 3210);
  });
}
