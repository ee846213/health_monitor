enum UsageCategory {
  social,
  video,
  reading,
  tools,
  productivity,
  unknown,
}

enum DigitalUsageSource {
  androidUsageStats,
  lifecycleAlternative,
}

enum UsageDataCompleteness {
  full,
  partialGap,
  degraded,
}

class DigitalUsageSummary {
  const DigitalUsageSummary({
    required this.date,
    required this.screenOnDuration,
    required this.unlockCount,
    required this.nighttimeUsageDuration,
    required this.focusSessionBreakCount,
    required this.topCategory,
    this.viewCount = 0,
    this.longestContinuousUsageDuration = Duration.zero,
    this.longestContinuousUsageStartedAt,
    this.source = DigitalUsageSource.lifecycleAlternative,
    this.completeness = UsageDataCompleteness.full,
  });

  final DateTime date;
  final Duration screenOnDuration;
  final int unlockCount;
  final Duration nighttimeUsageDuration;
  final int focusSessionBreakCount;
  final UsageCategory topCategory;
  final int viewCount;
  final Duration longestContinuousUsageDuration;

  /// 当日最长连续使用片段的起始时刻。
  ///
  /// 与 [longestContinuousUsageDuration] 配套，提供可定位到具体时间的代表时刻，
  /// 供节奏轴把“数字习惯”节点放到真实发生的时间上。
  /// 仅有按日聚合而无逐时刻信息时为 null，由上层降级处理。
  final DateTime? longestContinuousUsageStartedAt;

  final DigitalUsageSource source;
  final UsageDataCompleteness completeness;

  int get sessionCount => viewCount;
  int get effectiveViewCount => viewCount > 0 ? viewCount : unlockCount;
  bool get isDegraded => completeness == UsageDataCompleteness.degraded;
  bool get hasPartialGap => completeness == UsageDataCompleteness.partialGap;

  bool get hasNightRisk => nighttimeUsageDuration >= const Duration(hours: 1);

  // 碎片化查看优先使用“查看会话数 + 中断次数”语义；
  // 旧数据没有 viewCount 时，再回退到 unlockCount。
  bool get hasFragmentedUsage =>
      effectiveViewCount >= 40 || focusSessionBreakCount >= 12;
}
