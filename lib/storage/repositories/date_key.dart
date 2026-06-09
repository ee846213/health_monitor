class DateKey {
  const DateKey._();

  static String fromDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static List<String> recentDays(int days, {required DateTime referenceDate}) {
    if (days <= 0) {
      throw ArgumentError.value(days, 'days', '天数必须是正数');
    }

    return List<String>.generate(days, (index) {
      final date = referenceDate.subtract(Duration(days: days - index - 1));
      return fromDate(date);
    });
  }
}
