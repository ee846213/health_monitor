import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/permission_status_service.dart';

abstract class BackgroundCaptureStateService {
  Future<BackgroundCaptureState> evaluateState({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  });
}

class BackgroundCaptureService implements BackgroundCaptureStateService {
  const BackgroundCaptureService();

  @override
  Future<BackgroundCaptureState> evaluateState({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  }) async {
    final backgroundPermission =
        permissionStatuses[PermissionType.backgroundCapture] ??
        PermissionGrantStatus.unknown;
    final motionPermission =
        permissionStatuses[PermissionType.motion] ?? PermissionGrantStatus.unknown;
    final locationPermission =
        permissionStatuses[PermissionType.location] ?? PermissionGrantStatus.unknown;

    if (backgroundPermission != PermissionGrantStatus.granted) {
      return const BackgroundCaptureState(
        status: BackgroundCaptureStatus.permissionDenied,
        label: '后台权限未开启',
        reason: '当前只会在前台积累样本，无法形成连续后台链路。',
      );
    }

    if (motionPermission != PermissionGrantStatus.granted ||
        locationPermission != PermissionGrantStatus.granted) {
      return const BackgroundCaptureState(
        status: BackgroundCaptureStatus.paused,
        label: '后台采集已暂停',
        reason: '运动或位置前置权限不足，后台链路暂时不能稳定工作。',
      );
    }

    if (capabilitySet.backgroundCapture == CapabilitySupport.limited) {
      return const BackgroundCaptureState(
        status: BackgroundCaptureStatus.restricted,
        label: '后台能力受限',
        reason: '系统限制了当前平台的后台连续性，需要接受受限运行。',
      );
    }

    if (capabilitySet.backgroundCapture == CapabilitySupport.unsupported) {
      return const BackgroundCaptureState(
        status: BackgroundCaptureStatus.failed,
        label: '后台采集不可用',
        reason: '当前平台不支持所需的后台采集能力。',
      );
    }

    return const BackgroundCaptureState(
      status: BackgroundCaptureStatus.running,
      label: '后台采集中',
      reason: '后台权限、前置权限与平台能力都已满足。',
    );
  }
}

class FakeBackgroundCaptureService implements BackgroundCaptureStateService {
  const FakeBackgroundCaptureService(this._state);

  final BackgroundCaptureState _state;

  @override
  Future<BackgroundCaptureState> evaluateState({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  }) async {
    return _state;
  }
}
