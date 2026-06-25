import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

/// 规则引擎的统一输入。
///
/// 聚合所有领域仓储查询结果，为规则引擎提供单一入口。
/// 区分全量输入和降级输入（部分维度因权限或数据缺失不可用）。
class RuleInput {
  const RuleInput({
    required this.window,
    required this.activitySamples,
    required this.locationSummaries,
    required this.noiseSamples,
    this.ambientLightSamples = const <AmbientLightSample>[],
    required this.usageSummaries,
    required this.dailyMetricsList,
    required this.missingDimensions,
  });

  final QueryWindow window;
  final List<ActivitySample> activitySamples;
  final List<LocationSummary> locationSummaries;
  final List<NoiseSample> noiseSamples;
  final List<AmbientLightSample> ambientLightSamples;
  final List<DigitalUsageSummary> usageSummaries;
  final List<DailyMetrics> dailyMetricsList;
  final List<String> missingDimensions;

  /// 是否为全量输入。
  bool get isFullInput => missingDimensions.isEmpty;

  /// 是否为降级输入。
  bool get isDegraded => missingDimensions.isNotEmpty;

  /// 活动样本数量。
  int get activityCount => activitySamples.length;

  /// 规则层只消费高置信度活动样本，避免把噪声直接映射成提醒。
  List<ActivitySample> get confidentActivitySamples {
    return activitySamples
        .where((ActivitySample sample) => sample.isConfident)
        .toList(growable: false);
  }

  /// 静坐样本比例。
  double get stationaryRatio {
    if (activitySamples.isEmpty) return 0;
    return activitySamples
            .where((s) => s.type == ActivityType.stationary)
            .length /
        activitySamples.length;
  }

  /// 片段化后的有效久坐片段。
  List<SedentaryActivitySegment> get sedentarySegments {
    final sorted = confidentActivitySamples.toList()
      ..sort(
        (ActivitySample left, ActivitySample right) =>
            left.capturedAt.compareTo(right.capturedAt),
      );
    final segments = <SedentaryActivitySegment>[];
    SedentaryActivitySegment? current;

    for (final ActivitySample sample in sorted) {
      if (sample.type != ActivityType.stationary) {
        if (current != null) {
          segments.add(current);
        }
        current = null;
        continue;
      }

      final candidate = SedentaryActivitySegment.fromSample(sample);
      if (current == null) {
        current = candidate;
        continue;
      }

      if (current.canMerge(candidate)) {
        current = current.merge(candidate);
        continue;
      }

      segments.add(current);
      current = candidate;
    }

    if (current != null) {
      segments.add(current);
    }
    return _coalesceSedentarySegments(segments)
        .where((SedentaryActivitySegment segment) => segment.isEffective)
        .toList(growable: false);
  }

  /// 将间隔不超过 [SedentaryActivitySegment.maxGap] 的相邻片段再合并一轮，
  /// 避免短暂起身把同一段久坐拆得过碎。
  static List<SedentaryActivitySegment> _coalesceSedentarySegments(
    List<SedentaryActivitySegment> segments,
  ) {
    return SedentaryActivitySegment.coalesce(segments);
  }

  /// 总步数合计。
  int get totalSteps {
    if (dailyMetricsList.isNotEmpty) {
      return dailyMetricsList.fold<int>(
        0,
        (int total, DailyMetrics metrics) => total + metrics.stepCount,
      );
    }
    return activitySamples.fold(0, (sum, s) => sum + s.stepCount);
  }

  /// 噪音平均分贝。
  double get averageNoiseDb {
    if (noiseSamples.isEmpty) return 0;
    return noiseSamples.fold(0.0, (sum, s) => sum + s.decibel) /
        noiseSamples.length;
  }

  /// 光照平均 lux。
  double get averageLightLux {
    if (ambientLightSamples.isEmpty) return 0;
    return ambientLightSamples.fold(
          0.0,
          (double sum, AmbientLightSample sample) => sum + sample.lux,
        ) /
        ambientLightSamples.length;
  }

  /// 屏幕亮起时长合计（分钟）。
  double get totalScreenMinutes {
    if (usageSummaries.isEmpty) return 0;
    return usageSummaries.fold(
      0.0,
      (sum, s) => sum + s.screenOnDuration.inMinutes.toDouble(),
    );
  }

  /// 解锁次数合计。
  int get totalUnlockCount {
    if (usageSummaries.isEmpty) return 0;
    return usageSummaries.fold(0, (sum, s) => sum + s.unlockCount);
  }

