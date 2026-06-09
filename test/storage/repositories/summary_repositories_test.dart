import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

void main() {
  test('位置摘要仓储应支持按最近 7 天日期键查询', () async {
    final repository = InMemoryLocationSummaryRepository(
      summaries: <LocationSummary>[
        LocationSummary(
          date: DateTime(2026, 6, 7),
          distanceMeters: 1200,
          outdoorDuration: const Duration(minutes: 20),
          visitCount: 2,
          commuteCount: 1,
        ),
        LocationSummary(
          date: DateTime(2026, 6, 9),
          distanceMeters: 2800,
          outdoorDuration: const Duration(minutes: 40),
          visitCount: 4,
          commuteCount: 2,
        ),
      ],
    );

    final result = await repository.listRecentDays(
      7,
      referenceDate: DateTime(2026, 6, 9),
    );

    expect(result.map((item) => item.date.day), <int>[7, 9]);
  });

  test('数字生活摘要仓储应支持读取最近一天摘要', () async {
    final repository = InMemoryUsageSummaryRepository(
      summaries: <DigitalUsageSummary>[
        DigitalUsageSummary(
          date: DateTime(2026, 6, 8),
          screenOnDuration: const Duration(hours: 2),
          unlockCount: 20,
          nighttimeUsageDuration: const Duration(minutes: 12),
          focusSessionBreakCount: 4,
          topCategory: UsageCategory.tools,
        ),
        DigitalUsageSummary(
          date: DateTime(2026, 6, 9),
          screenOnDuration: const Duration(hours: 4),
          unlockCount: 48,
          nighttimeUsageDuration: const Duration(hours: 1, minutes: 10),
          focusSessionBreakCount: 15,
          topCategory: UsageCategory.social,
        ),
      ],
    );

    final result = await repository.getByDate(DateTime(2026, 6, 9));

    expect(result?.date.day, 9);
    expect(result?.topCategory, UsageCategory.social);
  });

  test('每日指标仓储应支持读取最近 7 天稳定有序结果', () async {
    final repository = InMemoryMetricsRepository(
      metrics: <DailyMetrics>[
        DailyMetrics(
          date: DateTime(2026, 6, 9),
          stepCount: 6200,
          sedentaryDuration: const Duration(hours: 5),
          screenOnDuration: const Duration(hours: 3),
          outdoorDuration: const Duration(minutes: 25),
          postureRiskCount: 1,
          highNoiseExposureDuration: const Duration(minutes: 5),
        ),
        DailyMetrics(
          date: DateTime(2026, 6, 5),
          stepCount: 4100,
          sedentaryDuration: const Duration(hours: 7),
          screenOnDuration: const Duration(hours: 4),
          outdoorDuration: const Duration(minutes: 10),
          postureRiskCount: 2,
          highNoiseExposureDuration: const Duration(minutes: 12),
        ),
      ],
    );

    final result = await repository.listRecentDays(
      7,
      referenceDate: DateTime(2026, 6, 9),
    );

    expect(result.map((item) => item.date.day), <int>[5, 9]);
  });
}
