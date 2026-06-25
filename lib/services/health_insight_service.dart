import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/notification/reminder_category.dart';
import 'package:health_monitor/domain/notification/reminder_preferences.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/domain/usage/screen_usage_habit_summary.dart';
import 'package:health_monitor/rules/engine/activity_rules.dart';
import 'package:health_monitor/rules/engine/environment_rules.dart';
import 'package:health_monitor/rules/engine/posture_rules.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/engine/usage_rules.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/rules/input/rule_input_service.dart';
import 'package:health_monitor/services/android_risk_event_bridge.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/ambient_light_sample_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/reminder_preferences_repository.dart';
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
    required this.environmentOverview,
    required this.screenUsageHabitSummary,
    required this.generatedReminders,
    required this.reminderHistory,
    required this.hasRealData,
  });

  final RuleInput input;
  final List<RuleVerdict> verdicts;
  final HealthInsightMetrics metrics;
  final EnvironmentOverview? environmentOverview;
  final ScreenUsageHabitSummary? screenUsageHabitSummary;
  final List<ReminderRecord> generatedReminders;
  final List<ReminderRecord> reminderHistory;
  final bool hasRealData;
}

class HealthInsightService {
  HealthInsightService({
    required ActivityRepository activityRepository,
    required AmbientLightSampleRepository ambientLightRepository,
    required LocationSummaryRepository locationRepository,
    required NoiseSampleRepository noiseRepository,
    required UsageSummaryRepository usageRepository,
    required MetricsRepository metricsRepository,
    required Future<ReminderRepository> Function() reminderRepositoryLoader,
    Future<ReminderPreferencesRepository> Function()?
        reminderPreferencesRepositoryLoader,
    required AndroidRiskEventBridge androidRiskEventBridge,
    required AndroidUsageStatsBridge androidUsageStatsBridge,
    DateTime Function()? now,
  })  : _inputService = RuleInputService(
          activityRepository: activityRepository,
          ambientLightRepository: ambientLightRepository,
          locationRepository: locationRepository,
          noiseRepository: noiseRepository,
          usageRepository: usageRepository,
          metricsRepository: metricsRepository,
        ),
        _usageRepository = usageRepository,
        _reminderRepositoryLoader = reminderRepositoryLoader,
        _reminderPreferencesRepositoryLoader =
            reminderPreferencesRepositoryLoader,
        _androidRiskEventBridge = androidRiskEventBridge,
        _androidUsageStatsBridge = androidUsageStatsBridge,
        _now = now ?? DateTime.now;

