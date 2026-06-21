enum TrendTab {
  steps,
  sedentary,
  screen,
  environment,
}

enum TrendRange {
  days7(7, '近 7 天'),
  days30(30, '近 30 天'),
  days90(90, '近 90 天');

  const TrendRange(this.dayCount, this.label);

  final int dayCount;
  final String label;
}

enum TrendAggregation {
  day,
  week,
  month,
}

enum TrendDataQuality {
  complete,
  partial,
  empty,
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
    this.range = TrendRange.days7,
    this.aggregation = TrendAggregation.day,
    this.dataQuality = TrendDataQuality.complete,
    this.defaultSelectedIndex,
    this.comparisonPoints = const <TrendPoint>[],
    this.emptyStateText,
  });

  final DateTime generatedAt;
  final TrendTab selectedTab;
  final String title;
  final String unitLabel;
  final List<TrendPoint> points;
  final String insightText;
  final TrendRange range;
  final TrendAggregation aggregation;
  final TrendDataQuality dataQuality;
  final int? defaultSelectedIndex;
  final List<TrendPoint> comparisonPoints;
  final String? emptyStateText;
}
