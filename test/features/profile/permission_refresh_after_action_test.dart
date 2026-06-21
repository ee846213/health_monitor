import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/features/profile/pages/profile_page.dart';
import 'package:health_monitor/features/profile/providers/notification_preference_provider.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('点击权限项后应重新读取权限并刷新首页状态', (
    WidgetTester tester,
  ) async {
    var granted = false;
    var readCount = 0;
    var readyDataReadCount = 0;
    var handledType = PermissionType.notification;
    final notifier = _FakeNotificationPreferenceNotifier(
      const NotificationPreference(
        enabled: true,
        startHour: 22,
        startMinute: 30,
        endHour: 7,
        endMinute: 0,
      ),
    );

    final container = ProviderContainer(
      overrides: <Override>[
        overviewPermissionStatusServiceProvider.overrideWithValue(
          _FakePermissionStatusService(
            onRead: () {
              readCount += 1;
              return <PermissionType, PermissionGrantStatus>{
                PermissionType.motion: granted
                    ? PermissionGrantStatus.granted
                    : PermissionGrantStatus.denied,
                PermissionType.location: PermissionGrantStatus.granted,
                PermissionType.microphone: PermissionGrantStatus.granted,
                PermissionType.notification: PermissionGrantStatus.granted,
                PermissionType.usageAccess: PermissionGrantStatus.granted,
                PermissionType.backgroundCapture: PermissionGrantStatus.granted,
              };
            },
          ),
        ),
        overviewReadyDataProvider.overrideWith((Ref ref) async {
          readyDataReadCount += 1;
          final statuses = await ref.watch(permissionStatusProvider.future);
          return OverviewReadyData(
            dashboard: _buildDashboardSnapshot(),
            permissionStatuses: statuses,
            missingDimensions: const <String>[],
            reminders: const <ReminderRecord>[],
            preciseDetectionNotice: null,
          );
        }),
        overviewViewModelProvider.overrideWith((Ref ref) async {
          final statuses = await ref.watch(permissionStatusProvider.future);
          return OverviewDashboardViewModel(
            screenState: OverviewScreenState.ready,
            dashboard: _buildDashboardSnapshot(),
            permissionStatuses: statuses,
          );
        }),
        notificationPreferenceProvider.overrideWith(() => notifier),
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
    final initialReadyData =
        await container.read(overviewReadyDataProvider.future);
    expect(
      initialReadyData.permissionStatuses[PermissionType.motion],
      PermissionGrantStatus.denied,
    );
    expect(readCount, 1);
    expect(readyDataReadCount, 1);
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile-permission-row')),
      300,
    );
    await tester.tap(find.byKey(const Key('profile-permission-row')));
    await tester.pumpAndSettle();
    expect(find.text('未开启'), findsWidgets);
    await tester.tap(find.text('活动识别'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('立即处理'));
    await tester.pumpAndSettle();

    expect(handledType, PermissionType.motion);
    expect(readCount, 2);
    final refreshedReadyData =
        await container.read(overviewReadyDataProvider.future);
    expect(
      refreshedReadyData.permissionStatuses[PermissionType.motion],
      PermissionGrantStatus.granted,
    );
    expect(readyDataReadCount, 2);
  });
}

DashboardSnapshot _buildDashboardSnapshot() {
  return DashboardSnapshot(
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
      text: '晚饭后散步 15 分钟会更稳妥。',
      source: DailyAdviceSource.llm,
    ),
    hasRealData: true,
    hasReminderHistory: true,
  );
}

class _FakePermissionStatusService implements PermissionStatusService {
  const _FakePermissionStatusService({required this.onRead});

  final Map<PermissionType, PermissionGrantStatus> Function() onRead;

  @override
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses() async {
    return onRead();
  }
}

class _FakeNotificationPreferenceNotifier
    extends NotificationPreferenceNotifier {
  _FakeNotificationPreferenceNotifier(NotificationPreference initialValue)
      : _initialValue = initialValue;

  final NotificationPreference _initialValue;

  @override
  Future<NotificationPreference> build() async {
    return _initialValue;
  }

  @override
  Future<void> save(NotificationPreference preference) async {
    state = AsyncData(preference);
  }
}