  /// 查看会话数合计。
  int get totalViewCount {
    if (usageSummaries.isEmpty) return 0;
    return usageSummaries.fold(
      0,
      (int sum, DigitalUsageSummary summary) =>
          sum + summary.effectiveViewCount,
    );
  }

  int get usageDayCount => usageSummaries.length;

  /// 单日平均查看次数。
  double get averageDailyViewCount {
    if (usageDayCount == 0) {
      return 0;
    }
    return totalViewCount / usageDayCount;
  }

  /// 夜间亮屏时长合计（分钟）。
  double get totalNightScreenMinutes {
    if (usageSummaries.isEmpty) return 0;
    return usageSummaries.fold(
      0.0,
      (double sum, DigitalUsageSummary summary) =>
          sum + summary.nighttimeUsageDuration.inMinutes,
    );
  }

  /// 单日平均夜间使用时长（分钟）。
  double get averageDailyNightScreenMinutes {
    if (usageDayCount == 0) {
      return 0;
    }
    return totalNightScreenMinutes / usageDayCount;
  }

  /// 专注中断次数合计。
  int get totalFocusSessionBreakCount {
    if (usageSummaries.isEmpty) return 0;
    return usageSummaries.fold(
      0,
      (int sum, DigitalUsageSummary summary) =>
          sum + summary.focusSessionBreakCount,
    );
  }

  /// 单日平均激活过密次数。
  double get averageDailyFocusSessionBreakCount {
    if (usageDayCount == 0) {
      return 0;
    }
    return totalFocusSessionBreakCount / usageDayCount;
  }

  Duration get longestContinuousUsageDuration {
    if (usageSummaries.isEmpty) {
      return Duration.zero;
    }
    return usageSummaries.fold(
      Duration.zero,
      (Duration current, DigitalUsageSummary summary) =>
          summary.longestContinuousUsageDuration > current
              ? summary.longestContinuousUsageDuration
              : current,
    );
  }

  int get longestContinuousUsageMinutes =>
      longestContinuousUsageDuration.inMinutes;

  DigitalUsageSource? get primaryUsageSource {
    if (usageSummaries.isEmpty) {
      return null;
    }
    return usageSummaries.last.source;
  }

  UsageDataCompleteness get usageCompleteness {
    if (usageSummaries.any((DigitalUsageSummary item) => item.isDegraded)) {
      return UsageDataCompleteness.degraded;
    }
    if (usageSummaries.any((DigitalUsageSummary item) => item.hasPartialGap)) {
      return UsageDataCompleteness.partialGap;
    }
    return UsageDataCompleteness.full;
  }

  /// 是否存在明显碎片化查看。
  bool get hasFragmentedUsage {
    return totalViewCount >= 40 || totalFocusSessionBreakCount >= 12;
  }

  Duration daytimeDarkLightDuration() {
    return _ambientLightDuration(
      daypart: EnvironmentDaypart.daytime,
      level: AmbientLightLevel.dark,
    );
  }

  Duration daytimeComfortableLightDuration() {
    return _ambientLightDuration(
      daypart: EnvironmentDaypart.daytime,
      level: AmbientLightLevel.comfortable,
    );
  }

  Duration daytimeBrightLightDuration() {
    return _ambientLightDuration(
      daypart: EnvironmentDaypart.daytime,
      level: AmbientLightLevel.bright,
    );
  }

  Duration nightLoudNoiseDuration() {
    return _noiseDuration(
      daypart: EnvironmentDaypart.night,
      level: NoiseLevel.loud,
    );
  }

  Duration nightModerateNoiseDuration() {
    return _noiseDuration(
      daypart: EnvironmentDaypart.night,
      level: NoiseLevel.moderate,
    );
  }

