import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/android_permission_bridge.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

enum PermissionGrantStatus {
  granted,
  denied,
  restricted,
  unknown,
}

enum PermissionActionResult {
  granted,
  denied,
  openedSettings,
  settingsUnavailable,
}

abstract class PermissionStatusService {
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses();
}

abstract class PermissionInteractionService {
  Future<PermissionActionResult> handlePermissionTap(PermissionType type);
}

typedef PermissionStatusReader = Future<PermissionGrantStatus> Function(
  PermissionType type,
);

class PermissionHandlerStatusService implements PermissionStatusService {
  const PermissionHandlerStatusService({
    AndroidPermissionBridge? androidPermissionBridge,
    PermissionStatusReader? runtimeStatusReader,
  })  : _androidPermissionBridge =
            androidPermissionBridge ?? const PlatformAndroidPermissionBridge(),
        _runtimeStatusReader =
            runtimeStatusReader ?? _defaultRuntimeStatusReader;

  final AndroidPermissionBridge _androidPermissionBridge;
  final PermissionStatusReader _runtimeStatusReader;

  @override
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses() async {
    final result = <PermissionType, PermissionGrantStatus>{};

    for (final PermissionType type in PermissionType.values) {
      result[type] = await _readPermissionStatus(type);
    }

    return result;
  }

  Future<PermissionGrantStatus> _readPermissionStatus(
    PermissionType type,
  ) async {
    switch (type) {
      case PermissionType.usageAccess:
        // Usage Access 不是 runtime permission，permission_handler 不能可靠读取。
        // 这里改走 Android 原生桥接，避免把系统授权误判成普通权限状态。
        final hasUsageAccess = await _androidPermissionBridge.hasUsageAccess();
        return hasUsageAccess
            ? PermissionGrantStatus.granted
            : PermissionGrantStatus.restricted;
      case PermissionType.healthConnect:
        final hasHealthConnectPermission =
            await _androidPermissionBridge.hasHealthConnectStepsPermission();
        return hasHealthConnectPermission
            ? PermissionGrantStatus.granted
            : PermissionGrantStatus.restricted;
      case PermissionType.backgroundCapture:
      case PermissionType.motion:
      case PermissionType.location:
      case PermissionType.microphone:
      case PermissionType.notification:
        return _runtimeStatusReader(type);
    }
  }

  static Future<PermissionGrantStatus> _defaultRuntimeStatusReader(
    PermissionType type,
  ) async {
    final permission_handler.Permission permission = mapPermissionType(type);
    final permission_handler.PermissionStatus status = await permission.status;
    return mapPermissionStatus(status);
  }
}

class PermissionRequestCoordinator {
  const PermissionRequestCoordinator({
    required this.statusReader,
    required this.requester,
    required this.appSettingsOpener,
  });

  final Future<PermissionGrantStatus> Function(PermissionType type) statusReader;
  final Future<PermissionGrantStatus> Function(PermissionType type) requester;
  final Future<bool> Function() appSettingsOpener;

  Future<PermissionActionResult> resolvePermissionAction(
    PermissionType type,
  ) async {
    final currentStatus = await statusReader(type);
    if (currentStatus == PermissionGrantStatus.granted) {
      return PermissionActionResult.granted;
    }

    if (currentStatus == PermissionGrantStatus.restricted) {
      final opened = await appSettingsOpener();
      return opened
          ? PermissionActionResult.openedSettings
          : PermissionActionResult.settingsUnavailable;
    }

    final requestedStatus = await requester(type);
    if (requestedStatus == PermissionGrantStatus.granted) {
      return PermissionActionResult.granted;
    }
    if (requestedStatus == PermissionGrantStatus.restricted) {
      final opened = await appSettingsOpener();
      return opened
          ? PermissionActionResult.openedSettings
          : PermissionActionResult.settingsUnavailable;
    }
    return PermissionActionResult.denied;
  }
}

