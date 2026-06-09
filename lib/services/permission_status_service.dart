import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

enum PermissionGrantStatus {
  granted,
  denied,
  restricted,
  unknown,
}

abstract class PermissionStatusService {
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses();
}

class PermissionHandlerStatusService implements PermissionStatusService {
  const PermissionHandlerStatusService();

  @override
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses() async {
    final result = <PermissionType, PermissionGrantStatus>{};

    for (final PermissionType type in PermissionType.values) {
      final permission_handler.Permission permission = mapPermissionType(type);
      final permission_handler.PermissionStatus status = await permission.status;
      result[type] = mapPermissionStatus(status);
    }

    return result;
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

PermissionGrantStatus mapPermissionStatus(permission_handler.PermissionStatus status) {
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
      return permission_handler.Permission.systemAlertWindow;
    case PermissionType.backgroundCapture:
      return permission_handler.Permission.ignoreBatteryOptimizations;
  }
}
