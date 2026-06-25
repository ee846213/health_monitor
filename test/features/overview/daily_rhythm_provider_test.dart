import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_signals.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_builder.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/features/overview/providers/daily_rhythm_clock_provider.dart';
import 'package:health_monitor/features/overview/providers/daily_rhythm_provider.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  test('无集中事件时不生成节奏轴模型', () {
    final container = ProviderContainer(
      overrides: <Override>[
        dailyRhythmClockProvider.overrideWith(
          (Ref ref) => DateTime(2026, 6, 16, 18),
        ),
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) =>
              _readyData(rhythmSignals: const DailyRhythmSignals.empty()),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(dailyRhythmUiModelProvider), isNull);
  });

  test('仅展示达到集中阈值的维度节点', () {
    final container = ProviderContainer(
      overrides: <Override>[
        dailyRhythmClockProvider.overrideWith(
          (Ref ref) => DateTime(2026, 6, 16, 18),
        ),
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) => _readyData(
            rhythmSignals: DailyRhythmSignals(
              activityPeakAt: DateTime(2026, 6, 16, 9, 30),
              activityPeakSteps: 480,
              sedentaryStartAt: DateTime(2026, 6, 16, 14, 30),
              sedentaryLongestMinutes: 65,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final model = container.read(dailyRhythmUiModelProvider);
    expect(model, isNotNull);
    expect(model!.nodes, hasLength(2));
    expect(
      model.nodes.map((node) => node.dimension).toList(),
      <dynamic>[
        DailyRhythmDimension.activity,
        DailyRhythmDimension.posture,
      ],
    );
  });

  test('步数达标时应额外展示达标节点', () {
    final container = ProviderContainer(
      overrides: <Override>[
        dailyRhythmClockProvider.overrideWith(
          (Ref ref) => DateTime(2026, 6, 16, 18),
        ),
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) => _readyData(
            rhythmSignals: DailyRhythmSignals(
              activityPeakAt: DateTime(2026, 6, 16, 9, 30),
              activityPeakSteps: 480,
              stepGoalReachedAt: DateTime(2026, 6, 16, 16, 45),
              stepGoalReachedIsPrecise: true,
            ),
            currentSteps: 6320,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final model = container.read(dailyRhythmUiModelProvider);
    expect(model, isNotNull);
    expect(model!.nodes, hasLength(2));
    expect(
      model.nodes.map((DailyRhythmNode node) => node.title).toList(),
      <String>['活动良好', '步数达标'],
    );
  });

  test('非精确活动节点不展示具体事件时间', () {
    final container = ProviderContainer(
      overrides: <Override>[
        dailyRhythmClockProvider.overrideWith(
          (Ref ref) => DateTime(2026, 6, 16, 18),
        ),
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) => _readyData(
            rhythmSignals: DailyRhythmSignals(
              activityPeakAt: DateTime(2026, 6, 16, 18),
              activityPeakSteps: 10086,
              activityPeakIsPrecise: false,
              stepGoalReachedAt: DateTime(2026, 6, 16, 18),
              stepGoalReachedIsPrecise: false,
            ),
            currentSteps: 10086,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final model = container.read(dailyRhythmUiModelProvider);
    expect(model, isNotNull);
    final activity = model!.nodes.firstWhere(
      (DailyRhythmNode node) => node.dimension == DailyRhythmDimension.activity,
    );
    final stepGoal = model.nodes.firstWhere(
      (DailyRhythmNode node) => node.title == '步数达标',
    );
    expect(activity.showEventTime, isFalse);
    expect(stepGoal.showEventTime, isFalse);
  });

  test('窗口外的节点不应出现在节奏轴模型中', () {
    final container = ProviderContainer(
      overrides: <Override>[
        dailyRhythmClockProvider.overrideWith(
          (Ref ref) => DateTime(2026, 6, 16, 12),
        ),
        overviewReadyDataStateProvider.overrideWith(
          (Ref ref) => _readyData(
            rhythmSignals: DailyRhythmSignals(
              activityPeakAt: DateTime(2026, 6, 16, 9, 30),
              activityPeakSteps: 480,
              sedentaryStartAt: DateTime(2026, 6, 16, 14, 30),
              sedentaryLongestMinutes: 65,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final model = container.read(dailyRhythmUiModelProvider);
    expect(model, isNotNull);
    expect(model!.nodes, hasLength(1));
    expect(model.nodes.single.dimension, DailyRhythmDimension.activity);
  });

  test('早间节点被 6:00 裁掉时应扩窗保留节奏轴', () {
    final model = buildDailyRhythmUiModel(
      dashboard: DashboardSnapshot(
        generatedAt: DateTime(2026, 6, 16, 9),
        healthScore: HealthScoreBreakdown(
          stepScore: 81,
          sedentaryScore: 92,
          screenScore: 88,
          totalScore: 87,
        ),
        stepCard: const DashboardStepCard(
          currentSteps: 4860,
          goalSteps: 6000,
          achievementPercent: 81,
        ),
        sedentaryCard: const DashboardSedentaryCard(
          totalMinutes: 0,
          longestSingleMinutes: 0,
        ),
        screenCard: const DashboardScreenCard(
          totalMinutes: 0,
          yesterdayDeltaMinutes: 0,
          changeDirection: DashboardChangeDirection.steady,
        ),
        environmentSnapshot: DashboardEnvironmentSnapshot(
          lightLabel: '舒适',
          noiseLabel: '正常',
        ),
        dailyAdviceBubble: DailyAdviceBubble(
          text: 'test',
          source: DailyAdviceSource.fallback,
        ),
        rhythmSignals: DailyRhythmSignals(
          activityPeakAt: DateTime(2026, 6, 16, 5, 30),
          activityPeakSteps: 480,
        ),
        hasRealData: true,
      ),
      missingDimensions: const <String>[],
      calendarDay: DateTime(2026, 6, 16),
      windowEnd: DateTime(2026, 6, 16, 12),
    );

    expect(model, isNotNull);
    expect(model!.windowStart, DateTime(2026, 6, 16, 5));
    expect(model.nodes, hasLength(1));
  });
}

OverviewReadyData _readyData({
  required DailyRhythmSignals rhythmSignals,
  int currentSteps = 4860,
}) {
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
        currentSteps: currentSteps,
        goalSteps: 6000,
        achievementPercent: ((currentSteps / 6000) * 100).round().clamp(0, 100),
      ),
      sedentaryCard: DashboardSedentaryCard(
        totalMinutes: 96,
        longestSingleMinutes: 65,
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
      rhythmSignals: rhythmSignals,
      hasRealData: true,
      hasReminderHistory: true,
    ),
    permissionStatuses: <PermissionType, PermissionGrantStatus>{
      PermissionType.motion: PermissionGrantStatus.granted,
      PermissionType.location: PermissionGrantStatus.granted,
      PermissionType.microphone: PermissionGrantStatus.granted,
      PermissionType.notification: PermissionGrantStatus.granted,
      PermissionType.usageAccess: PermissionGrantStatus.granted,
      PermissionType.healthConnect: PermissionGrantStatus.granted,
      PermissionType.backgroundCapture: PermissionGrantStatus.granted,
    },
    missingDimensions: const <String>[],
    reminders: const <ReminderRecord>[],
    preciseDetectionNotice: null,
  );
}
