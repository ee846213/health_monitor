import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('首页在刷新仪表盘数据时应保留已展示内容而不是回到加载态', (
    WidgetTester tester,
  ) async {
    final screenStateProvider = StateProvider<AsyncValue<OverviewScreenState>>(
      (Ref ref) => const AsyncData(OverviewScreenState.ready),
    );
    final readyData = OverviewReadyData(
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

    final container = ProviderContainer(
      overrides: <Override>[
        overviewScreenStateProvider.overrideWith(
          (Ref ref) => ref.watch(screenStateProvider),
        ),
        overviewReadyDataStateProvider.overrideWith((Ref ref) => readyData),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('综合健康分'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    container.read(screenStateProvider.notifier).state =
        const AsyncLoading<OverviewScreenState>().copyWithPrevious(
      const AsyncData(OverviewScreenState.ready),
    );
    await tester.pump();

    expect(find.text('综合健康分'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    container.read(screenStateProvider.notifier).state =
        const AsyncData(OverviewScreenState.ready);
    await tester.pumpAndSettle();

    expect(find.text('综合健康分'), findsOneWidget);
  });
}
