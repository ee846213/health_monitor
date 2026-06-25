import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_signals.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/daily_rhythm_clock_provider.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/features/overview/widgets/daily_rhythm_timeline.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('首页展示生活节奏轴、今日状态、四维摘要和行动建议', (
    WidgetTester tester,
  ) async {
    final readyData = _buildReadyData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          dailyRhythmClockProvider.overrideWith(
            (Ref ref) => DateTime(2026, 6, 16, 22),
          ),
          overviewScreenStateProvider.overrideWith(
            (Ref ref) => const AsyncData(OverviewScreenState.ready),
          ),
          overviewReadyDataStateProvider.overrideWith((Ref ref) => readyData),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今天的节奏'), findsOneWidget);
    expect(find.byType(DailyRhythmTimeline), findsOneWidget);
    expect(find.text('今日状态'), findsOneWidget);
    expect(find.text('活动'), findsOneWidget);
    expect(find.text('久坐'), findsOneWidget);
    expect(find.text('环境噪音'), findsOneWidget);
    expect(find.text('数字习惯'), findsOneWidget);
    await tester.tap(find.byKey(const Key('rhythm-node-activity')));
    await tester.pumpAndSettle();
    expect(find.textContaining('活动'), findsWidgets);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('overview-action-card')),
      300,
    );
    expect(find.byKey(const Key('overview-action-card')), findsOneWidget);
  });

  testWidgets('无集中事件时首页不展示节奏轴', (WidgetTester tester) async {
    final readyData = _buildReadyData(
      rhythmSignals: const DailyRhythmSignals.empty(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          dailyRhythmClockProvider.overrideWith(
            (Ref ref) => DateTime(2026, 6, 16, 22),
          ),
          overviewScreenStateProvider.overrideWith(
            (Ref ref) => const AsyncData(OverviewScreenState.ready),
          ),
          overviewReadyDataStateProvider.overrideWith((Ref ref) => readyData),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今天的节奏'), findsOneWidget);
    expect(find.byType(DailyRhythmTimeline), findsNothing);
  });

  testWidgets('点击今日结论应跳转到趋势页', (WidgetTester tester) async {
    final readyData = _buildReadyData();
    final router = GoRouter(
      initialLocation: '/overview',
      routes: <RouteBase>[
        GoRoute(
          path: '/overview',
          builder: (_, __) => const OverviewPage(),
        ),
        GoRoute(
          path: '/trends',
          builder: (_, __) => const Scaffold(body: Text('趋势页占位')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          dailyRhythmClockProvider.overrideWith(
            (Ref ref) => DateTime(2026, 6, 16, 22),
          ),
          overviewScreenStateProvider.overrideWith(
            (Ref ref) => const AsyncData(OverviewScreenState.ready),
          ),
          overviewReadyDataStateProvider.overrideWith((Ref ref) => readyData),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('overview-summary-card')));
    await tester.pumpAndSettle();

    expect(find.text('趋势页占位'), findsOneWidget);
  });
}

DailyRhythmSignals _concentratedRhythmSignals() {
  return DailyRhythmSignals(
    activityPeakAt: DateTime(2026, 6, 16, 9, 30),
    activityPeakSteps: 480,
    sedentaryStartAt: DateTime(2026, 6, 16, 14, 30),
    sedentaryLongestMinutes: 65,
    digitalUsageAt: DateTime(2026, 6, 16, 21),
    digitalUsageIsPrecise: true,
    digitalLongestSessionMinutes: 35,
  );
}

OverviewReadyData _buildReadyData({
  DailyRhythmSignals? rhythmSignals,
}) {
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
      rhythmSignals: rhythmSignals ?? _concentratedRhythmSignals(),
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
