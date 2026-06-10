import 'package:health_monitor/domain/background/ios_background_capture_config.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/permission_status_service.dart';
/// iPhone 后台采集模式组合。
///
/// 根据当前可用权限与平台能力，将采集行为归纳为若干预定义模式。
/// 每种模式对应一组可调度的后台任务，使协调器层不必感知每个模式的具体含义。
enum IosBackgroundCaptureMode {
  /// 全能力模式：运动 + 位置 + 数字生活替代指标均可调度。
  full,

  /// 仅有运动能力：位置权限不足或不可用。
  motionOnly,

  /// 仅有位置能力：运动权限不足或不可用。
  locationOnly,

  /// 仅有数字生活替代指标：运动与位置权限均不足。
  digitalUsageOnly,

  /// 极端受限：任何权限或能力都不足，仅保留最基本的系统级刷新。
  minimal,

  /// 禁用：后台采集不应启动。
  disabled,
}

/// iPhone 后台采集策略的完整定义。
///
/// 包含四个检查项的全部信息：
/// 1. Motion / Location / Background 模式组合策略
/// 2. 环境能力系统允许范围内实现
/// 3. 数字生活替代指标后台刷新策略
/// 4. 状态恢复与限制识别
class IosBackgroundCaptureStrategy {
  const IosBackgroundCaptureStrategy({
    required this.isEnabled,
    required this.isRestricted,
    required this.title,
    required this.body,
    required this.backgroundRefreshIntervalMinutes,
    required this.supportedModes,
    required this.reasons,
    required this.captureMode,
    required this.digitalUsageRefreshIntervalMinutes,
    required this.bgTaskEstimatedWindowSeconds,
    required this.canRestore,
    required this.restoreStrategy,
  });

  /// 策略是否启用（即使受限也可能启用）。
  final bool isEnabled;

  /// 是否处于系统限制状态（如 limited backgroundCapture）。
  final bool isRestricted;

  /// 前台通知/状态栏标题。
  final String title;

  /// 策略说明正文。
  final String body;

  /// 整体后台刷新间隔（分钟），基于模式组合和系统限制计算得出。
  final int backgroundRefreshIntervalMinutes;

  /// 支持的采集模式列表。
  final List<String> supportedModes;

  /// 降级原因列表。
  final List<String> reasons;

  /// 最终确定的采集模式组合。
  final IosBackgroundCaptureMode captureMode;

  /// 数字生活替代指标的刷新间隔（分钟），与系统限制联动。
  final int digitalUsageRefreshIntervalMinutes;

  /// BGTaskScheduler 窗口期估计值（秒），0 表示无法估算。
  final int bgTaskEstimatedWindowSeconds;

  /// 是否可以从系统限制/错误中自动恢复。
  final bool canRestore;

  /// 恢复策略描述。
  final String restoreStrategy;
}
/// 系统后台限制级别。
///
/// 用于将 platform capability 映射到 iPhone 具体的行为约束。
enum IosBackgroundSystemRestrictionLevel {
  /// 无限制。
  unrestricted,

  /// 标准限制：BGTaskScheduler 窗口期、低功耗模式影响。
  standard,

  /// 严格限制：后台应用刷新关闭或 App 被挂起。
  strict,

  /// 不支持。
  unsupported,
}

/// 环境能力系统允许范围内的刷新间隔计算。
class IosBackgroundSystemConstraint {
  final IosBackgroundSystemRestrictionLevel restrictionLevel;

  const IosBackgroundSystemConstraint({required this.restrictionLevel});

  /// 根据系统限制级别计算合理的后台刷新间隔（分钟）。
  ///
  /// iPhone 在标准限制下 BGTaskScheduler 窗口期通常为 15-30 分钟一次，
  /// 低功耗模式时窗口期延长到 1-2 小时。
  int effectiveBackgroundIntervalMinutes(int userPreferredMinutes) {
    switch (restrictionLevel) {
      case IosBackgroundSystemRestrictionLevel.unrestricted:
        return userPreferredMinutes.clamp(5, 60);
      case IosBackgroundSystemRestrictionLevel.standard:
        return userPreferredMinutes.clamp(15, 120);
      case IosBackgroundSystemRestrictionLevel.strict:
        return userPreferredMinutes.clamp(60, 240);
      case IosBackgroundSystemRestrictionLevel.unsupported:
        return 240;
    }
  }

  /// 系统允许的后台窗口期估计（秒）。
  int estimatedWindowSeconds() {
    switch (restrictionLevel) {
      case IosBackgroundSystemRestrictionLevel.unrestricted:
        return 180;
      case IosBackgroundSystemRestrictionLevel.standard:
        return 30;
      case IosBackgroundSystemRestrictionLevel.strict:
        return 5;
      case IosBackgroundSystemRestrictionLevel.unsupported:
        return 0;
    }
  }

  /// 在当前限制下数字生活替代指标是否能正常刷新。
  bool digitalUsageSchedulable() {
    return restrictionLevel != IosBackgroundSystemRestrictionLevel.unsupported;
  }
}

