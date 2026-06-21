class WalkingScreenRiskEvent {
  const WalkingScreenRiskEvent({
    required this.eventId,
    required this.occurredAt,
    required this.screenOnStartedAt,
    required this.continuousWalkingSeconds,
    required this.stepDelta,
    required this.notificationDelivered,
  });

  final String eventId;
  final DateTime occurredAt;
  final DateTime screenOnStartedAt;
  final int continuousWalkingSeconds;
  final int stepDelta;
  final bool notificationDelivered;

  factory WalkingScreenRiskEvent.fromChannelPayload(
    Map<Object?, Object?> payload,
  ) {
    final occurredAtMillis = payload['occurredAtMillis'] as int? ?? 0;
    final screenOnStartedAtMillis =
        payload['screenOnStartedAtMillis'] as int? ?? 0;
    return WalkingScreenRiskEvent(
      eventId: payload['eventId'] as String? ?? '',
      occurredAt: DateTime.fromMillisecondsSinceEpoch(occurredAtMillis),
      screenOnStartedAt: DateTime.fromMillisecondsSinceEpoch(
        screenOnStartedAtMillis,
      ),
      continuousWalkingSeconds:
          payload['continuousWalkingSeconds'] as int? ?? 0,
      stepDelta: payload['stepDelta'] as int? ?? 0,
      notificationDelivered: payload['notificationDelivered'] as bool? ?? false,
    );
  }
}
