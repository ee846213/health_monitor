import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health_monitor/domain/risk/walking_screen_risk_event.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

class AndroidRiskEventBridgeException implements Exception {
  const AndroidRiskEventBridgeException(this.message);

  final String message;

  @override
  String toString() => 'AndroidRiskEventBridgeException($message)';
}

class AndroidRiskEventBridge {
  AndroidRiskEventBridge({
    PlatformBridgeService? platformBridgeService,
    bool Function()? isAndroid,
  }) : _platformBridgeService = platformBridgeService ?? PlatformBridgeService(),
       _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final PlatformBridgeService _platformBridgeService;
  final bool Function() _isAndroid;

  Future<List<WalkingScreenRiskEvent>> drainWalkingScreenRiskEvents() async {
    if (!_isAndroid()) {
      return const <WalkingScreenRiskEvent>[];
    }

    try {
      final payload =
          await _platformBridgeService.methodChannel.invokeMethod<List<Object?>>(
            'android.riskEvents.drainWalkingScreenRisks',
          ) ??
          const <Object?>[];
      return payload
          .whereType<Map<Object?, Object?>>()
          .map(WalkingScreenRiskEvent.fromChannelPayload)
          .where((WalkingScreenRiskEvent item) => item.eventId.isNotEmpty)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw AndroidRiskEventBridgeException(
        '读取 Android 精确风险事件失败: ${error.message ?? error.code}',
      );
    }
  }
}
