import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';

typedef AmbientLightEventStreamFactory = Stream<Object?> Function();

class AmbientLightCaptureException implements Exception {
  const AmbientLightCaptureException(this.message);

  final String message;

  @override
  String toString() => 'AmbientLightCaptureException($message)';
}

class AmbientLightCaptureService {
  AmbientLightCaptureService({
    EventChannel? eventChannel,
    AmbientLightEventStreamFactory? eventStreamFactory,
    bool Function()? isAndroid,
  })  : _eventChannel =
            eventChannel ?? const EventChannel('health_monitor/light_samples'),
        _eventStreamFactory = eventStreamFactory,
        _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final EventChannel _eventChannel;
  final AmbientLightEventStreamFactory? _eventStreamFactory;
  final bool Function() _isAndroid;

  Stream<AmbientLightSample> watchAmbientLightSamples() {
    if (!_isAndroid()) {
      return const Stream<AmbientLightSample>.empty();
    }

    final sourceStream = _eventStreamFactory?.call() ??
        _eventChannel.receiveBroadcastStream().cast<Object?>();

    final samples = sourceStream.transform<AmbientLightSample>(
      StreamTransformer<Object?, AmbientLightSample>.fromHandlers(
        handleData: (Object? payload, EventSink<AmbientLightSample> sink) {
          final data = payload;
          if (data is! Map<Object?, Object?>) {
            return;
          }

          final lux = (data['lux'] as num?)?.toDouble();
          final capturedAtMillis = data['capturedAtMillis'] as int?;
          if (lux == null || capturedAtMillis == null) {
            return;
          }

          sink.add(
            AmbientLightSample.fromLux(
              capturedAt: DateTime.fromMillisecondsSinceEpoch(
                capturedAtMillis,
              ),
              duration: const Duration(seconds: 1),
              lux: lux,
            ),
          );
        },
        handleError: (
          Object error,
          StackTrace stackTrace,
          EventSink<AmbientLightSample> sink,
        ) {
          sink.addError(
            AmbientLightCaptureException('环境光照采集失败: $error'),
            stackTrace,
          );
        },
      ),
    );
    return _limitSamples(samples);
  }

  Stream<AmbientLightSample> _limitSamples(
    Stream<AmbientLightSample> samples,
  ) async* {
    AmbientLightSample? lastEmitted;
    await for (final sample in samples) {
      final previous = lastEmitted;
      if (previous != null &&
          sample.capturedAt.difference(previous.capturedAt) <
              const Duration(seconds: 1)) {
        continue;
      }
      lastEmitted = sample;
      yield sample;
    }
  }
}
