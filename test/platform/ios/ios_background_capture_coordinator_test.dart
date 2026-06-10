import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/ios_background_capture_config.dart';
import 'package:health_monitor/domain/background/ios_background_capture_strategy.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/platform/ios/ios_background_capture_coordinator.dart';
import 'package:health_monitor/services/background_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  const config = IosBackgroundCaptureConfig(
    statusTitle: '\u5065\u5eb7\u76d1\u6d4b\u6b63\u5728\u540e\u53f0\u5237\u65b0',
    statusBody: '\u7528\u4e8e\u5728\u7cfb\u7edf\u5141\u8bb8\u8303\u56f4\u5185\u5237\u65b0\u6d3b\u52a8\u3001\u4f4d\u7f6e\u4e0e\u6570\u5b57\u751f\u6d3b\u66ff\u4ee3\u6307\u6807\u3002',
    enableMotion: true,
    enableLocation: true,
    enableDigitalUsage: true,
    backgroundRefreshIntervalMinutes: 15,
  );

  test('\u53d7\u9650\u4f46\u7b56\u7565\u53ef\u7528\u65f6\u5e94\u4ecd\u7136\u542f\u52a8\u540e\u53f0\u91c7\u96c6', () async {
    final gateway = _FakeIosBackgroundCaptureGateway();
    final coordinator = IosBackgroundCaptureCoordinator(
      backgroundCaptureStateService: const FakeBackgroundCaptureService(
        BackgroundCaptureState(
          status: BackgroundCaptureStatus.restricted,
          label: '\u540e\u53f0\u80fd\u529b\u53d7\u9650',
          reason: '\u7cfb\u7edf\u9650\u5236\u4e86\u5f53\u524d\u5e73\u53f0\u7684\u540e\u53f0\u8fde\u7eed\u6027\u3002',
        ),
      ),
      strategyResolver: const IosBackgroundCaptureStrategyResolver(),
      backgroundCaptureGateway: gateway,
    );

    final state = await coordinator.syncCapture(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(state.status, BackgroundCaptureStatus.restricted);
    expect(gateway.startedConfigs, <IosBackgroundCaptureConfig>[config]);
    expect(gateway.stopCallCount, 0);
  });

  test('motion \u548c location \u6743\u9650\u90fd\u4e0d\u8db3\u65f6\u5e94\u505c\u6b62\u540e\u53f0\u91c7\u96c6', () async {
    final gateway = _FakeIosBackgroundCaptureGateway();
    final coordinator = IosBackgroundCaptureCoordinator(
      backgroundCaptureStateService: const FakeBackgroundCaptureService(
        BackgroundCaptureState(
          status: BackgroundCaptureStatus.permissionDenied,
          label: '\u540e\u53f0\u6743\u9650\u672a\u5f00\u542f',
          reason: '\u5f53\u524d\u53ea\u4f1a\u5728\u524d\u53f0\u79ef\u7d2f\u6837\u672c\u3002',
        ),
      ),
      strategyResolver: const IosBackgroundCaptureStrategyResolver(),
      backgroundCaptureGateway: gateway,
    );

    final state = await coordinator.syncCapture(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.denied,
        PermissionType.location: PermissionGrantStatus.denied,
      },
      config: config,
    );

    expect(state.status, BackgroundCaptureStatus.permissionDenied);
    expect(gateway.startedConfigs, isNotEmpty);
    expect(gateway.stopCallCount, 0);
  });

  test('\u540e\u53f0\u80fd\u529b\u4e0d\u652f\u6301\u65f6\u5e94\u505c\u6b62\u540e\u53f0\u91c7\u96c6', () async {
    final gateway = _FakeIosBackgroundCaptureGateway();
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
    final coordinator = IosBackgroundCaptureCoordinator(
      backgroundCaptureStateService: const FakeBackgroundCaptureService(
        BackgroundCaptureState(
          status: BackgroundCaptureStatus.failed,
          label: '\u540e\u53f0\u91c7\u96c6\u4e0d\u53ef\u7528',
          reason: '\u5f53\u524d\u5e73\u53f0\u4e0d\u652f\u6301\u6240\u9700\u7684\u540e\u53f0\u91c7\u96c6\u80fd\u529b\u3002',
        ),
      ),
      strategyResolver: const IosBackgroundCaptureStrategyResolver(),
      backgroundCaptureGateway: gateway,
    );

    final state = await coordinator.syncCapture(
      capabilitySet: unsupportedSet,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(state.status, BackgroundCaptureStatus.failed);
    expect(gateway.stopCallCount, 1);
  });
}

class _FakeIosBackgroundCaptureGateway implements IosBackgroundCaptureGateway {
  final List<IosBackgroundCaptureConfig> startedConfigs =
      <IosBackgroundCaptureConfig>[];
  int stopCallCount = 0;

  @override
  Future<void> startBackgroundCapture(IosBackgroundCaptureConfig config) async {
    startedConfigs.add(config);
  }

  @override
  Future<void> stopBackgroundCapture() async {
    stopCallCount += 1;
  }
}
