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

  /// 静坐样本比例。
  double get stationaryRatio {
    if (activitySamples.isEmpty) return 0;
    return activitySamples
            .where((s) => s.type == ActivityType.stationary)
            .length /
        activitySamples.length;
  }

  /// 总步数合计。
  int get totalSteps =>
      activitySamples.fold(0, (sum, s) => sum + s.stepCount);

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
