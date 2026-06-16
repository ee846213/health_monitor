import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.generatedAt,
    this.healthScore,
    this.trendSnapshot,
    this.reminderPlan,
    this.hasRealData = false,
    this.hasReminderHistory = false,
  });

  final DateTime generatedAt;
  final HealthScoreBreakdown? healthScore;
  final TrendSnapshot? trendSnapshot;
  final ReminderDeliveryPlan? reminderPlan;
  final bool hasRealData;
  final bool hasReminderHistory;
}
