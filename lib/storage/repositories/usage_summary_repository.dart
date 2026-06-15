import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/isar/collections/usage_summary_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

abstract class UsageSummaryRepository {
  Future<DigitalUsageSummary?> getByDate(DateTime date);

  Future<void> upsertSummary(DigitalUsageSummary summary);

  Future<void> upsertAll(List<DigitalUsageSummary> summaries);
}

class InMemoryUsageSummaryRepository implements UsageSummaryRepository {
  InMemoryUsageSummaryRepository({
    required List<DigitalUsageSummary> summaries,
  }) : _summaries = <DigitalUsageSummary>[
         ...summaries,
       ];

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

  @override
  Future<void> upsertSummary(DigitalUsageSummary summary) async {
    final key = DateKey.fromDate(summary.date);
    _summaries.removeWhere((item) => DateKey.fromDate(item.date) == key);
    _summaries.add(summary);
  }

  @override
  Future<void> upsertAll(List<DigitalUsageSummary> summaries) async {
    for (final summary in summaries) {
      await upsertSummary(summary);
    }
  }
}

class IsarUsageSummaryRepository implements UsageSummaryRepository {
  IsarUsageSummaryRepository(this._isarFuture);

  final Future<Isar> _isarFuture;

  @override
  Future<DigitalUsageSummary?> getByDate(DateTime date) async {
    final isar = await _isarFuture;
    final key = DateKey.fromDate(date);
    final record = await isar.usageSummaryRecords
        .filter()
        .dateKeyEqualTo(key)
        .findFirst();
    return record?.toDomain();
  }

  @override
  Future<void> upsertSummary(DigitalUsageSummary summary) async {
    final isar = await _isarFuture;
    final record = UsageSummaryRecord.fromDomain(summary);
    final existing = await isar.usageSummaryRecords
        .filter()
        .dateKeyEqualTo(record.dateKey)
        .findAll();

    await isar.writeTxn(() async {
      if (existing.isNotEmpty) {
        await isar.usageSummaryRecords.deleteAll(existing.map((item) => item.id).toList(growable: false));
      }
      await isar.usageSummaryRecords.put(record);
    });
  }

  @override
  Future<void> upsertAll(List<DigitalUsageSummary> summaries) async {
    for (final summary in summaries) {
      await upsertSummary(summary);
    }
  }
}
