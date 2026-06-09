import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('最近数小时窗口应从基准时间向前回退指定小时数', () {
    final reference = DateTime(2026, 6, 9, 18, 30);
    final window = QueryWindow.recentHours(6, referenceTime: reference);

    expect(window.startAt, DateTime(2026, 6, 9, 12, 30));
    expect(window.endAt, reference);
    expect(window.label, '最近6小时');
  });

  test('最近一天窗口应覆盖 24 小时而不是自然日切片', () {
    final reference = DateTime(2026, 6, 9, 8, 15);
    final window = QueryWindow.recentDay(referenceTime: reference);

    expect(window.startAt, DateTime(2026, 6, 8, 8, 15));
    expect(window.endAt, reference);
    expect(window.label, '最近一天');
  });

  test('最近 7 天窗口应保留周级聚合所需跨度', () {
    final reference = DateTime(2026, 6, 9, 21);
    final window = QueryWindow.recentDays(7, referenceTime: reference);

    expect(window.startAt, DateTime(2026, 6, 2, 21));
    expect(window.endAt, reference);
    expect(window.label, '最近7天');
  });

  test('窗口应拒绝非正数跨度', () {
    expect(
      () => QueryWindow.recentHours(0, referenceTime: DateTime(2026, 6, 9)),
      throwsArgumentError,
    );
    expect(
      () => QueryWindow.recentDays(-1, referenceTime: DateTime(2026, 6, 9)),
      throwsArgumentError,
    );
  });
}
