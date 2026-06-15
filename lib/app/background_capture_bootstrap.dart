import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/services/android_background_capture_bridge.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

class AndroidBackgroundCaptureBootstrapService {
  AndroidBackgroundCaptureBootstrapService({
    required this.startBackgroundCapture,
    required this.getHostStatus,
    bool Function()? isAndroid,
    this.config = const AndroidBackgroundCaptureConfig(
      notificationTitle: '健康监测正在后台运行',
      notificationBody: '用于持续记录步数、活动与位置样本。',
      enableMotion: true,
      enableLocation: true,
      enableNoise: false,
      enableDigitalUsage: true,
      sampleIntervalMinutes: 15,
    ),
  }) : _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final Future<void> Function(AndroidBackgroundCaptureConfig config) startBackgroundCapture;
  final Future<AndroidBackgroundCaptureHostStatus> Function() getHostStatus;
  final bool Function() _isAndroid;
  final AndroidBackgroundCaptureConfig config;

  Future<void> sync() async {
    if (!_isAndroid()) {
      return;
    }

    try {
      final status = await getHostStatus();
      if (status.isRunning) {
        return;
      }
    } catch (_) {
      // 宿主状态不可读时，直接走启动兜底，避免后台链路意外中断。
    }

    await startBackgroundCapture(config);
  }
}

final androidBackgroundCaptureBridgeProvider =
    Provider<AndroidBackgroundCaptureBridge>((Ref ref) {
      return AndroidBackgroundCaptureBridge(
        platformBridgeService: PlatformBridgeService(),
      );
    });

final androidBackgroundCaptureBootstrapServiceProvider =
    Provider<AndroidBackgroundCaptureBootstrapService>((Ref ref) {
      final bridge = ref.watch(androidBackgroundCaptureBridgeProvider);
      return AndroidBackgroundCaptureBootstrapService(
        startBackgroundCapture: bridge.startBackgroundCapture,
        getHostStatus: bridge.getHostStatus,
      );
    });
