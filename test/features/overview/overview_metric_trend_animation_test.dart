import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/overview_metric_trend_provider.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

const _trendDataA = OverviewMetricTrendData(
  activity: <double>[0, 0.4, 1],
  posture: <double>[0, 0.45, 1],
  digital: <double>[0, 0.68, 1],
);

const _trendDataB = OverviewMetricTrendData(
  activity: <double>[0.2, 0.6, 0.8],
  posture: <double>[0.1, 0.5, 0.9],
  digital: <double>[0.4, 0.5, 0.7],
);

/// 测试侧的“当前趋势数据”状态源。
/// 让被测的 [overviewMetricTrendDataProvider] 改读这里的值，
/// 即可在运行时模拟“数据刷新”而无需重建整个 ProviderScope。
final _testTrendDataProvider =
    StateProvider<OverviewMetricTrendData>((Ref ref) => _trendDataA);

void main() {
  testWidgets('首页四维趋势线具有开始态、中间态和结束态', (WidgetTester tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildApp(container, disableAnimations: false));
    // 趋势数据通过异步 FutureProvider 暴露：先用一个零时长 pump 让
    // 微任务完成、首次真实数据到位，从此处开始度量入场动画。
    await tester.pump();
    expect(_activityTrendProgress(tester), 0);

    await tester.pump(const Duration(milliseconds: 250));
    expect(_activityTrendProgress(tester), inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_activityTrendProgress(tester), closeTo(1, 0.001));
  });

  testWidgets('减少动态效果时趋势线直接显示最终状态', (WidgetTester tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildApp(container, disableAnimations: true));
    await tester.pump();
    expect(_activityTrendProgress(tester), closeTo(1, 0.001));
  });

  testWidgets('三条趋势线应按维度顺序错峰生长', (WidgetTester tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildApp(container, disableAnimations: false));
    await tester.pump();

    // 真实数据刚到位的第一帧：三条线都尚未开始生长。
    expect(_trendProgress(tester, 'activity'), 0);
    expect(_trendProgress(tester, 'posture'), 0);
    expect(_trendProgress(tester, 'digital'), 0);

    // 在第一条线的错峰窗口（< 90ms）内推进一段：
    // 活动维度应已开始生长，其余两条仍停留在等待区。
    await tester.pump(const Duration(milliseconds: 30));
    expect(_trendProgress(tester, 'activity'), greaterThan(0));
    expect(_trendProgress(tester, 'posture'), 0);
    expect(_trendProgress(tester, 'digital'), 0);

    await tester.pumpAndSettle();
    expect(_trendProgress(tester, 'activity'), closeTo(1, 0.001));
    expect(_trendProgress(tester, 'posture'), closeTo(1, 0.001));
    expect(_trendProgress(tester, 'digital'), closeTo(1, 0.001));
  });

  testWidgets('数据刷新时趋势线应重新生长', (WidgetTester tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildApp(container, disableAnimations: false));
    await tester.pumpAndSettle();
    expect(_activityTrendProgress(tester), closeTo(1, 0.001));

    // 切换底层数据，相当于真实采集刷新后 trend provider 输出了新序列。
    container.read(_testTrendDataProvider.notifier).state = _trendDataB;
    // 第一个零时长 pump 让 FutureProvider 完成重新解析；
    // 第二个零时长 pump 让 _MetricRow 看到新的 OverviewMetricTrendData
    // 并在 didUpdateWidget 中 reset 控制器到 0。
    await tester.pump();
    await tester.pump();
    expect(
      _activityTrendProgress(tester),
      lessThan(0.05),
      reason: '数据刷新后应当从 0 附近重新生长，而不是停留在上一次的终点',
    );

    await tester.pump(const Duration(milliseconds: 200));
    expect(_activityTrendProgress(tester), inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_activityTrendProgress(tester), closeTo(1, 0.001));
  });
}

ProviderContainer _buildContainer() {
  return ProviderContainer(
    overrides: <Override>[
      overviewScreenStateProvider.overrideWith(
        (Ref ref) => const AsyncData(OverviewScreenState.ready),
      ),
      overviewReadyDataStateProvider.overrideWith((Ref ref) => _buildReadyData()),
      overviewMetricTrendDataProvider.overrideWith(
        (Ref ref) async => ref.watch(_testTrendDataProvider),
      ),
    ],
  );
}

Widget _buildApp(
  ProviderContainer container, {
  required bool disableAnimations,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
          ),
          child: child!,
        );
      },
      home: const OverviewPage(),
    ),
  );
}

double _activityTrendProgress(WidgetTester tester) {
  return _trendProgress(tester, 'activity');
}

double _trendProgress(WidgetTester tester, String dimension) {
  final customPaint = tester.widget<CustomPaint>(
    find.byKey(Key('metric-$dimension-trend')),
  );
  final dynamic painter = customPaint.painter;
  return painter.progress as double;
}

OverviewReadyData _buildReadyData() {
  return OverviewReadyData(
    dashboard: DashboardSnapshot(
      generatedAt: DateTime(2026, 6, 16, 9),
      healthScore: HealthScoreBreakdown(
        stepScore: 81,
        sedentaryScore: 92,
        screenScore: 88,
        totalScore: 87,
      ),
      stepCard: DashboardStepCard(
        currentSteps: 4860,
        goalSteps: 6000,
        achievementPercent: 81,
      ),
      sedentaryCard: DashboardSedentaryCard(
        totalMinutes: 96,
        longestSingleMinutes: 42,
      ),
      screenCard: DashboardScreenCard(
        totalMinutes: 148,
        yesterdayDeltaMinutes: -18,
        changeDirection: DashboardChangeDirection.down,
      ),
      environmentSnapshot: DashboardEnvironmentSnapshot(
        lightLabel: '舒适',
        noiseLabel: '正常',
      ),
      dailyAdviceBubble: DailyAdviceBubble(
        text: '晚饭后散步 15 分钟会更稳。',
        source: DailyAdviceSource.llm,
      ),
      hasRealData: true,
      hasReminderHistory: true,
    ),
    permissionStatuses: <PermissionType, PermissionGrantStatus>{
      PermissionType.motion: PermissionGrantStatus.granted,
      PermissionType.location: PermissionGrantStatus.granted,
      PermissionType.microphone: PermissionGrantStatus.granted,
      PermissionType.notification: PermissionGrantStatus.granted,
      PermissionType.usageAccess: PermissionGrantStatus.granted,
      PermissionType.backgroundCapture: PermissionGrantStatus.granted,
    },
    missingDimensions: const <String>[],
    reminders: const <ReminderRecord>[],
    preciseDetectionNotice: null,
  );
}
