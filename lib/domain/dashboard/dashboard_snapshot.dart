import 'package:health_monitor/domain/dashboard/daily_rhythm_signals.dart';
import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';

enum DailyAdviceSource {
  fallback,
  cache,
  llm,
}

class DailyAdviceBubble {
  const DailyAdviceBubble({
    required this.text,
    required this.source,
  });

  final String text;
  final DailyAdviceSource source;
}

class DashboardStepCard {
  const DashboardStepCard({
    required this.currentSteps,
    required this.goalSteps,
    required this.achievementPercent,
  });

  final int currentSteps;
  final int goalSteps;
  final int achievementPercent;
}

class DashboardSedentaryCard {
  const DashboardSedentaryCard({
    required this.totalMinutes,
    required this.longestSingleMinutes,
  });

  final int totalMinutes;
  final int longestSingleMinutes;
}

enum DashboardChangeDirection {
  up,
  down,
  steady,
}

class DashboardScreenCard {
  const DashboardScreenCard({
    required this.totalMinutes,
    required this.yesterdayDeltaMinutes,
    required this.changeDirection,
    this.longestSingleMinutes = 0,
  });

  final int totalMinutes;
  final int longestSingleMinutes;
  final int yesterdayDeltaMinutes;
  final DashboardChangeDirection changeDirection;
}

class DashboardEnvironmentSnapshot {
  const DashboardEnvironmentSnapshot({
    required this.lightLabel,
    required this.noiseLabel,
  });

  final String lightLabel;
  final String noiseLabel;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.generatedAt,
    required this.healthScore,
    required this.stepCard,
    required this.sedentaryCard,
    required this.screenCard,
    required this.environmentSnapshot,
    required this.dailyAdviceBubble,
    this.rhythmSignals = const DailyRhythmSignals.empty(),
    this.trendSnapshot,
    this.reminderPlan,
    this.hasRealData = false,
    this.hasReminderHistory = false,
  });

  final DateTime generatedAt;
  final HealthScoreBreakdown healthScore;
  final DashboardStepCard stepCard;
  final DashboardSedentaryCard sedentaryCard;
  final DashboardScreenCard screenCard;
  final DashboardEnvironmentSnapshot environmentSnapshot;
  final DailyAdviceBubble dailyAdviceBubble;
  final DailyRhythmSignals rhythmSignals;
  final TrendSnapshot? trendSnapshot;
  final ReminderDeliveryPlan? reminderPlan;
  final bool hasRealData;
  final bool hasReminderHistory;
}
