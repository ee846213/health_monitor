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

  bool contains(DateTime value) {
    return !value.isBefore(startAt) && !value.isAfter(endAt);
  }
}
