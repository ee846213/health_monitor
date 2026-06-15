import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/services/ambient_light_capture_service.dart';

void main() {
  test('Android 光照事件应解析为环境光照样本', () async {
    final service = AmbientLightCaptureService(
      isAndroid: () => true,
      eventStreamFactory: () {
        return Stream<Object?>.value(<Object?, Object?>{
          'capturedAtMillis': DateTime(2026, 6, 16, 9).millisecondsSinceEpoch,
          'lux': 1200.0,
        });
      },
    );

    final sample = await service.watchAmbientLightSamples().first;

    expect(sample.level, AmbientLightLevel.bright);
    expect(sample.lux, 1200.0);
    expect(sample.duration, const Duration(seconds: 1));
  });

  test('非 Android 平台应直接返回空流', () async {
    final service = AmbientLightCaptureService(
      isAndroid: () => false,
      eventStreamFactory: () {
        return Stream<Object?>.value(<Object?, Object?>{
          'capturedAtMillis': DateTime(2026, 6, 16, 9).millisecondsSinceEpoch,
          'lux': 300.0,
        });
      },
    );

    final samples = await service.watchAmbientLightSamples().toList();

    expect(samples, isEmpty);
  });

  test('原生流错误应转换为 AmbientLightCaptureException', () async {
    final controller = StreamController<Object?>();
    final service = AmbientLightCaptureService(
      isAndroid: () => true,
      eventStreamFactory: () => controller.stream,
    );

    final future = service.watchAmbientLightSamples().first;
    controller.addError(StateError('light sensor unavailable'));

    await expectLater(future, throwsA(isA<AmbientLightCaptureException>()));
    await controller.close();
  });
}
