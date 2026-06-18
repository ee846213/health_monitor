import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/overview/providers/overview_detail_providers.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

void main() {
  test('亮屏详情应从今日摘要生成白天和夜间使用数据', () async {
    final now = DateTime.now();
    final repository = InMemoryUsageSummaryRepository(
      summaries: <DigitalUsageSummary>[
        DigitalUsageSummary(
          date: DateTime(now.year, now.month, now.day),
          screenOnDuration: const Duration(minutes: 148),
          unlockCount: 20,
          nighttimeUsageDuration: const Duration(minutes: 38),
          focusSessionBreakCount: 4,
          topCategory: UsageCategory.social,
          source: DigitalUsageSource.androidUsageStats,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: <Override>[
        usageSummaryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(
      overviewScreenDetailProvider.future,
    );

    expect(snapshot.totalDuration, const Duration(minutes: 148));
    expect(snapshot.buckets, hasLength(2));
    expect(snapshot.buckets[0].label, '白天');
    expect(snapshot.buckets[0].duration, const Duration(minutes: 110));
    expect(snapshot.buckets[1].label, '夜间');
    expect(snapshot.buckets[1].duration, const Duration(minutes: 38));
    expect(snapshot.sourceLabel, '系统 Usage Stats');
  });
}
