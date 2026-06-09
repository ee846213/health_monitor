import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';

abstract class MetricsRepository {
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  });
}

class InMemoryMetricsRepository implements MetricsRepository {
  InMemoryMetricsRepository({
    required List<DailyMetrics> metrics,
  }) : _metrics = List<DailyMetrics>.unmodifiable(metrics);

  final List<DailyMetrics> _metrics;

  @override
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final keys = DateKey.recentDays(days, referenceDate: referenceDate).toSet();
    final result = _metrics.where((item) => keys.contains(DateKey.fromDate(item.date))).toList();
    result.sort((left, right) => left.date.compareTo(right.date));
    return result;
  }
}
