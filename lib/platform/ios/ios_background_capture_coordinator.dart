import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/ios_background_capture_config.dart';
import 'package:health_monitor/domain/background/ios_background_capture_strategy.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/background_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';

abstract class IosBackgroundCaptureGateway {
  Future<void> startBackgroundCapture(IosBackgroundCaptureConfig config);

  Future<void> stopBackgroundCapture();
}

class IosBackgroundCaptureCoordinator {
  IosBackgroundCaptureCoordinator({
    required BackgroundCaptureStateService backgroundCaptureStateService,
    required IosBackgroundCaptureStrategyResolver strategyResolver,
    required IosBackgroundCaptureGateway backgroundCaptureGateway,
  }) : _backgroundCaptureStateService = backgroundCaptureStateService,
       _strategyResolver = strategyResolver,
       _backgroundCaptureGateway = backgroundCaptureGateway;

  final BackgroundCaptureStateService _backgroundCaptureStateService;
  final IosBackgroundCaptureStrategyResolver _strategyResolver;
  final IosBackgroundCaptureGateway _backgroundCaptureGateway;

  Future<BackgroundCaptureState> syncCapture({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
    required IosBackgroundCaptureConfig config,
  }) async {
    final state = await _backgroundCaptureStateService.evaluateState(
      capabilitySet: capabilitySet,
      permissionStatuses: permissionStatuses,
    );
    final strategy = _strategyResolver.resolve(
      capabilitySet: capabilitySet,
      permissionStatuses: permissionStatuses,
      config: config,
    );

    // iPhone 的后台策略即使受限也可能保留一部分系统允许的刷新能力，
    // 所以这里不能像 Android 那样把“受限”直接视为停用，而要交给策略层判断。
    if (strategy.isEnabled) {
      await _backgroundCaptureGateway.startBackgroundCapture(config);
      return state;
    }

    await _backgroundCaptureGateway.stopBackgroundCapture();
    return state;
  }
}
