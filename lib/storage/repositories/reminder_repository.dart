import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/storage/isar/collections/reminder_record_entity.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

abstract class ReminderRepository {
  Future<void> saveAll(Iterable<ReminderRecord> records);

  Future<List<ReminderRecord>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  });

  Future<ReminderRecord?> getLatest();

  Future<List<ReminderRecord>> listUndeliveredSince(DateTime since);

  Future<void> markDelivered(
    Iterable<ReminderRecord> records, {
    required DateTime deliveredAt,
  });

  Future<void> updateResponse(
    ReminderRecord record,
    ReminderResponse response,
  );
}

class InMemoryReminderRepository implements ReminderRepository {
  InMemoryReminderRepository({
    List<ReminderRecord> records = const <ReminderRecord>[],
  }) : _records = <ReminderRecord>[] {
    _mergeRecords(records);
  }

  final List<ReminderRecord> _records;

  @override
  Future<void> saveAll(Iterable<ReminderRecord> records) async {
    _mergeRecords(records);
  }

  @override
  Future<List<ReminderRecord>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final keys = DateKey.recentDays(days, referenceDate: referenceDate).toSet();
    final result = _records
        .where((item) => keys.contains(DateKey.fromDate(item.triggeredAt)))
        .toList();

    // 提醒历史页默认展示“最近发生了什么”，因此仓储层统一按最新在前排序，
    // 避免页面层和详情页各自重复处理顺序，也让最新提醒读取保持一致。
    result.sort((left, right) => right.triggeredAt.compareTo(left.triggeredAt));
    return result;
  }

  @override
  Future<ReminderRecord?> getLatest() async {
    if (_records.isEmpty) {
      return null;
    }

    final sorted = _records.toList()
      ..sort((left, right) => right.triggeredAt.compareTo(left.triggeredAt));
    return sorted.first;
  }

  @override
  Future<List<ReminderRecord>> listUndeliveredSince(DateTime since) async {
    return _records
        .where(
          (item) => item.triggeredAt.isAfter(since) && item.deliveredAt == null,
        )
        .toList(growable: false);
  }

  @override
  Future<void> markDelivered(
    Iterable<ReminderRecord> records, {
    required DateTime deliveredAt,
  }) async {
    final deliveredKeys = records.map(_historyDedupKeyForRecord).toSet();
    for (var index = 0; index < _records.length; index++) {
      final item = _records[index];
      if (item.deliveredAt == null &&
          deliveredKeys.contains(_historyDedupKeyForRecord(item))) {
        _records[index] = item.copyWith(deliveredAt: deliveredAt);
      }
    }
  }

  @override
  Future<void> updateResponse(
    ReminderRecord record,
    ReminderResponse response,
  ) async {
    final key = _historyDedupKeyForRecord(record);
    for (var index = 0; index < _records.length; index++) {
      if (_historyDedupKeyForRecord(_records[index]) == key) {
        _records[index] = _records[index].copyWith(response: response);
        return;
      }
    }
  }

  void _mergeRecords(Iterable<ReminderRecord> records) {
    final existingKeys = _records.map(_historyDedupKeyForRecord).toSet();
    for (final record in records) {
      final key = _historyDedupKeyForRecord(record);
      if (existingKeys.add(key)) {
        _records.add(record);
      }
    }
  }
}

class IsarReminderRepository implements ReminderRepository {
  IsarReminderRepository(this._isar);

  final Isar _isar;

