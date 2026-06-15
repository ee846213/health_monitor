enum CaptureHealthState {
  healthy,
  recovering,
  degraded,
  stalled,
}

class CaptureCheckpoint {
  const CaptureCheckpoint({
    required this.streamKey,
    required this.state,
    required this.sampleCount,
    required this.gapCount,
    required this.recoveryCount,
    this.lastEventTypeKey,
    this.lastEventAt,
    this.lastSampleAt,
    this.lastErrorAt,
    this.lastRecoveredAt,
    this.lastStateRebuiltAt,
    this.lastNativeSummaryDrainedAt,
    this.lastMessage,
    this.lastErrorMessage,
  });

  final String streamKey;
  final CaptureHealthState state;
  final int sampleCount;
  final int gapCount;
  final int recoveryCount;
  final String? lastEventTypeKey;
  final DateTime? lastEventAt;
  final DateTime? lastSampleAt;
  final DateTime? lastErrorAt;
  final DateTime? lastRecoveredAt;
  final DateTime? lastStateRebuiltAt;
  final DateTime? lastNativeSummaryDrainedAt;
  final String? lastMessage;
  final String? lastErrorMessage;
}
