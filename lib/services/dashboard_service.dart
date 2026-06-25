import 'package:health_monitor/domain/dashboard/daily_rhythm_concentration.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_signals.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

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
    return buildFromInsight(
      insight: insight,
      referenceTime: referenceTime,
    );
  }

  Future<DashboardSnapshot> buildFromInsight({
    required HealthInsightSnapshot insight,
    required DateTime referenceTime,
  }) async {
    final todayScreenMinutes = _screenMinutesForDate(
      input: insight.input,
      date: referenceTime,
    );
    final sedentaryStats = _sedentaryCardStats(insight.input, referenceTime);
    final dashboardMetrics = HealthInsightMetrics(
      stepCount: insight.metrics.stepCount,
      sedentaryMinutes: sedentaryStats.totalMinutes,
      screenMinutes: todayScreenMinutes,
      outdoorMinutes: insight.metrics.outdoorMinutes,
    );
    final healthScore = calculateHealthScore(
      stepCount: dashboardMetrics.stepCount,
      sedentaryMinutes: dashboardMetrics.sedentaryMinutes,
      screenMinutes: dashboardMetrics.screenMinutes,
    );
    final advice = await _buildDailyAdvice(
      referenceTime: referenceTime,
      input: insight.input,
      metrics: dashboardMetrics,
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
        totalMinutes: sedentaryStats.totalMinutes,
        longestSingleMinutes: sedentaryStats.longestMinutes,
      ),
      screenCard: DashboardScreenCard(
        // 洞察输入会同时携带昨日摘要，以便计算“较昨日”变化。
        // 首页卡片展示的是今日值，因此不能直接使用跨摘要累加后的 metrics。
        totalMinutes: todayScreenMinutes,
        longestSingleMinutes: _screenLongestSingleMinutesForDate(
          input: insight.input,
          date: referenceTime,
        ),
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
      rhythmSignals: _buildRhythmSignals(
        input: insight.input,
        referenceTime: referenceTime,
      ),
      hasRealData: insight.hasRealData,
      hasReminderHistory: insight.reminderHistory.isNotEmpty,
    );
  }
}

SedentaryWindowSummary _sedentaryCardStats(
  RuleInput input,
  DateTime referenceTime,
) {
  return summarizeSedentaryForWindow(
    activitySamples: input.activitySamples,
    window: QueryWindow.calendarDay(referenceDate: referenceTime),
    missingDimensions: input.missingDimensions,
  );
}

int _screenMinutesForDate({
  required RuleInput input,
  required DateTime date,
}) {
  return _usageSummaryForDate(input: input, date: date)
          ?.screenOnDuration
          .inMinutes ??
      0;
}

int _screenLongestSingleMinutesForDate({
  required RuleInput input,
  required DateTime date,
}) {
  return _usageSummaryForDate(input: input, date: date)
          ?.longestContinuousUsageDuration
          .inMinutes ??
      0;
}

