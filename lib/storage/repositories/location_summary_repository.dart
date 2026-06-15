import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/storage/isar/collections/location_summary_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

abstract class LocationSummaryRepository {
  Future<List<LocationSummary>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  });

  Future<void> upsertSummary(LocationSummary summary);
}

class InMemoryLocationSummaryRepository implements LocationSummaryRepository {
  InMemoryLocationSummaryRepository({
    required List<LocationSummary> summaries,
  }) : _summaries = <LocationSummary>[
         ...summaries,
       ];

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

  @override
  Future<void> upsertSummary(LocationSummary summary) async {
    final key = DateKey.fromDate(summary.date);
    _summaries.removeWhere((item) => DateKey.fromDate(item.date) == key);
    _summaries.add(summary);
  }
}

class IsarLocationSummaryRepository implements LocationSummaryRepository {
  IsarLocationSummaryRepository(this._isarFuture);

  final Future<Isar> _isarFuture;

  @override
  Future<List<LocationSummary>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final isar = await _isarFuture;
    final keys = DateKey.recentDays(days, referenceDate: referenceDate);
    final records = await isar.locationSummaryRecords.where().anyId().findAll();
    final result = records
        .where((record) => keys.contains(record.dateKey))
        .map((LocationSummaryRecord record) => record.toDomain())
        .toList(growable: false);
    result.sort((left, right) => left.date.compareTo(right.date));
    return result;
  }

  @override
  Future<void> upsertSummary(LocationSummary summary) async {
    final isar = await _isarFuture;
    final record = LocationSummaryRecord.fromDomain(summary);
    final existing = await isar.locationSummaryRecords
        .filter()
        .dateKeyEqualTo(record.dateKey)
        .findAll();

    await isar.writeTxn(() async {
      if (existing.isNotEmpty) {
        await isar.locationSummaryRecords.deleteAll(existing.map((item) => item.id).toList(growable: false));
      }
      await isar.locationSummaryRecords.put(record);
    });
  }
}
