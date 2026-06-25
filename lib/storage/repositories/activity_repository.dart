import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/rhythm_step_sample_dedup.dart';
import 'package:health_monitor/storage/isar/collections/activity_sample_record.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:isar/isar.dart';

abstract class ActivityRepository {
  Future<List<ActivitySample>> listByWindow(QueryWindow window);

  Future<void> saveAll(Iterable<ActivitySample> samples);

  Future<int> deleteBefore(DateTime cutoff);

  /// 用最新 Health Connect 小时桶覆盖当日对应样本，避免重复累计。
  Future<void> replaceHealthConnectHourlyForDay(
    DateTime dayStart,
    Iterable<ActivitySample> samples,
  );
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

  @override
  Future<int> deleteBefore(DateTime cutoff) async {
    final before = _samples.length;
    _samples.removeWhere((sample) => sample.capturedAt.isBefore(cutoff));
    return before - _samples.length;
  }

  @override
  Future<void> replaceHealthConnectHourlyForDay(
    DateTime dayStart,
    Iterable<ActivitySample> samples,
  ) async {
    final dayEnd = dayStart.add(const Duration(days: 1));
    final hcSamples = samples.toList(growable: false);
    final coveredHours = healthConnectHourStarts(hcSamples);
    _samples.removeWhere(
      (ActivitySample sample) =>
          sample.source == MotionSampleSource.healthConnectHourly &&
          !sample.capturedAt.isBefore(dayStart) &&
          sample.capturedAt.isBefore(dayEnd),
    );
    _samples.removeWhere(
      (ActivitySample sample) =>
          sample.source == MotionSampleSource.platformActivity &&
          isSameCalendarDay(sample.capturedAt, dayStart) &&
          isCoveredByHealthConnectHour(sample.capturedAt, coveredHours),
    );
    _samples.addAll(hcSamples);
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

  @override
  Future<int> deleteBefore(DateTime cutoff) async {
    final isar = await _isarFuture;
    return isar.writeTxn(
      () => isar.activitySampleRecords
          .filter()
          .capturedAtLessThan(cutoff)
          .deleteAll(),
    );
  }

  @override
  Future<void> replaceHealthConnectHourlyForDay(
    DateTime dayStart,
    Iterable<ActivitySample> samples,
  ) async {
    final isar = await _isarFuture;
    final dayEnd = dayStart.add(const Duration(days: 1));
    final hcSamples = samples.toList(growable: false);
    final coveredHours = healthConnectHourStarts(hcSamples);
    final records = hcSamples.map(ActivitySampleRecord.fromDomain).toList(growable: false);
    await isar.writeTxn(() async {
      await isar.activitySampleRecords
          .filter()
          .sourceKeyEqualTo(MotionSampleSource.healthConnectHourly.name)
          .capturedAtBetween(
            dayStart,
            dayEnd,
            includeLower: true,
            includeUpper: false,
          )
          .deleteAll();
      for (final hourStart in coveredHours) {
        final hourEnd = hourStart.add(const Duration(hours: 1));
        await isar.activitySampleRecords
            .filter()
            .sourceKeyEqualTo(MotionSampleSource.platformActivity.name)
            .capturedAtBetween(
              hourStart,
              hourEnd,
              includeLower: true,
              includeUpper: false,
            )
            .deleteAll();
      }
      if (records.isNotEmpty) {
        await isar.activitySampleRecords.putAll(records);
      }
    });
  }
}
