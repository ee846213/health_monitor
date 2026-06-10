import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/services/permission_status_service.dart';

/// 统一的后台采集状态评估接口。
///
/// 页面层与协调器通过本接口获取平台无关的后台链路状态，
/// 不必关心 Android/iOS 的具体策略差异。
abstract class BackgroundCaptureStateService {
  Future<BackgroundCaptureState> evaluateState({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  });
}

/// 统一后台采集状态评估服务。
///
/// 评估逻辑按优先级逐层判断：
/// 1. 后台权限不足 -> permissionDenied
/// 2. 运动/位置前置权限不足 -> paused
/// 3. 平台能力为 limited -> restricted
/// 4. 平台能力为 unsupported -> failed
/// 5. 以上都满足 -> running
///
/// 其中 paused 与 running 都视为 isOperational，
/// restricted/failed/permissionDenied 视为 requiresAttention。
class BackgroundCaptureService implements BackgroundCaptureStateService {
  const BackgroundCaptureService();

  @override
  Future<BackgroundCaptureState> evaluateState({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  }) async {
    final backgroundPermission =
        permissionStatuses[PermissionType.backgroundCapture] ??
        PermissionGrantStatus.unknown;
    final motionPermission =
        permissionStatuses[PermissionType.motion] ?? PermissionGrantStatus.unknown;
    final locationPermission =
        permissionStatuses[PermissionType.location] ?? PermissionGrantStatus.unknown;

    // 第一优先级：后台权限未授予。
    // 没有后台权限意味着无法运行前台服务或触发系统级后台任务，
    // 此时应用只能在用户前台使用期间积累样本，无法形成连续后台链路。
    if (backgroundPermission != PermissionGrantStatus.granted) {
      return const BackgroundCaptureState(
        status: BackgroundCaptureStatus.permissionDenied,
        label: '后台权限未开启',
        reason: '当前只会在前台积累样本，无法形成连续后台链路。',
      );
    }

    // 第二优先级：前置传感器权限不足。
    // 即使后天权限已授予，如果核心传感器（运动、位置）未授权，
    // 后台任务无法产生有效数据，标记为 paused 而非 failed，
    // 因为用户随时可能授予权限后恢复。
    if (motionPermission != PermissionGrantStatus.granted ||
        locationPermission != PermissionGrantStatus.granted) {
      return const BackgroundCaptureState(
        status: BackgroundCaptureStatus.paused,
        label: '后台采集已暂停',
        reason: '运动或位置前置权限不足，后台链路暂时不能稳定工作。',
      );
    }

    // 第三优先级：平台能力受限但可用。
    // 典型的 iPhone 场景：BGTaskScheduler 存在但窗口期不稳定。
    // 标记为 restricted 让页面层展示警告但不阻断。
    if (capabilitySet.backgroundCapture == CapabilitySupport.limited) {
      return const BackgroundCaptureState(
        status: BackgroundCaptureStatus.restricted,
        label: '后台能力受限',
        reason: '系统限制了当前平台的后台连续性，需要接受受限运行。',
      );
    }

    // 第四优先级：平台不支持后台采集。
    // 与权限不足不同，这是客观能力缺失，无法通过用户操作恢复。
    if (capabilitySet.backgroundCapture == CapabilitySupport.unsupported) {
      return const BackgroundCaptureState(
        status: BackgroundCaptureStatus.failed,
        label: '后台采集不可用',
        reason: '当前平台不支持所需的后台采集能力。',
      );
    }

    // 所有条件满足：后台权限、前置权限、平台能力均就绪。
    return const BackgroundCaptureState(
      status: BackgroundCaptureStatus.running,
      label: '后台采集中',
      reason: '后台权限、前置权限与平台能力都已满足。',
    );
  }
}

/// 固定返回状态的测试替身。
///
/// 用于单元测试中模拟特定后台状态场景。
class FakeBackgroundCaptureService implements BackgroundCaptureStateService {
  const FakeBackgroundCaptureService(this._state);

  final BackgroundCaptureState _state;

  @override
  Future<BackgroundCaptureState> evaluateState({
    required PlatformCapabilitySet capabilitySet,
    required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  }) async {
    return _state;
  }
}
