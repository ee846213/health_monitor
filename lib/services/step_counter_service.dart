import 'dart:async';
import 'dart:io';

import 'package:health_monitor/domain/motion/step_count_state.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

class StepCounterService {
  StepCounterService({
    PlatformBridgeService? platformBridgeService,
    bool Function()? isAndroid,
  })  : _platformBridgeService = platformBridgeService ?? PlatformBridgeService(),
        _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final PlatformBridgeService _platformBridgeService;
  final bool Function() _isAndroid;

  Future<StepCountState> readCurrent() async {
    if (!_isAndroid()) {
      return StepCountState.unavailable(reason: 'non_android');
    }

    final payload = await _platformBridgeService.methodChannel.invokeMapMethod<Object?, Object?>(
      'android.steps.current',
    );
    return _parsePayload(payload);
  }

  Stream<StepCountState> watchStepCounts() async* {
    if (!_isAndroid()) {
      return;
    }

    while (true) {
      final current = await readCurrent();
      if (current.isAvailable) {
        yield current;
      }
      await Future<void>.delayed(const Duration(minutes: 1));
    }
  }

  StepCountState _parsePayload(Map<Object?, Object?>? payload) {
    final reading = StepCountReading.fromChannelPayload(payload);
    if (!reading.isAvailable) {
      return StepCountState.unavailable(reason: reading.reason);
    }
    return StepCountState(
      capturedAt: reading.capturedAt,
      stepCount: reading.rawStepCount,
      isAvailable: true,
    );
  }
}