/// 数字生活替代指标后台刷新策略。
///
/// iPhone 无法直接读取 Android 式的 UsageStats，因此依靠以下替代指标：
/// - 屏幕亮/灭事件（通过 Darwin 通知）
/// - 应用切换事件（通过 UIApplication 生命周期）
/// - 专注模式状态（通过 FCNotificationName）
///
/// 替代指标不需要持续运行，只需在后台调度窗口期内检查状态快照。
/// 系统限制严格时采样间隔需延长以适配更长的后台窗口期。
class IosDigitalUsageAlternativeRefreshPolicy {
  final int refreshIntervalMinutes;

  const IosDigitalUsageAlternativeRefreshPolicy({
    required this.refreshIntervalMinutes,
  });

  /// 根据系统限制级别计算替代指标的最佳刷新间隔。
  static IosDigitalUsageAlternativeRefreshPolicy compute({
    required IosBackgroundSystemRestrictionLevel restrictionLevel,
  }) {
    switch (restrictionLevel) {
      case IosBackgroundSystemRestrictionLevel.unrestricted:
        return const IosDigitalUsageAlternativeRefreshPolicy(refreshIntervalMinutes: 15);
      case IosBackgroundSystemRestrictionLevel.standard:
        return const IosDigitalUsageAlternativeRefreshPolicy(refreshIntervalMinutes: 30);
      case IosBackgroundSystemRestrictionLevel.strict:
        return const IosDigitalUsageAlternativeRefreshPolicy(refreshIntervalMinutes: 120);
      case IosBackgroundSystemRestrictionLevel.unsupported:
        return const IosDigitalUsageAlternativeRefreshPolicy(refreshIntervalMinutes: 240);
    }
  }
}

/// 状态恢复策略。
///
/// iPhone 在以下场景后需要尝试恢复后台采集：
/// - 系统唤醒（从低功耗模式恢复）
/// - 权限从拒绝变为授予
/// - 系统后台限制从 strict 降级为 standard
/// - App 被系统挂起后重新进入前台
/// - BGTaskScheduler 窗口期被触发
class IosBackgroundCaptureRestoreStrategy {
  final bool canRestore;
  final String description;

  const IosBackgroundCaptureRestoreStrategy({
    required this.canRestore,
    required this.description,
  });

  /// 根据当前策略状态和系统限制评估可恢复性。
  static IosBackgroundCaptureRestoreStrategy evaluate({
    required bool isEnabled,
    required IosBackgroundSystemRestrictionLevel restrictionLevel,
    required bool hasMotionPermission,
    required bool hasLocationPermission,
  }) {
    if (!isEnabled) {
      return const IosBackgroundCaptureRestoreStrategy(
        canRestore: false,
        description: '策略未启用，无法恢复后台采集。',
      );
    }

    if (restrictionLevel == IosBackgroundSystemRestrictionLevel.unsupported) {
      return const IosBackgroundCaptureRestoreStrategy(
        canRestore: false,
        description: '当前系统版本不支持后台采集恢复。',
      );
    }

    if (restrictionLevel == IosBackgroundSystemRestrictionLevel.strict) {
      return const IosBackgroundCaptureRestoreStrategy(
        canRestore: true,
        description: '后台应用刷新已关闭，恢复需等用户重新开启或下次前台启动。',
      );
    }

    if (!hasMotionPermission && !hasLocationPermission) {
      return const IosBackgroundCaptureRestoreStrategy(
        canRestore: true,
        description: '权限不足，待用户授予运动或位置权限后自动恢复。',
      );
    }

    if (restrictionLevel == IosBackgroundSystemRestrictionLevel.standard) {
      return const IosBackgroundCaptureRestoreStrategy(
        canRestore: true,
        description: '标准系统限制下，下一次 BGTaskScheduler 窗口期自动恢复采集调度。',
      );
    }

    return const IosBackgroundCaptureRestoreStrategy(
      canRestore: true,
      description: '系统限制正常，采集将按计划窗口期自动恢复。',
    );
  }
}

/// 将平台能力矩阵中的 backgroundCapture 级别转为系统限制级别。
IosBackgroundSystemRestrictionLevel mapCapabilityToRestrictionLevel(
  CapabilitySupport backgroundCapture,
) {
  switch (backgroundCapture) {
    case CapabilitySupport.supported:
      return IosBackgroundSystemRestrictionLevel.unrestricted;
    case CapabilitySupport.limited:
      return IosBackgroundSystemRestrictionLevel.standard;
    case CapabilitySupport.unsupported:
      return IosBackgroundSystemRestrictionLevel.unsupported;
  }
}

class IosBackgroundCaptureStrategyResolver {
  const IosBackgroundCaptureStrategyResolver();

