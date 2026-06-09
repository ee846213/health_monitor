import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('活动仓储应仅返回落在窗口内的样本', () async {
    final repository = InMemoryActivityRepository(
      samples: <ActivitySample>[
        ActivitySample(
          capturedAt: DateTime(2026, 6, 9, 8),
          duration: const Duration(minutes: 20),
          type: ActivityType.walking,
          confidence: 0.8,
          stepCount: 1200,
          source: MotionSampleSource.sensorFusion,
        ),
        ActivitySample(
          capturedAt: DateTime(2026, 6, 9, 16),
          duration: const Duration(minutes: 45),
          type: ActivityType.stationary,
          confidence: 0.9,
          stepCount: 0,
          source: MotionSampleSource.sensorFusion,
        ),
        ActivitySample(
          capturedAt: DateTime(2026, 6, 9, 18),
          duration: const Duration(minutes: 10),
          type: ActivityType.walking,
          confidence: 0.82,
          stepCount: 900,
          source: MotionSampleSource.sensorFusion,
        ),
      ],
    );

    final result = await repository.listByWindow(
      QueryWindow.recentHours(4, referenceTime: DateTime(2026, 6, 9, 18, 30)),
    );

    expect(result.map((sample) => sample.capturedAt.hour), <int>[16, 18]);
  });

  test('活动仓储应按时间升序输出结果，便于后续聚合', () async {
    final repository = InMemoryActivityRepository(
      samples: <ActivitySample>[
        ActivitySample(
          capturedAt: DateTime(2026, 6, 9, 18),
          duration: const Duration(minutes: 10),
          type: ActivityType.walking,
          confidence: 0.82,
          stepCount: 900,
          source: MotionSampleSource.sensorFusion,
        ),
        ActivitySample(
          capturedAt: DateTime(2026, 6, 9, 16),
          duration: const Duration(minutes: 45),
          type: ActivityType.stationary,
          confidence: 0.9,
          stepCount: 0,
          source: MotionSampleSource.sensorFusion,
        ),
      ],
    );

    final result = await repository.listByWindow(
      QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 9, 23)),
    );

    expect(result.map((sample) => sample.capturedAt.hour), <int>[16, 18]);
  });
}
