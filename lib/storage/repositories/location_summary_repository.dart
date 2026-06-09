import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';

abstract class LocationSummaryRepository {
  Future<List<LocationSummary>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  });
}

class InMemoryLocationSummaryRepository implements LocationSummaryRepository {
  InMemoryLocationSummaryRepository({
    required List<LocationSummary> summaries,
  }) : _summaries = List<LocationSummary>.unmodifiable(summaries);

  final List<LocationSummary> _summaries;

  @override
  Future<List<LocationSummary>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final keys = DateKey.recentDays(days, referenceDate: referenceDate).toSet();
    final result = _summaries.where((summary) => keys.contains(DateKey.fromDate(summary.date))).toList();
    result.sort((left, right) => left.date.compareTo(right.date));
    return result;
  }
}
