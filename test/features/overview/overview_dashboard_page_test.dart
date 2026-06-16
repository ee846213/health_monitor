import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('首页展示综合健康分、三张卡片、环境快照和 AI 建议', (
    WidgetTester tester,
  ) async {
    final readyData = _buildReadyData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewScreenStateProvider.overrideWith(
            (Ref ref) => const AsyncData(OverviewScreenState.ready),
          ),
          overviewReadyDataStateProvider.overrideWith((Ref ref) => readyData),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('综合健康分'), findsOneWidget);
    expect(find.text('步数'), findsOneWidget);
    expect(find.text('久坐'), findsOneWidget);
    expect(find.text('屏幕'), findsOneWidget);
    expect(find.textContaining('环境快照'), findsOneWidget);
    expect(find.textContaining('AI 建议'), findsOneWidget);
    expect(find.text('晚饭后散步 15 分钟会更稳。'), findsOneWidget);
  });

  testWidgets('点击综合健康分应跳转到趋势页', (WidgetTester tester) async {
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
          overviewScreenStateProvider.overrideWith(
            (Ref ref) => const AsyncData(OverviewScreenState.ready),
          ),
          overviewReadyDataStateProvider.overrideWith((Ref ref) => readyData),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('综合健康分'));
    await tester.pumpAndSettle();

    expect(find.text('趋势页占位'), findsOneWidget);
  });
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
