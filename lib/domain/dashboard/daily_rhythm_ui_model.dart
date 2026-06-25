import 'package:health_monitor/domain/dashboard/daily_rhythm_window.dart';

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
    this.showEventTime = true,
  });

  final DateTime time;
  final DailyRhythmDimension dimension;
  final String title;
  final String value;
  final String reason;
  final String suggestion;
  final bool isAvailable;

  /// 为 false 时节奏轴节点不展示具体时刻（无法精确定位达标时间时使用）。
  final bool showEventTime;
}

class DailyRhythmUiModel {
  const DailyRhythmUiModel({
    required this.generatedAt,
    required this.nodes,
    required this.currentTime,
    required this.windowStart,
    required this.hasRealData,
  });

  final DateTime generatedAt;
  final List<DailyRhythmNode> nodes;
  final DateTime currentTime;
  final DateTime windowStart;
  final bool hasRealData;

  DailyRhythmWindow get window =>
      DailyRhythmWindow(start: windowStart, end: currentTime);
}
