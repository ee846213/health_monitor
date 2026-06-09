enum UsageCategory {
  social,
  video,
  reading,
  tools,
  productivity,
  unknown,
}

class DigitalUsageSummary {
  const DigitalUsageSummary({
    required this.date,
    required this.screenOnDuration,
    required this.unlockCount,
    required this.nighttimeUsageDuration,
    required this.focusSessionBreakCount,
    required this.topCategory,
  });

  final DateTime date;
  final Duration screenOnDuration;
  final int unlockCount;
  final Duration nighttimeUsageDuration;
  final int focusSessionBreakCount;
  final UsageCategory topCategory;

  bool get hasNightRisk => nighttimeUsageDuration >= const Duration(hours: 1);

  // “碎片化查看”优先用解锁次数和专注中断次数联合判断，
  // 这样 Android 全量能力和 iPhone 替代指标都能复用同一套语义。
  bool get hasFragmentedUsage => unlockCount >= 40 || focusSessionBreakCount >= 12;
}
