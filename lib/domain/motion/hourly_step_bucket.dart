class HourlyStepBucket {
  const HourlyStepBucket({
    required this.startAt,
    required this.endAt,
    required this.stepCount,
  });

  factory HourlyStepBucket.fromChannelPayload(Object? payload) {
    if (payload is! Map) {
      return HourlyStepBucket.empty();
    }
    final startMillis = payload['startMillis'];
    final endMillis = payload['endMillis'];
    final stepCount = payload['stepCount'];
    if (startMillis is! int || endMillis is! int) {
      return HourlyStepBucket.empty();
    }
    return HourlyStepBucket(
      startAt: DateTime.fromMillisecondsSinceEpoch(startMillis),
      endAt: DateTime.fromMillisecondsSinceEpoch(endMillis),
      stepCount: stepCount is int
          ? stepCount
          : stepCount is double
              ? stepCount.round()
              : 0,
    );
  }

  factory HourlyStepBucket.empty() {
    return HourlyStepBucket(
      startAt: DateTime.fromMillisecondsSinceEpoch(0),
      endAt: DateTime.fromMillisecondsSinceEpoch(0),
      stepCount: 0,
    );
  }

  final DateTime startAt;
  final DateTime endAt;
  final int stepCount;

  bool get isValid => stepCount > 0 && startAt.isBefore(endAt);
}

class HealthConnectStatus {
  const HealthConnectStatus({
    required this.isAvailable,
    required this.hasStepsPermission,
    required this.needsInstall,
  });

  factory HealthConnectStatus.fromChannelPayload(Map<Object?, Object?>? payload) {
    if (payload == null) {
      return const HealthConnectStatus(
        isAvailable: false,
        hasStepsPermission: false,
        needsInstall: false,
      );
    }
    return HealthConnectStatus(
      isAvailable: payload['isAvailable'] as bool? ?? false,
      hasStepsPermission: payload['hasStepsPermission'] as bool? ?? false,
      needsInstall: payload['needsInstall'] as bool? ?? false,
    );
  }

  final bool isAvailable;
  final bool hasStepsPermission;
  final bool needsInstall;
}
