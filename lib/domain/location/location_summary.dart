class LocationSummary {
  const LocationSummary({
    required this.date,
    required this.distanceMeters,
    required this.outdoorDuration,
    required this.visitCount,
    required this.commuteCount,
  });

  final DateTime date;
  final double distanceMeters;
  final Duration outdoorDuration;
  final int visitCount;
  final int commuteCount;

  bool get hasMeaningfulMobility => distanceMeters >= 1000 || commuteCount > 0;

  bool get hasOutdoorExposure => outdoorDuration >= const Duration(minutes: 20);
}
