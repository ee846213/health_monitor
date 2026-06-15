import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/storage/isar/collections/daily_metrics_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

abstract class MetricsRepository {
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  });

  Future<void> upsertMetrics(DailyMetrics metrics);
}

class InMemoryMetricsRepository implements MetricsRepository {
  InMemoryMetricsRepository({
    required List<DailyMetrics> metrics,
  }) : _metrics = <DailyMetrics>[
         ...metrics,
       ];

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

  @override
  Future<void> upsertMetrics(DailyMetrics metrics) async {
    final key = DateKey.fromDate(metrics.date);
    _metrics.removeWhere((item) => DateKey.fromDate(item.date) == key);
    _metrics.add(metrics);
  }
}

class IsarMetricsRepository implements MetricsRepository {
  IsarMetricsRepository(this._isarFuture);

  final Future<Isar> _isarFuture;

  @override
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final isar = await _isarFuture;
    final keys = DateKey.recentDays(days, referenceDate: referenceDate);
    final records = await isar.dailyMetricsRecords.where().anyId().findAll();
    final result = records
        .where((record) => keys.contains(record.dateKey))
        .map((DailyMetricsRecord record) => record.toDomain())
        .toList(growable: false);
    result.sort((left, right) => left.date.compareTo(right.date));
    return result;
  }

  @override
  Future<void> upsertMetrics(DailyMetrics metrics) async {
    final isar = await _isarFuture;
    final record = DailyMetricsRecord.fromDomain(metrics);
    final existing = await isar.dailyMetricsRecords
        .filter()
        .dateKeyEqualTo(record.dateKey)
        .findAll();

    await isar.writeTxn(() async {
      if (existing.isNotEmpty) {
        await isar.dailyMetricsRecords.deleteAll(existing.map((item) => item.id).toList(growable: false));
      }
      await isar.dailyMetricsRecords.put(record);
    });
  }
}
