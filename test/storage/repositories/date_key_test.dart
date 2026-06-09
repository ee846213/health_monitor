import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';

void main() {
  test('日期键应格式化为稳定的 yyyy-MM-dd', () {
    expect(DateKey.fromDate(DateTime(2026, 6, 9, 23, 59)), '2026-06-09');
    expect(DateKey.fromDate(DateTime(2026, 1, 2, 8)), '2026-01-02');
  });

  test('最近 7 天日期键应按升序输出，便于周聚合', () {
    final keys = DateKey.recentDays(
      7,
      referenceDate: DateTime(2026, 6, 9, 21),
    );

    expect(keys.first, '2026-06-03');
    expect(keys.last, '2026-06-09');
    expect(keys, hasLength(7));
  });
}
