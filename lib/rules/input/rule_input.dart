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
    required this.usageSummaries,
    required this.dailyMetricsList,
    required this.missingDimensions,
  });

  final QueryWindow window;
  final List<ActivitySample> activitySamples;
  final List<LocationSummary> locationSummaries;
  final List<NoiseSample> noiseSamples;
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
        if (current != null && current.isEffective) {
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

      if (current.isEffective) {
        segments.add(current);
      }
      current = candidate;
    }

    if (current != null && current.isEffective) {
      segments.add(current);
    }
    return segments;
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
    return noiseSamples.fold(0.0, (sum, s) => sum + s.decibel) / noiseSamples.length;
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

  /// 夜间亮屏时长合计（分钟）。
  double get totalNightScreenMinutes {
    if (usageSummaries.isEmpty) return 0;
    return usageSummaries.fold(
      0.0,
      (double sum, DigitalUsageSummary summary) =>
          sum + summary.nighttimeUsageDuration.inMinutes,
    );
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

  /// 是否存在明显碎片化查看。
  bool get hasFragmentedUsage {
    return totalUnlockCount >= 40 || totalFocusSessionBreakCount >= 12;
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
      case 'digital_usage':
        return usageSummaries.isNotEmpty;
      case 'daily_metrics':
        return dailyMetricsList.isNotEmpty;
      default:
        return false;
    }
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
  static const Duration maxGap = Duration(seconds: 30);

  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;

  bool get isEffective => duration >= minimumDuration;

  bool canMerge(SedentaryActivitySegment other) {
    return !other.startedAt.isAfter(endedAt.add(maxGap));
  }

  SedentaryActivitySegment merge(SedentaryActivitySegment other) {
    final mergedEnd = other.endedAt.isAfter(endedAt) ? other.endedAt : endedAt;
    return SedentaryActivitySegment(
      startedAt: startedAt,
      endedAt: mergedEnd,
      duration: mergedEnd.difference(startedAt),
    );
  }
}
