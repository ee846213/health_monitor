class NativeStepDaySummary {
  const NativeStepDaySummary({
    required this.date,
    required this.capturedAt,
    required this.stepCount,
  });

  factory NativeStepDaySummary.fromChannelPayload(Object? payload) {
    if (payload is! Map<Object?, Object?>) {
      return NativeStepDaySummary.invalid();
    }
    final dayKey = payload['dayKey'] as String?;
    final capturedAtMillis = payload['capturedAtMillis'];
    return NativeStepDaySummary(
      date: _dateFromKey(dayKey),
      capturedAt: capturedAtMillis is int
          ? DateTime.fromMillisecondsSinceEpoch(capturedAtMillis)
          : DateTime.now(),
      stepCount: _readInt(payload['stepCount']),
    );
  }

  factory NativeStepDaySummary.invalid() {
    final now = DateTime.now();
    return NativeStepDaySummary(
      date: DateTime(now.year, now.month, now.day),
      capturedAt: now,
      stepCount: 0,
    );
  }

  final DateTime date;
  final DateTime capturedAt;
  final int stepCount;

  bool get isValid => stepCount > 0;

  static DateTime _dateFromKey(String? value) {
    final parts = value?.split('-') ?? const <String>[];
    if (parts.length != 3) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(
      int.tryParse(parts[0]) ?? DateTime.now().year,
      int.tryParse(parts[1]) ?? DateTime.now().month,
      int.tryParse(parts[2]) ?? DateTime.now().day,
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
}
