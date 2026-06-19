import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/storage/isar/collections/ambient_light_sample_record.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:isar/isar.dart';

abstract class AmbientLightSampleRepository {
  Future<List<AmbientLightSample>> listByWindow(QueryWindow window);

  Future<void> saveAll(Iterable<AmbientLightSample> samples);

  Future<int> deleteBefore(DateTime cutoff);
}

class InMemoryAmbientLightSampleRepository
    implements AmbientLightSampleRepository {
  InMemoryAmbientLightSampleRepository({
    required List<AmbientLightSample> samples,
  }) : _samples = List<AmbientLightSample>.from(samples);

  final List<AmbientLightSample> _samples;

  @override
  Future<List<AmbientLightSample>> listByWindow(QueryWindow window) async {
    final result = _samples
        .where(
            (AmbientLightSample sample) => window.contains(sample.capturedAt))
        .toList();
    result.sort(
      (AmbientLightSample left, AmbientLightSample right) =>
          left.capturedAt.compareTo(right.capturedAt),
    );
    return result;
  }

  @override
  Future<void> saveAll(Iterable<AmbientLightSample> samples) async {
    _samples.addAll(samples);
  }

  @override
  Future<int> deleteBefore(DateTime cutoff) async {
    final before = _samples.length;
    _samples.removeWhere((sample) => sample.capturedAt.isBefore(cutoff));
    return before - _samples.length;
  }
}

class IsarAmbientLightSampleRepository implements AmbientLightSampleRepository {
  IsarAmbientLightSampleRepository(this._isarFuture);

  final Future<Isar> _isarFuture;

  @override
  Future<List<AmbientLightSample>> listByWindow(QueryWindow window) async {
    final isar = await _isarFuture;
    final records = await isar.ambientLightSampleRecords
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
        .map((AmbientLightSampleRecord record) => record.toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> saveAll(Iterable<AmbientLightSample> samples) async {
    final isar = await _isarFuture;
    final records = samples
        .map(AmbientLightSampleRecord.fromDomain)
        .toList(growable: false);
    if (records.isEmpty) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.ambientLightSampleRecords.putAll(records);
    });
  }

  @override
  Future<int> deleteBefore(DateTime cutoff) async {
    final isar = await _isarFuture;
    return isar.writeTxn(
      () => isar.ambientLightSampleRecords
          .filter()
          .capturedAtLessThan(cutoff)
          .deleteAll(),
    );
  }
}
