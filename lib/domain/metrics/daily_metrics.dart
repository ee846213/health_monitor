enum DailyConcern {
  sedentary,
  lowActivity,
  screenOveruse,
  postureRisk,
  highNoiseExposure,
}

class DailyMetrics {
  const DailyMetrics({
    required this.date,
    required this.stepCount,
    required this.sedentaryDuration,
    required this.screenOnDuration,
    required this.outdoorDuration,
    required this.postureRiskCount,
    required this.highNoiseExposureDuration,
  });

  final DateTime date;
  final int stepCount;
  final Duration sedentaryDuration;
  final Duration screenOnDuration;
  final Duration outdoorDuration;
  final int postureRiskCount;
  final Duration highNoiseExposureDuration;

  List<DailyConcern> get primaryConcerns {
    final concerns = <DailyConcern>[];

    if (sedentaryDuration >= const Duration(hours: 6)) {
      concerns.add(DailyConcern.sedentary);
    }
    if (stepCount < 5000 || outdoorDuration < const Duration(minutes: 20)) {
      concerns.add(DailyConcern.lowActivity);
    }
    if (screenOnDuration >= const Duration(hours: 4)) {
      concerns.add(DailyConcern.screenOveruse);
    }

    return concerns;
  }

  bool get isStableDay => primaryConcerns.isEmpty;
}
