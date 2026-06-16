import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

typedef LoadInsightSnapshot = Future<HealthInsightSnapshot> Function({
  required QueryWindow window,
  DateTime? referenceTime,
});

typedef BuildDashboardDailyAdvice = Future<DailyAdviceBubble> Function({
  required DateTime referenceTime,
  required RuleInput input,
  required HealthInsightMetrics metrics,
  required List<RuleVerdict> verdicts,
  required EnvironmentOverview? environmentOverview,
});

class DashboardService {
  DashboardService({
    required LoadInsightSnapshot loadInsightSnapshot,
    required BuildDashboardDailyAdvice buildDailyAdvice,
  })  : _loadInsightSnapshot = loadInsightSnapshot,
        _buildDailyAdvice = buildDailyAdvice;

  final LoadInsightSnapshot _loadInsightSnapshot;
  final BuildDashboardDailyAdvice _buildDailyAdvice;

  Future<DashboardSnapshot> build({
    required DateTime referenceTime,
  }) async {
    final insight = await _loadInsightSnapshot(
      window: QueryWindow.recentDay(referenceTime: referenceTime),
      referenceTime: referenceTime,
    );
    final healthScore = calculateHealthScore(
      stepCount: insight.metrics.stepCount,
      sedentaryMinutes: insight.metrics.sedentaryMinutes,
      screenMinutes: insight.metrics.screenMinutes,
    );
    final advice = await _buildDailyAdvice(
      referenceTime: referenceTime,
      input: insight.input,
      metrics: insight.metrics,
      verdicts: insight.verdicts,
      environmentOverview: insight.environmentOverview,
    );

    return DashboardSnapshot(
      generatedAt: referenceTime,
      healthScore: healthScore,
      stepCard: DashboardStepCard(
        currentSteps: insight.metrics.stepCount,
        goalSteps: 6000,
        achievementPercent:
            ((insight.metrics.stepCount / 6000) * 100).round().clamp(0, 100),
      ),
      sedentaryCard: DashboardSedentaryCard(
        totalMinutes: insight.metrics.sedentaryMinutes,
        longestSingleMinutes: insight.input.sedentarySegments.fold<int>(
          0,
          (current, segment) => segment.duration.inMinutes > current
              ? segment.duration.inMinutes
              : current,
        ),
      ),
      screenCard: DashboardScreenCard(
        totalMinutes: insight.metrics.screenMinutes,
        yesterdayDeltaMinutes: _screenDeltaFromPreviousDay(
          input: insight.input,
          todayDate: referenceTime,
        ),
        changeDirection: _screenDirectionFromPreviousDay(
          input: insight.input,
          todayDate: referenceTime,
        ),
      ),
      environmentSnapshot: DashboardEnvironmentSnapshot(
        lightLabel: _lightLabel(insight.input.ambientLightSamples),
        noiseLabel: _noiseLabel(insight.input.noiseSamples),
      ),
      dailyAdviceBubble: advice,
      hasRealData: insight.hasRealData,
      hasReminderHistory: insight.reminderHistory.isNotEmpty,
    );
  }
}

String _lightLabel(List<AmbientLightSample> samples) {
  if (samples.isEmpty) {
    return '等待采集';
  }
  final latest = samples.last;
  switch (latest.level) {
    case AmbientLightLevel.dark:
      return '过暗';
    case AmbientLightLevel.comfortable:
      return '舒适';
    case AmbientLightLevel.bright:
      return '明亮';
  }
}

String _noiseLabel(List<NoiseSample> samples) {
  if (samples.isEmpty) {
    return '等待采集';
  }
  final latest = samples.last;
  switch (latest.level) {
    case NoiseLevel.quiet:
      return '安静';
    case NoiseLevel.moderate:
      return '正常';
    case NoiseLevel.loud:
      return '嘈杂';
  }
}

int _screenDeltaFromPreviousDay({
  required RuleInput input,
  required DateTime todayDate,
}) {
  final todayKey = DateKey.fromDate(todayDate);
  final yesterdayKey = DateKey.fromDate(
    todayDate.subtract(const Duration(days: 1)),
  );
  final todayMinutes = input.usageSummaries
      .where((item) => DateKey.fromDate(item.date) == todayKey)
      .fold<int>(
        0,
        (sum, item) => sum + item.screenOnDuration.inMinutes,
      );
  final yesterdayMinutes = input.usageSummaries
      .where((item) => DateKey.fromDate(item.date) == yesterdayKey)
      .fold<int>(
        0,
        (sum, item) => sum + item.screenOnDuration.inMinutes,
      );
  return todayMinutes - yesterdayMinutes;
}

DashboardChangeDirection _screenDirectionFromPreviousDay({
  required RuleInput input,
  required DateTime todayDate,
}) {
  final delta = _screenDeltaFromPreviousDay(
    input: input,
    todayDate: todayDate,
  );
  if (delta > 0) {
    return DashboardChangeDirection.up;
  }
  if (delta < 0) {
    return DashboardChangeDirection.down;
  }
  return DashboardChangeDirection.steady;
}