  IosBackgroundCaptureStrategy resolve({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
    required IosBackgroundCaptureConfig config,
  }) {
    final reasons = <String>[];
    final supportedModes = <String>[];
    var isRestricted = false;

    final motionPermission =
        permissionStatuses[PermissionType.motion] ?? PermissionGrantStatus.unknown;
    final locationPermission =
        permissionStatuses[PermissionType.location] ?? PermissionGrantStatus.unknown;
    final hasMotion = motionPermission == PermissionGrantStatus.granted;
    final hasLocation = locationPermission == PermissionGrantStatus.granted;

    // -- 检查项 1：模式组合 --
    if (!hasMotion) {
      reasons.add('运动权限不足，iPhone 后台只能保留极弱的替代刷新，不能形成稳定的活动链路。');
    } else {
      supportedModes.add('motion');
    }

    if (!hasLocation) {
      reasons.add('位置权限不足，iPhone 后台无法稳定生成位置摘要。');
    } else {
      supportedModes.add('location');
    }

    if (capabilitySet.digitalUsageAlternative == CapabilitySupport.supported) {
      supportedModes.add('digital_usage_alternative');
    } else {
      reasons.add('当前平台缺少数字生活替代指标能力。');
    }
    if (capabilitySet.backgroundCapture == CapabilitySupport.unsupported) {
      reasons.add('当前平台不支持后台刷新能力。');
      return IosBackgroundCaptureStrategy(
        isEnabled: false,
        isRestricted: true,
        title: config.statusTitle,
        body: reasons.join(''),
        backgroundRefreshIntervalMinutes: 240,
        supportedModes: supportedModes,
        reasons: reasons,
        captureMode: IosBackgroundCaptureMode.disabled,
        digitalUsageRefreshIntervalMinutes: 240,
        bgTaskEstimatedWindowSeconds: 0,
        canRestore: false,
        restoreStrategy: '当前系统版本不支持后台采集恢复。',
      );
    } else if (capabilitySet.backgroundCapture == CapabilitySupport.limited) {
      reasons.add('iPhone 后台刷新仅能在系统允许范围内执行，因此属于受限正式端。');
      isRestricted = true;
    }

    // 基于各维度组合确定最终采集模式。
    final captureMode = _determineCaptureMode(
      hasMotion: hasMotion,
      hasLocation: hasLocation,
      hasDigitalUsage:
          capabilitySet.digitalUsageAlternative == CapabilitySupport.supported,
      isRestricted: isRestricted,
    );

    // -- 检查项 2：环境能力系统允许范围内 --
    final restrictionLevel = mapCapabilityToRestrictionLevel(
      capabilitySet.backgroundCapture,
    );
    final systemConstraint = IosBackgroundSystemConstraint(
      restrictionLevel: restrictionLevel,
    );
    final effectiveInterval =
        systemConstraint.effectiveBackgroundIntervalMinutes(
      config.backgroundRefreshIntervalMinutes,
    );
    final estimatedWindow = systemConstraint.estimatedWindowSeconds();

    // -- 检查项 3：数字生活替代指标后台刷新策略 --
    final digitalUsagePolicy = IosDigitalUsageAlternativeRefreshPolicy.compute(
      restrictionLevel: restrictionLevel,
    );
    final digitalUsageInterval = digitalUsagePolicy.refreshIntervalMinutes;

    // -- 检查项 4：状态恢复与限制识别 --
    final restoreStrategy = IosBackgroundCaptureRestoreStrategy.evaluate(
      isEnabled: captureMode != IosBackgroundCaptureMode.disabled,
      restrictionLevel: restrictionLevel,
      hasMotionPermission: hasMotion,
      hasLocationPermission: hasLocation,
    );

    final isEnabled = captureMode != IosBackgroundCaptureMode.disabled;

    return IosBackgroundCaptureStrategy(
      isEnabled: isEnabled,
      isRestricted: isRestricted,
      title: config.statusTitle,
      body: reasons.isEmpty ? config.statusBody : reasons.join(''),
      backgroundRefreshIntervalMinutes: effectiveInterval,
      supportedModes: supportedModes,
      reasons: reasons,
      captureMode: captureMode,
      digitalUsageRefreshIntervalMinutes: digitalUsageInterval,
      bgTaskEstimatedWindowSeconds: estimatedWindow,
      canRestore: restoreStrategy.canRestore,
      restoreStrategy: restoreStrategy.description,
    );
  }

  /// 根据各维度可用性确定采集模式组合。
  IosBackgroundCaptureMode _determineCaptureMode({
    required bool hasMotion,
    required bool hasLocation,
    required bool hasDigitalUsage,
    required bool isRestricted,
  }) {
    if (hasMotion && hasLocation) {
      return IosBackgroundCaptureMode.full;
    }
    if (hasMotion) {
      return IosBackgroundCaptureMode.motionOnly;
    }
    if (hasLocation) {
      return IosBackgroundCaptureMode.locationOnly;
    }
    if (hasDigitalUsage) {
      return IosBackgroundCaptureMode.digitalUsageOnly;
    }
    if (isRestricted) {
      return IosBackgroundCaptureMode.minimal;
    }
    return IosBackgroundCaptureMode.disabled;
  }
}

