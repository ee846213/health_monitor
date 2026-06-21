import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/profile/pages/profile_page.dart';
import 'package:health_monitor/features/profile/providers/notification_preference_provider.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('未开启权限时点击权限项应触发权限处理流程', (
    WidgetTester tester,
  ) async {
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
    final viewModel = _buildViewModel(
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.denied,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.microphone: PermissionGrantStatus.granted,
        PermissionType.usageAccess: PermissionGrantStatus.granted,
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
          notificationPreferenceProvider.overrideWith(() => notifier),
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

    await tester.scrollUntilVisible(
      find.byKey(const Key('profile-permission-row')),
      300,
    );
    await tester.tap(find.byKey(const Key('profile-permission-row')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('活动识别'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('立即处理'));
    await tester.pumpAndSettle();

    expect(handledType, PermissionType.motion);
  });

  testWidgets('Usage Access 项应走专用处理流程', (WidgetTester tester) async {
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
    final viewModel = _buildViewModel(
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.microphone: PermissionGrantStatus.granted,
        PermissionType.usageAccess: PermissionGrantStatus.restricted,
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
          notificationPreferenceProvider.overrideWith(() => notifier),
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

    await tester.scrollUntilVisible(
      find.byKey(const Key('profile-permission-row')),
      300,
    );
    await tester.tap(find.byKey(const Key('profile-permission-row')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('数字生活习惯分析'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('立即处理'));
    await tester.pumpAndSettle();

    expect(handledType, PermissionType.usageAccess);
  });

  testWidgets('我的页应展示勿扰时段区块', (WidgetTester tester) async {
    final notifier = _FakeNotificationPreferenceNotifier(
      const NotificationPreference(
        enabled: true,
        startHour: 22,
        startMinute: 30,
        endHour: 7,
        endMinute: 0,
      ),
    );
    final viewModel = _buildViewModel(
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
          notificationPreferenceProvider.overrideWith(() => notifier),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('do-not-disturb-row')),
      300,
    );
    expect(find.text('勿扰时间'), findsOneWidget);
  });

  testWidgets('我的感知状态分数、趋势和结论为三个独立点击区域', (tester) async {
    final notifier = _FakeNotificationPreferenceNotifier(
      const NotificationPreference(
        enabled: true,
        startHour: 22,
        startMinute: 30,
        endHour: 7,
        endMinute: 0,
      ),
    );
    final viewModel = _buildViewModel(
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith((ref) async => viewModel),
          notificationPreferenceProvider.overrideWith(() => notifier),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-sensing-score')), findsOneWidget);
    expect(find.byKey(const Key('profile-sensing-trend')), findsOneWidget);
    expect(find.byKey(const Key('profile-sensing-verdict')), findsOneWidget);

    final scoreRect =
        tester.getRect(find.byKey(const Key('profile-sensing-score')));
    final trendRect =
        tester.getRect(find.byKey(const Key('profile-sensing-trend')));
    final verdictRect =
        tester.getRect(find.byKey(const Key('profile-sensing-verdict')));
    expect(scoreRect.overlaps(trendRect), isFalse);
    expect(scoreRect.overlaps(verdictRect), isFalse);
    expect(trendRect.overlaps(verdictRect), isFalse);
  });
}

OverviewDashboardViewModel _buildViewModel({
  required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
}) {
  return OverviewDashboardViewModel(
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
    permissionStatuses: permissionStatuses,
  );
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
