import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/background/android_foreground_service_strategy.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  const resolver = AndroidForegroundServiceStrategyResolver();
  const config = AndroidBackgroundCaptureConfig(
    notificationTitle: '健康监测正在后台运行',
    notificationBody: '用于持续积累活动、位置与用机样本。',
    enableMotion: true,
    enableLocation: true,
    enableNoise: false,
    enableDigitalUsage: true,
    sampleIntervalMinutes: 15,
  );

  test('权限和平台能力都满足时应启用前台服务策略', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().android,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.backgroundCapture: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(strategy.isEnabled, isTrue);
    expect(strategy.shouldShowNotification, isTrue);
    expect(strategy.title, config.notificationTitle);
    expect(strategy.body, config.notificationBody);
    expect(strategy.reasons, isEmpty);
  });

  test('后台权限不足时应输出降级原因', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().android,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.backgroundCapture: PermissionGrantStatus.denied,
      },
      config: config,
    );

    expect(strategy.isEnabled, isFalse);
    expect(strategy.reasons, isNotEmpty);
    expect(strategy.body, contains('后台采集权限未开启'));
  });
}
