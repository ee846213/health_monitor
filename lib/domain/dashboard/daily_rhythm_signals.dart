/// 生活节奏轴的真实事件时刻信号。
///
/// 节奏轴需要把四个维度的节点落在“真实发生的时间”上，而不是写死的示例时刻。
/// 这里只承载从聚合输入中提取出的代表性时刻，页面层据此放置节点，
/// 当某维度缺乏可定位到具体时间的真实样本时，对应字段为 null；
/// 是否展示节奏轴节点由 [DailyRhythmConcentration] 在上层判定。
class DailyRhythmSignals {
  const DailyRhythmSignals({
    this.activityPeakAt,
    this.activityPeakSteps,
    this.activityPeakIsPrecise = true,
    this.sedentaryStartAt,
    this.sedentaryLongestMinutes,
    this.noisePeakAt,
    this.noisePeakDecibel,
    this.digitalUsageAt,
    this.digitalUsageIsPrecise = false,
    this.digitalLongestSessionMinutes,
    this.stepGoalReachedAt,
    this.stepGoalReachedIsPrecise = false,
  });

  const DailyRhythmSignals.empty()
      : activityPeakAt = null,
        activityPeakSteps = null,
        activityPeakIsPrecise = false,
        sedentaryStartAt = null,
        sedentaryLongestMinutes = null,
        noisePeakAt = null,
        noisePeakDecibel = null,
        digitalUsageAt = null,
        digitalUsageIsPrecise = false,
        digitalLongestSessionMinutes = null,
        stepGoalReachedAt = null,
        stepGoalReachedIsPrecise = false;

  /// 当日活动最活跃片段（步数最高的可信运动样本）的发生时刻。
  final DateTime? activityPeakAt;

  /// 活动最活跃片段对应的步数，用于解释节点依据。
  final int? activityPeakSteps;

  /// [activityPeakAt] 是否来自真实分时活动样本。
  ///
  /// 为 false 时表示只有当日总步数可用，节奏轴只能把活动节点放在刷新时刻附近，
  /// 不应向用户展示为真实的运动发生时间。
  final bool activityPeakIsPrecise;

  /// 最长连续久坐片段的起始时刻。
  final DateTime? sedentaryStartAt;

  /// 最长连续久坐片段时长（分钟），用于解释节点依据。
  final int? sedentaryLongestMinutes;

  /// 噪音最高样本的发生时刻。
  final DateTime? noisePeakAt;

  /// 噪音最高样本的分贝值，用于解释节点依据。
  final double? noisePeakDecibel;

  /// 数字使用的代表时刻。
  ///
  /// 优先取“当日最长连续使用片段”的起点（精确时刻，[digitalUsageIsPrecise] 为 true）；
  /// 若仅有按日聚合且夜间使用偏长，则退化到一个夜间代表时刻（[digitalUsageIsPrecise] 为 false）；
  /// 完全无法定位时保持 null，由上层使用降级占位时刻。
  final DateTime? digitalUsageAt;

  /// [digitalUsageAt] 是否来自真实会话起点（而非夜间降级代表时刻）。
  final bool digitalUsageIsPrecise;

  /// 当日最长连续使用片段时长（分钟），用于解释精确节点的依据。
  final int? digitalLongestSessionMinutes;

  /// 当日步数首次达到目标的时刻。
  final DateTime? stepGoalReachedAt;

  /// [stepGoalReachedAt] 是否来自逐步数累计（而非当日已达标但无法还原的降级时刻）。
  final bool stepGoalReachedIsPrecise;
}
