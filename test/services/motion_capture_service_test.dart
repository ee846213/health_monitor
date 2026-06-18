import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/services/motion_capture_service.dart';

void main() {
  test('低强度加速度应映射为静止样本', () async {
    final service = MotionCaptureService(
      sensorStreamFactory: ({
        Duration samplingPeriod = const Duration(milliseconds: 200),
      }) {
        return Stream<MotionVectorSample>.value(
          MotionVectorSample(
            capturedAt: DateTime(2026, 6, 9, 18),
            x: 0.02,
            y: 0.03,
            z: 0.04,
          ),
        );
      },
    );

    final sample = await service.watchActivitySamples().first;

    expect(sample.type, ActivityType.stationary);
    expect(sample.confidence, greaterThanOrEqualTo(0.7));
    expect(sample.stepCount, 0);
  });

  test('含重力的静置加速度应映射为静止样本', () async {
    final service = MotionCaptureService(
      sensorStreamFactory: ({
        Duration samplingPeriod = const Duration(milliseconds: 200),
      }) {
        return Stream<MotionVectorSample>.value(
          MotionVectorSample(
            capturedAt: DateTime(2026, 6, 9, 18),
            x: 0,
            y: 0,
            z: 9.80665,
          ),
        );
      },
    );

    final sample = await service.watchActivitySamples().first;

    expect(sample.type, ActivityType.stationary);
    expect(sample.confidence, greaterThanOrEqualTo(0.7));
  });

  test('中等强度加速度应映射为步行样本', () async {
    final service = MotionCaptureService(
      sensorStreamFactory: ({
        Duration samplingPeriod = const Duration(milliseconds: 200),
      }) {
        return Stream<MotionVectorSample>.value(
          MotionVectorSample(
            capturedAt: DateTime(2026, 6, 9, 18),
            x: 1.3,
            y: 0.8,
            z: 0.6,
          ),
        );
      },
    );

    final sample = await service.watchActivitySamples().first;

    expect(sample.type, ActivityType.walking);
    expect(sample.stepCount, 0);
  });

  test('高强度加速度应映射为跑步样本', () async {
    final service = MotionCaptureService(
      sensorStreamFactory: ({
        Duration samplingPeriod = const Duration(milliseconds: 200),
      }) {
        return Stream<MotionVectorSample>.value(
          MotionVectorSample(
            capturedAt: DateTime(2026, 6, 9, 18),
            x: 3.1,
            y: 2.2,
            z: 1.4,
          ),
        );
      },
    );

    final sample = await service.watchActivitySamples().first;

    expect(sample.type, ActivityType.running);
    expect(sample.stepCount, 0);
  });

  test('传感器错误应转换为可消费的捕获异常', () async {
    final controller = StreamController<MotionVectorSample>();
    final service = MotionCaptureService(
      sensorStreamFactory: ({
        Duration samplingPeriod = const Duration(milliseconds: 200),
      }) {
        return controller.stream;
      },
    );

    final future = service.watchActivitySamples().first;
    controller.addError(StateError('sensor missing'));

    await expectLater(future, throwsA(isA<MotionCaptureException>()));
    await controller.close();
  });
}
