enum DailyRhythmDimension {
  activity,
  posture,
  noise,
  digital,
}

class DailyRhythmNode {
  const DailyRhythmNode({
    required this.time,
    required this.dimension,
    required this.title,
    required this.value,
    required this.reason,
    required this.suggestion,
    required this.isAvailable,
  });

  final DateTime time;
  final DailyRhythmDimension dimension;
  final String title;
  final String value;
  final String reason;
  final String suggestion;
  final bool isAvailable;
}

class DailyRhythmUiModel {
  const DailyRhythmUiModel({
    required this.generatedAt,
    required this.nodes,
    required this.currentTime,
    required this.hasRealData,
  });

  final DateTime generatedAt;
  final List<DailyRhythmNode> nodes;
  final DateTime currentTime;
  final bool hasRealData;
}
