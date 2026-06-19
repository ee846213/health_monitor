import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/services/noise_capture_service.dart';

void main() {
  test('噪音流应转换为带 12 秒权重的噪音样本', () async {
    final service = NoiseCaptureService(
      hasMicrophonePermission: () async => true,
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
    expect(sample.duration, const Duration(seconds: 12));
  });

  test('高噪音读数应映射为 loud', () async {
    final service = NoiseCaptureService(
      hasMicrophonePermission: () async => true,
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
      hasMicrophonePermission: () async => true,
      noiseStreamFactory: () => controller.stream,
    );

    final future = service.watchNoiseSamples().first;
    controller.addError(StateError('microphone unavailable'));

    await expectLater(future, throwsA(isA<NoiseCaptureException>()));
    await controller.close();
  });

  test('未授予麦克风权限时不应启动底层噪音流', () async {
    var started = false;
    final service = NoiseCaptureService(
      hasMicrophonePermission: () async => false,
      noiseStreamFactory: () {
        started = true;
        return const Stream<NoiseReadingSample>.empty();
      },
    );

    await expectLater(
      service.watchNoiseSamples().first,
      throwsA(
        isA<NoiseCaptureException>().having(
          (NoiseCaptureException error) => error.message,
          'message',
          contains('麦克风权限'),
        ),
      ),
    );
    expect(started, isFalse);
  });

  test('底层流无数据结束时应结束当前噪音流', () async {
    final service = NoiseCaptureService(
      hasMicrophonePermission: () async => true,
      noiseStreamFactory: () => const Stream<NoiseReadingSample>.empty(),
    );

    await expectLater(
      service.watchNoiseSamples().first,
      throwsA(isA<StateError>()),
    );
  });

  test('占空比应在采样结束后取消底层流，并在休眠后重新启动', () async {
    var starts = 0;
    var cancels = 0;
    final timers = <Timer>[];
    final service = NoiseCaptureService(
      activeDuration: const Duration(milliseconds: 20),
      idleDuration: const Duration(milliseconds: 30),
      hasMicrophonePermission: () async => true,
      noiseStreamFactory: () {
        starts += 1;
        late final StreamController<NoiseReadingSample> controller;
        Timer? timer;
        controller = StreamController<NoiseReadingSample>(
          onListen: () {
            timer = Timer.periodic(const Duration(milliseconds: 2), (_) {
              controller.add(
                NoiseReadingSample(
                  capturedAt: DateTime.now(),
                  meanDecibel: 52,
                  maxDecibel: 56,
                ),
              );
            });
            timers.add(timer!);
          },
          onCancel: () {
            cancels += 1;
            timer?.cancel();
          },
        );
        return controller.stream;
      },
    );

    final subscription = service.watchNoiseSamples().listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 125));
    await subscription.cancel();
    for (final timer in timers) {
      timer.cancel();
    }

    expect(starts, greaterThanOrEqualTo(2));
    expect(cancels, equals(starts));
  });

  test('单个采样阶段的加权时长合计应保持一分钟', () async {
    final samples = <NoiseSample>[];
    late final StreamController<NoiseReadingSample> controller;
    Timer? timer;
    final service = NoiseCaptureService(
      activeDuration: const Duration(milliseconds: 50),
      idleDuration: const Duration(seconds: 1),
      sampleWindowDuration: const Duration(milliseconds: 10),
      hasMicrophonePermission: () async => true,
      noiseStreamFactory: () {
        controller = StreamController<NoiseReadingSample>(
          onListen: () {
            timer = Timer.periodic(const Duration(milliseconds: 1), (_) {
              controller.add(
                NoiseReadingSample(
                  capturedAt: DateTime.now(),
                  meanDecibel: 50,
                  maxDecibel: 54,
                ),
              );
            });
          },
          onCancel: () => timer?.cancel(),
        );
        return controller.stream;
      },
    );

    final subscription = service.watchNoiseSamples().listen(samples.add);
    await Future<void>.delayed(const Duration(milliseconds: 75));
    await subscription.cancel();

    expect(samples, hasLength(5));
    expect(
      samples.fold<Duration>(
        Duration.zero,
        (Duration total, NoiseSample sample) => total + sample.duration,
      ),
      const Duration(minutes: 1),
    );
  });

  test('休眠阶段取消订阅不应等待完整休眠时长', () async {
    final service = NoiseCaptureService(
      activeDuration: const Duration(milliseconds: 10),
      idleDuration: const Duration(seconds: 1),
      hasMicrophonePermission: () async => true,
      noiseStreamFactory: () {
        return Stream<NoiseReadingSample>.value(
          NoiseReadingSample(
            capturedAt: DateTime.now(),
            meanDecibel: 45,
            maxDecibel: 48,
          ),
        );
      },
    );

    final subscription = service.watchNoiseSamples().listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final stopwatch = Stopwatch()..start();
    await subscription.cancel();
    stopwatch.stop();

    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 100)));
  });
}
