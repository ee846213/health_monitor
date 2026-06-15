import 'dart:async';

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
  testWidgets('首页在刷新概览数据时应保留已展示内容而不是回到加载态',
      (WidgetTester tester) async {
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

    var buildCount = 0;
    final pendingRefresh = Completer<OverviewViewModel>();
    final container = ProviderContainer(
      overrides: <Override>[
        overviewViewModelProvider.overrideWith((Ref ref) {
          buildCount += 1;
          if (buildCount == 1) {
            return Future<OverviewViewModel>.value(viewModel);
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

    expect(find.text('活动量偏低'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    container.invalidate(overviewViewModelProvider);
    await tester.pump();

    expect(find.text('活动量偏低'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    pendingRefresh.complete(viewModel);
    await tester.pumpAndSettle();

    expect(buildCount, 2);
    expect(find.text('活动量偏低'), findsWidgets);
  });
}