  EnvironmentDaypart daypartFor(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 6 && hour < 18) {
      return EnvironmentDaypart.daytime;
    }
    if (hour >= 18 && hour < 22) {
      return EnvironmentDaypart.evening;
    }
    return EnvironmentDaypart.night;
  }

  /// 步行时长合计（分钟）。
  double get totalWalkingMinutes {
    if (confidentActivitySamples.isEmpty) return 0;
    return confidentActivitySamples
        .where((ActivitySample sample) => sample.type == ActivityType.walking)
        .fold<double>(
          0,
          (double total, ActivitySample sample) =>
              total + sample.duration.inMinutes,
        );
  }

  /// 户外时长合计（分钟）。
  double get totalOutdoorMinutes {
    if (locationSummaries.isEmpty) return 0;
    return locationSummaries.fold(
      0.0,
      (sum, s) => sum + s.outdoorDuration.inMinutes.toDouble(),
    );
  }

  /// 久坐时长合计（分钟）。
  double get totalSedentaryMinutes {
    if (dailyMetricsList.isEmpty) return 0;
    return dailyMetricsList.fold(
      0.0,
      (sum, s) => sum + s.sedentaryDuration.inMinutes.toDouble(),
    );
  }

  /// 检查某维度是否可用。
  bool isDimensionAvailable(String dimension) {
    if (missingDimensions.contains(dimension)) return false;
    switch (dimension) {
      case 'activity':
        return activitySamples.isNotEmpty;
      case 'location':
        return locationSummaries.isNotEmpty;
      case 'noise':
        return noiseSamples.isNotEmpty;
      case 'light':
        return ambientLightSamples.isNotEmpty;
      case 'digital_usage':
        return usageSummaries.isNotEmpty;
      case 'daily_metrics':
        return dailyMetricsList.isNotEmpty;
      default:
        return false;
    }
  }

  Duration _ambientLightDuration({
    required EnvironmentDaypart daypart,
    required AmbientLightLevel level,
  }) {
    return ambientLightSamples
        .where(
          (AmbientLightSample sample) =>
              daypartFor(sample.capturedAt) == daypart && sample.level == level,
        )
        .fold<Duration>(
          Duration.zero,
          (Duration total, AmbientLightSample sample) =>
              total + sample.duration,
        );
  }

  Duration _noiseDuration({
    required EnvironmentDaypart daypart,
    required NoiseLevel level,
  }) {
    return noiseSamples
        .where(
          (NoiseSample sample) =>
              daypartFor(sample.capturedAt) == daypart && sample.level == level,
        )
        .fold<Duration>(
          Duration.zero,
          (Duration total, NoiseSample sample) => total + sample.duration,
        );
  }
}

class SedentaryActivitySegment {
  const SedentaryActivitySegment({
    required this.startedAt,
    required this.endedAt,
    required this.duration,
  });

  factory SedentaryActivitySegment.fromSample(ActivitySample sample) {
    return SedentaryActivitySegment(
      startedAt: sample.capturedAt,
      endedAt: sample.capturedAt.add(sample.duration),
      duration: sample.duration,
    );
  }

  static const Duration minimumDuration = Duration(minutes: 3);
  /// 相邻静坐样本或片段之间允许合并的最大间隔。
  static const Duration maxGap = Duration(minutes: 3);

  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;

  bool get isEffective => duration >= minimumDuration;

  bool canMerge(SedentaryActivitySegment other) {
    return !other.startedAt.isAfter(effectiveEndedAt.add(maxGap));
  }

  SedentaryActivitySegment merge(SedentaryActivitySegment other) {
    final mergedStart =
        startedAt.isBefore(other.startedAt) ? startedAt : other.startedAt;
    final mergedWallEnd =
        endedAt.isAfter(other.endedAt) ? endedAt : other.endedAt;
    final mergedEffectiveEnd = effectiveEndedAt.isAfter(other.effectiveEndedAt)
        ? effectiveEndedAt
        : other.effectiveEndedAt;
    final Duration mergedDuration;
    if (!other.startedAt.isAfter(effectiveEndedAt)) {
      // 时间重叠时取并集，避免同一段静坐被拆成多条重叠记录。
      mergedDuration = mergedEffectiveEnd.difference(mergedStart);
    } else {
      mergedDuration = duration + other.duration;
    }
    return SedentaryActivitySegment(
      startedAt: mergedStart,
      endedAt: mergedWallEnd,
      duration: mergedDuration,
    );
  }

  /// 合并后的真实静坐结束时刻（不含中间短暂起身间隔）。
  DateTime get effectiveEndedAt => startedAt.add(duration);

  /// 供展示使用：结束时刻与 [duration] 对齐。
  SedentaryActivitySegment forDisplay() {
    final end = effectiveEndedAt;
    if (endedAt == end) {
      return this;
    }
    return SedentaryActivitySegment(
      startedAt: startedAt,
      endedAt: end,
      duration: duration,
    );
  }

