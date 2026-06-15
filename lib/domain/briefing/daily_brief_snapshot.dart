class DailyBriefMetric {
  const DailyBriefMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;
}

class DailyBriefSnapshot {
  const DailyBriefSnapshot({
    required this.headline,
    required this.supportingDetail,
    required this.metrics,
    required this.suggestions,
    this.qualityNote,
  });

  final String headline;
  final String supportingDetail;
  final List<DailyBriefMetric> metrics;
  final List<String> suggestions;
  final String? qualityNote;
}
