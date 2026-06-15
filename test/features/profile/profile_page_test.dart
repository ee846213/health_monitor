import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/profile/pages/profile_page.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('未开启权限时点击权限项应触发权限处理流程', (
    WidgetTester tester,
  ) async {
    var handledType = PermissionType.notification;
    final viewModel = OverviewViewModel(
      screenState: OverviewScreenState.ready,
      isLoading: false,
      verdicts: const <RuleVerdict>[],
      summaryLabel: '今日状态稳定',
      summaryDetail: '当前已有可展示数据。',
      metrics: const OverviewMetricSnapshot(
        stepCount: 3200,
        sedentaryMinutes: 90,
        screenMinutes: 120,
        outdoorMinutes: 18,
      ),
      reminders: const <ReminderRecord>[],
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.denied,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.microphone: PermissionGrantStatus.granted,
        PermissionType.usageAccess: PermissionGrantStatus.granted,
      },
      missingDimensions: const <String>[],
      hasRealData: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
          permissionInteractionServiceProvider.overrideWithValue(
            FakePermissionInteractionService(
              handler: (PermissionType type) async {
                handledType = type;
                return PermissionActionResult.granted;
              },
            ),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('活动识别'));
    await tester.tap(find.text('活动识别'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('立即处理'));
    await tester.pumpAndSettle();

    expect(handledType, PermissionType.motion);
  });

  testWidgets('Usage Access 项应走专用处理流程', (
    WidgetTester tester,
  ) async {
    var handledType = PermissionType.notification;
    final viewModel = OverviewViewModel(
      screenState: OverviewScreenState.ready,
      isLoading: false,
      verdicts: const <RuleVerdict>[],
      summaryLabel: '今日状态稳定',
      summaryDetail: '当前已有可展示数据。',
      metrics: const OverviewMetricSnapshot(
        stepCount: 3200,
        sedentaryMinutes: 90,
        screenMinutes: 120,
        outdoorMinutes: 18,
      ),
      reminders: const <ReminderRecord>[],
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.microphone: PermissionGrantStatus.granted,
        PermissionType.usageAccess: PermissionGrantStatus.restricted,
      },
      missingDimensions: const <String>[],
      hasRealData: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
          permissionInteractionServiceProvider.overrideWithValue(
            FakePermissionInteractionService(
              handler: (PermissionType type) async {
                handledType = type;
                return PermissionActionResult.openedSettings;
              },
            ),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('数字生活习惯分析'));
    await tester.tap(find.text('数字生活习惯分析'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('立即处理'));
    await tester.pumpAndSettle();

    expect(handledType, PermissionType.usageAccess);
  });
}
