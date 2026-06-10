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
  testWidgets('点击权限项后应重新读取权限并刷新首页状态', (WidgetTester tester) async {
    var granted = false;
    var readCount = 0;
    var handledType = PermissionType.notification;

    final container = ProviderContainer(
      overrides: <Override>[
        overviewPermissionStatusServiceProvider.overrideWithValue(
          _FakePermissionStatusService(
            onRead: () {
              readCount += 1;
              return <PermissionType, PermissionGrantStatus>{
                PermissionType.motion:
                    granted ? PermissionGrantStatus.granted : PermissionGrantStatus.denied,
                PermissionType.location: PermissionGrantStatus.granted,
                PermissionType.microphone: PermissionGrantStatus.granted,
                PermissionType.notification: PermissionGrantStatus.granted,
                PermissionType.usageAccess: PermissionGrantStatus.granted,
                PermissionType.backgroundCapture: PermissionGrantStatus.granted,
              };
            },
          ),
        ),
        overviewViewModelProvider.overrideWith((Ref ref) async {
          final statuses = await ref.watch(permissionStatusProvider.future);
          final deniedCount = statuses.values.where(
            (PermissionGrantStatus status) =>
                status == PermissionGrantStatus.denied ||
                status == PermissionGrantStatus.restricted,
          ).length;
          return OverviewViewModel(
            screenState:
                deniedCount >= 3 ? OverviewScreenState.permissionDenied : OverviewScreenState.ready,
            isLoading: false,
            verdicts: const <RuleVerdict>[],
            summaryLabel: '测试',
            summaryDetail: '测试',
            metrics: const OverviewMetricSnapshot(
              stepCount: 1,
              sedentaryMinutes: 1,
              screenMinutes: 1,
              outdoorMinutes: 1,
            ),
            reminders: const <ReminderRecord>[],
            permissionStatuses: statuses,
            missingDimensions: const <String>[],
            hasRealData: true,
          );
        }),
        permissionInteractionServiceProvider.overrideWithValue(
          FakePermissionInteractionService(
            handler: (PermissionType type) async {
              handledType = type;
              granted = true;
              return PermissionActionResult.granted;
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(readCount, 1);
    expect(find.text('未开启'), findsWidgets);

    await tester.ensureVisible(find.text('活动识别'));
    await tester.tap(find.text('活动识别'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('立即处理'));
    await tester.pumpAndSettle();

    expect(handledType, PermissionType.motion);
    expect(readCount, 2);
    expect(find.text('已开启'), findsWidgets);
  });
}

class _FakePermissionStatusService implements PermissionStatusService {
  const _FakePermissionStatusService({required this.onRead});

  final Map<PermissionType, PermissionGrantStatus> Function() onRead;

  @override
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses() async {
    return onRead();
  }
}
