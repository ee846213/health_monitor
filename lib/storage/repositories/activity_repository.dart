import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/storage/isar/collections/activity_sample_record.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:isar/isar.dart';

abstract class ActivityRepository {
  Future<List<ActivitySample>> listByWindow(QueryWindow window);

  Future<void> saveAll(Iterable<ActivitySample> samples);
}

class InMemoryActivityRepository implements ActivityRepository {
  InMemoryActivityRepository({
    required List<ActivitySample> samples,
  }) : _samples = List<ActivitySample>.from(samples);

  final List<ActivitySample> _samples;

  @override
  Future<List<ActivitySample>> listByWindow(QueryWindow window) async {
    final result =
        _samples.where((sample) => window.contains(sample.capturedAt)).toList();
    result.sort((left, right) => left.capturedAt.compareTo(right.capturedAt));
    return result;
  }

  @override
  Future<void> saveAll(Iterable<ActivitySample> samples) async {
    _samples.addAll(samples);
  }
}

class IsarActivityRepository implements ActivityRepository {
  IsarActivityRepository(this._isarFuture);

  final Future<Isar> _isarFuture;

  @override
  Future<List<ActivitySample>> listByWindow(QueryWindow window) async {
    final isar = await _isarFuture;
    final records = await isar.activitySampleRecords
        .filter()
        .capturedAtBetween(
          window.startAt,
          window.endAt,
          includeLower: true,
          includeUpper: false,
        )
        .sortByCapturedAt()
        .findAll();
    return records
        .map((ActivitySampleRecord record) => record.toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> saveAll(Iterable<ActivitySample> samples) async {
    final isar = await _isarFuture;
    final records =
        samples.map(ActivitySampleRecord.fromDomain).toList(growable: false);
    if (records.isEmpty) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.activitySampleRecords.putAll(records);
    });
  }
}
