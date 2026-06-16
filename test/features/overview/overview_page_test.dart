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
  testWidgets('overview shows dashboard for ready data', (WidgetTester tester) async {
    const viewModel = OverviewViewModel(
      screenState: OverviewScreenState.ready,
      isLoading: false,
      verdicts: <RuleVerdict>[
        RuleVerdict(
          dimension: 'activity',
          level: 'concern',
          summary: 'ACTIVE_TOO_LOW',
          detail: 'take a 5 minute walk',
        ),
      ],
      summaryLabel: 'ACTIVE_TOO_LOW',
      summaryDetail: 'take a 5 minute walk',
      todayStatusLabel: 'ACTIVE_LOW',
      todayStatusDetail: 'steps 1600, sedentary 145',
      conclusionLabel: 'ACTIVE_TOO_LOW',
      conclusionDetail: 'take a 5 minute walk',
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

    expect(find.text('ACTIVE_LOW'), findsOneWidget);
    expect(find.byWidgetPredicate((Widget widget) =>
        widget.runtimeType.toString() == '_MetricCard'), findsNWidgets(3));
    expect(find.text('take a 5 minute walk'), findsWidgets);
  });

  testWidgets('overview keeps dashboard structure when data is insufficient',
      (WidgetTester tester) async {
    const viewModel = OverviewViewModel(
      screenState: OverviewScreenState.dataInsufficient,
      isLoading: false,
      verdicts: <RuleVerdict>[],
      summaryLabel: 'DATA_PENDING',
      summaryDetail: 'keep using the app so data can accumulate',
      metrics: OverviewMetricSnapshot(
        stepCount: 0,
        sedentaryMinutes: 0,
        screenMinutes: 0,
        outdoorMinutes: 0,
      ),
      reminders: <ReminderRecord>[],
      permissionStatuses: <PermissionType, PermissionGrantStatus>{},
      missingDimensions: <String>[],
      hasRealData: false,
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

    expect(find.text('DATA_PENDING'), findsOneWidget);
    expect(find.byWidgetPredicate((Widget widget) =>
        widget.runtimeType.toString() == '_MetricCard'), findsNWidgets(3));
    expect(find.text('DATA_INSUFFICIENT'), findsNothing);
  });
}
