import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/overview_detail_providers.dart';
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
          overviewStepDetailProvider.overrideWith(
            (Ref ref) async => _stepDetail(),
          ),
          overviewSedentaryDetailProvider.overrideWith(
            (Ref ref) async => _sedentaryDetail(),
          ),
          overviewScreenDetailProvider.overrideWith(
            (Ref ref) async => _screenDetail(),
          ),
          overviewEnvironmentDetailProvider.overrideWith(
            (Ref ref) async => _environmentDetail(),
          ),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    final stepCard = tester.getRect(
      find.byKey(const Key('metric-step-card')),
    );
    final sedentaryCard = tester.getRect(
      find.byKey(const Key('metric-sedentary-card')),
    );
    final screenCard = tester.getRect(
      find.byKey(const Key('metric-screen-card')),
    );
    expect(sedentaryCard.height, stepCard.height);
    expect(sedentaryCard.height, screenCard.height);

    await tester.tap(find.byKey(const Key('metric-step-card')));
    await tester.pumpAndSettle();
    expect(find.text('近 7 天步数'), findsOneWidget);
    expect(find.text('今日 4860 步，目标 6000 步，达成 81%。'), findsOneWidget);
    expect(find.textContaining('6000 步'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('step-bar-今天')), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('metric-sedentary-card')));
    await tester.pumpAndSettle();
    expect(find.text('今日久坐分布'), findsOneWidget);
    expect(find.textContaining('96 分钟'), findsOneWidget);
    expect(
      find.byKey(ValueKey<DateTime>(DateTime(2026, 6, 16, 9))),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('metric-screen-card')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('metric-screen-card')));
    await tester.pumpAndSettle();
    expect(find.text('分时段使用分布'), findsOneWidget);
    expect(find.textContaining('148 分钟'), findsOneWidget);
    expect(find.text('白天 · 06:00 - 22:00'), findsOneWidget);
    expect(find.text('夜间 · 22:00 - 06:00'), findsOneWidget);
    expect(find.text('110 分钟'), findsOneWidget);
    expect(find.text('38 分钟'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('screen-白天')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('screen-夜间')),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('metric-noise-card')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('metric-noise-card')));
    await tester.pumpAndSettle();
    expect(find.text('当前环境'), findsOneWidget);
    expect(find.text('舒适 · 320 lx'), findsOneWidget);
    expect(find.text('正常 · 48 dB'), findsOneWidget);
  });

  testWidgets('环境浮层遇到无效分贝值时应降级显示暂无样本', (
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
          overviewEnvironmentDetailProvider.overrideWith(
            (Ref ref) async => OverviewEnvironmentDetailSnapshot(
              lightLabel: '舒适',
              noiseLabel: '正常',
              lux: 320,
              decibel: double.nan,
            ),
          ),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('metric-noise-card')));
    await tester.pumpAndSettle();

    expect(find.text('当前环境'), findsOneWidget);
    expect(find.text('舒适 · 320 lx'), findsOneWidget);
    expect(find.text('正常 · 暂无样本'), findsOneWidget);
  });
}

OverviewStepDetailSnapshot _stepDetail() {
  final today = DateTime(2026, 6, 16);
  return OverviewStepDetailSnapshot(
    goalSteps: 6000,
    todaySteps: 4860,
    todayProgress: 0.81,
    points: List<OverviewStepTrendPoint>.generate(
      7,
      (int index) => OverviewStepTrendPoint(
        date: today.subtract(Duration(days: 6 - index)),
        steps: 1800 + index * 510,
        isToday: index == 6,
      ),
    ),
  );
}

OverviewSedentaryDetailSnapshot _sedentaryDetail() {
  return OverviewSedentaryDetailSnapshot(
    totalDuration: const Duration(minutes: 96),
    longestDuration: const Duration(minutes: 42),
    segments: <OverviewSedentarySegmentSnapshot>[
      OverviewSedentarySegmentSnapshot(
        startedAt: DateTime(2026, 6, 16, 9),
        endedAt: DateTime(2026, 6, 16, 9, 42),
        duration: const Duration(minutes: 42),
      ),
      OverviewSedentarySegmentSnapshot(
        startedAt: DateTime(2026, 6, 16, 14),
        endedAt: DateTime(2026, 6, 16, 14, 30),
        duration: const Duration(minutes: 30),
      ),
    ],
  );
}

OverviewScreenDetailSnapshot _screenDetail() {
  final today = DateTime(2026, 6, 16);
  return OverviewScreenDetailSnapshot(
    todaySummary: DigitalUsageSummary(
      date: today,
      screenOnDuration: const Duration(minutes: 148),
      unlockCount: 20,
      nighttimeUsageDuration: const Duration(minutes: 38),
      focusSessionBreakCount: 4,
      topCategory: UsageCategory.social,
    ),
    yesterdaySummary: null,
    totalDuration: const Duration(minutes: 148),
    deltaMinutes: -18,
    buckets: const <OverviewScreenUsageBucket>[
      OverviewScreenUsageBucket(
        label: '白天',
        duration: Duration(minutes: 110),
        subtitle: '06:00 - 22:00',
      ),
      OverviewScreenUsageBucket(
        label: '夜间',
        duration: Duration(minutes: 38),
        subtitle: '22:00 - 06:00',
      ),
    ],
    sourceLabel: '系统 Usage Stats',
    qualityLabel: null,
  );
}

OverviewEnvironmentDetailSnapshot _environmentDetail() {
  return OverviewEnvironmentDetailSnapshot(
    lightLabel: '舒适',
    noiseLabel: '正常',
    lux: 320,
    decibel: 48,
    lightCapturedAt: DateTime(2026, 6, 16, 9, 20),
    noiseCapturedAt: DateTime(2026, 6, 16, 9, 18),
  );
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
