import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';

abstract class UsageSummaryRepository {
  Future<DigitalUsageSummary?> getByDate(DateTime date);
}

class InMemoryUsageSummaryRepository implements UsageSummaryRepository {
  InMemoryUsageSummaryRepository({
    required List<DigitalUsageSummary> summaries,
  }) : _summaries = List<DigitalUsageSummary>.unmodifiable(summaries);

  final List<DigitalUsageSummary> _summaries;

  @override
  Future<DigitalUsageSummary?> getByDate(DateTime date) async {
    final key = DateKey.fromDate(date);

    for (final summary in _summaries) {
      if (DateKey.fromDate(summary.date) == key) {
        return summary;
      }
    }

    return null;
  }
}
