import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health_monitor/domain/motion/hourly_step_bucket.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

class HealthConnectBridge {
  HealthConnectBridge({
    PlatformBridgeService? platformBridgeService,
    bool Function()? isAndroid,
  })  : _platformBridgeService = platformBridgeService ?? PlatformBridgeService(),
        _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final PlatformBridgeService _platformBridgeService;
  final bool Function() _isAndroid;

  Future<HealthConnectStatus> getStatus() async {
    if (!_isAndroid()) {
      return const HealthConnectStatus(
        isAvailable: false,
        hasStepsPermission: false,
        needsInstall: false,
      );
    }
    try {
      final payload = await _platformBridgeService.methodChannel
              .invokeMapMethod<Object?, Object?>('android.healthConnect.getStatus') ??
          const <Object?, Object?>{};
      return HealthConnectStatus.fromChannelPayload(payload);
    } on PlatformException {
      return const HealthConnectStatus(
        isAvailable: false,
        hasStepsPermission: false,
        needsInstall: false,
      );
    }
  }

  Future<List<HourlyStepBucket>> readHourlySteps({
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    if (!_isAndroid()) {
      return const <HourlyStepBucket>[];
    }
    try {
      final payload = await _platformBridgeService.methodChannel
          .invokeListMethod<Object?>('android.healthConnect.readHourlySteps', <String, Object>{
        'startMillis': startAt.millisecondsSinceEpoch,
        'endMillis': endAt.millisecondsSinceEpoch,
      });
      return payload
              ?.map(HourlyStepBucket.fromChannelPayload)
              .where((HourlyStepBucket item) => item.isValid)
              .toList(growable: false) ??
          const <HourlyStepBucket>[];
    } on PlatformException {
      return const <HourlyStepBucket>[];
    }
  }

  Future<bool> requestPermissions() async {
    if (!_isAndroid()) {
      return false;
    }
    try {
      final payload = await _platformBridgeService.methodChannel
          .invokeMapMethod<Object?, Object?>(
        'android.healthConnect.requestPermissions',
      );
      return payload?['granted'] as bool? ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openSettings() async {
    if (!_isAndroid()) {
      return false;
    }
    try {
      return await _platformBridgeService.methodChannel
              .invokeMethod<bool>('android.healthConnect.openSettings') ??
          false;
    } on PlatformException {
      return false;
    }
  }
}
