import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/permission_status_service.dart';

class AndroidForegroundServiceStrategy {
  const AndroidForegroundServiceStrategy({
    required this.isEnabled,
    required this.title,
    required this.body,
    required this.sampleIntervalMinutes,
    required this.reasons,
  });

  final bool isEnabled;
  final String title;
  final String body;
  final int sampleIntervalMinutes;
  final List<String> reasons;

  bool get shouldShowNotification => isEnabled;
}

class AndroidForegroundServiceStrategyResolver {
  const AndroidForegroundServiceStrategyResolver();

  AndroidForegroundServiceStrategy resolve({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
    required AndroidBackgroundCaptureConfig config,
  }) {
    final reasons = <String>[];

    final backgroundPermission =
        permissionStatuses[PermissionType.backgroundCapture] ??
        PermissionGrantStatus.unknown;
    if (backgroundPermission != PermissionGrantStatus.granted) {
      reasons.add('后台采集权限未开启，前台服务只能用于保持宿主在线，不能保证连续采集。');
    }

    final motionPermission =
        permissionStatuses[PermissionType.motion] ?? PermissionGrantStatus.unknown;
    final locationPermission =
        permissionStatuses[PermissionType.location] ?? PermissionGrantStatus.unknown;
    if (motionPermission != PermissionGrantStatus.granted ||
        locationPermission != PermissionGrantStatus.granted) {
      reasons.add('运动或位置前置权限不足，需要先降级当前采集组合。');
    }

    if (capabilitySet.backgroundCapture == CapabilitySupport.unsupported) {
      reasons.add('当前平台不支持所需的后台连续性能力。');
    } else if (capabilitySet.backgroundCapture == CapabilitySupport.limited) {
      reasons.add('当前平台的后台连续性受系统限制，前台服务只作为受限保活方案。');
    }

    final isEnabled = reasons.isEmpty;
    return AndroidForegroundServiceStrategy(
      isEnabled: isEnabled,
      title: config.notificationTitle,
      body: isEnabled ? config.notificationBody : reasons.join(''),
      sampleIntervalMinutes: config.sampleIntervalMinutes,
      reasons: reasons,
    );
  }
}
