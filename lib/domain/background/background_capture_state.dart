enum BackgroundCaptureStatus {
  running,
  restricted,
  paused,
  failed,
  permissionDenied,
}

class BackgroundCaptureState {
  const BackgroundCaptureState({
    required this.status,
    required this.label,
    required this.reason,
  });

  final BackgroundCaptureStatus status;
  final String label;
  final String reason;

  bool get isOperational =>
      status == BackgroundCaptureStatus.running ||
      status == BackgroundCaptureStatus.paused;

  bool get requiresAttention =>
      status == BackgroundCaptureStatus.restricted ||
      status == BackgroundCaptureStatus.failed ||
      status == BackgroundCaptureStatus.permissionDenied;
}
