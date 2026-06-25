import 'package:health_monitor/storage/repositories/date_key.dart';

/// 生活节奏轴的可见时间窗口：从今日早晨起点到当前时刻。
class DailyRhythmWindow {
  const DailyRhythmWindow({
    required this.start,
    required this.end,
  });

  /// 节奏轴左侧「早晨」对应的默认起点（6:00）。
  static const int defaultMorningHour = 6;

  final DateTime start;
  final DateTime end;

  /// 以 [now] 为右边界构造当日可见窗口。
  factory DailyRhythmWindow.forNow(DateTime now) {
    return DailyRhythmWindow.forCalendarDay(now, windowEnd: now);
  }

  /// 以 [calendarDay] 的自然日为范围，右边界由 [windowEnd] 决定。
  ///
  /// 首页「今天」与简报「当日」共用：今天截到当前时刻，历史日截到当日结束。
  factory DailyRhythmWindow.forCalendarDay(
    DateTime calendarDay, {
    required DateTime windowEnd,
  }) {
    final day = DateTime(calendarDay.year, calendarDay.month, calendarDay.day);
    final morningStart = DateTime(
      day.year,
      day.month,
      day.day,
      defaultMorningHour,
    );
    final start = windowEnd.isBefore(morningStart) ? day : morningStart;
    return DailyRhythmWindow(start: start, end: windowEnd);
  }

  /// 自然日结束时刻，用于历史日的节奏轴右边界。
  static DateTime endOfCalendarDay(DateTime day) {
    return DateTime(day.year, day.month, day.day, 23, 59, 59);
  }

  /// 事件是否落在窗口内（含起止边界，按分钟粒度比较）。
  bool contains(DateTime time) {
    if (DateKey.fromDate(time) != DateKey.fromDate(end)) {
      return false;
    }
    final minute = _truncateToMinute(time);
    final startMinute = _truncateToMinute(start);
    final endMinute = _truncateToMinute(end);
    return !minute.isBefore(startMinute) && !minute.isAfter(endMinute);
  }

  Duration get span {
    final diff = end.difference(start);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// 将 [time] 映射到节奏轴弧线的 0~1 位置。
  static DateTime _truncateToMinute(DateTime time) {
    return DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
    );
  }

  double normalizedFor(DateTime time) {
    final spanMs = span.inMilliseconds;
    if (spanMs <= 0) {
      return 0;
    }
    final offsetMs = time.difference(start).inMilliseconds;
    return (offsetMs / spanMs).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyRhythmWindow &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}
