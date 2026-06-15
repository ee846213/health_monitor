enum UsageHabitLevel {
  steady,
  elevated,
  high,
}

class ScreenUsageHabitSummary {
  const ScreenUsageHabitSummary({
    required this.headline,
    required this.supportingDetail,
    required this.checkingFrequencyLevel,
    required this.nightUsageLevel,
    required this.activationDensityLevel,
    required this.longestSessionMinutes,
    required this.sourceLabel,
    this.qualityNote,
  });

  final String headline;
  final String supportingDetail;
  final UsageHabitLevel checkingFrequencyLevel;
  final UsageHabitLevel nightUsageLevel;
  final UsageHabitLevel activationDensityLevel;
  final int longestSessionMinutes;
  final String sourceLabel;
  final String? qualityNote;
}
