import 'dart:async';

import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:noise_meter/noise_meter.dart' as noise_meter;
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

typedef NoiseReadingStreamFactory = Stream<NoiseReadingSample> Function();
typedef MicrophonePermissionReader = Future<bool> Function();

class NoiseReadingSample {
  const NoiseReadingSample({
    required this.capturedAt,
    required this.meanDecibel,
    required this.maxDecibel,
  });

  final DateTime capturedAt;
  final double meanDecibel;
  final double maxDecibel;
}

class NoiseCaptureException implements Exception {
  const NoiseCaptureException(this.message);

  final String message;

  @override
  String toString() => 'NoiseCaptureException($message)';
}

class NoiseCaptureService {
  NoiseCaptureService({
    NoiseReadingStreamFactory? noiseStreamFactory,
    MicrophonePermissionReader? hasMicrophonePermission,
  })  : _noiseStreamFactory = noiseStreamFactory ?? _defaultNoiseStreamFactory,
        _hasMicrophonePermission =
            hasMicrophonePermission ?? _defaultMicrophonePermissionReader;

  final NoiseReadingStreamFactory _noiseStreamFactory;
  final MicrophonePermissionReader _hasMicrophonePermission;

  Stream<NoiseSample> watchNoiseSamples() async* {
    // 某些 Android 设备在麦克风权限未授权时，底层插件会直接触发原生崩溃。
    // 这里先在 Dart 层做权限闸门，未授权时走降级而不是触发底层录音初始化。
    if (!await _hasMicrophonePermission()) {
      throw const NoiseCaptureException('未授予麦克风权限，暂不启动环境噪音采集');
    }

    yield* _noiseStreamFactory().transform<NoiseSample>(
      StreamTransformer<NoiseReadingSample, NoiseSample>.fromHandlers(
        handleData: (NoiseReadingSample reading, EventSink<NoiseSample> sink) {
          sink.add(
            NoiseSample.fromDecibel(
              capturedAt: reading.capturedAt,
              duration: const Duration(seconds: 1),
              decibel: reading.meanDecibel,
            ),
          );
        },
        handleError: (
          Object error,
          StackTrace stackTrace,
          EventSink<NoiseSample> sink,
        ) {
          sink.addError(
            NoiseCaptureException('实时噪音采集失败: $error'),
            stackTrace,
          );
        },
      ),
    );
  }

  static Stream<NoiseReadingSample> _defaultNoiseStreamFactory() {
    final meter = noise_meter.NoiseMeter();
    return meter.noise.map((noise_meter.NoiseReading reading) {
      return NoiseReadingSample(
        capturedAt: DateTime.now(),
        meanDecibel: reading.meanDecibel,
        maxDecibel: reading.maxDecibel,
      );
    });
  }

  static Future<bool> _defaultMicrophonePermissionReader() async {
    final status = await permission_handler.Permission.microphone.status;
    return status == permission_handler.PermissionStatus.granted;
  }
}
