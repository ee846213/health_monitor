import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';

void main() {
  test('默认权限说明应覆盖阶段 0 要求的核心权限', () {
    final descriptors = PermissionDescriptor.defaults();

    expect(descriptors, hasLength(6));
    expect(
      descriptors.map((descriptor) => descriptor.type),
      containsAll(<PermissionType>[
        PermissionType.motion,
        PermissionType.location,
        PermissionType.microphone,
        PermissionType.notification,
        PermissionType.usageAccess,
        PermissionType.backgroundCapture,
      ]),
    );
  });

  test('每个权限说明都应包含中文用途、缺失影响与降级策略', () {
    final descriptor = PermissionDescriptor.defaults().firstWhere(
      (item) => item.type == PermissionType.location,
    );

    expect(descriptor.title, '位置权限');
    expect(descriptor.whyNeeded, contains('位置摘要'));
    expect(descriptor.analysisUsage, contains('活动'));
    expect(descriptor.missingImpact, isNotEmpty);
    expect(descriptor.degradeBehavior, contains('降级'));
    expect(descriptor.required, isFalse);
  });

  test('Usage Access 应标记为 Android 专属高限制权限', () {
    final descriptor = PermissionDescriptor.defaults().firstWhere(
      (item) => item.type == PermissionType.usageAccess,
    );

    expect(descriptor.availability, PermissionAvailability.androidOnly);
    expect(descriptor.isHighFriction, isTrue);
    expect(descriptor.required, isFalse);
  });

  test('后台采集说明应明确依赖前置权限与平台受限状态', () {
    final descriptor = PermissionDescriptor.defaults().firstWhere(
      (item) => item.type == PermissionType.backgroundCapture,
    );

    expect(
      descriptor.prerequisites,
      containsAll(<PermissionType>[PermissionType.motion, PermissionType.location]),
    );
    expect(descriptor.availability, PermissionAvailability.crossPlatformLimited);
    expect(descriptor.degradeBehavior, contains('前台'));
  });
}
