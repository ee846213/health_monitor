import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/rules/engine/activity_rules.dart';
import 'package:health_monitor/rules/engine/environment_rules.dart';
import 'package:health_monitor/rules/engine/posture_rules.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/engine/usage_rules.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/rules/input/rule_input_service.dart';
import 'package:health_monitor/services/android_risk_event_bridge.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

class HealthInsightMetrics {
  const HealthInsightMetrics({
    required this.stepCount,
    required this.sedentaryMinutes,
    required this.screenMinutes,
    required this.outdoorMinutes,
  });

  final int stepCount;
  final int sedentaryMinutes;
  final int screenMinutes;
  final int outdoorMinutes;
}

class HealthInsightSnapshot {
  const HealthInsightSnapshot({
    required this.input,
    required this.verdicts,
    required this.metrics,
    required this.generatedReminders,
    required this.reminderHistory,
    required this.hasRealData,
  });

  final RuleInput input;
  final List<RuleVerdict> verdicts;
  final HealthInsightMetrics metrics;
  final List<ReminderRecord> generatedReminders;
  final List<ReminderRecord> reminderHistory;
  final bool hasRealData;
}

class HealthInsightService {
  HealthInsightService({
    required ActivityRepository activityRepository,
    required LocationSummaryRepository locationRepository,
    required NoiseSampleRepository noiseRepository,
    required UsageSummaryRepository usageRepository,
    required MetricsRepository metricsRepository,
    required Future<ReminderRepository> Function() reminderRepositoryLoader,
    required AndroidRiskEventBridge androidRiskEventBridge,
    DateTime Function()? now,
  }) : _inputService = RuleInputService(
         activityRepository: activityRepository,
         locationRepository: locationRepository,
         noiseRepository: noiseRepository,
         usageRepository: usageRepository,
         metricsRepository: metricsRepository,
       ),
       _reminderRepositoryLoader = reminderRepositoryLoader,
       _androidRiskEventBridge = androidRiskEventBridge,
       _now = now ?? DateTime.now;

  final RuleInputService _inputService;
  final Future<ReminderRepository> Function() _reminderRepositoryLoader;
  final AndroidRiskEventBridge _androidRiskEventBridge;
  final DateTime Function() _now;

  static const List<HealthRule> _rules = <HealthRule>[
    ActivityRule(),
    PostureRule(),
    UsageRule(),
    EnvironmentRule(),
  ];

  Future<HealthInsightSnapshot> buildSnapshot({
    required QueryWindow window,
    DateTime? referenceTime,
  }) async {
    final now = referenceTime ?? _now();
    final input = await _inputService.buildInput(window: window);
    final verdicts = _evaluateRules(input);
    final metrics = HealthInsightMetrics(
      stepCount: input.totalSteps,
      sedentaryMinutes: _estimateSedentaryMinutes(input),
      screenMinutes: input.totalScreenMinutes.round(),
      outdoorMinutes: input.totalOutdoorMinutes.round(),
    );
    final generatedReminders = _buildReminderRecords(verdicts, now);
    final reminderRepository = await _reminderRepositoryLoader();
    final reminderHistory = await reminderRepository.listRecentDays(
      7,
      referenceDate: now,
    );

    return HealthInsightSnapshot(
      input: input,
      verdicts: verdicts,
      metrics: metrics,
      generatedReminders: generatedReminders,
      reminderHistory: reminderHistory,
      hasRealData: _hasRealData(input),
    );
  }

  Future<void> persistRuleReminders({
    DateTime? referenceTime,
  }) async {
    final now = referenceTime ?? _now();
    final snapshot = await buildSnapshot(
      window: QueryWindow.recentDay(referenceTime: now),
      referenceTime: now,
    );
    if (snapshot.generatedReminders.isEmpty) {
      return;
    }
    final reminderRepository = await _reminderRepositoryLoader();
    await reminderRepository.saveAll(snapshot.generatedReminders);
  }

  Future<List<ReminderRecord>> syncNativeWalkingScreenRiskEvents() async {
    final events = await _androidRiskEventBridge.drainWalkingScreenRiskEvents();
    if (events.isEmpty) {
      return const <ReminderRecord>[];
    }

    final records = events
        .map(
          (event) => ReminderRecord.fromWalkingScreenRiskEvent(
            eventId: event.eventId,
            triggeredAt: event.occurredAt,
          ),
        )
        .toList(growable: false);
    final reminderRepository = await _reminderRepositoryLoader();
    await reminderRepository.saveAll(records);
    return records;
  }
}

List<RuleVerdict> _evaluateRules(RuleInput input) {
  final verdicts = <RuleVerdict>[];
  for (final HealthRule rule in HealthInsightService._rules) {
    verdicts.addAll(rule.evaluate(input));
  }
  verdicts.sort(_compareVerdictPriority);
  return verdicts;
}

int _compareVerdictPriority(RuleVerdict left, RuleVerdict right) {
  const priority = <String, int>{
    'concern': 0,
    'warning': 1,
    'normal': 2,
  };
  return (priority[left.level] ?? 9).compareTo(priority[right.level] ?? 9);
}

bool _hasRealData(RuleInput input) {
  return input.isDimensionAvailable('activity') ||
      input.isDimensionAvailable('location') ||
      input.isDimensionAvailable('noise') ||
      input.isDimensionAvailable('digital_usage') ||
      input.isDimensionAvailable('daily_metrics');
}

List<ReminderRecord> _buildReminderRecords(
  List<RuleVerdict> verdicts,
  DateTime referenceTime,
) {
  final reminderVerdicts = verdicts
      .where((RuleVerdict verdict) => verdict.shouldRemind)
      .toList(growable: false);

  return List<ReminderRecord>.generate(
    reminderVerdicts.length,
    (int index) => ReminderRecord.fromVerdict(
      verdict: reminderVerdicts[index],
      now: referenceTime.subtract(Duration(minutes: index * 5)),
    ),
    growable: false,
  );
}

int _estimateSedentaryMinutes(RuleInput input) {
  if (input.totalSedentaryMinutes > 0) {
    return input.totalSedentaryMinutes.round();
  }
  return input.sedentarySegments.fold<int>(
    0,
    (int total, SedentaryActivitySegment segment) =>
        total + segment.duration.inMinutes,
  );
}
