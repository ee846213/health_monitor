import 'package:health_monitor/storage/isar/collections/ai_suggestion_cache_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

abstract class AiSuggestionCacheRepository {
  Future<String?> readForDate(DateTime date);

  Future<void> save({
    required DateTime date,
    required String text,
  });
}

class InMemoryAiSuggestionCacheRepository
    implements AiSuggestionCacheRepository {
  InMemoryAiSuggestionCacheRepository({
    Map<String, String> initialCache = const <String, String>{},
  }) : _cache = <String, String>{...initialCache};

  final Map<String, String> _cache;

  @override
  Future<String?> readForDate(DateTime date) async {
    return _cache[DateKey.fromDate(date)];
  }

  @override
  Future<void> save({
    required DateTime date,
    required String text,
  }) async {
    _cache[DateKey.fromDate(date)] = text;
  }
}

class IsarAiSuggestionCacheRepository implements AiSuggestionCacheRepository {
  IsarAiSuggestionCacheRepository(this._isar);

  final Isar _isar;

  @override
  Future<String?> readForDate(DateTime date) async {
    final record = await _isar.aiSuggestionCacheRecords
        .filter()
        .dateKeyEqualTo(DateKey.fromDate(date))
        .findFirst();
    return record?.text;
  }

  @override
  Future<void> save({
    required DateTime date,
    required String text,
  }) async {
    final record = AiSuggestionCacheRecord.fromFields(date: date, text: text);
    final existing = await _isar.aiSuggestionCacheRecords
        .filter()
        .dateKeyEqualTo(record.dateKey)
        .findAll();

    await _isar.writeTxn(() async {
      if (existing.isNotEmpty) {
        await _isar.aiSuggestionCacheRecords.deleteAll(
          existing.map((item) => item.id).toList(growable: false),
        );
      }
      await _isar.aiSuggestionCacheRecords.put(record);
    });
  }
}
