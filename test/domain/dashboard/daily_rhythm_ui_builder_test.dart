import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_signals.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_builder.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';

void main() {
  test('节奏轴节点 value 只展示当前片段时长，不展示累计亮屏或累计久坐', () {
    final day = DateTime(2026, 6, 22);
    final model = buildDailyRhythmUiModel(
      dashboard: DashboardSnapshot(
        generatedAt: day,
        healthScore: HealthScoreBreakdown(
          stepScore: 80,
          sedentaryScore: 80,
          screenScore: 80,
          totalScore: 80,
        ),
        stepCard: const DashboardStepCard(
          currentSteps: 4860,
          goalSteps: 6000,
          achievementPercent: 81,
        ),
        sedentaryCard: const DashboardSedentaryCard(
          totalMinutes: 96,
          longestSingleMinutes: 65,
        ),
        screenCard: const DashboardScreenCard(
          totalMinutes: 132,
          longestSingleMinutes: 54,
          yesterdayDeltaMinutes: 0,
          changeDirection: DashboardChangeDirection.steady,
        ),
        environmentSnapshot: DashboardEnvironmentSnapshot(
          lightLabel: '舒适',
          noiseLabel: '正常',
        ),
        dailyAdviceBubble: DailyAdviceBubble(
          text: '测试',
          source: DailyAdviceSource.fallback,
        ),
        rhythmSignals: DailyRhythmSignals(
          activityPeakAt: DateTime(2026, 6, 22, 9, 30),
          activityPeakSteps: 480,
          sedentaryStartAt: DateTime(2026, 6, 22, 14, 30),
          sedentaryLongestMinutes: 65,
          digitalUsageAt: DateTime(2026, 6, 22, 20, 40),
          digitalUsageIsPrecise: true,
          digitalLongestSessionMinutes: 54,
        ),
        hasRealData: true,
        hasReminderHistory: false,
      ),
      missingDimensions: const <String>[],
      calendarDay: day,
      windowEnd: DateTime(2026, 6, 22, 21),
    );

    expect(model, isNotNull);
    final digital = model!.nodes.singleWhere(
      (DailyRhythmNode node) => node.dimension == DailyRhythmDimension.digital,
    );
    expect(digital.value, '连续看屏 54 分钟');
    expect(digital.value, isNot(contains('累计')));
    expect(digital.value, isNot(contains('2.2')));

    final posture = model.nodes.singleWhere(
      (DailyRhythmNode node) => node.dimension == DailyRhythmDimension.posture,
    );
    expect(posture.value, '久坐 65 分钟');
    expect(posture.value, isNot(contains('1.6')));

    final activity = model.nodes.singleWhere(
      (DailyRhythmNode node) =>
          node.dimension == DailyRhythmDimension.activity &&
          node.title == '活动积累中',
    );
    expect(activity.value, '约 480 步');
    expect(activity.value, isNot(contains('4860')));
  });
}
