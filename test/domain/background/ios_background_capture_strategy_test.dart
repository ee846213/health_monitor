import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/ios_background_capture_config.dart';
import 'package:health_monitor/domain/background/ios_background_capture_strategy.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  const resolver = IosBackgroundCaptureStrategyResolver();
  const config = IosBackgroundCaptureConfig(
    statusTitle: '\u5065\u5eb7\u76d1\u6d4b\u6b63\u5728\u540e\u53f0\u5237\u65b0',
    statusBody: '\u7528\u4e8e\u5728\u7cfb\u7edf\u5141\u8bb8\u8303\u56f4\u5185\u5237\u65b0\u6d3b\u52a8\u3001\u4f4d\u7f6e\u4e0e\u6570\u5b57\u751f\u6d3b\u66ff\u4ee3\u6307\u6807\u3002',
    enableMotion: true,
    enableLocation: true,
    enableDigitalUsage: true,
    backgroundRefreshIntervalMinutes: 15,
  );

  test('\u53d7\u9650\u6b63\u5f0f\u7aef full \u6a21\u5f0f\u7ec4\u5408\u7b56\u7565', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(strategy.isEnabled, isTrue);
    expect(strategy.isRestricted, isTrue);
    expect(strategy.captureMode, IosBackgroundCaptureMode.full);
    expect(strategy.supportedModes, contains('motion'));
    expect(strategy.supportedModes, contains('location'));
    expect(strategy.supportedModes, contains('digital_usage_alternative'));
    expect(strategy.reasons, isNotEmpty);
  });

  test('\u8fd0\u52a8\u6743\u9650\u4e0d\u8db3\u65f6\u964d\u7ea7\u5230 locationOnly', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.denied,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(strategy.isEnabled, isTrue);
    expect(strategy.captureMode, IosBackgroundCaptureMode.locationOnly);
    expect(strategy.supportedModes, isNot(contains('motion')));
    expect(strategy.supportedModes, contains('location'));
    expect(strategy.reasons, isNotEmpty);
  });

  test('\u4f4d\u7f6e\u6743\u9650\u4e0d\u8db3\u65f6\u964d\u7ea7\u5230 motionOnly', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.denied,
      },
      config: config,
    );

    expect(strategy.isEnabled, isTrue);
    expect(strategy.captureMode, IosBackgroundCaptureMode.motionOnly);
    expect(strategy.supportedModes, contains('motion'));
    expect(strategy.supportedModes, isNot(contains('location')));
  });

  test('motion \u548c location \u6743\u9650\u90fd\u4e0d\u8db3\u65f6\u964d\u7ea7\u5230 digitalUsageOnly', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.denied,
        PermissionType.location: PermissionGrantStatus.denied,
      },
      config: config,
    );

    expect(strategy.isEnabled, isTrue);
    expect(strategy.captureMode, IosBackgroundCaptureMode.digitalUsageOnly);
  });

  test('\u540e\u53f0\u80fd\u529b\u4e0d\u652f\u6301\u65f6\u8fdb\u5165 disabled \u6a21\u5f0f', () {
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
    final strategy = resolver.resolve(
      capabilitySet: unsupportedSet,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(strategy.isEnabled, isFalse);
    expect(strategy.captureMode, IosBackgroundCaptureMode.disabled);
  });

  test('\u73af\u5883\u80fd\u529b\u7cfb\u7edf\u9650\u5236\u5f71\u54cd\u5237\u65b0\u95f4\u9694\u4e0e\u7a97\u53e3\u671f', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(strategy.bgTaskEstimatedWindowSeconds, greaterThan(0));
    expect(strategy.backgroundRefreshIntervalMinutes, greaterThanOrEqualTo(15));
  });

  test('\u6570\u5b57\u751f\u6d3b\u66ff\u4ee3\u6307\u6807\u5237\u65b0\u95f4\u9694\u4e0e\u7cfb\u7edf\u9650\u5236\u8054\u52a8', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(strategy.digitalUsageRefreshIntervalMinutes, greaterThan(0));
  });

  test('\u6743\u9650\u4e0d\u8db3\u65f6\u72b6\u6001\u6062\u590d\u7b56\u7565\u53ef\u6062\u590d', () {
    final strategy = resolver.resolve(
      capabilitySet: CapabilityMatrix.defaultMatrix().ios,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.denied,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(strategy.canRestore, isTrue);
    expect(strategy.restoreStrategy, isNotEmpty);
  });

  test('\u540e\u53f0\u80fd\u529b\u4e0d\u652f\u6301\u65f6\u72b6\u6001\u6062\u590d\u4e0d\u53ef\u7528', () {
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
    final strategy = resolver.resolve(
      capabilitySet: unsupportedSet,
      permissionStatuses: const <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.granted,
      },
      config: config,
    );

    expect(strategy.canRestore, isFalse);
  });
}
