enum PostureType {
  upright,
  neckDown,
  reclined,
  walkingWhileLooking,
}

enum PostureRiskLevel {
  low,
  medium,
  high,
}

class PostureSample {
  const PostureSample({
    required this.capturedAt,
    required this.duration,
    required this.posture,
    required this.riskLevel,
    required this.continuousHold,
  });

  final DateTime capturedAt;
  final Duration duration;
  final PostureType posture;
  final PostureRiskLevel riskLevel;
  final Duration continuousHold;

  bool get isHighRisk => riskLevel == PostureRiskLevel.high;

  // 这里把“高风险”与“持续持机足够久”同时作为提醒条件，
  // 是为了给后续规则层留下明确边界，避免仅凭瞬时姿态就触发打扰。
  bool get requiresReminder {
    return isHighRisk && continuousHold >= const Duration(minutes: 10);
  }
}
