import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

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
      mapPermissionStatus(permission_handler.PermissionStatus.permanentlyDenied),
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
}
