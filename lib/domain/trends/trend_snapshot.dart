class TrendPoint {
  const TrendPoint({
    required this.label,
    required this.value,
    this.delta,
  });

  final String label;
  final num value;
  final num? delta;
}

class TrendSnapshot {
  const TrendSnapshot({
    required this.generatedAt,
    this.windowLabel,
    this.points = const <TrendPoint>[],
    this.insightText,
  });

  final DateTime generatedAt;
  final String? windowLabel;
  final List<TrendPoint> points;
  final String? insightText;
}
