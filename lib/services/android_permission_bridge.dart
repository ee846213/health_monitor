import 'package:flutter/services.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

abstract class AndroidPermissionBridge {
  Future<bool> hasUsageAccess();

  Future<bool> openUsageAccessSettings();

  Future<bool> hasHealthConnectStepsPermission();

  Future<bool> requestHealthConnectStepsPermission();

  Future<bool> openHealthConnectSettings();
}

class PlatformAndroidPermissionBridge implements AndroidPermissionBridge {
  const PlatformAndroidPermissionBridge();

  @override
  Future<bool> hasUsageAccess() {
    return _invokeBool('android.permissions.hasUsageAccess');
  }

  @override
  Future<bool> openUsageAccessSettings() {
    return _invokeBool('android.permissions.openUsageAccessSettings');
  }

  @override
  Future<bool> hasHealthConnectStepsPermission() async {
    try {
      final platformBridgeService = PlatformBridgeService();
      final payload = await platformBridgeService.methodChannel
              .invokeMapMethod<Object?, Object?>('android.healthConnect.getStatus') ??
          const <Object?, Object?>{};
      return payload['hasStepsPermission'] as bool? ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> requestHealthConnectStepsPermission() async {
    try {
      final platformBridgeService = PlatformBridgeService();
      final payload = await platformBridgeService.methodChannel
          .invokeMapMethod<Object?, Object?>(
        'android.healthConnect.requestPermissions',
      );
      return payload?['granted'] as bool? ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> openHealthConnectSettings() {
    return _invokeBool('android.healthConnect.openSettings');
  }

  Future<bool> _invokeBool(String method) async {
    // 这里直接复用统一平台桥接，避免权限层再额外维护一套原生通道。
    // 某些平台如果尚未实现对应方法，统一按“未开启/不可用”处理，
    // 这样上层可以继续降级运行，而不是因为缺少原生实现直接崩溃。
    final platformBridgeService = PlatformBridgeService();
    try {
      return await platformBridgeService.methodChannel
              .invokeMethod<bool>(method) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
