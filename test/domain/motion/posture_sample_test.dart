import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/motion/posture_sample.dart';

void main() {
  test('高风险姿势样本应提示需要提醒', () {
    final sample = PostureSample(
      capturedAt: DateTime(2026, 6, 9, 22),
      duration: const Duration(minutes: 18),
      posture: PostureType.neckDown,
      riskLevel: PostureRiskLevel.high,
      continuousHold: const Duration(minutes: 16),
    );

    expect(sample.requiresReminder, isTrue);
    expect(sample.isHighRisk, isTrue);
  });

  test('低风险短时样本不应触发提醒', () {
    final sample = PostureSample(
      capturedAt: DateTime(2026, 6, 9, 10),
      duration: const Duration(minutes: 4),
      posture: PostureType.upright,
      riskLevel: PostureRiskLevel.low,
      continuousHold: const Duration(minutes: 3),
    );

    expect(sample.requiresReminder, isFalse);
    expect(sample.isHighRisk, isFalse);
  });
}