  @override
  Future<void> saveAll(Iterable<ReminderRecord> records) async {
    final normalizedRecords = _dedupeIncomingRecords(records);
    if (normalizedRecords.isEmpty) {
      return;
    }

    final existingRecords =
        await _isar.reminderRecordEntitys.where().anyId().findAll();
    final existingKeys = existingRecords.map(_historyDedupKeyForEntity).toSet();

    final entitiesToInsert = normalizedRecords
        .where(
          (ReminderRecord record) =>
              !existingKeys.contains(_historyDedupKeyForRecord(record)),
        )
        .map(ReminderRecordEntity.fromDomain)
        .toList(growable: false);

    if (entitiesToInsert.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.reminderRecordEntitys.putAll(entitiesToInsert);
    });
  }

  @override
  Future<List<ReminderRecord>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final keys = DateKey.recentDays(days, referenceDate: referenceDate);
    final entities =
        await _isar.reminderRecordEntitys.where().anyId().findAll();
    final filteredEntities = entities
        .where((ReminderRecordEntity entity) => keys.contains(entity.dateKey))
        .toList(growable: false);
    filteredEntities.sort(
      (left, right) => right.triggeredAt.compareTo(left.triggeredAt),
    );

    return filteredEntities
        .map((ReminderRecordEntity entity) => entity.toDomain())
        .toList(growable: false);
  }

  @override
  Future<ReminderRecord?> getLatest() async {
    final entities =
        await _isar.reminderRecordEntitys.where().anyId().findAll();
    if (entities.isEmpty) {
      return null;
    }
    entities.sort(
      (left, right) => right.triggeredAt.compareTo(left.triggeredAt),
    );
    return entities.first.toDomain();
  }

  @override
  Future<List<ReminderRecord>> listUndeliveredSince(DateTime since) async {
    final entities =
        await _isar.reminderRecordEntitys.where().anyId().findAll();
    return entities
        .where(
          (item) => item.triggeredAt.isAfter(since) && item.deliveredAt == null,
        )
        .map((item) => item.toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> markDelivered(
    Iterable<ReminderRecord> records, {
    required DateTime deliveredAt,
  }) async {
    final deliveredKeys = records.map(_historyDedupKeyForRecord).toSet();
    final entities =
        await _isar.reminderRecordEntitys.where().anyId().findAll();
    final targets = entities
        .where(
            (item) => deliveredKeys.contains(_historyDedupKeyForEntity(item)))
        .toList(growable: false);
    if (targets.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      for (final entity in targets) {
        if (entity.deliveredAt != null) {
          continue;
        }
        entity.deliveredAt = deliveredAt;
      }
      await _isar.reminderRecordEntitys.putAll(targets);
    });
  }

  @override
  Future<void> updateResponse(
    ReminderRecord record,
    ReminderResponse response,
  ) async {
    final key = _historyDedupKeyForRecord(record);
    final entities =
        await _isar.reminderRecordEntitys.where().anyId().findAll();
    final target = entities.cast<ReminderRecordEntity?>().firstWhere(
          (entity) =>
              entity != null && _historyDedupKeyForEntity(entity) == key,
          orElse: () => null,
        );
    if (target == null) {
      return;
    }
    target.responseKey = response.name;
    await _isar.writeTxn(() async {
      await _isar.reminderRecordEntitys.put(target);
    });
  }
}

List<ReminderRecord> _dedupeIncomingRecords(Iterable<ReminderRecord> records) {
  final dedupedByKey = <String, ReminderRecord>{};
  for (final record in records) {
    dedupedByKey.putIfAbsent(_historyDedupKeyForRecord(record), () => record);
  }
  return dedupedByKey.values.toList(growable: false);
}

String _historyDedupKeyForRecord(ReminderRecord record) {
  if (record.sourceEventId != null && record.sourceEventId!.isNotEmpty) {
    return 'event:${record.sourceEventId}';
  }

  // 当前提醒记录还没有来自后台任务或通知系统的稳定事件 ID。
  // 在正式事件链路补齐前，先用“日期 + 类型 + 标题 + 原因摘要”作为去重键，
  // 避免规则重复计算、页面重建或多次进入时把同一条提醒刷成多条历史。
  return [
    DateKey.fromDate(record.triggeredAt),
    record.type.name,
    record.title,
    record.reasonSummary,
  ].join('|');
}

String _historyDedupKeyForEntity(ReminderRecordEntity entity) {
  if (entity.sourceEventId != null && entity.sourceEventId!.isNotEmpty) {
    return 'event:${entity.sourceEventId}';
  }

  return [
    entity.dateKey,
    entity.typeKey,
    entity.title,
    entity.reasonSummary,
  ].join('|');
}
