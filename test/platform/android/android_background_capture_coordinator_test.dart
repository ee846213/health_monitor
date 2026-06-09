import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/android_foreground_service_strategy.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/platform/android/android_background_capture_coordinator.dart';
import 'package:health_monitor/services/background_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  test('后台状态可运行时应启动 Android 后台采集', () async {
    final bridge = _FakeAndroidBackgroundCaptureGateway();
    final coordinator = AndroidBackgroundCaptureCoordinator(
      backgroundCaptureStateService: const FakeBackgroundCaptureService(
        BackgroundCaptureState(
          status: BackgroundCaptureStatus.running,
          label: '后台采集中',
          reason: '前台服务已就绪。',
        ),
      ),
      foregroundServiceStrategyResolver: const AndroidForegroundServiceStrategyResolver(),
      backgroundCaptureGateway: bridge,
    );

    final state = await coordinator.syncCapture(
      capabilitySet: CapabilityMatrix.defaultMatrix().android,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.backgroundCapture: PermissionGrantStatus.granted,
      },
      config: _testConfig,
    );

    expect(state.status, BackgroundCaptureStatus.running);
    expect(bridge.startedConfigs, <AndroidBackgroundCaptureConfig>[_testConfig]);
    expect(bridge.stopCallCount, 0);
  });

  test('后台状态不可运行时应停止 Android 后台采集', () async {
    final bridge = _FakeAndroidBackgroundCaptureGateway();
    final coordinator = AndroidBackgroundCaptureCoordinator(
      backgroundCaptureStateService: const FakeBackgroundCaptureService(
        BackgroundCaptureState(
          status: BackgroundCaptureStatus.permissionDenied,
          label: '后台权限未开启',
          reason: '当前只会在前台积累样本。',
        ),
      ),
      foregroundServiceStrategyResolver: const AndroidForegroundServiceStrategyResolver(),
      backgroundCaptureGateway: bridge,
    );

    final state = await coordinator.syncCapture(
      capabilitySet: CapabilityMatrix.defaultMatrix().android,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.backgroundCapture: PermissionGrantStatus.denied,
      },
      config: _testConfig,
    );

    expect(state.status, BackgroundCaptureStatus.permissionDenied);
    expect(bridge.startedConfigs, isEmpty);
    expect(bridge.stopCallCount, 1);
  });
}

const AndroidBackgroundCaptureConfig _testConfig = AndroidBackgroundCaptureConfig(
  notificationTitle: '健康监测正在后台运行',
  notificationBody: '用于持续积累活动、位置与用机样本。',
  enableMotion: true,
  enableLocation: true,
  enableNoise: false,
  enableDigitalUsage: true,
  sampleIntervalMinutes: 15,
);

class _FakeAndroidBackgroundCaptureGateway
    implements AndroidBackgroundCaptureGateway {
  final List<AndroidBackgroundCaptureConfig> startedConfigs =
      <AndroidBackgroundCaptureConfig>[];
  int stopCallCount = 0;

  @override
  Future<void> startBackgroundCapture(
    AndroidBackgroundCaptureConfig config,
  ) async {
    startedConfigs.add(config);
  }

  @override
  Future<void> stopBackgroundCapture() async {
    stopCallCount += 1;
  }
}
