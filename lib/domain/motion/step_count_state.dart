enum StepCountSource {
  systemCounter,
  estimated,
  unavailable,
}

class StepCountReading {
  const StepCountReading({
    required this.capturedAt,
    required this.rawStepCount,
    required this.isAvailable,
    this.reason,
  });

  factory StepCountReading.fromChannelPayload(Object? payload) {
    if (payload is! Map) {
      return StepCountReading.unavailable(
        reason: 'step_counter_payload_invalid',
      );
    }

    final isAvailable = payload['isAvailable'] as bool? ?? true;
    final reason = payload['reason'] as String?;
    final capturedAtMillis = payload['capturedAtMillis'];
    final capturedAt = capturedAtMillis is int
        ? DateTime.fromMillisecondsSinceEpoch(capturedAtMillis)
        : DateTime.now();

    if (!isAvailable) {
      return StepCountReading.unavailable(
        capturedAt: capturedAt,
        reason: reason ?? 'step_counter_unavailable',
      );
    }

    final rawStepCountValue = payload['stepCount'] ?? payload['rawStepCount'];
    final rawStepCount = rawStepCountValue is int
        ? rawStepCountValue
        : rawStepCountValue is double
            ? rawStepCountValue.round()
            : 0;

    return StepCountReading(
      capturedAt: capturedAt,
      rawStepCount: rawStepCount,
      isAvailable: true,
      reason: reason,
    );
  }

  factory StepCountReading.unavailable({
    DateTime? capturedAt,
    String? reason,
  }) {
    return StepCountReading(
      capturedAt: capturedAt ?? DateTime.now(),
      rawStepCount: 0,
      isAvailable: false,
      reason: reason,
    );
  }

  final DateTime capturedAt;
  final int rawStepCount;
  final bool isAvailable;
  final String? reason;
}

class StepCountState {
  const StepCountState({
    required this.capturedAt,
    required this.stepCount,
    required this.isAvailable,
    this.reason,
  });

  factory StepCountState.unavailable({
    DateTime? capturedAt,
    String? reason,
  }) {
    return StepCountState(
      capturedAt: capturedAt ?? DateTime.now(),
      stepCount: 0,
      isAvailable: false,
      reason: reason,
    );
  }

  final DateTime capturedAt;
  final int stepCount;
  final bool isAvailable;
  final String? reason;

  StepCountState copyWith({
    DateTime? capturedAt,
    int? stepCount,
    bool? isAvailable,
    String? reason,
  }) {
    return StepCountState(
      capturedAt: capturedAt ?? this.capturedAt,
      stepCount: stepCount ?? this.stepCount,
      isAvailable: isAvailable ?? this.isAvailable,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StepCountState &&
        other.capturedAt == capturedAt &&
        other.stepCount == stepCount &&
        other.isAvailable == isAvailable &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(capturedAt, stepCount, isAvailable, reason);
}
