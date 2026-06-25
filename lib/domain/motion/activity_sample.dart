enum ActivityType {
  stationary,
  walking,
  running,
  cycling,
  unknown,
}

enum MotionSampleSource {
  sensorFusion,
  platformActivity,
  healthConnectHourly,
  manualFallback,
}

class ActivitySample {
  const ActivitySample({
    required this.capturedAt,
    required this.duration,
    required this.type,
    required this.confidence,
    required this.stepCount,
    required this.source,
  });

  final DateTime capturedAt;
  final Duration duration;
  final ActivityType type;
  final double confidence;
  final int stepCount;
  final MotionSampleSource source;

  bool get isSedentary {
    return type == ActivityType.stationary && duration >= const Duration(minutes: 30);
  }

  // 规则层需要快速过滤掉置信度过低的片段，避免把噪声直接传给提醒逻辑。
  bool get isConfident => confidence >= 0.7;
}
