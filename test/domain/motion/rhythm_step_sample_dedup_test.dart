import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/rhythm_step_sample_dedup.dart';

void main() {
  test('Health Connect 小时桶应覆盖同小时系统增量', () {
    final coveredHours = healthConnectHourStarts(<ActivitySample>[
      ActivitySample(
        capturedAt: DateTime(2026, 6, 22, 8),
        duration: const Duration(hours: 1),
        type: ActivityType.walking,
        confidence: 0.85,
        stepCount: 3200,
        source: MotionSampleSource.healthConnectHourly,
      ),
    ]);

    expect(
      isCoveredByHealthConnectHour(DateTime(2026, 6, 22, 8, 45), coveredHours),
      isTrue,
    );
    expect(
      isCoveredByHealthConnectHour(DateTime(2026, 6, 22, 9, 10), coveredHours),
      isFalse,
    );
  });

  test('去重应保留非 HC 小时的系统增量与其它来源样本', () {
    final samples = <ActivitySample>[
      ActivitySample(
        capturedAt: DateTime(2026, 6, 22, 8, 15),
        duration: const Duration(seconds: 1),
        type: ActivityType.walking,
        confidence: 0.85,
        stepCount: 420,
        source: MotionSampleSource.platformActivity,
      ),
      ActivitySample(
        capturedAt: DateTime(2026, 6, 22, 18, 30),
        duration: const Duration(seconds: 1),
        type: ActivityType.walking,
        confidence: 0.85,
        stepCount: 260,
        source: MotionSampleSource.platformActivity,
      ),
      ActivitySample(
        capturedAt: DateTime(2026, 6, 22, 10),
        duration: const Duration(minutes: 20),
        type: ActivityType.walking,
        confidence: 0.8,
        stepCount: 0,
        source: MotionSampleSource.sensorFusion,
      ),
    ];
    final coveredHours = healthConnectHourStarts(<ActivitySample>[
      ActivitySample(
        capturedAt: DateTime(2026, 6, 22, 8),
        duration: const Duration(hours: 1),
        type: ActivityType.walking,
        confidence: 0.85,
        stepCount: 3200,
        source: MotionSampleSource.healthConnectHourly,
      ),
    ]);

    final deduped = dedupePlatformActivityAgainstHealthConnect(
      samples,
      coveredHours,
    );

    expect(deduped, hasLength(2));
    expect(deduped.first.capturedAt.hour, 18);
    expect(deduped.last.source, MotionSampleSource.sensorFusion);
  });
}
