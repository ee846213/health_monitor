import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/android_permission_bridge.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

void main() {
  test('权限状态映射应统一转换为领域层语义', () {
    expect(
      mapPermissionStatus(permission_handler.PermissionStatus.granted),
      PermissionGrantStatus.granted,
    );
    expect(
      mapPermissionStatus(permission_handler.PermissionStatus.denied),
      PermissionGrantStatus.denied,
    );
    expect(
      mapPermissionStatus(
          permission_handler.PermissionStatus.permanentlyDenied),
      PermissionGrantStatus.restricted,
    );
    expect(
      mapPermissionStatus(permission_handler.PermissionStatus.limited),
      PermissionGrantStatus.restricted,
    );
  });

  test('权限类型应映射到对应的 permission_handler 权限', () {
    expect(
      mapPermissionType(PermissionType.motion),
      permission_handler.Permission.activityRecognition,
    );
    expect(
      mapPermissionType(PermissionType.location),
      permission_handler.Permission.locationWhenInUse,
    );
    expect(
      mapPermissionType(PermissionType.microphone),
      permission_handler.Permission.microphone,
    );
    expect(
      mapPermissionType(PermissionType.notification),
      permission_handler.Permission.notification,
    );
  });

  test('Usage Access 状态应由原生桥接读取而不是沿用通用权限映射', () async {
    final bridge = _FakeAndroidPermissionBridge(
      hasUsageAccessValue: true,
      openUsageAccessSettingsValue: true,
    );
    final service = PermissionHandlerStatusService(
      androidPermissionBridge: bridge,
      runtimeStatusReader: (PermissionType type) async =>
          PermissionGrantStatus.denied,
    );

    final statuses = await service.getStatuses();

    expect(statuses[PermissionType.usageAccess], PermissionGrantStatus.granted);
    expect(bridge.hasUsageAccessCallCount, 1);
  });

  test('未永久拒绝时应优先再次申请权限', () async {
    final service = PermissionRequestCoordinator(
      statusReader: (PermissionType type) async => PermissionGrantStatus.denied,
      requester: (PermissionType type) async => PermissionGrantStatus.granted,
      appSettingsOpener: () async => true,
    );

    final result = await service.resolvePermissionAction(PermissionType.motion);

    expect(result, PermissionActionResult.granted);
  });

  test('永久拒绝时应引导去设置页', () async {
    var openedSettings = false;
    final service = PermissionRequestCoordinator(
      statusReader: (PermissionType type) async =>
          PermissionGrantStatus.restricted,
      requester: (PermissionType type) async =>
          PermissionGrantStatus.restricted,
      appSettingsOpener: () async {
        openedSettings = true;
        return true;
      },
    );

    final result =
        await service.resolvePermissionAction(PermissionType.microphone);

    expect(result, PermissionActionResult.openedSettings);
    expect(openedSettings, isTrue);
  });

  test('Usage Access 点击后应先走原生设置页桥接', () async {
    final bridge = _FakeAndroidPermissionBridge(
      hasUsageAccessValue: false,
      openUsageAccessSettingsValue: true,
    );
    final service = PermissionHandlerInteractionService(
      androidPermissionBridge: bridge,
    );

    final result =
        await service.handlePermissionTap(PermissionType.usageAccess);

    expect(result, PermissionActionResult.openedSettings);
    expect(bridge.hasUsageAccessCallCount, 1);
    expect(bridge.openUsageAccessSettingsCallCount, 1);
  });
  test('Health Connect 点击后应优先申请步数权限', () async {
    final bridge = _FakeAndroidPermissionBridge(
      hasUsageAccessValue: false,
      openUsageAccessSettingsValue: false,
      requestHealthConnectStepsPermissionValue: true,
    );
    final service = PermissionHandlerInteractionService(
      androidPermissionBridge: bridge,
    );

    final result =
        await service.handlePermissionTap(PermissionType.healthConnect);

    expect(result, PermissionActionResult.granted);
    expect(bridge.hasHealthConnectStepsPermissionCallCount, 1);
    expect(bridge.requestHealthConnectStepsPermissionCallCount, 1);
    expect(bridge.openHealthConnectSettingsCallCount, 0);
  });

  test('Health Connect 已授权时不应重复申请', () async {
    final bridge = _FakeAndroidPermissionBridge(
      hasUsageAccessValue: false,
      openUsageAccessSettingsValue: false,
      hasHealthConnectStepsPermissionValue: true,
    );
    final service = PermissionHandlerInteractionService(
      androidPermissionBridge: bridge,
    );

    final result =
        await service.handlePermissionTap(PermissionType.healthConnect);

    expect(result, PermissionActionResult.granted);
    expect(bridge.hasHealthConnectStepsPermissionCallCount, 1);
    expect(bridge.requestHealthConnectStepsPermissionCallCount, 0);
  });

  test('Health Connect 申请未通过时应打开专用设置页', () async {
    final bridge = _FakeAndroidPermissionBridge(
      hasUsageAccessValue: false,
      openUsageAccessSettingsValue: false,
      requestHealthConnectStepsPermissionValue: false,
      openHealthConnectSettingsValue: true,
    );
    final service = PermissionHandlerInteractionService(
      androidPermissionBridge: bridge,
    );

    final result =
        await service.handlePermissionTap(PermissionType.healthConnect);

    expect(result, PermissionActionResult.openedSettings);
    expect(bridge.requestHealthConnectStepsPermissionCallCount, 1);
    expect(bridge.openHealthConnectSettingsCallCount, 1);
  });
}

class _FakeAndroidPermissionBridge implements AndroidPermissionBridge {
  _FakeAndroidPermissionBridge({
    required this.hasUsageAccessValue,
    required this.openUsageAccessSettingsValue,
    this.hasHealthConnectStepsPermissionValue = false,
    this.requestHealthConnectStepsPermissionValue = false,
    this.openHealthConnectSettingsValue = false,
  });

  final bool hasUsageAccessValue;
  final bool openUsageAccessSettingsValue;
  final bool hasHealthConnectStepsPermissionValue;
  final bool requestHealthConnectStepsPermissionValue;
  final bool openHealthConnectSettingsValue;
  int hasUsageAccessCallCount = 0;
  int openUsageAccessSettingsCallCount = 0;
  int hasHealthConnectStepsPermissionCallCount = 0;
  int requestHealthConnectStepsPermissionCallCount = 0;
  int openHealthConnectSettingsCallCount = 0;

  @override
  Future<bool> hasUsageAccess() async {
    hasUsageAccessCallCount += 1;
    return hasUsageAccessValue;
  }

  @override
  Future<bool> openUsageAccessSettings() async {
    openUsageAccessSettingsCallCount += 1;
    return openUsageAccessSettingsValue;
  }

  @override
  Future<bool> hasHealthConnectStepsPermission() async {
    hasHealthConnectStepsPermissionCallCount += 1;
    return hasHealthConnectStepsPermissionValue;
  }

  @override
  Future<bool> requestHealthConnectStepsPermission() async {
    requestHealthConnectStepsPermissionCallCount += 1;
    return requestHealthConnectStepsPermissionValue;
  }

  @override
  Future<bool> openHealthConnectSettings() async {
    openHealthConnectSettingsCallCount += 1;
    return openHealthConnectSettingsValue;
  }
}
