import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/storage/isar/collections/noise_sample_record.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:isar/isar.dart';

abstract class NoiseSampleRepository {
  Future<List<NoiseSample>> listByWindow(QueryWindow window);

  Future<void> saveAll(Iterable<NoiseSample> samples);
}

class InMemoryNoiseSampleRepository implements NoiseSampleRepository {
  InMemoryNoiseSampleRepository({
    required List<NoiseSample> samples,
  }) : _samples = List<NoiseSample>.from(samples);

  final List<NoiseSample> _samples;

  @override
  Future<List<NoiseSample>> listByWindow(QueryWindow window) async {
    final result =
        _samples.where((sample) => window.contains(sample.capturedAt)).toList();
    result.sort((left, right) => left.capturedAt.compareTo(right.capturedAt));
    return result;
  }

  @override
  Future<void> saveAll(Iterable<NoiseSample> samples) async {
    _samples.addAll(samples);
  }
}

class IsarNoiseSampleRepository implements NoiseSampleRepository {
  IsarNoiseSampleRepository(this._isarFuture);

  final Future<Isar> _isarFuture;

  @override
  Future<List<NoiseSample>> listByWindow(QueryWindow window) async {
    final isar = await _isarFuture;
    final records = await isar.noiseSampleRecords
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
        .map((NoiseSampleRecord record) => record.toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> saveAll(Iterable<NoiseSample> samples) async {
    final isar = await _isarFuture;
    final records =
        samples.map(NoiseSampleRecord.fromDomain).toList(growable: false);
    if (records.isEmpty) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.noiseSampleRecords.putAll(records);
    });
  }
}
