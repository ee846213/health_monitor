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
    this.activeDuration = const Duration(seconds: 5),
    this.idleDuration = const Duration(seconds: 55),
    this.sampleWindowDuration = const Duration(seconds: 1),
    this.weightedSampleDuration = const Duration(seconds: 12),
  })  : assert(activeDuration > Duration.zero),
        assert(idleDuration >= Duration.zero),
        assert(sampleWindowDuration > Duration.zero),
        assert(weightedSampleDuration > Duration.zero),
        _noiseStreamFactory = noiseStreamFactory ?? _defaultNoiseStreamFactory,
        _hasMicrophonePermission =
            hasMicrophonePermission ?? _defaultMicrophonePermissionReader;

  final NoiseReadingStreamFactory _noiseStreamFactory;
  final MicrophonePermissionReader _hasMicrophonePermission;

  /// 每分钟只启用麦克风 5 秒，降低持续录音带来的 CPU 与功耗。
  ///
  /// 采样阶段仍按秒生成领域样本，每个有效秒按 12 秒计权；
  /// 5 个有效秒合计代表 60 秒的分钟级噪音暴露。
  final Duration activeDuration;
  final Duration idleDuration;
  final Duration sampleWindowDuration;
  final Duration weightedSampleDuration;

  Stream<NoiseSample> watchNoiseSamples() async* {
    // 部分 Android 设备在未授权时初始化录音会直接触发原生崩溃，
    // 因此必须先在 Dart 层完成权限闸门。
    if (!await _hasMicrophonePermission()) {
      throw const NoiseCaptureException('未授予麦克风权限，暂不启动环境噪音采集');
    }

    yield* _createDutyCycledStream();
  }

  Stream<NoiseSample> _createDutyCycledStream() {
    late final StreamController<NoiseSample> controller;
    StreamSubscription<NoiseSample>? activeSubscription;
    Timer? phaseTimer;
    var stopped = false;
    var phaseId = 0;
    late void Function() startActivePhase;

    Future<void> stopActivePhase({
      required int expectedPhaseId,
      required bool scheduleNext,
    }) async {
      if (expectedPhaseId != phaseId) {
        return;
      }

      phaseTimer?.cancel();
      phaseTimer = null;
      final subscription = activeSubscription;
      activeSubscription = null;
      await subscription?.cancel();

      if (!stopped && scheduleNext) {
        phaseTimer = Timer(idleDuration, startActivePhase);
      }
    }

    void handleActiveDone({
      required int expectedPhaseId,
      required bool timedOut,
    }) {
      if (!timedOut) {
        unawaited(
          stopActivePhase(
            expectedPhaseId: expectedPhaseId,
            scheduleNext: false,
          ).then((_) async {
            if (!controller.isClosed) {
              await controller.close();
            }
          }),
        );
        return;
      }

      unawaited(
        stopActivePhase(
          expectedPhaseId: expectedPhaseId,
          scheduleNext: true,
        ),
      );
    }

    startActivePhase = () {
      if (stopped) {
        return;
      }

      phaseId += 1;
      final currentPhaseId = phaseId;
      final activeStartedAt = DateTime.now();
      var timedOut = false;
      final samples = _noiseStreamFactory().transform<NoiseSample>(
        StreamTransformer<NoiseReadingSample, NoiseSample>.fromHandlers(
          handleData: (
            NoiseReadingSample reading,
            EventSink<NoiseSample> sink,
          ) {
            sink.add(
              NoiseSample.fromDecibel(
                capturedAt: reading.capturedAt,
                duration: weightedSampleDuration,
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

      activeSubscription = _aggregatePerSecond(
        _takeFor(
          samples,
          activeDuration,
          onTimeout: () => timedOut = true,
        ),
        activeStartedAt: activeStartedAt,
      ).listen(
        controller.add,
        onError: controller.addError,
        onDone: () => handleActiveDone(
          expectedPhaseId: currentPhaseId,
          timedOut: timedOut,
        ),
      );
    };

    Future<void> stop() async {
      if (stopped) {
        return;
      }
      stopped = true;
      phaseId += 1;
      phaseTimer?.cancel();
      phaseTimer = null;
      final subscription = activeSubscription;
      activeSubscription = null;
      await subscription?.cancel();
    }

    controller = StreamController<NoiseSample>(
      onListen: startActivePhase,
      onCancel: stop,
    );
    return controller.stream;
  }

  Stream<T> _takeFor<T>(
    Stream<T> source,
    Duration duration, {
    required void Function() onTimeout,
  }) {
    late final StreamController<T> controller;
    StreamSubscription<T>? subscription;
    Timer? timer;
    var stopped = false;

    Future<void> stop() async {
      if (stopped) {
        return;
      }
      stopped = true;
      timer?.cancel();
      timer = null;
      final activeSubscription = subscription;
      subscription = null;
      await activeSubscription?.cancel();
      if (!controller.isClosed) {
        await controller.close();
      }
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = source.listen(
          controller.add,
          onError: controller.addError,
          onDone: () => unawaited(stop()),
        );
        timer = Timer(duration, () {
          onTimeout();
          unawaited(stop());
        });
      },
      onCancel: stop,
    );
    return controller.stream;
  }

  Stream<NoiseSample> _aggregatePerSecond(
    Stream<NoiseSample> samples, {
    required DateTime activeStartedAt,
  }) async* {
    int? windowIndex;
    DateTime? capturedAt;
    var decibelTotal = 0.0;
    var sampleCount = 0;
    final maxWindowIndex = (activeDuration.inMicroseconds - 1) ~/
        sampleWindowDuration.inMicroseconds;

    NoiseSample buildSample() {
      return NoiseSample.fromDecibel(
        capturedAt: capturedAt!,
        duration: weightedSampleDuration,
        decibel: decibelTotal / sampleCount,
      );
    }

    await for (final sample in samples) {
      final elapsedMicroseconds =
          DateTime.now().difference(activeStartedAt).inMicroseconds;
      final currentWindowIndex =
          (elapsedMicroseconds ~/ sampleWindowDuration.inMicroseconds).clamp(
        0,
        maxWindowIndex,
      );
      if (windowIndex != null && currentWindowIndex != windowIndex) {
        yield buildSample();
        decibelTotal = 0;
        sampleCount = 0;
      }
      windowIndex = currentWindowIndex;
      if (sampleCount == 0) {
        capturedAt = sample.capturedAt;
      }
      decibelTotal += sample.decibel;
      sampleCount += 1;
    }

    if (windowIndex != null && sampleCount > 0) {
      yield buildSample();
    }
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
