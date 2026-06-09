import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/android_background_capture_bridge.dart';
import 'package:health_monitor/services/background_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';

abstract class AndroidBackgroundCaptureGateway {
  Future<void> startBackgroundCapture(AndroidBackgroundCaptureConfig config);

  Future<void> stopBackgroundCapture();
}

class AndroidBackgroundCaptureCoordinator {
  AndroidBackgroundCaptureCoordinator({
    required BackgroundCaptureStateService backgroundCaptureStateService,
    required AndroidBackgroundCaptureGateway backgroundCaptureGateway,
  }) : _backgroundCaptureStateService = backgroundCaptureStateService,
       _backgroundCaptureGateway = backgroundCaptureGateway;

  final BackgroundCaptureStateService _backgroundCaptureStateService;
  final AndroidBackgroundCaptureGateway _backgroundCaptureGateway;

  Future<BackgroundCaptureState> syncCapture({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
    required AndroidBackgroundCaptureConfig config,
  }) async {
    final state = await _backgroundCaptureStateService.evaluateState(
      capabilitySet: capabilitySet,
      permissionStatuses: permissionStatuses,
    );

    // 先用共享状态模型统一决定启停，避免页面层绕过降级规则直接驱动原生后台能力。
    if (state.status == BackgroundCaptureStatus.running) {
      await _backgroundCaptureGateway.startBackgroundCapture(config);
      return state;
    }

    // 对受限、暂停、失败与权限不足场景统一执行停止，
    // 可以避免原生侧继续沿用过期配置在后台保活。
    await _backgroundCaptureGateway.stopBackgroundCapture();
    return state;
  }
}

class AndroidBackgroundCaptureBridgeGateway
    implements AndroidBackgroundCaptureGateway {
  const AndroidBackgroundCaptureBridgeGateway(this._bridge);

  final AndroidBackgroundCaptureBridge _bridge;

  @override
  Future<void> startBackgroundCapture(
    AndroidBackgroundCaptureConfig config,
  ) {
    return _bridge.startBackgroundCapture(config);
  }

  @override
  Future<void> stopBackgroundCapture() {
    return _bridge.stopBackgroundCapture();
  }
}
