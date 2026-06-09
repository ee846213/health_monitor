import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';

void main() {
  test('数字生活摘要应识别夜间使用风险与碎片化查看', () {
    final summary = DigitalUsageSummary(
      date: DateTime(2026, 6, 9),
      screenOnDuration: const Duration(hours: 5, minutes: 20),
      unlockCount: 82,
      nighttimeUsageDuration: const Duration(hours: 1, minutes: 35),
      focusSessionBreakCount: 24,
      topCategory: UsageCategory.social,
    );

    expect(summary.hasNightRisk, isTrue);
    expect(summary.hasFragmentedUsage, isTrue);
  });

  test('温和使用模式不应被标记为高风险', () {
    final summary = DigitalUsageSummary(
      date: DateTime(2026, 6, 9),
      screenOnDuration: const Duration(hours: 1, minutes: 40),
      unlockCount: 18,
      nighttimeUsageDuration: const Duration(minutes: 10),
      focusSessionBreakCount: 3,
      topCategory: UsageCategory.tools,
    );

    expect(summary.hasNightRisk, isFalse);
    expect(summary.hasFragmentedUsage, isFalse);
  });
}