/// 同一自然日若存在多条 usage 摘要，先合并再取数，避免累计亮屏被重复相加。
DigitalUsageSummary? _usageSummaryForDate({
  required RuleInput input,
  required DateTime date,
}) {
  final dateKey = DateKey.fromDate(date);
  DigitalUsageSummary? merged;
  for (final DigitalUsageSummary summary in input.usageSummaries) {
    if (DateKey.fromDate(summary.date) != dateKey) {
      continue;
    }
    merged = merged == null
        ? summary
        : mergeUsageSummaryPreservingProgress(merged, summary);
  }
  return merged;
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
  final todayMinutes = _screenMinutesForDate(
    input: input,
    date: todayDate,
  );
  final yesterdayMinutes = _screenMinutesForDate(
    input: input,
    date: todayDate.subtract(const Duration(days: 1)),
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

/// 从聚合输入中提取节奏轴各维度的真实事件时刻。
///
/// 只在确有可定位到具体时间的真实样本时填充对应字段；
/// 是否展示节奏轴节点由上层按集中程度过滤。
DailyRhythmSignals _buildRhythmSignals({
  required RuleInput input,
  required DateTime referenceTime,
  int goalSteps = DailyRhythmConcentration.dailyStepGoal,
}) {
  final activityPeak = _resolveActivityPeak(input, referenceTime);
  final sedentaryPeak = _longestSedentarySegment(input, referenceTime);
  final noisePeak = _noisePeakSample(input, referenceTime);
  final digital = _digitalUsageSignal(input, referenceTime);
  final stepGoalReached = _resolveStepGoalReached(
    input,
    referenceTime,
    goalSteps: goalSteps,
  );

  return DailyRhythmSignals(
    activityPeakAt: activityPeak?.at,
    activityPeakSteps: activityPeak?.steps,
    activityPeakIsPrecise: activityPeak?.isPrecise ?? false,
    sedentaryStartAt: sedentaryPeak?.startedAt,
    sedentaryLongestMinutes: sedentaryPeak?.duration.inMinutes,
    noisePeakAt: noisePeak?.capturedAt,
    noisePeakDecibel: noisePeak?.decibel,
    digitalUsageAt: digital.at,
    digitalUsageIsPrecise: digital.isPrecise,
    digitalLongestSessionMinutes: digital.longestSessionMinutes,
    stepGoalReachedAt: stepGoalReached?.at,
    stepGoalReachedIsPrecise: stepGoalReached?.isPrecise ?? false,
  );
}

bool _isSameDay(DateTime a, DateTime b) =>
    DateKey.fromDate(a) == DateKey.fromDate(b);

class _ActivityPeak {
  const _ActivityPeak({
    required this.at,
    required this.steps,
    this.isPrecise = true,
  });

  final DateTime at;
  final int steps;
  final bool isPrecise;
}

class _StepGoalReached {
  const _StepGoalReached({
    required this.at,
    required this.isPrecise,
  });

  final DateTime at;
  final bool isPrecise;
}

/// 从带逐步数样本中推算首次达到 [goalSteps] 的时刻；无逐步数时降级到当前参考时刻。
_StepGoalReached? _resolveStepGoalReached(
  RuleInput input,
  DateTime referenceTime, {
  required int goalSteps,
}) {
  if (input.totalSteps < goalSteps) {
    return null;
  }
  final stepsForDay = _stepsForDay(input, referenceTime);
  if (stepsForDay < goalSteps) {
    return null;
  }

  final timedSamples = input.confidentActivitySamples
      .where(
        (ActivitySample sample) =>
            _isSameDay(sample.capturedAt, referenceTime) &&
            sample.stepCount > 0,
      )
      .toList()
    ..sort(
      (ActivitySample left, ActivitySample right) {
        final timeCompare = left.capturedAt.compareTo(right.capturedAt);
        if (timeCompare != 0) {
          return timeCompare;
        }
        // 同一小时内 Health Connect 桶优先于实时增量样本，保证达标时刻更稳定。
        final leftIsHealthConnect =
            left.source == MotionSampleSource.healthConnectHourly;
        final rightIsHealthConnect =
            right.source == MotionSampleSource.healthConnectHourly;
        if (leftIsHealthConnect == rightIsHealthConnect) {
          return 0;
        }
        return leftIsHealthConnect ? -1 : 1;
      },
    );

  var cumulative = 0;
  for (final ActivitySample sample in timedSamples) {
    cumulative += sample.stepCount;
    if (cumulative >= goalSteps) {
      return _StepGoalReached(at: sample.capturedAt, isPrecise: true);
    }
  }

  // 总步数已达标但逐步数样本累计不足：优先用走跑集中时段估计，避免落到刷新时刻。
  final hourlyFallback = _activityPeakFromHourlyMotion(input, referenceTime);
  if (hourlyFallback != null) {
    return _StepGoalReached(at: hourlyFallback.at, isPrecise: false);
  }
  if (timedSamples.isNotEmpty) {
    return _StepGoalReached(
      at: timedSamples.last.capturedAt,
      isPrecise: false,
    );
  }
  return _StepGoalReached(
    at: _fallbackRhythmTime(referenceTime),
    isPrecise: false,
  );
}

/// 当日最活跃时刻：优先取步数最高的可信走/跑样本；
/// 传感器融合链路默认不写逐步数时，退化为最长连续走/跑片段起点，
/// 并按中等步速估算步数供集中度判定。
_ActivityPeak? _resolveActivityPeak(
  RuleInput input,
  DateTime referenceTime,
) {
  ActivitySample? peakByHealthConnect;
  ActivitySample? peakBySteps;
  for (final ActivitySample sample in input.confidentActivitySamples) {
    if (!_isSameDay(sample.capturedAt, referenceTime)) {
      continue;
    }
    if (sample.type != ActivityType.walking &&
        sample.type != ActivityType.running) {
      continue;
    }
    if (sample.stepCount <= 0) {
      continue;
    }
    if (sample.source == MotionSampleSource.healthConnectHourly) {
      if (peakByHealthConnect == null ||
          sample.stepCount > peakByHealthConnect.stepCount) {
        peakByHealthConnect = sample;
      }
      continue;
    }
    if (peakBySteps == null || sample.stepCount > peakBySteps.stepCount) {
      peakBySteps = sample;
    }
  }
  if (peakByHealthConnect != null) {
    return _ActivityPeak(
      at: peakByHealthConnect.capturedAt,
      steps: peakByHealthConnect.stepCount,
    );
  }
  if (peakBySteps != null) {
    return _ActivityPeak(
      at: peakBySteps.capturedAt,
      steps: peakBySteps.stepCount,
    );
  }

  final segment = _longestActiveMovementSegment(input, referenceTime);
  if (segment != null) {
    final estimatedSteps = _estimateStepsFromMovementDuration(segment.duration);
    if (estimatedSteps >= DailyRhythmConcentration.minActivityPeakSteps) {
      return _ActivityPeak(
        at: segment.startedAt,
        steps: estimatedSteps,
      );
    }
  }

  if (input.totalSteps >= DailyRhythmConcentration.minActivityPeakSteps) {
    final hourlyFallback = _activityPeakFromHourlyMotion(input, referenceTime);
    if (hourlyFallback != null) {
      return hourlyFallback;
    }
    final stepsForDay = _stepsForDay(input, referenceTime);
    if (stepsForDay >= DailyRhythmConcentration.dailyStepGoal) {
      return _ActivityPeak(
        at: _fallbackRhythmTime(referenceTime),
        steps: stepsForDay,
        isPrecise: false,
      );
    }
  }
  return null;
}

int _stepsForDay(RuleInput input, DateTime referenceTime) {
  final dayKey = DateKey.fromDate(referenceTime);
  final metricSteps = input.dailyMetricsList
      .where((DailyMetrics metrics) => DateKey.fromDate(metrics.date) == dayKey)
      .fold<int>(
          0, (int total, DailyMetrics metrics) => total + metrics.stepCount);
  final activitySteps = input.activitySamples
      .where((ActivitySample sample) =>
          _isSameDay(sample.capturedAt, referenceTime))
      .fold<int>(
          0, (int total, ActivitySample sample) => total + sample.stepCount);
  return metricSteps > activitySteps ? metricSteps : activitySteps;
}

DateTime _fallbackRhythmTime(DateTime referenceTime) {
  return DateTime(
    referenceTime.year,
    referenceTime.month,
    referenceTime.day,
    referenceTime.hour,
    referenceTime.minute,
  );
}

class _MovementSegment {
  const _MovementSegment({
    required this.startedAt,
    required this.endedAt,
    required this.duration,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;

  bool canMerge(_MovementSegment other) {
    return !other.startedAt.isAfter(
      endedAt.add(SedentaryActivitySegment.maxGap),
    );
  }

  _MovementSegment merge(_MovementSegment other) {
    final mergedEnd = other.endedAt.isAfter(endedAt) ? other.endedAt : endedAt;
    return _MovementSegment(
      startedAt: startedAt,
      endedAt: mergedEnd,
      duration: duration + other.duration,
    );
  }
}

_MovementSegment? _longestActiveMovementSegment(
  RuleInput input,
  DateTime referenceTime,
) {
  final sorted = input.confidentActivitySamples.toList()
    ..sort(
      (ActivitySample left, ActivitySample right) =>
          left.capturedAt.compareTo(right.capturedAt),
    );
  _MovementSegment? current;
  _MovementSegment? longest;

  for (final ActivitySample sample in sorted) {
    if (!_isSameDay(sample.capturedAt, referenceTime)) {
      continue;
    }
    if (sample.type != ActivityType.walking &&
        sample.type != ActivityType.running) {
      continue;
    }

    final candidate = _MovementSegment(
      startedAt: sample.capturedAt,
      endedAt: sample.capturedAt.add(sample.duration),
      duration: sample.duration,
    );
    if (current == null) {
      current = candidate;
      continue;
    }
    if (current.canMerge(candidate)) {
      current = current.merge(candidate);
      continue;
    }
    if (longest == null || current.duration > longest.duration) {
      longest = current;
    }
    current = candidate;
  }

  if (current != null &&
      (longest == null || current.duration > longest.duration)) {
    longest = current;
  }
  return longest;
}

int _estimateStepsFromMovementDuration(Duration duration) {
  // 约 100 步/分钟，仅供节奏轴集中度判定，不作为精确计步。
  return (duration.inSeconds / 60 * 100).round();
}

/// 当日步数已达标但缺少逐步数样本时，取走/跑最集中的小时作为代表时刻。
_ActivityPeak? _activityPeakFromHourlyMotion(
  RuleInput input,
  DateTime referenceTime,
) {
  final buckets = <int, Duration>{};
  for (final ActivitySample sample in input.confidentActivitySamples) {
    if (!_isSameDay(sample.capturedAt, referenceTime)) {
      continue;
    }
    if (sample.type != ActivityType.walking &&
        sample.type != ActivityType.running) {
      continue;
    }
    final hour = sample.capturedAt.hour;
    buckets[hour] = (buckets[hour] ?? Duration.zero) + sample.duration;
  }
  if (buckets.isEmpty) {
    return null;
  }
  final best = buckets.entries.reduce(
    (MapEntry<int, Duration> left, MapEntry<int, Duration> right) =>
        left.value >= right.value ? left : right,
  );
  if (best.value < const Duration(minutes: 1)) {
    return null;
  }
  return _ActivityPeak(
    at: DateTime(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
      best.key,
    ),
    steps: input.totalSteps,
  );
}

/// 当日最长连续久坐片段，作为姿势维度的代表时刻。
SedentaryActivitySegment? _longestSedentarySegment(
  RuleInput input,
  DateTime referenceTime,
) {
  final window = QueryWindow.calendarDay(referenceDate: referenceTime);
  SedentaryActivitySegment? longest;
  for (final SedentaryActivitySegment segment
      in SedentaryActivitySegment.clippedToWindow(
    input.sedentarySegments,
    window,
  )) {
    if (longest == null || segment.duration > longest.duration) {
      longest = segment;
    }
  }
  return longest;
}

/// 当日分贝最高的噪音样本，作为环境维度的代表时刻。
NoiseSample? _noisePeakSample(RuleInput input, DateTime referenceTime) {
  NoiseSample? peak;
  for (final NoiseSample sample in input.noiseSamples) {
    if (!_isSameDay(sample.capturedAt, referenceTime)) {
      continue;
    }
    if (peak == null || sample.decibel > peak.decibel) {
      peak = sample;
    }
  }
  return peak;
}

class _DigitalUsageSignal {
  const _DigitalUsageSignal({
    this.at,
    this.isPrecise = false,
    this.longestSessionMinutes,
  });

  final DateTime? at;
  final bool isPrecise;
  final int? longestSessionMinutes;
}

/// 计算数字习惯节点的代表时刻。
///
/// 优先使用“当日最长连续使用片段”的真实起点（来自带时间戳的使用事件采集链路）；
/// 若没有逐时刻信息但夜间使用偏长，则退化到夜间代表时刻；
/// 完全无法定位时返回空信号，由 UI 层使用降级占位时刻，不伪造精确时间。
_DigitalUsageSignal _digitalUsageSignal(
  RuleInput input,
  DateTime referenceTime,
) {
  final today = _usageSummaryForDate(input: input, date: referenceTime);
  if (today == null) {
    return const _DigitalUsageSignal();
  }

  final preciseStart = today.longestContinuousUsageStartedAt;
  final longestDuration = today.longestContinuousUsageDuration;
  if (preciseStart != null && longestDuration > Duration.zero) {
    return _DigitalUsageSignal(
      at: preciseStart,
      isPrecise: true,
      longestSessionMinutes: longestDuration.inMinutes,
    );
  }

  if (today.nighttimeUsageDuration >= const Duration(minutes: 30)) {
    return _DigitalUsageSignal(
      at: DateTime(
        referenceTime.year,
        referenceTime.month,
        referenceTime.day,
        22,
      ),
    );
  }

  return const _DigitalUsageSignal();
}
