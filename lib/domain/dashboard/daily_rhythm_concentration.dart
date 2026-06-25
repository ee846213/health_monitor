import 'package:health_monitor/domain/dashboard/daily_rhythm_signals.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';

/// 节奏轴节点是否达到「足够集中、值得展示」的判定。
///
/// 只在确有可定位时刻且强度超过阈值的维度上落节点，
/// 避免用全天均匀分布的汇总数据伪造节奏轴事件。
class DailyRhythmConcentration {
  const DailyRhythmConcentration._();

  /// 活动峰值样本至少达到的步数。
  static const int minActivityPeakSteps = 200;

  /// 最长连续久坐片段至少持续的分钟数。
  static const int minSedentaryMinutes = 60;

  /// 数字习惯最长连续使用片段至少持续的分钟数（须为精确起点）。
  static const int minDigitalSessionMinutes = 30;

  /// 与首页步数卡片一致的单日步数目标。
  static const int dailyStepGoal = 6000;

  static bool shouldShowActivity(DailyRhythmSignals signals) {
    final peakAt = signals.activityPeakAt;
    if (peakAt == null) {
      return false;
    }
    return (signals.activityPeakSteps ?? 0) >= minActivityPeakSteps;
  }

  /// 当日步数已达标且能定位到代表时刻时展示达标节点。
  static bool shouldShowStepGoalReached(
    DailyRhythmSignals signals, {
    required int currentSteps,
    required int goalSteps,
  }) {
    if (currentSteps < goalSteps) {
      return false;
    }
    return signals.stepGoalReachedAt != null;
  }

  static bool shouldShowPosture(DailyRhythmSignals signals) {
    final startAt = signals.sedentaryStartAt;
    if (startAt == null) {
      return false;
    }
    return (signals.sedentaryLongestMinutes ?? 0) >= minSedentaryMinutes;
  }

  static bool shouldShowDigital(
    DailyRhythmSignals signals, {
    required bool hasScreen,
  }) {
    if (!hasScreen) {
      return false;
    }
    final usageAt = signals.digitalUsageAt;
    if (usageAt == null || !signals.digitalUsageIsPrecise) {
      return false;
    }
    return (signals.digitalLongestSessionMinutes ?? 0) >=
        minDigitalSessionMinutes;
  }

  static bool shouldShowDimension(
    DailyRhythmDimension dimension,
    DailyRhythmSignals signals, {
    required bool hasScreen,
  }) {
    return switch (dimension) {
      DailyRhythmDimension.activity => shouldShowActivity(signals),
      DailyRhythmDimension.posture => shouldShowPosture(signals),
      DailyRhythmDimension.noise => false,
      DailyRhythmDimension.digital =>
        shouldShowDigital(signals, hasScreen: hasScreen),
    };
  }
}