  final RuleInputService _inputService;
  final UsageSummaryRepository _usageRepository;
  final Future<ReminderRepository> Function() _reminderRepositoryLoader;
  final Future<ReminderPreferencesRepository> Function()?
      _reminderPreferencesRepositoryLoader;
  final AndroidRiskEventBridge _androidRiskEventBridge;
  final AndroidUsageStatsBridge _androidUsageStatsBridge;
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
    final environmentOverview = _buildEnvironmentOverview(input);
    final screenUsageHabitSummary = _buildScreenUsageHabitSummary(input);
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
      environmentOverview: environmentOverview,
      screenUsageHabitSummary: screenUsageHabitSummary,
      generatedReminders: generatedReminders,
      reminderHistory: reminderHistory,
      hasRealData: _hasRealData(input),
    );
  }

  Future<void> persistRuleReminders({
    DateTime? referenceTime,
  }) async {
    final now = referenceTime ?? _now();
    final preferences = await _readReminderPreferences();
    if (!preferences.masterEnabled) {
      return;
    }
    final snapshot = await buildSnapshot(
      window: QueryWindow.recentDay(referenceTime: now),
      referenceTime: now,
    );
    final allowed = snapshot.generatedReminders
        .where(
          (ReminderRecord record) =>
              preferences.isReminderTypeAllowed(record.reminderTypeKey),
        )
        .toList(growable: false);
    if (allowed.isEmpty) {
      return;
    }
    final reminderRepository = await _reminderRepositoryLoader();
    await reminderRepository.saveAll(allowed);
  }

  Future<List<ReminderRecord>> syncNativeWalkingScreenRiskEvents() async {
    final events = await _androidRiskEventBridge.drainWalkingScreenRiskEvents();
    if (events.isEmpty) {
      return const <ReminderRecord>[];
    }

    final preferences = await _readReminderPreferences();
    if (!preferences.isCategoryEnabled(ReminderCategory.walkingScreen)) {
      return const <ReminderRecord>[];
    }

    final records = events
        .map(
          (event) => ReminderRecord.fromWalkingScreenRiskEvent(
            eventId: event.eventId,
            triggeredAt: event.occurredAt,
            notificationDelivered: event.notificationDelivered,
          ),
        )
        .toList(growable: false);
    final reminderRepository = await _reminderRepositoryLoader();
    await reminderRepository.saveAll(records);
    return records;
  }

  Future<void> syncAndroidUsageSummaries({
    required QueryWindow window,
    DateTime? referenceTime,
  }) async {
    final capability = await _androidUsageStatsBridge.getCapabilityStatus();
    if (!capability.canReadUsageStats) {
      return;
    }

    final summaries = <DigitalUsageSummary>[
      ...await _androidUsageStatsBridge.drainPendingSummaries(),
    ];
    final now = referenceTime ?? _now();
    final dailySummary = await _androidUsageStatsBridge.readDailySummary(
      referenceTime: now,
    );
    if (dailySummary != null) {
      summaries.add(dailySummary);
    }
    if (window.dailyDates().length > 1) {
      summaries.addAll(
        await _androidUsageStatsBridge.readRangeSummaries(window: window),
      );
    }

    if (summaries.isEmpty) {
      return;
    }
    await _usageRepository.upsertAll(_dedupeUsageSummaries(summaries));
  }

  Future<ReminderPreferences> _readReminderPreferences() async {
    final loader = _reminderPreferencesRepositoryLoader;
    if (loader == null) {
      return ReminderPreferences.defaults;
    }
    final repository = await loader();
    return repository.read();
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
      input.isDimensionAvailable('light') ||
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

EnvironmentOverview? _buildEnvironmentOverview(RuleInput input) {
  final hasNoise = input.isDimensionAvailable('noise');
  final hasLight = input.isDimensionAvailable('light');
  if (!hasNoise && !hasLight) {
    return null;
  }

  final daytimeDarkMinutes = input.daytimeDarkLightDuration().inMinutes;
  final daytimeComfortableMinutes =
      input.daytimeComfortableLightDuration().inMinutes;
  final daytimeBrightMinutes = input.daytimeBrightLightDuration().inMinutes;
  final nightLoudMinutes = input.nightLoudNoiseDuration().inMinutes;
  final nightModerateMinutes = input.nightModerateNoiseDuration().inMinutes;

  final daytimeLightSummary = hasLight
      ? '白天过暗 $daytimeDarkMinutes 分钟，舒适 '
          '$daytimeComfortableMinutes 分钟，明亮 $daytimeBrightMinutes 分钟。'
      : '当前没有可用的真实光照数据。';
  final nightNoiseSummary = hasNoise
      ? '夜间嘈杂 $nightLoudMinutes 分钟，普通波动 '
          '$nightModerateMinutes 分钟。'
      : '当前没有可用的噪音数据。';

  if (daytimeDarkMinutes >= 60 && nightLoudMinutes >= 30) {
    return EnvironmentOverview(
      headline: '环境切换偏紧绷',
      detail: '白天光线偏暗，同时夜间噪音偏高，恢复性的环境还不够稳定。',
      daytimeLightSummary: daytimeLightSummary,
      nightNoiseSummary: nightNoiseSummary,
      primaryConcern: EnvironmentPrimaryConcern.mixed,
    );
  }

  if (nightLoudMinutes >= 30) {
    return EnvironmentOverview(
      headline: '夜间环境偏嘈杂',
      detail: '夜间连续嘈杂时段偏长，容易影响晚间放松和睡前收尾。',
      daytimeLightSummary: daytimeLightSummary,
      nightNoiseSummary: nightNoiseSummary,
      primaryConcern: EnvironmentPrimaryConcern.highNoise,
    );
  }

  if (daytimeDarkMinutes >= 60) {
    return EnvironmentOverview(
      headline: '白天光线偏暗',
      detail: '白天处在低照度环境的时间偏长，容易让节律和专注感一起变钝。',
      daytimeLightSummary: daytimeLightSummary,
      nightNoiseSummary: nightNoiseSummary,
      primaryConcern: EnvironmentPrimaryConcern.lowLight,
    );
  }

  return EnvironmentOverview(
    headline: '环境整体平稳',
    detail: '白天光线和夜间噪音都没有出现特别突出的风险段。',
    daytimeLightSummary: daytimeLightSummary,
    nightNoiseSummary: nightNoiseSummary,
    primaryConcern: EnvironmentPrimaryConcern.none,
  );
}

ScreenUsageHabitSummary? _buildScreenUsageHabitSummary(RuleInput input) {
  if (!input.isDimensionAvailable('digital_usage')) {
    return null;
  }

  final checkingLevel = _levelForValue(
    input.averageDailyViewCount,
    elevatedThreshold: 25,
    highThreshold: 40,
  );
  final nightLevel = _levelForValue(
    input.averageDailyNightScreenMinutes,
    elevatedThreshold: 30,
    highThreshold: 60,
  );
  final activationLevel = _levelForValue(
    input.averageDailyFocusSessionBreakCount,
    elevatedThreshold: 8,
    highThreshold: 12,
  );
  final longestMinutes = input.longestContinuousUsageMinutes;
  final sourceLabel = switch (input.primaryUsageSource) {
    DigitalUsageSource.androidUsageStats => 'Android Usage Stats 全量统计',
    DigitalUsageSource.lifecycleAlternative => '替代指标估计',
    null => '暂无来源',
  };
  final qualityNote = switch (input.usageCompleteness) {
    UsageDataCompleteness.partialGap => '部分时段存在缺口，摘要已按可用数据生成。',
    UsageDataCompleteness.degraded => '当前为降级模式，屏幕习惯按替代指标估计。',
    UsageDataCompleteness.full => null,
  };

  if (nightLevel == UsageHabitLevel.high) {
    return ScreenUsageHabitSummary(
      headline: '深夜使用偏长',
      supportingDetail:
          '最近平均每天夜间看屏 ${input.averageDailyNightScreenMinutes.round()} 分钟，建议给睡前留一点收尾时间。',
      checkingFrequencyLevel: checkingLevel,
      nightUsageLevel: nightLevel,
      activationDensityLevel: activationLevel,
      longestSessionMinutes: longestMinutes,
      sourceLabel: sourceLabel,
      qualityNote: qualityNote,
    );
  }

  if (checkingLevel == UsageHabitLevel.high) {
    return ScreenUsageHabitSummary(
      headline: '查看频率偏高',
      supportingDetail:
          '最近平均每天查看 ${input.averageDailyViewCount.round()} 次，节奏偏碎，原始解锁约 ${input.totalUnlockCount} 次。',
      checkingFrequencyLevel: checkingLevel,
      nightUsageLevel: nightLevel,
      activationDensityLevel: activationLevel,
      longestSessionMinutes: longestMinutes,
      sourceLabel: sourceLabel,
      qualityNote: qualityNote,
    );
  }

  if (activationLevel == UsageHabitLevel.high) {
    return ScreenUsageHabitSummary(
      headline: '时段激活过密',
      supportingDetail:
          '最近平均每天有 ${input.averageDailyFocusSessionBreakCount.round()} 次短间隔再次查看，容易切碎注意力。',
      checkingFrequencyLevel: checkingLevel,
      nightUsageLevel: nightLevel,
      activationDensityLevel: activationLevel,
      longestSessionMinutes: longestMinutes,
      sourceLabel: sourceLabel,
      qualityNote: qualityNote,
    );
  }

  if (longestMinutes >= 45) {
    return ScreenUsageHabitSummary(
      headline: '最长连续使用偏长',
      supportingDetail: '单次最长连续使用约 $longestMinutes 分钟，其余查看节奏整体还算平稳。',
      checkingFrequencyLevel: checkingLevel,
      nightUsageLevel: nightLevel,
      activationDensityLevel: activationLevel,
      longestSessionMinutes: longestMinutes,
      sourceLabel: sourceLabel,
      qualityNote: qualityNote,
    );
  }

  return ScreenUsageHabitSummary(
    headline: '查看节奏平稳',
    supportingDetail:
        '最近平均每天查看 ${input.averageDailyViewCount.round()} 次，夜间使用 ${input.averageDailyNightScreenMinutes.round()} 分钟，整体收尾较平稳。',
    checkingFrequencyLevel: checkingLevel,
    nightUsageLevel: nightLevel,
    activationDensityLevel: activationLevel,
    longestSessionMinutes: longestMinutes,
    sourceLabel: sourceLabel,
    qualityNote: qualityNote,
  );
}

UsageHabitLevel _levelForValue(
  double value, {
  required double elevatedThreshold,
  required double highThreshold,
}) {
  if (value >= highThreshold) {
    return UsageHabitLevel.high;
  }
  if (value >= elevatedThreshold) {
    return UsageHabitLevel.elevated;
  }
  return UsageHabitLevel.steady;
}

List<DigitalUsageSummary> _dedupeUsageSummaries(
  List<DigitalUsageSummary> summaries,
) {
  final keyed = <String, DigitalUsageSummary>{};
  for (final summary in summaries) {
    final dateKey =
        '${summary.date.year}-${summary.date.month}-${summary.date.day}';
    final existing = keyed[dateKey];
    keyed[dateKey] = existing == null
        ? summary
        : mergeUsageSummaryPreservingProgress(existing, summary);
  }
  return keyed.values.toList(growable: false);
}
