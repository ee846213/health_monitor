import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/background_capture_bootstrap.dart';
import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';

void main() {
  test('宿主已在运行时不应重复启动后台采集', () async {
    var startCount = 0;
    final service = AndroidBackgroundCaptureBootstrapService(
      startBackgroundCapture: (AndroidBackgroundCaptureConfig config) async {
        startCount += 1;
      },
      getHostStatus: () async {
        return const AndroidBackgroundCaptureHostStatus(
          isRunning: true,
          summary: 'running',
        );
      },
      isAndroid: () => true,
    );

    await service.sync();

    expect(startCount, 0);
  });

  test('宿主未运行时应启动后台采集', () async {
    var startCount = 0;
    AndroidBackgroundCaptureConfig? capturedConfig;
    final service = AndroidBackgroundCaptureBootstrapService(
      startBackgroundCapture: (AndroidBackgroundCaptureConfig config) async {
        startCount += 1;
        capturedConfig = config;
      },
      getHostStatus: () async {
        return const AndroidBackgroundCaptureHostStatus(
          isRunning: false,
          summary: 'stopped',
        );
      },
      isAndroid: () => true,
    );

    await service.sync();

    expect(startCount, 1);
    expect(capturedConfig?.sampleIntervalMinutes, 15);
    expect(capturedConfig?.enableMotion, isTrue);
  });
}
