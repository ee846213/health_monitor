class BackgroundStepDeltaEvent {
  const BackgroundStepDeltaEvent({
    required this.eventId,
    required this.capturedAt,
    required this.stepDelta,
    required this.dayStepTotal,
    this.stationaryDuration = Duration.zero,
  });

  factory BackgroundStepDeltaEvent.fromChannelPayload(
    Map<Object?, Object?> payload,
  ) {
    final capturedAtMillis = payload['capturedAtMillis'];
    return BackgroundStepDeltaEvent(
      eventId: payload['eventId'] as String? ?? '',
      capturedAt: capturedAtMillis is int
          ? DateTime.fromMillisecondsSinceEpoch(capturedAtMillis)
          : DateTime.now(),
      stepDelta: _readInt(payload['stepDelta']),
      dayStepTotal: _readInt(payload['dayStepTotal']),
      stationaryDuration: Duration(
        milliseconds: _readInt(payload['stationaryDurationMillis']),
      ),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return 0;
  }

  final String eventId;
  final DateTime capturedAt;
  final int stepDelta;
  final int dayStepTotal;
  final Duration stationaryDuration;

  bool get hasStepDelta => stepDelta > 0;

  bool get hasStationaryDuration => stationaryDuration > Duration.zero;

  bool get isValid =>
      eventId.isNotEmpty && (hasStepDelta || hasStationaryDuration);
}
