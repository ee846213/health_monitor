import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health_monitor/domain/motion/background_step_delta_event.dart';
import 'package:health_monitor/domain/motion/native_step_day_summary.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

class AndroidStepDeltaBridgeException implements Exception {
  const AndroidStepDeltaBridgeException(this.message);

  final String message;

  @override
  String toString() => 'AndroidStepDeltaBridgeException($message)';
}

class AndroidStepDeltaBridge {
  AndroidStepDeltaBridge({
    PlatformBridgeService? platformBridgeService,
    bool Function()? isAndroid,
  })  : _platformBridgeService =
            platformBridgeService ?? PlatformBridgeService(),
        _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final PlatformBridgeService _platformBridgeService;
  final bool Function() _isAndroid;

  Future<List<BackgroundStepDeltaEvent>> drainBackgroundStepDeltas() async {
    if (!_isAndroid()) {
      return const <BackgroundStepDeltaEvent>[];
    }

    try {
      final payload = await _platformBridgeService.methodChannel
              .invokeMethod<List<Object?>>(
            'android.steps.drainBackgroundDeltas',
          ) ??
          const <Object?>[];
      return payload
          .whereType<Map<Object?, Object?>>()
          .map(BackgroundStepDeltaEvent.fromChannelPayload)
          .where((BackgroundStepDeltaEvent item) => item.isValid)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw AndroidStepDeltaBridgeException(
        '读取 Android 后台步数增量失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<List<NativeStepDaySummary>> readHistoricalStepDays({
    int maxDays = 30,
  }) async {
    if (!_isAndroid()) {
      return const <NativeStepDaySummary>[];
    }

    try {
      final payload =
          await _platformBridgeService.methodChannel.invokeListMethod<Object?>(
                'android.steps.readHistoricalDays',
                <String, Object>{'maxDays': maxDays},
              ) ??
              const <Object?>[];
      return payload
          .map(NativeStepDaySummary.fromChannelPayload)
          .where((NativeStepDaySummary item) => item.isValid)
          .toList(growable: false);
    } on MissingPluginException {
      return const <NativeStepDaySummary>[];
    } on PlatformException catch (error) {
      throw AndroidStepDeltaBridgeException(
        '读取 Android 普通计步历史失败: ${error.message ?? error.code}',
      );
    }
  }
}
