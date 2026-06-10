import 'package:flutter/services.dart';
import 'package:health_monitor/domain/background/ios_background_capture_config.dart';
import 'package:health_monitor/domain/background/ios_background_capture_host_status.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

class IosBackgroundCaptureException implements Exception {
  const IosBackgroundCaptureException(this.message);

  final String message;

  @override
  String toString() => 'IosBackgroundCaptureException($message)';
}

abstract class IosBackgroundCaptureHostStatusService {
  Future<IosBackgroundCaptureHostStatus> getHostStatus();
}

class IosBackgroundCaptureBridge implements IosBackgroundCaptureHostStatusService {
  IosBackgroundCaptureBridge({
    required PlatformBridgeService platformBridgeService,
  }) : _platformBridgeService = platformBridgeService;

  final PlatformBridgeService _platformBridgeService;

  Future<void> startBackgroundCapture(IosBackgroundCaptureConfig config) async {
    try {
      await _platformBridgeService.methodChannel.invokeMethod<void>(
        'ios.background.start',
        config.channelPayload(),
      );
    } on PlatformException catch (error) {
      throw IosBackgroundCaptureException(
        '启动 iPhone 后台刷新失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<void> stopBackgroundCapture() async {
    try {
      await _platformBridgeService.methodChannel.invokeMethod<void>(
        'ios.background.stop',
      );
    } on PlatformException catch (error) {
      throw IosBackgroundCaptureException(
        '停止 iPhone 后台刷新失败: ${error.message ?? error.code}',
      );
    }
  }

  @override
  Future<IosBackgroundCaptureHostStatus> getHostStatus() async {
    try {
      final payload =
          await _platformBridgeService.methodChannel
              .invokeMapMethod<Object?, Object?>('ios.background.status') ??
          const <Object?, Object?>{};
      return IosBackgroundCaptureHostStatus.fromChannelPayload(payload);
    } on PlatformException catch (error) {
      throw IosBackgroundCaptureException(
        '读取 iPhone 宿主后台状态失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<IosBackgroundCaptureHostStatus> markBackgroundCaptureError(
    String message,
  ) async {
    try {
      final payload =
          await _platformBridgeService.methodChannel.invokeMapMethod<Object?, Object?>(
            'ios.background.error',
            <String, Object>{
              'message': message,
            },
          ) ??
          const <Object?, Object?>{};
      return IosBackgroundCaptureHostStatus.fromChannelPayload(payload);
    } on PlatformException catch (error) {
      throw IosBackgroundCaptureException(
        '上报 iPhone 宿主后台异常失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<IosBackgroundCaptureHostStatus> refreshBackgroundCapture() async {
    try {
      final payload =
          await _platformBridgeService.methodChannel.invokeMapMethod<Object?, Object?>(
            'ios.background.refresh',
          ) ??
          const <Object?, Object?>{};
      return IosBackgroundCaptureHostStatus.fromChannelPayload(payload);
    } on PlatformException catch (error) {
      throw IosBackgroundCaptureException(
        '刷新 iPhone 宿主后台调度失败: ${error.message ?? error.code}',
      );
    }
  }
}

class FakeIosBackgroundCaptureHostStatusService
    implements IosBackgroundCaptureHostStatusService {
  const FakeIosBackgroundCaptureHostStatusService(this._status);

  final IosBackgroundCaptureHostStatus _status;

  @override
  Future<IosBackgroundCaptureHostStatus> getHostStatus() async {
    return _status;
  }
}
