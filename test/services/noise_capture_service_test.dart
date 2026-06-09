import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/services/noise_capture_service.dart';

void main() {
  test('噪音流应转换为噪音样本', () async {
    final service = NoiseCaptureService(
      noiseStreamFactory: () {
        return Stream<NoiseReadingSample>.value(
          NoiseReadingSample(
            capturedAt: DateTime(2026, 6, 9, 20),
            meanDecibel: 58,
            maxDecibel: 63,
          ),
        );
      },
    );

    final sample = await service.watchNoiseSamples().first;

    expect(sample.level, NoiseLevel.moderate);
    expect(sample.decibel, 58);
  });

  test('高噪音读数应映射为 loud', () async {
    final service = NoiseCaptureService(
      noiseStreamFactory: () {
        return Stream<NoiseReadingSample>.value(
          NoiseReadingSample(
            capturedAt: DateTime(2026, 6, 9, 23),
            meanDecibel: 74,
            maxDecibel: 80,
          ),
        );
      },
    );

    final sample = await service.watchNoiseSamples().first;

    expect(sample.level, NoiseLevel.loud);
    expect(sample.isDisturbing, isTrue);
  });

  test('采集错误应转换为可消费异常', () async {
    final controller = StreamController<NoiseReadingSample>();
    final service = NoiseCaptureService(
      noiseStreamFactory: () => controller.stream,
    );

    final future = service.watchNoiseSamples().first;
    controller.addError(StateError('microphone unavailable'));

    await expectLater(future, throwsA(isA<NoiseCaptureException>()));
    await controller.close();
  });
}
