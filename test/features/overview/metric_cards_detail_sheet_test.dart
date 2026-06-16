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
  testWidgets('首页三张指标卡应可弹出对应详情浮层', (WidgetTester tester) async {
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

    await tester.tap(find.byKey(const Key('metric-step-card')));
    await tester.pumpAndSettle();
    expect(find.text('近 7 天步数'), findsOneWidget);
    expect(find.textContaining('4860 步'), findsOneWidget);
    expect(find.textContaining('6000 步'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('metric-sedentary-card')));
    await tester.pumpAndSettle();
    expect(find.text('今日久坐分布'), findsOneWidget);
    expect(find.textContaining('96 分钟'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('metric-screen-card')));
    await tester.pumpAndSettle();
    expect(find.text('分时段使用分布'), findsOneWidget);
    expect(find.textContaining('148 分钟'), findsOneWidget);
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
