import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/ios_background_capture_strategy.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/background_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  const service = BackgroundCaptureService();

  group('BackgroundCaptureState', () {
    test('running isOperational 应为 true, requiresAttention 应为 false', () {
      const state = BackgroundCaptureState(
        status: BackgroundCaptureStatus.running,
        label: 'Running',
        reason: 'All permissions granted.',
      );
      expect(state.isOperational, isTrue);
      expect(state.requiresAttention, isFalse);
    });

    test('paused isOperational 应为 true, requiresAttention 应为 false', () {
      const state = BackgroundCaptureState(
        status: BackgroundCaptureStatus.paused,
        label: 'Paused',
        reason: 'Motion permission missing.',
      );
      expect(state.isOperational, isTrue);
      expect(state.requiresAttention, isFalse);
    });

    test('restricted requiresAttention 应为 true', () {
      const state = BackgroundCaptureState(
        status: BackgroundCaptureStatus.restricted,
        label: 'Limited',
        reason: 'Platform limited.',
      );
      expect(state.requiresAttention, isTrue);
    });

    test('failed requiresAttention 应为 true, isOperational 应为 false', () {
      const state = BackgroundCaptureState(
        status: BackgroundCaptureStatus.failed,
        label: 'Failed',
        reason: 'Platform unsupported.',
      );
      expect(state.isOperational, isFalse);
      expect(state.requiresAttention, isTrue);
    });

    test('permissionDenied requiresAttention 应为 true, isOperational 应为 false', () {
      const state = BackgroundCaptureState(
        status: BackgroundCaptureStatus.permissionDenied,
        label: 'Denied',
        reason: 'Background permission denied.',
      );
      expect(state.isOperational, isFalse);
      expect(state.requiresAttention, isTrue);
    });

    test('toMap 应序列化为正确键值对', () {
      const state = BackgroundCaptureState(
        status: BackgroundCaptureStatus.running,
        label: 'Running',
        reason: 'OK',
      );
      final map = state.toMap();
      expect(map['status'], 'running');
      expect(map['label'], 'Running');
      expect(map['reason'], 'OK');
    });
  });

  group('BackgroundCaptureService.evaluateState', () {
    test('后台权限未授予时应返回 permissionDenied', () async {
      final state = await service.evaluateState(
        capabilitySet: CapabilityMatrix.defaultMatrix().android,
        permissionStatuses: const <PermissionType, PermissionGrantStatus>{
          PermissionType.backgroundCapture: PermissionGrantStatus.denied,
          PermissionType.motion: PermissionGrantStatus.granted,
          PermissionType.location: PermissionGrantStatus.granted,
        },
      );
      expect(state.status, BackgroundCaptureStatus.permissionDenied);
    });

    test('运动权限不足时应返回 paused', () async {
      final state = await service.evaluateState(
        capabilitySet: CapabilityMatrix.defaultMatrix().android,
        permissionStatuses: const <PermissionType, PermissionGrantStatus>{
          PermissionType.backgroundCapture: PermissionGrantStatus.granted,
          PermissionType.motion: PermissionGrantStatus.denied,
          PermissionType.location: PermissionGrantStatus.granted,
        },
      );
      expect(state.status, BackgroundCaptureStatus.paused);
    });

    test('位置权限不足时应返回 paused', () async {
      final state = await service.evaluateState(
        capabilitySet: CapabilityMatrix.defaultMatrix().android,
        permissionStatuses: const <PermissionType, PermissionGrantStatus>{
          PermissionType.backgroundCapture: PermissionGrantStatus.granted,
          PermissionType.motion: PermissionGrantStatus.granted,
          PermissionType.location: PermissionGrantStatus.denied,
        },
      );
      expect(state.status, BackgroundCaptureStatus.paused);
    });

    test('平台 limited 且有完整权限时应返回 restricted', () async {
      final state = await service.evaluateState(
        capabilitySet: CapabilityMatrix.defaultMatrix().ios,
        permissionStatuses: const <PermissionType, PermissionGrantStatus>{
          PermissionType.backgroundCapture: PermissionGrantStatus.granted,
          PermissionType.motion: PermissionGrantStatus.granted,
          PermissionType.location: PermissionGrantStatus.granted,
        },
      );
      expect(state.status, BackgroundCaptureStatus.restricted);
    });

    test('平台 unsupported 且有权限时应返回 failed', () async {
      final unsupportedSet = PlatformCapabilitySet(
        tier: PlatformCapabilityTier.limitedOfficial,
        activityRecognition: CapabilitySupport.supported,
        postureSignals: CapabilitySupport.supported,
        locationSummary: CapabilitySupport.supported,
        environmentNoise: CapabilitySupport.supported,
        screenUsageSummary: CapabilitySupport.unsupported,
        appCategoryUsage: CapabilitySupport.unsupported,
        digitalUsageAlternative: CapabilitySupport.supported,
        backgroundCapture: CapabilitySupport.unsupported,
      );
      final state = await service.evaluateState(
        capabilitySet: unsupportedSet,
        permissionStatuses: const <PermissionType, PermissionGrantStatus>{
          PermissionType.backgroundCapture: PermissionGrantStatus.granted,
          PermissionType.motion: PermissionGrantStatus.granted,
          PermissionType.location: PermissionGrantStatus.granted,
        },
      );
      expect(state.status, BackgroundCaptureStatus.failed);
    });

    test('所有条件满足时应返回 running', () async {
      final state = await service.evaluateState(
        capabilitySet: CapabilityMatrix.defaultMatrix().android,
        permissionStatuses: const <PermissionType, PermissionGrantStatus>{
          PermissionType.backgroundCapture: PermissionGrantStatus.granted,
          PermissionType.motion: PermissionGrantStatus.granted,
          PermissionType.location: PermissionGrantStatus.granted,
        },
      );
      expect(state.status, BackgroundCaptureStatus.running);
    });
  });

  group('FakeBackgroundCaptureService', () {
    test('应返回构造时传入的固定状态', () async {
      const fake = FakeBackgroundCaptureService(
        BackgroundCaptureState(
          status: BackgroundCaptureStatus.paused,
          label: 'Paused',
          reason: 'Test pause.',
        ),
      );
      final state = await fake.evaluateState(
        capabilitySet: CapabilityMatrix.defaultMatrix().android,
        permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
      );
      expect(state.status, BackgroundCaptureStatus.paused);
      expect(state.label, 'Paused');
    });
  });
}
