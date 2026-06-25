import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  test('切换日期后在新数据到达前不应继续展示旧简报内容', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        briefingReferenceTimeProvider.overrideWithValue(
          () => DateTime(2026, 6, 18, 10),
        ),
        briefingViewModelProvider.overrideWith((Ref ref) async {
          final selectedDate = ref.watch(briefingSelectedDateProvider);
          final day = selectedDate ?? DateTime(2026, 6, 18);
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return _viewModelForDay(day);
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(briefingSelectedDateProvider.notifier).state =
        DateTime(2026, 6, 18);
    await container.read(briefingViewModelProvider.future);
    expect(container.read(briefingHeadlineProvider), '6月18日结论');

    container.read(briefingSelectedDateProvider.notifier).state =
        DateTime(2026, 6, 17);
    expect(container.read(briefingContentLoadingProvider), isTrue);
    expect(container.read(briefingHeadlineProvider), '等待采集数据');

    await container.read(briefingViewModelProvider.future);
    expect(container.read(briefingContentLoadingProvider), isFalse);
    expect(container.read(briefingHeadlineProvider), '6月17日结论');
  });
}

BriefingViewModel _viewModelForDay(DateTime day) {
  return BriefingViewModel(
    selectionKey: 'day:2026-${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}',
    selectedRange: BriefingTimeRange.today,
    windowLabel: '${day.month}月${day.day}日',
    screenState: OverviewScreenState.ready,
    briefSnapshot: DailyBriefSnapshot(
      headline: '${day.month}月${day.day}日结论',
      supportingDetail: '详情',
      metrics: const <DailyBriefMetric>[
        DailyBriefMetric(label: '步数', value: '1200', unit: '步'),
        DailyBriefMetric(label: '久坐', value: '60', unit: '分钟'),
        DailyBriefMetric(label: '屏幕使用', value: '90', unit: '分钟'),
      ],
      suggestions: const <String>['保持当前节奏。'],
    ),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
    hasRealData: true,
    isLoading: false,
  );
}
