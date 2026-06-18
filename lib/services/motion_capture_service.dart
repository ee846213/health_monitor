import 'dart:async';
import 'dart:math' as math;

import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:sensors_plus/sensors_plus.dart';

typedef MotionSensorStreamFactory = Stream<MotionVectorSample> Function({
  Duration samplingPeriod,
});

class MotionVectorSample {
  const MotionVectorSample({
    required this.capturedAt,
    required this.x,
    required this.y,
    required this.z,
  });

  final DateTime capturedAt;
  final double x;
  final double y;
  final double z;
}

class MotionCaptureException implements Exception {
  const MotionCaptureException(this.message);

  final String message;

  @override
  String toString() => 'MotionCaptureException($message)';
}

class MotionCaptureService {
  MotionCaptureService({
    MotionSensorStreamFactory? sensorStreamFactory,
  }) : _sensorStreamFactory =
            sensorStreamFactory ?? _defaultSensorStreamFactory;

  final MotionSensorStreamFactory _sensorStreamFactory;

  Stream<ActivitySample> watchActivitySamples({
    Duration samplingPeriod = const Duration(milliseconds: 200),
  }) {
    return _sensorStreamFactory(samplingPeriod: samplingPeriod)
        .transform<ActivitySample>(
      StreamTransformer<MotionVectorSample, ActivitySample>.fromHandlers(
        handleData:
            (MotionVectorSample sample, EventSink<ActivitySample> sink) {
          sink.add(_toActivitySample(sample));
        },
        handleError: (Object error, StackTrace stackTrace,
            EventSink<ActivitySample> sink) {
          sink.addError(
            MotionCaptureException('实时传感器采集失败: $error'),
            stackTrace,
          );
        },
      ),
    );
  }

  static Stream<MotionVectorSample> _defaultSensorStreamFactory({
    Duration samplingPeriod = const Duration(milliseconds: 200),
  }) {
    return accelerometerEventStream(samplingPeriod: samplingPeriod)
        .map((AccelerometerEvent event) {
      return MotionVectorSample(
        capturedAt: DateTime.now(),
        x: event.x,
        y: event.y,
        z: event.z,
      );
    });
  }

  ActivitySample _toActivitySample(MotionVectorSample sample) {
    final magnitude = math.sqrt(
      sample.x * sample.x + sample.y * sample.y + sample.z * sample.z,
    );
    final movementIntensity = math.min(
      magnitude,
      (magnitude - _gravityMagnitude).abs(),
    );
    final ActivityType type;

    // 这里先用非常保守的阈值把原始传感器流转换成“静止/步行/跑步”三档，
    // 目标不是立即得到高精度识别，而是先打通真实采集 -> 领域样本 -> 调试页这条链路。
    if (movementIntensity < 0.3) {
      type = ActivityType.stationary;
    } else if (movementIntensity < 2.2) {
      type = ActivityType.walking;
    } else {
      type = ActivityType.running;
    }

    return ActivitySample(
      capturedAt: sample.capturedAt,
      duration: const Duration(seconds: 1),
      type: type,
      confidence: _confidenceForMagnitude(movementIntensity),
      // 传感器融合阶段只输出活动类型，不在这里伪造步数。
      // 步数需要来自系统计步器或更可靠的平台来源，否则手机静置时也会因为轻微抖动持续增长。
      stepCount: 0,
      source: MotionSampleSource.sensorFusion,
    );
  }

  static const double _gravityMagnitude = 9.80665;

  double _confidenceForMagnitude(double magnitude) {
    if (magnitude < 0.3) {
      return 0.9;
    }
    if (magnitude < 2.2) {
      return 0.78;
    }
    return 0.74;
  }
}
