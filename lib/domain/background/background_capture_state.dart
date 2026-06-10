/// 统一后台采集状态模型。
///
/// 不区分 Android / iOS，为页面层提供单一状态入口。
/// 由 [BackgroundCaptureService] 根据权限与平台能力综合评估。
enum BackgroundCaptureStatus {
  /// 后台采集正常运行中。
  running,

  /// 后台采集受系统限制但仍在工作（如 iPhone 的 limited 模式）。
  restricted,

  /// 后台采集因权限不足临时暂停，待权限恢复后可继续。
  paused,

  /// 后台采集任务执行失败，需要用户干预。
  failed,

  /// 关键后台权限未授予，无法启动后台采集链路。
  permissionDenied,
}

/// 平台无关的后台采集状态快照。
///
/// 页面层通过 [BackgroundCaptureStateService] 获取该状态，
/// 不需要感知具体的 Android/iOS 策略细节。
class BackgroundCaptureState {
  const BackgroundCaptureState({
    required this.status,
    required this.label,
    required this.reason,
  });

  /// 当前状态枚举。
  final BackgroundCaptureStatus status;

  /// 面向用户展示的简短标签。
  final String label;

  /// 面向用户或诊断展示的详细原因。
  final String reason;

  /// 后台链路是否处于可持续运行状态。
  ///
  /// [running] 和 [paused] 都视为可运行，前者活跃中，后者暂停但未失败。
  bool get isOperational =>
      status == BackgroundCaptureStatus.running ||
      status == BackgroundCaptureStatus.paused;

  /// 是否需要用户关注或干预。
  ///
  /// 除 running 和 paused 外的所有状态都需要展示警告。
  bool get requiresAttention =>
      status == BackgroundCaptureStatus.restricted ||
      status == BackgroundCaptureStatus.failed ||
      status == BackgroundCaptureStatus.permissionDenied;

  /// 序列化为调试页/日志可用的键值对。
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'status': status.name,
      'label': label,
      'reason': reason,
    };
  }
}
