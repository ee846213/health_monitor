class HealthScoreBreakdown {
  const HealthScoreBreakdown({
    required this.stepScore,
    required this.sedentaryScore,
    required this.screenScore,
    required this.totalScore,
  });

  final int stepScore;
  final int sedentaryScore;
  final int screenScore;
  final int totalScore;
}

HealthScoreBreakdown calculateHealthScore({
  required int stepCount,
  required int sedentaryMinutes,
  required int screenMinutes,
}) {
  final stepScore = _calculateStepScore(stepCount);
  final sedentaryScore = _calculatePenaltyScore(
    actualMinutes: sedentaryMinutes,
    idealUpperBoundMinutes: 120,
    zeroScoreAtMinutes: 360,
  );
  final screenScore = _calculateScreenScore(
    screenMinutes: screenMinutes,
    targetMinutes: 180,
  );
  final totalScore =
      ((stepScore * 0.4) + (sedentaryScore * 0.4) + (screenScore * 0.2))
          .round();

  return HealthScoreBreakdown(
    stepScore: stepScore,
    sedentaryScore: sedentaryScore,
    screenScore: screenScore,
    totalScore: totalScore,
  );
}

int _calculateStepScore(int stepCount) {
  if (stepCount <= 0) {
    return 0;
  }
  final score = (stepCount / 6000 * 100).round();
  return score.clamp(0, 100);
}

int _calculatePenaltyScore({
  required int actualMinutes,
  required int idealUpperBoundMinutes,
  required int zeroScoreAtMinutes,
}) {
  if (actualMinutes <= idealUpperBoundMinutes) {
    return 100;
  }
  if (actualMinutes >= zeroScoreAtMinutes) {
    return 0;
  }

  final score =
      ((zeroScoreAtMinutes - actualMinutes) /
              (zeroScoreAtMinutes - idealUpperBoundMinutes) *
              100)
          .round();
  return score.clamp(0, 100);
}

int _calculateScreenScore({
  required int screenMinutes,
  required int targetMinutes,
}) {
  if (screenMinutes <= 0) {
    return 0;
  }
  final score = (screenMinutes / targetMinutes * 100).round();
  return score.clamp(0, 100);
}
