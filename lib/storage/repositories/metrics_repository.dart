import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/storage/isar/collections/daily_metrics_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

abstract class MetricsRepository {
  Future<DailyMetrics?> getByDate(DateTime date);

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
  Future<DailyMetrics?> getByDate(DateTime date) async {
    final key = DateKey.fromDate(date);
    for (final item in _metrics) {
      if (DateKey.fromDate(item.date) == key) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final keys = DateKey.recentDays(days, referenceDate: referenceDate).toSet();
    final result = _metrics
        .where((item) => keys.contains(DateKey.fromDate(item.date)))
        .toList();
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
  Future<DailyMetrics?> getByDate(DateTime date) async {
    final isar = await _isarFuture;
    final record = await isar.dailyMetricsRecords
        .filter()
        .dateKeyEqualTo(DateKey.fromDate(date))
        .findFirst();
    return record?.toDomain();
  }

  @override
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final isar = await _isarFuture;
    final keys = DateKey.recentDays(days, referenceDate: referenceDate);
    final records = await isar.dailyMetricsRecords
        .filter()
        .anyOf(
          keys,
          (query, String key) => query.dateKeyEqualTo(key),
        )
        .findAll();
    final result = records
        .map((DailyMetricsRecord record) => record.toDomain())
        .toList(growable: false);
    result.sort((left, right) => left.date.compareTo(right.date));
    return result;
  }

  @override
  Future<void> upsertMetrics(DailyMetrics metrics) async {
    final isar = await _isarFuture;
    final record = DailyMetricsRecord.fromDomain(metrics);
    await isar.writeTxn(() async {
      final existing = await isar.dailyMetricsRecords
          .filter()
          .dateKeyEqualTo(record.dateKey)
          .findAll();
      if (existing.isNotEmpty) {
        await isar.dailyMetricsRecords.deleteAll(
          existing.map((item) => item.id).toList(growable: false),
        );
      }
      await isar.dailyMetricsRecords.put(record);
    });
  }
}
