import 'dart:async';

import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:noise_meter/noise_meter.dart' as noise_meter;

typedef NoiseReadingStreamFactory = Stream<NoiseReadingSample> Function();

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
  }) : _noiseStreamFactory = noiseStreamFactory ?? _defaultNoiseStreamFactory;

  final NoiseReadingStreamFactory _noiseStreamFactory;

  Stream<NoiseSample> watchNoiseSamples() {
    return _noiseStreamFactory().transform<NoiseSample>(
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
}
