import 'package:flutter/services.dart';
import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

class AndroidBackgroundCaptureException implements Exception {
  const AndroidBackgroundCaptureException(this.message);

  final String message;

  @override
  String toString() => 'AndroidBackgroundCaptureException($message)';
}

abstract class AndroidBackgroundCaptureHostStatusService {
  Future<AndroidBackgroundCaptureHostStatus> getHostStatus();
}

class AndroidBackgroundCaptureBridge
    implements AndroidBackgroundCaptureHostStatusService {
  AndroidBackgroundCaptureBridge({
    required PlatformBridgeService platformBridgeService,
  }) : _platformBridgeService = platformBridgeService;

  final PlatformBridgeService _platformBridgeService;

  Future<void> startBackgroundCapture(
    AndroidBackgroundCaptureConfig config,
  ) async {
    try {
      await _platformBridgeService.methodChannel.invokeMethod<void>(
        'android.background.start',
        config.channelPayload(),
      );
    } on PlatformException catch (error) {
      throw AndroidBackgroundCaptureException(
        '启动 Android 后台采集失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<void> stopBackgroundCapture() async {
    try {
      await _platformBridgeService.methodChannel.invokeMethod<void>(
        'android.background.stop',
      );
    } on PlatformException catch (error) {
      throw AndroidBackgroundCaptureException(
        '停止 Android 后台采集失败: ${error.message ?? error.code}',
      );
    }
  }

  @override
  Future<AndroidBackgroundCaptureHostStatus> getHostStatus() async {
    try {
      final payload =
          await _platformBridgeService.methodChannel
              .invokeMapMethod<Object?, Object?>('android.background.status') ??
          const <Object?, Object?>{};
      return AndroidBackgroundCaptureHostStatus.fromChannelPayload(payload);
    } on PlatformException catch (error) {
      throw AndroidBackgroundCaptureException(
        '读取 Android 宿主后台状态失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<AndroidBackgroundCaptureHostStatus> markBackgroundCaptureError(
    String message,
  ) async {
    try {
      final payload =
          await _platformBridgeService.methodChannel.invokeMapMethod<Object?, Object?>(
            'android.background.error',
            <String, Object>{
              'message': message,
            },
          ) ??
          const <Object?, Object?>{};
      return AndroidBackgroundCaptureHostStatus.fromChannelPayload(payload);
    } on PlatformException catch (error) {
      throw AndroidBackgroundCaptureException(
        '上报 Android 宿主后台异常失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<AndroidBackgroundCaptureHostStatus> refreshBackgroundCapture() async {
    try {
      final payload =
          await _platformBridgeService.methodChannel.invokeMapMethod<Object?, Object?>(
            'android.background.refresh',
          ) ??
          const <Object?, Object?>{};
      return AndroidBackgroundCaptureHostStatus.fromChannelPayload(payload);
    } on PlatformException catch (error) {
      throw AndroidBackgroundCaptureException(
        '刷新 Android 宿主后台调度失败: ${error.message ?? error.code}',
      );
    }
  }
}

class FakeAndroidBackgroundCaptureHostStatusService
    implements AndroidBackgroundCaptureHostStatusService {
  const FakeAndroidBackgroundCaptureHostStatusService(this._status);

  final AndroidBackgroundCaptureHostStatus _status;

  @override
  Future<AndroidBackgroundCaptureHostStatus> getHostStatus() async {
    return _status;
  }
}
