import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/app.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/reminders/pages/reminder_pages.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

void main() {
  const overviewViewModel = OverviewViewModel(
    screenState: OverviewScreenState.ready,
    isLoading: false,
    verdicts: <RuleVerdict>[
      RuleVerdict(
        dimension: 'activity',
        level: 'normal',
        summary: '活动水平正常',
        detail: '今天已经采集到稳定活动样本。',
      ),
    ],
    summaryLabel: '活动水平正常',
    summaryDetail: '今天已经采集到稳定活动样本。',
    metrics: OverviewMetricSnapshot(
      stepCount: 5200,
      sedentaryMinutes: 80,
      screenMinutes: 110,
      outdoorMinutes: 22,
    ),
    reminders: <ReminderRecord>[],
    permissionStatuses: <PermissionType, PermissionGrantStatus>{},
    missingDimensions: <String>[],
    hasRealData: true,
  );

  testWidgets('应用壳应渲染今日概览标题', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider
              .overrideWith((Ref ref) async => overviewViewModel),
        ],
        child: const HealthMonitorApp(),
      ),
    );
    await tester.pump();

    expect(find.text('今日状态'), findsOneWidget);
  });

  testWidgets('应用壳应提供采集调试入口', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider
              .overrideWith((Ref ref) async => overviewViewModel),
        ],
        child: const HealthMonitorApp(),
      ),
    );
    await tester.pump();

    final router = GoRouter.of(tester.element(find.byType(AppShell)));
    router.go('/diagnostics');
    await tester.pump(const Duration(milliseconds: 300));

    expect(router.state.uri.toString(), '/diagnostics');
  });

  testWidgets('提醒记录页点击后应进入提醒详情页', (WidgetTester tester) async {
    final historyRecord = ReminderRecord(
      triggeredAt: DateTime(2026, 6, 10, 15),
      type: ReminderType.sedentaryBreak,
      title: '起身走一走',
      message: '你已经久坐较长时间，先活动 5 分钟。',
      reasonSummary: '最近 2 小时静止样本占比较高。',
      actionSuggestion: '现在起身活动，再继续手头任务。',
      response: ReminderResponse.pending,
    );
    final historyRepository = InMemoryReminderRepository(
      records: <ReminderRecord>[historyRecord],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider
              .overrideWith((Ref ref) async => overviewViewModel),
          reminderRepositoryProvider.overrideWith(
            (Ref ref) async => historyRepository,
          ),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/reminders',
            routes: <RouteBase>[
              GoRoute(
                path: '/reminders',
                builder: (_, __) => const ReminderListPage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'detail',
                    builder: (BuildContext context, GoRouterState state) {
                      final extra = state.extra as ReminderRecord;
                      return ReminderDetailPage(record: extra);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('起身走一走'), findsOneWidget);

    await tester.tap(find.text('起身走一走'));
    await tester.pumpAndSettle();

    expect(find.text('你已经久坐较长时间，先活动 5 分钟。'), findsOneWidget);
    expect(find.text('最近 2 小时静止样本占比较高。'), findsOneWidget);
  });

  testWidgets('提醒记录页应优先读取历史仓储而不是概览里的即时提醒', (WidgetTester tester) async {
    final generatedReminder = ReminderRecord(
      triggeredAt: DateTime(2026, 6, 10, 11),
      type: ReminderType.postureRisk,
      title: '抬高手肘',
      message: '即时规则结果，不应直接作为历史页数据源。',
      reasonSummary: '即时提醒',
      actionSuggestion: '调整姿势。',
      response: ReminderResponse.pending,
    );
    final persistedReminder = ReminderRecord(
      triggeredAt: DateTime(2026, 6, 10, 9),
      type: ReminderType.nightUsage,
      title: '历史提醒',
      message: '这是持久化历史中的提醒。',
      reasonSummary: '历史来源',
      actionSuggestion: '减少夜间刷屏。',
      response: ReminderResponse.dismissed,
    );
    final historyRepository = InMemoryReminderRepository(
      records: <ReminderRecord>[persistedReminder],
    );

    final viewModelWithGeneratedReminder = OverviewViewModel(
      screenState: OverviewScreenState.ready,
      isLoading: false,
      verdicts: <RuleVerdict>[],
      summaryLabel: '活动水平正常',
      summaryDetail: '今天已经采集到稳定活动样本。',
      metrics: OverviewMetricSnapshot(
        stepCount: 5200,
        sedentaryMinutes: 80,
        screenMinutes: 110,
        outdoorMinutes: 22,
      ),
      reminders: <ReminderRecord>[generatedReminder],
      permissionStatuses: <PermissionType, PermissionGrantStatus>{},
      missingDimensions: <String>[],
      hasRealData: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith(
            (Ref ref) async => viewModelWithGeneratedReminder,
          ),
          reminderRepositoryProvider.overrideWith(
            (Ref ref) async => historyRepository,
          ),
        ],
        child: const MaterialApp(home: ReminderListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('历史提醒'), findsOneWidget);
    expect(find.text('抬高手肘'), findsNothing);
  });
}
