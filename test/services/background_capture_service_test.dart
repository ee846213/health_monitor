import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/background_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  test('权限和平台能力都满足时应返回运行中状态', () async {
    const service = BackgroundCaptureService();

    final state = await service.evaluateState(
      capabilitySet: CapabilityMatrix.defaultMatrix().android,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.backgroundCapture: PermissionGrantStatus.granted,
      },
    );

    expect(state.status, BackgroundCaptureStatus.running);
  });

  test('后台权限未开启时应返回权限不足状态', () async {
    const service = BackgroundCaptureService();

    final state = await service.evaluateState(
      capabilitySet: CapabilityMatrix.defaultMatrix().android,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.backgroundCapture: PermissionGrantStatus.denied,
      },
    );

    expect(state.status, BackgroundCaptureStatus.permissionDenied);
    expect(state.label, contains('未开启'));
  });

  test('平台仅支持受限后台能力时应返回受限状态', () async {
    const service = BackgroundCaptureService();

    final state = await service.evaluateState(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
        PermissionType.backgroundCapture: PermissionGrantStatus.granted,
      },
    );

    expect(state.status, BackgroundCaptureStatus.restricted);
    expect(state.reason, contains('系统'));
  });
}
