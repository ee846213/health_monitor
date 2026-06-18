enum TrendTab {
  steps,
  sedentary,
  screen,
  environment,
}

class TrendPoint {
  const TrendPoint({
    required this.label,
    required this.value,
    this.hasData = true,
    this.delta,
  });

  final String label;
  final num value;
  final bool hasData;
  final num? delta;
}

class TrendSnapshot {
  const TrendSnapshot({
    required this.generatedAt,
    required this.selectedTab,
    required this.title,
    required this.unitLabel,
    required this.points,
    required this.insightText,
    this.emptyStateText,
  });

  final DateTime generatedAt;
  final TrendTab selectedTab;
  final String title;
  final String unitLabel;
  final List<TrendPoint> points;
  final String insightText;
  final String? emptyStateText;
}
