enum CaptureHealthEventType {
  streamStarted,
  firstSampleReceived,
  gapDetected,
  streamError,
  streamRecovered,
  stateRebuilt,
  nativeSummaryDrained,
}

class CaptureHealthEvent {
  const CaptureHealthEvent({
    required this.eventId,
    required this.streamKey,
    required this.eventType,
    required this.occurredAt,
    this.detail,
    this.sampleCount,
    this.gapSeconds,
    this.errorMessage,
  });

  final String eventId;
  final String streamKey;
  final CaptureHealthEventType eventType;
  final DateTime occurredAt;
  final String? detail;
  final int? sampleCount;
  final int? gapSeconds;
  final String? errorMessage;
}
