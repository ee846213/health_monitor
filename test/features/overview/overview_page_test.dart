import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('首页应渲染真实概览文案而不是静态占位文案', (WidgetTester tester) async {
    const viewModel = OverviewViewModel(
      screenState: OverviewScreenState.ready,
      isLoading: false,
      verdicts: <RuleVerdict>[
        RuleVerdict(
          dimension: 'activity',
          level: 'concern',
          summary: '活动量偏低',
          detail: '最近两小时连续久坐，建议先起来活动 5 分钟。',
        ),
      ],
      summaryLabel: '活动量偏低',
      summaryDetail: '最近两小时连续久坐，建议先起来活动 5 分钟。',
      todayStatusLabel: '活动偏少',
      todayStatusDetail: '步数 1600，久坐 145 分钟。',
      conclusionLabel: '活动量偏低',
      conclusionDetail: '最近两小时连续久坐，建议先起来活动 5 分钟。',
      metrics: OverviewMetricSnapshot(
        stepCount: 1600,
        sedentaryMinutes: 145,
        screenMinutes: 80,
        outdoorMinutes: 10,
      ),
      reminders: <ReminderRecord>[],
      permissionStatuses: <PermissionType, PermissionGrantStatus>{},
      missingDimensions: <String>[],
      hasRealData: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('活动偏少'), findsOneWidget);
    expect(find.text('步数 1600，久坐 145 分钟。'), findsOneWidget);
    expect(find.text('活动量偏低'), findsWidgets);
    expect(find.text('最近两小时连续久坐，建议先起来活动 5 分钟。'), findsWidgets);
    expect(find.text('今天整体还不错，下午久坐有点集中。'), findsNothing);
  });
}
