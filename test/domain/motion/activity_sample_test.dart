import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';

void main() {
  test('活动样本应暴露持续时长与久坐判断', () {
    final sample = ActivitySample(
      capturedAt: DateTime(2026, 6, 9, 9),
      duration: const Duration(minutes: 45),
      type: ActivityType.stationary,
      confidence: 0.92,
      stepCount: 0,
      source: MotionSampleSource.sensorFusion,
    );

    expect(sample.duration, const Duration(minutes: 45));
    expect(sample.isSedentary, isTrue);
    expect(sample.isConfident, isTrue);
  });

  test('步行样本不应被判断为久坐', () {
    final sample = ActivitySample(
      capturedAt: DateTime(2026, 6, 9, 18),
      duration: const Duration(minutes: 12),
      type: ActivityType.walking,
      confidence: 0.75,
      stepCount: 1200,
      source: MotionSampleSource.sensorFusion,
    );

    expect(sample.isSedentary, isFalse);
    expect(sample.stepCount, 1200);
  });
}
