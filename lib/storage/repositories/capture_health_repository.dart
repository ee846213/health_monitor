import 'package:health_monitor/domain/health/capture_checkpoint.dart';
import 'package:health_monitor/domain/health/capture_health_event.dart';
import 'package:health_monitor/storage/isar/collections/capture_checkpoint_record.dart';
import 'package:health_monitor/storage/isar/collections/capture_health_event_record.dart';
import 'package:isar/isar.dart';

abstract class CaptureHealthRepository {
  Future<void> saveEvent(CaptureHealthEvent event);

  Future<void> saveEvents(Iterable<CaptureHealthEvent> events);

  Future<List<CaptureHealthEvent>> listRecentEvents({
    required int limit,
    String? streamKey,
  });

  Future<CaptureCheckpoint?> getCheckpoint(String streamKey);

  Future<List<CaptureCheckpoint>> listCheckpoints();

  Future<void> upsertCheckpoint(CaptureCheckpoint checkpoint);
}

class InMemoryCaptureHealthRepository implements CaptureHealthRepository {
  InMemoryCaptureHealthRepository({
    List<CaptureHealthEvent> events = const <CaptureHealthEvent>[],
    List<CaptureCheckpoint> checkpoints = const <CaptureCheckpoint>[],
  })  : _events = <CaptureHealthEvent>[...events],
        _checkpoints = <String, CaptureCheckpoint>{
          for (final checkpoint in checkpoints)
            checkpoint.streamKey: checkpoint,
        };

  final List<CaptureHealthEvent> _events;
  final Map<String, CaptureCheckpoint> _checkpoints;

  @override
  Future<void> saveEvent(CaptureHealthEvent event) async {
    _events.add(event);
  }

  @override
  Future<void> saveEvents(Iterable<CaptureHealthEvent> events) async {
    _events.addAll(events);
  }

  @override
  Future<List<CaptureHealthEvent>> listRecentEvents({
    required int limit,
    String? streamKey,
  }) async {
    final result = _events.where((event) {
      if (streamKey == null) {
        return true;
      }
      return event.streamKey == streamKey;
    }).toList()
      ..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
    return result.take(limit).toList(growable: false);
  }

  @override
  Future<CaptureCheckpoint?> getCheckpoint(String streamKey) async {
    return _checkpoints[streamKey];
  }

  @override
  Future<List<CaptureCheckpoint>> listCheckpoints() async {
    final result = _checkpoints.values.toList()
      ..sort((left, right) => left.streamKey.compareTo(right.streamKey));
    return result;
  }

  @override
  Future<void> upsertCheckpoint(CaptureCheckpoint checkpoint) async {
    _checkpoints[checkpoint.streamKey] = checkpoint;
  }
}

class IsarCaptureHealthRepository implements CaptureHealthRepository {
  IsarCaptureHealthRepository(this._isarFuture);

  final Future<Isar> _isarFuture;

  @override
  Future<void> saveEvent(CaptureHealthEvent event) async {
    await saveEvents(<CaptureHealthEvent>[event]);
  }

  @override
  Future<void> saveEvents(Iterable<CaptureHealthEvent> events) async {
    final isar = await _isarFuture;
    final records =
        events.map(CaptureHealthEventRecord.fromDomain).toList(growable: false);
    if (records.isEmpty) {
      return;
    }
    await isar.writeTxn(() async {
      await isar.captureHealthEventRecords.putAll(records);
    });
  }

  @override
  Future<List<CaptureHealthEvent>> listRecentEvents({
    required int limit,
    String? streamKey,
  }) async {
    final isar = await _isarFuture;
    final records =
        await isar.captureHealthEventRecords.where().anyId().findAll();
    final result = records
        .where((CaptureHealthEventRecord record) {
          if (streamKey == null) {
            return true;
          }
          return record.streamKey == streamKey;
        })
        .map((CaptureHealthEventRecord record) => record.toDomain())
        .toList()
      ..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
    return result.take(limit).toList(growable: false);
  }

  @override
  Future<CaptureCheckpoint?> getCheckpoint(String streamKey) async {
    final isar = await _isarFuture;
    final record = await isar.captureCheckpointRecords
        .filter()
        .streamKeyEqualTo(streamKey)
        .findFirst();
    return record?.toDomain();
  }

  @override
  Future<List<CaptureCheckpoint>> listCheckpoints() async {
    final isar = await _isarFuture;
    final records =
        await isar.captureCheckpointRecords.where().anyId().findAll();
    final result = records
        .map((CaptureCheckpointRecord record) => record.toDomain())
        .toList(growable: false);
    result.sort((left, right) => left.streamKey.compareTo(right.streamKey));
    return result;
  }

  @override
  Future<void> upsertCheckpoint(CaptureCheckpoint checkpoint) async {
    final isar = await _isarFuture;
    final record = CaptureCheckpointRecord.fromDomain(checkpoint);
    final existing = await isar.captureCheckpointRecords
        .filter()
        .streamKeyEqualTo(checkpoint.streamKey)
        .findAll();

    await isar.writeTxn(() async {
      if (existing.isNotEmpty) {
        await isar.captureCheckpointRecords
            .deleteAll(existing.map((item) => item.id).toList(growable: false));
      }
      await isar.captureCheckpointRecords.put(record);
    });
  }
}