  /// 将片段裁剪到 [window] 内；与窗口无交集时返回 null。
  SedentaryActivitySegment? clipTo(QueryWindow window) {
    final display = forDisplay();
    final effectiveEnd = display.effectiveEndedAt;
    if (!effectiveEnd.isAfter(window.startAt) ||
        !display.startedAt.isBefore(window.endAt)) {
      return null;
    }
    final clippedStart = display.startedAt.isBefore(window.startAt)
        ? window.startAt
        : display.startedAt;
    final clippedEnd =
        effectiveEnd.isAfter(window.endAt) ? window.endAt : effectiveEnd;
    if (!clippedEnd.isAfter(clippedStart)) {
      return null;
    }
    final clippedDuration = clippedEnd.difference(clippedStart);
    return SedentaryActivitySegment(
      startedAt: clippedStart,
      endedAt: clippedEnd,
      duration: clippedDuration,
    );
  }

  /// 按查询窗口裁剪久坐片段；跨自然日时会拆成多段。
  static List<SedentaryActivitySegment> clippedToWindow(
    Iterable<SedentaryActivitySegment> segments,
    QueryWindow window,
  ) {
    final clipped = <SedentaryActivitySegment>[];
    final days = window.dailyDates();
    for (final SedentaryActivitySegment segment in segments) {
      if (days.length <= 1) {
        final part = segment.clipTo(window);
        if (part != null) {
          clipped.add(part);
        }
        continue;
      }
      for (final DateTime day in days) {
        final part = segment.clipTo(
          QueryWindow.calendarDay(referenceDate: day),
        );
        if (part != null) {
          clipped.add(part);
        }
      }
    }
    clipped.sort(
      (SedentaryActivitySegment left, SedentaryActivitySegment right) =>
          left.startedAt.compareTo(right.startedAt),
    );
    return coalesce(clipped);
  }

  /// 合并相邻或重叠的久坐片段（展示层使用真实静坐结束时刻判定间隔）。
  static List<SedentaryActivitySegment> coalesce(
    List<SedentaryActivitySegment> segments,
  ) {
    if (segments.isEmpty) {
      return const <SedentaryActivitySegment>[];
    }
    final merged = <SedentaryActivitySegment>[segments.first];
    for (var index = 1; index < segments.length; index++) {
      final next = segments[index];
      final previous = merged.last;
      if (previous.canMerge(next)) {
        merged[merged.length - 1] = previous.merge(next);
      } else {
        merged.add(next);
      }
    }
    return merged;
  }
}

/// 久坐窗口汇总，供首页卡片与详情浮层共用同一口径。
class SedentaryWindowSummary {
  const SedentaryWindowSummary({
    required this.totalDuration,
    required this.longestDuration,
    required this.segments,
  });

  final Duration totalDuration;
  final Duration longestDuration;
  final List<SedentaryActivitySegment> segments;

  int get totalMinutes => totalDuration.inMinutes;
  int get longestMinutes => longestDuration.inMinutes;
}

/// 基于活动样本生成裁剪后的久坐统计，避免原始指标或跨天样本污染展示。
SedentaryWindowSummary summarizeSedentaryForWindow({
  required List<ActivitySample> activitySamples,
  required QueryWindow window,
  List<String> missingDimensions = const <String>[],
}) {
  final scopedSamples = activitySamples
      .where((ActivitySample sample) => window.contains(sample.capturedAt))
      .toList(growable: false);
  final input = RuleInput(
    window: window,
    activitySamples: scopedSamples,
    locationSummaries: const <LocationSummary>[],
    noiseSamples: const <NoiseSample>[],
    ambientLightSamples: const <AmbientLightSample>[],
    usageSummaries: const <DigitalUsageSummary>[],
    dailyMetricsList: const <DailyMetrics>[],
    missingDimensions: missingDimensions,
  );
  final segments = SedentaryActivitySegment.clippedToWindow(
    input.sedentarySegments,
    window,
  )
      .where((SedentaryActivitySegment segment) => segment.isEffective)
      .toList(growable: false);
  var totalDuration = Duration.zero;
  var longestDuration = Duration.zero;
  for (final SedentaryActivitySegment segment in segments) {
    totalDuration += segment.duration;
    if (segment.duration > longestDuration) {
      longestDuration = segment.duration;
    }
  }
  return SedentaryWindowSummary(
    totalDuration: totalDuration,
    longestDuration: longestDuration,
    segments: segments,
  );
}
