import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/briefing/pages/briefing_page.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_detail_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('简报页支持时间范围切换并打开三类指标详情', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          briefingViewModelProvider.overrideWith((ref) async {
            final range = ref.watch(briefingTimeRangeProvider);
            return _viewModelFor(range);
          }),
          briefingStepDetailProvider.overrideWith(
            (ref, range) async => _stepDetailFor(range),
          ),
          briefingSedentaryDetailProvider.overrideWith(
            (ref, range) async => _sedentaryDetailFor(range),
          ),
          briefingScreenDetailProvider.overrideWith(
            (ref, range) async => _screenDetailFor(range),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: BriefingPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('briefing-step-card')), findsOneWidget);
    expect(find.text('1200 步'), findsOneWidget);
    expect(find.text('三个核心指标'), findsNothing);

    await tester.tap(find.byKey(const Key('briefing-step-card')));
    await tester.pumpAndSettle();
    expect(find.textContaining('7 天步数'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('briefing-sedentary-card')));
    await tester.pumpAndSettle();
    expect(find.textContaining('久坐分布'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('briefing-screen-card')));
    await tester.pumpAndSettle();
    expect(find.textContaining('分时段使用分布'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('昨日'));
    await tester.pumpAndSettle();
    expect(find.text('2400 步'), findsOneWidget);

    await tester.tap(find.text('最近 7 天'));
    await tester.pumpAndSettle();
    expect(find.text('6000 步'), findsOneWidget);
  });
}

BriefingViewModel _viewModelFor(BriefingTimeRange range) {
  final steps = switch (range) {
    BriefingTimeRange.today => 1200,
    BriefingTimeRange.yesterday => 2400,
    BriefingTimeRange.recent7Days => 6000,
  };
  return BriefingViewModel(
    selectedRange: range,
    windowLabel: range.label,
    screenState: OverviewScreenState.ready,
    briefSnapshot: DailyBriefSnapshot(
      headline: '状态平稳',
      supportingDetail: '当前范围内已有可用数据。',
      metrics: <DailyBriefMetric>[
        DailyBriefMetric(label: '步数', value: '$steps', unit: '步'),
        const DailyBriefMetric(label: '久坐', value: '60', unit: '分钟'),
        const DailyBriefMetric(label: '屏幕使用', value: '90', unit: '分钟'),
      ],
      suggestions: const <String>['继续保持当前节奏。'],
    ),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
    hasRealData: true,
    isLoading: false,
  );
}

OverviewStepDetailSnapshot _stepDetailFor(BriefingTimeRange range) {
  final steps = range == BriefingTimeRange.recent7Days ? 6000 : 1200;
  final now = DateTime(2026, 6, 18);
  return OverviewStepDetailSnapshot(
    goalSteps: range == BriefingTimeRange.recent7Days ? 42000 : 6000,
    todaySteps: steps,
    todayProgress: steps / 6000,
    points: List<OverviewStepTrendPoint>.generate(
      7,
      (index) => OverviewStepTrendPoint(
        date: now.subtract(Duration(days: 6 - index)),
        steps: index == 6 ? steps : 800 + index * 100,
        isToday: range == BriefingTimeRange.today && index == 6,
      ),
    ),
  );
}

OverviewSedentaryDetailSnapshot _sedentaryDetailFor(
  BriefingTimeRange range,
) {
  final start = DateTime(2026, 6, 18, 9);
  return OverviewSedentaryDetailSnapshot(
    totalDuration: const Duration(minutes: 60),
    longestDuration: const Duration(minutes: 35),
    segments: <OverviewSedentarySegmentSnapshot>[
      OverviewSedentarySegmentSnapshot(
        startedAt: start,
        endedAt: start.add(const Duration(minutes: 35)),
        duration: const Duration(minutes: 35),
      ),
    ],
  );
}

OverviewScreenDetailSnapshot _screenDetailFor(BriefingTimeRange range) {
  return const OverviewScreenDetailSnapshot(
    todaySummary: null,
    yesterdaySummary: null,
    totalDuration: Duration(minutes: 90),
    deltaMinutes: 0,
    buckets: <OverviewScreenUsageBucket>[
      OverviewScreenUsageBucket(
        label: '白天',
        duration: Duration(minutes: 70),
        subtitle: '06:00 - 22:00',
      ),
      OverviewScreenUsageBucket(
        label: '夜间',
        duration: Duration(minutes: 20),
        subtitle: '22:00 - 06:00',
      ),
    ],
    sourceLabel: '测试数据',
    qualityLabel: null,
  );
}
