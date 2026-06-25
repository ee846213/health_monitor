import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  test('同一时间范围内数据变化只刷新卡片字段，不刷新简报页外层', () async {
    final viewModelProvider = StateProvider<BriefingViewModel?>(
      (Ref ref) => _buildViewModel(
        headline: '初始结论',
        stepCount: '1200',
      ),
    );
    final container = ProviderContainer(
      overrides: <Override>[
        briefingViewModelStateProvider.overrideWith(
          (Ref ref) => ref.watch(viewModelProvider),
        ),
      ],
    );
    addTearDown(container.dispose);

    final pageEvents = <AsyncValue<BriefingTimeRange>>[];
    final headlineEvents = <String>[];
    final metricEvents = <List<DailyBriefMetric>>[];
    final pageSubscription = container.listen<AsyncValue<BriefingTimeRange>>(
      briefingPageRangeProvider,
      (previous, next) => pageEvents.add(next),
      fireImmediately: false,
    );
    final headlineSubscription = container.listen<String>(
      briefingHeadlineProvider,
      (previous, next) => headlineEvents.add(next),
      fireImmediately: false,
    );
    final metricSubscription = container.listen<List<DailyBriefMetric>>(
      briefingMetricsProvider,
      (previous, next) => metricEvents.add(next),
      fireImmediately: false,
    );
    addTearDown(pageSubscription.close);
    addTearDown(headlineSubscription.close);
    addTearDown(metricSubscription.close);

    container.read(viewModelProvider.notifier).state = _buildViewModel(
      headline: '更新后的结论',
      stepCount: '2400',
    );
    await container.pump();

    expect(pageEvents, isEmpty);
    expect(headlineEvents, <String>['更新后的结论']);
    expect(metricEvents.single.first.value, '2400');
  });
}

BriefingViewModel _buildViewModel({
  required String headline,
  required String stepCount,
}) {
  return BriefingViewModel(
    selectionKey: 'day:2026-06-18',
    selectedRange: BriefingTimeRange.today,
    windowLabel: '今日',
    screenState: OverviewScreenState.ready,
    briefSnapshot: DailyBriefSnapshot(
      headline: headline,
      supportingDetail: '简报详情',
      metrics: <DailyBriefMetric>[
        DailyBriefMetric(label: '步数', value: stepCount, unit: '步'),
        const DailyBriefMetric(label: '久坐', value: '60', unit: '分钟'),
        const DailyBriefMetric(label: '屏幕使用', value: '90', unit: '分钟'),
      ],
      suggestions: const <String>['保持当前节奏。'],
    ),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{
      PermissionType.motion: PermissionGrantStatus.granted,
      PermissionType.location: PermissionGrantStatus.granted,
      PermissionType.microphone: PermissionGrantStatus.granted,
      PermissionType.notification: PermissionGrantStatus.granted,
      PermissionType.usageAccess: PermissionGrantStatus.granted,
      PermissionType.backgroundCapture: PermissionGrantStatus.granted,
    },
    hasRealData: true,
    isLoading: false,
  );
}
