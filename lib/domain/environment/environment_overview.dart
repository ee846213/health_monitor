enum EnvironmentDaypart {
  daytime,
  evening,
  night,
}

enum EnvironmentPrimaryConcern {
  none,
  lowLight,
  highNoise,
  mixed,
}

class EnvironmentOverview {
  const EnvironmentOverview({
    required this.headline,
    required this.detail,
    required this.daytimeLightSummary,
    required this.nightNoiseSummary,
    required this.primaryConcern,
  });

  final String headline;
  final String detail;
  final String daytimeLightSummary;
  final String nightNoiseSummary;
  final EnvironmentPrimaryConcern primaryConcern;
}
