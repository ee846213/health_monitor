import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('首页在刷新仪表盘数据时应保留已展示内容而不是回到加载态', (
    WidgetTester tester,
  ) async {
    final viewModel = OverviewDashboardViewModel(
      screenState: OverviewScreenState.ready,
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
      permissionStatuses: <PermissionType, PermissionGrantStatus>{},
    );

    var buildCount = 0;
    final pendingRefresh = Completer<OverviewDashboardViewModel>();
    final container = ProviderContainer(
      overrides: <Override>[
        overviewViewModelProvider.overrideWith((Ref ref) {
          buildCount += 1;
          if (buildCount == 1) {
            return Future<OverviewDashboardViewModel>.value(viewModel);
          }
          return pendingRefresh.future;
        }),
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

    container.invalidate(overviewViewModelProvider);
    await tester.pump();

    expect(find.text('综合健康分'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    pendingRefresh.complete(viewModel);
    await tester.pumpAndSettle();

    expect(buildCount, 2);
    expect(find.text('综合健康分'), findsOneWidget);
  });
}
