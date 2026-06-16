import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  test('步数变化时只更新步数相关 provider，不更新噪音图标 provider', () async {
    final readyDataProvider =
        StateProvider<OverviewReadyData?>((Ref ref) => _buildReadyData(
              steps: 1200,
              lightLabel: '舒适',
              noiseLabel: '正常',
            ));
    final container = ProviderContainer(
      overrides: <Override>[
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) => ref.watch(readyDataProvider),
        ),
      ],
    );
    addTearDown(container.dispose);

    final stepEvents = <String>[];
    final noiseIconEvents = <OverviewEnvironmentNoiseIcon>[];

    final stepSub = container.listen<String>(
      overviewStepValueTextProvider,
      (previous, next) => stepEvents.add(next),
      fireImmediately: false,
    );
    final noiseSub = container.listen<OverviewEnvironmentNoiseIcon>(
      overviewEnvironmentNoiseIconProvider,
      (previous, next) => noiseIconEvents.add(next),
      fireImmediately: false,
    );
    addTearDown(stepSub.close);
    addTearDown(noiseSub.close);

    container.read(readyDataProvider.notifier).state = _buildReadyData(
      steps: 2400,
      lightLabel: '舒适',
      noiseLabel: '正常',
    );
    await container.pump();

    expect(stepEvents, <String>['2400']);
    expect(noiseIconEvents, isEmpty);
  });

  test('环境变化时只更新环境相关 provider，不更新步数字段 provider', () async {
    final readyDataProvider =
        StateProvider<OverviewReadyData?>((Ref ref) => _buildReadyData(
              steps: 1200,
              lightLabel: '舒适',
              noiseLabel: '正常',
            ));
    final container = ProviderContainer(
      overrides: <Override>[
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) => ref.watch(readyDataProvider),
        ),
      ],
    );
    addTearDown(container.dispose);

    final lightTextEvents = <String>[];
    final lightIconEvents = <OverviewEnvironmentLightIcon>[];
    final stepEvents = <String>[];

    final lightTextSub = container.listen<String>(
      overviewEnvironmentLightTextProvider,
      (previous, next) => lightTextEvents.add(next),
      fireImmediately: false,
    );
    final lightIconSub = container.listen<OverviewEnvironmentLightIcon>(
      overviewEnvironmentLightIconProvider,
      (previous, next) => lightIconEvents.add(next),
      fireImmediately: false,
    );
    final stepSub = container.listen<String>(
      overviewStepValueTextProvider,
      (previous, next) => stepEvents.add(next),
      fireImmediately: false,
    );
    addTearDown(lightTextSub.close);
    addTearDown(lightIconSub.close);
    addTearDown(stepSub.close);

    container.read(readyDataProvider.notifier).state = _buildReadyData(
      steps: 1200,
      lightLabel: '明亮',
      noiseLabel: '正常',
    );
    await container.pump();

    expect(lightTextEvents, <String>['明亮']);
    expect(lightIconEvents, <OverviewEnvironmentLightIcon>[
      OverviewEnvironmentLightIcon.bright,
    ]);
    expect(stepEvents, isEmpty);
  });
}

OverviewReadyData _buildReadyData({
  required int steps,
  required String lightLabel,
  required String noiseLabel,
}) {
  return OverviewReadyData(
    dashboard: DashboardSnapshot(
      generatedAt: DateTime(2026, 6, 17, 9),
      healthScore: HealthScoreBreakdown(
        stepScore: steps >= 2400 ? 40 : 20,
        sedentaryScore: 80,
        screenScore: 88,
        totalScore: steps >= 2400 ? 70 : 62,
      ),
      stepCard: DashboardStepCard(
        currentSteps: steps,
        goalSteps: 6000,
        achievementPercent: ((steps / 6000) * 100).round(),
      ),
      sedentaryCard: const DashboardSedentaryCard(
        totalMinutes: 96,
        longestSingleMinutes: 42,
      ),
      screenCard: const DashboardScreenCard(
        totalMinutes: 148,
        yesterdayDeltaMinutes: -18,
        changeDirection: DashboardChangeDirection.down,
      ),
      environmentSnapshot: DashboardEnvironmentSnapshot(
        lightLabel: lightLabel,
        noiseLabel: noiseLabel,
      ),
      dailyAdviceBubble: const DailyAdviceBubble(
        text: '晚饭后散步 15 分钟会更稳。',
        source: DailyAdviceSource.llm,
      ),
      hasRealData: true,
      hasReminderHistory: true,
    ),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{
      PermissionType.motion: PermissionGrantStatus.granted,
      PermissionType.location: PermissionGrantStatus.granted,
      PermissionType.microphone: PermissionGrantStatus.granted,
      PermissionType.notification: PermissionGrantStatus.granted,
      PermissionType.usageAccess: PermissionGrantStatus.granted,
      PermissionType.backgroundCapture: PermissionGrantStatus.granted,
    },
    reminders: const <ReminderRecord>[],
    preciseDetectionNotice: null,
    missingDimensions: const <String>[],
  );
}
