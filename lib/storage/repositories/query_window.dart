class QueryWindow {
  const QueryWindow._({
    required this.startAt,
    required this.endAt,
    required this.label,
  });

  final DateTime startAt;
  final DateTime endAt;
  final String label;

  factory QueryWindow.recentHours(int hours, {required DateTime referenceTime}) {
    if (hours <= 0) {
      throw ArgumentError.value(hours, 'hours', '时间窗口必须是正数');
    }

    return QueryWindow._(
      startAt: referenceTime.subtract(Duration(hours: hours)),
      endAt: referenceTime,
      label: '最近$hours小时',
    );
  }

  factory QueryWindow.recentDay({required DateTime referenceTime}) {
    return QueryWindow._(
      startAt: referenceTime.subtract(const Duration(days: 1)),
      endAt: referenceTime,
      label: '最近一天',
    );
  }

  factory QueryWindow.calendarDay({required DateTime referenceDate}) {
    final startAt = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    return QueryWindow._(
      startAt: startAt,
      endAt: startAt.add(const Duration(days: 1)),
      label: '今日',
    );
  }

  factory QueryWindow.recentDays(int days, {required DateTime referenceTime}) {
    if (days <= 0) {
      throw ArgumentError.value(days, 'days', '时间窗口必须是正数');
    }

    return QueryWindow._(
      startAt: referenceTime.subtract(Duration(days: days)),
      endAt: referenceTime,
      label: '最近$days天',
    );
  }

  factory QueryWindow.recentCalendarDays(
    int days, {
    required DateTime referenceDate,
  }) {
    if (days <= 0) {
      throw ArgumentError.value(days, 'days', '时间窗口必须是正数');
    }

    final endAt = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    ).add(const Duration(days: 1));
    return QueryWindow._(
      startAt: endAt.subtract(Duration(days: days)),
      endAt: endAt,
      label: '最近$days天',
    );
  }

  bool contains(DateTime value) {
    return !value.isBefore(startAt) && value.isBefore(endAt);
  }

  List<DateTime> dailyDates() {
    final dates = <DateTime>[];
    var current = DateTime(startAt.year, startAt.month, startAt.day);
    final inclusiveEnd = endAt.subtract(const Duration(microseconds: 1));
    final endDay = DateTime(
      inclusiveEnd.year,
      inclusiveEnd.month,
      inclusiveEnd.day,
    );
    while (!current.isAfter(endDay)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }
}
