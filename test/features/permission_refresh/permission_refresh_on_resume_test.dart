import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  test('恢复前台后权限状态应重新读取', () async {
    var readCount = 0;
    var granted = false;

    final container = ProviderContainer(
      overrides: <Override>[
        overviewPermissionStatusServiceProvider.overrideWithValue(
          _FakePermissionStatusService(
            onRead: () {
              readCount += 1;
              return <PermissionType, PermissionGrantStatus>{
                PermissionType.motion:
                    granted
                        ? PermissionGrantStatus.granted
                        : PermissionGrantStatus.denied,
                PermissionType.location:
                    granted
                        ? PermissionGrantStatus.granted
                        : PermissionGrantStatus.denied,
                PermissionType.microphone:
                    granted
                        ? PermissionGrantStatus.granted
                        : PermissionGrantStatus.denied,
                PermissionType.notification: PermissionGrantStatus.granted,
                PermissionType.usageAccess: PermissionGrantStatus.granted,
                PermissionType.backgroundCapture: PermissionGrantStatus.granted,
              };
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final first = await container.read(permissionStatusProvider.future);
    expect(first[PermissionType.motion], PermissionGrantStatus.denied);
    expect(readCount, 1);

    granted = true;
    container.invalidate(permissionStatusProvider);

    final second = await container.read(permissionStatusProvider.future);
    expect(second[PermissionType.motion], PermissionGrantStatus.granted);
    expect(readCount, 2);
  });
}

class _FakePermissionStatusService implements PermissionStatusService {
  const _FakePermissionStatusService({required this.onRead});

  final Map<PermissionType, PermissionGrantStatus> Function() onRead;

  @override
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses() async {
    return onRead();
  }
}