class PermissionHandlerInteractionService
    implements PermissionInteractionService {
  PermissionHandlerInteractionService({
    PermissionRequestCoordinator? coordinator,
    AndroidPermissionBridge? androidPermissionBridge,
  })  : _androidPermissionBridge =
            androidPermissionBridge ?? const PlatformAndroidPermissionBridge(),
        _coordinator =
            coordinator ??
            const PermissionRequestCoordinator(
              statusReader: _readStatus,
              requester: _requestPermission,
              appSettingsOpener: _openAppSettings,
            );

  final AndroidPermissionBridge _androidPermissionBridge;
  final PermissionRequestCoordinator _coordinator;

  @override
  Future<PermissionActionResult> handlePermissionTap(PermissionType type) {
    if (type == PermissionType.usageAccess) {
      return _handleUsageAccessTap();
    }
    if (type == PermissionType.healthConnect) {
      return _handleHealthConnectTap();
    }
    return _coordinator.resolvePermissionAction(type);
  }

  static Future<PermissionGrantStatus> _readStatus(PermissionType type) async {
    final permission = mapPermissionType(type);
    return mapPermissionStatus(await permission.status);
  }

  static Future<PermissionGrantStatus> _requestPermission(
    PermissionType type,
  ) async {
    final permission = mapPermissionType(type);
    return mapPermissionStatus(await permission.request());
  }

  Future<PermissionActionResult> _handleUsageAccessTap() async {
    final currentStatus = await _androidPermissionBridge.hasUsageAccess();
    if (currentStatus) {
      return PermissionActionResult.granted;
    }

    final opened = await _androidPermissionBridge.openUsageAccessSettings();
    return opened
        ? PermissionActionResult.openedSettings
        : PermissionActionResult.settingsUnavailable;
  }

  Future<PermissionActionResult> _handleHealthConnectTap() async {
    final hasPermission =
        await _androidPermissionBridge.hasHealthConnectStepsPermission();
    if (hasPermission) {
      return PermissionActionResult.granted;
    }

    final granted =
        await _androidPermissionBridge.requestHealthConnectStepsPermission();
    if (granted) {
      return PermissionActionResult.granted;
    }

    final opened = await _androidPermissionBridge.openHealthConnectSettings();
    return opened
        ? PermissionActionResult.openedSettings
        : PermissionActionResult.settingsUnavailable;
  }

  static Future<bool> _openAppSettings() {
    return permission_handler.openAppSettings();
  }
}

class FakePermissionStatusService implements PermissionStatusService {
  const FakePermissionStatusService(this._statuses);

  final Map<PermissionType, PermissionGrantStatus> _statuses;

  @override
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses() async {
    return _statuses;
  }
}

class FakePermissionInteractionService
    implements PermissionInteractionService {
  const FakePermissionInteractionService({
    required this.handler,
  });

  final Future<PermissionActionResult> Function(PermissionType type) handler;

  @override
  Future<PermissionActionResult> handlePermissionTap(PermissionType type) {
    return handler(type);
  }
}

final permissionInteractionServiceProvider =
    Provider<PermissionInteractionService>((Ref ref) {
      return PermissionHandlerInteractionService();
    });

PermissionGrantStatus mapPermissionStatus(
  permission_handler.PermissionStatus status,
) {
  if (status == permission_handler.PermissionStatus.granted) {
    return PermissionGrantStatus.granted;
  }
  if (status == permission_handler.PermissionStatus.denied) {
    return PermissionGrantStatus.denied;
  }
  if (status == permission_handler.PermissionStatus.restricted ||
      status == permission_handler.PermissionStatus.limited ||
      status == permission_handler.PermissionStatus.permanentlyDenied ||
      status == permission_handler.PermissionStatus.provisional) {
    return PermissionGrantStatus.restricted;
  }
  return PermissionGrantStatus.unknown;
}

permission_handler.Permission mapPermissionType(PermissionType type) {
  switch (type) {
    case PermissionType.motion:
      return permission_handler.Permission.activityRecognition;
    case PermissionType.location:
      return permission_handler.Permission.locationWhenInUse;
    case PermissionType.microphone:
      return permission_handler.Permission.microphone;
    case PermissionType.notification:
      return permission_handler.Permission.notification;
    case PermissionType.usageAccess:
      // 这里只保留给历史上的 runtime 映射调用；真正的 Usage Access
      // 已由专用 Android 桥接接管，避免走错成 overlay 权限。
      return permission_handler.Permission.systemAlertWindow;
    case PermissionType.healthConnect:
      return permission_handler.Permission.activityRecognition;
    case PermissionType.backgroundCapture:
      return permission_handler.Permission.ignoreBatteryOptimizations;
  }
}
