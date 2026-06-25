import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_window.dart';

void main() {
  test('forNow 在 6 点后应以早晨为起点、当前时刻为终点', () {
    final now = DateTime(2026, 6, 22, 15, 40);
    final window = DailyRhythmWindow.forNow(now);

    expect(window.start, DateTime(2026, 6, 22, 6));
    expect(window.end, now);
    expect(window.contains(DateTime(2026, 6, 22, 9, 30)), isTrue);
    expect(window.contains(DateTime(2026, 6, 22, 15, 30)), isTrue);
    expect(window.contains(DateTime(2026, 6, 22, 5, 30)), isFalse);
    expect(window.contains(DateTime(2026, 6, 22, 15, 41)), isFalse);
  });

  test('forNow 在 6 点前应以当日 0 点为起点', () {
    final now = DateTime(2026, 6, 22, 5, 10);
    final window = DailyRhythmWindow.forNow(now);

    expect(window.start, DateTime(2026, 6, 22));
    expect(window.contains(DateTime(2026, 6, 22, 4)), isTrue);
    expect(window.contains(DateTime(2026, 6, 21, 23)), isFalse);
  });

  test('forCalendarDay 历史日应以当日结束为右边界', () {
    final day = DateTime(2026, 6, 20);
    final end = DailyRhythmWindow.endOfCalendarDay(day);
    final window = DailyRhythmWindow.forCalendarDay(day, windowEnd: end);

    expect(window.start, DateTime(2026, 6, 20, 6));
    expect(window.end, end);
    expect(window.contains(DateTime(2026, 6, 20, 21)), isTrue);
    expect(window.contains(DateTime(2026, 6, 21, 0)), isFalse);
  });

  test('normalizedFor 应把窗口起止映射到 0 与 1', () {
    final window = DailyRhythmWindow(
      start: DateTime(2026, 6, 22, 6),
      end: DateTime(2026, 6, 22, 14),
    );

    expect(window.normalizedFor(DateTime(2026, 6, 22, 6)), closeTo(0, 1e-9));
    expect(window.normalizedFor(DateTime(2026, 6, 22, 14)), closeTo(1, 1e-9));
    expect(window.normalizedFor(DateTime(2026, 6, 22, 10)), closeTo(0.5, 1e-9));
  });
}
