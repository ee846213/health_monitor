import 'package:health_monitor/domain/motion/activity_sample.dart';

/// 节奏轴步数样本按自然小时对齐，用于 Health Connect 桶与系统增量去重。
DateTime rhythmStepHourStart(DateTime capturedAt) {
  return DateTime(
    capturedAt.year,
    capturedAt.month,
    capturedAt.day,
    capturedAt.hour,
  );
}

/// 从 Health Connect 小时桶样本提取已覆盖的小时起点集合。
Set<DateTime> healthConnectHourStarts(Iterable<ActivitySample> samples) {
  return samples
      .where(
        (ActivitySample sample) =>
            sample.source == MotionSampleSource.healthConnectHourly,
      )
      .map((ActivitySample sample) => rhythmStepHourStart(sample.capturedAt))
      .toSet();
}

/// 给定时刻是否落在已有 Health Connect 小时桶覆盖范围内。
bool isCoveredByHealthConnectHour(
  DateTime capturedAt,
  Set<DateTime> coveredHourStarts,
) {
  return coveredHourStarts.contains(rhythmStepHourStart(capturedAt));
}

/// 丢弃与 Health Connect 小时桶同小时的系统计步增量样本。
List<ActivitySample> dedupePlatformActivityAgainstHealthConnect(
  Iterable<ActivitySample> samples,
  Set<DateTime> healthConnectHourStarts,
) {
  if (healthConnectHourStarts.isEmpty) {
    return List<ActivitySample>.from(samples);
  }
  return samples
      .where(
        (ActivitySample sample) =>
            sample.source != MotionSampleSource.platformActivity ||
            !isCoveredByHealthConnectHour(
              sample.capturedAt,
              healthConnectHourStarts,
            ),
      )
      .toList(growable: false);
}

bool isSameCalendarDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
