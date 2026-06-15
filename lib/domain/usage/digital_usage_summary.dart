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
