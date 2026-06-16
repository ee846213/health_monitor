import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

part 'ai_suggestion_cache_record.g.dart';

@collection
class AiSuggestionCacheRecord {
  Id id = Isar.autoIncrement;
  late String dateKey;
  late DateTime generatedAt;
  late String text;

  static AiSuggestionCacheRecord fromFields({
    required DateTime date,
    required String text,
  }) {
    return AiSuggestionCacheRecord()
      ..dateKey = DateKey.fromDate(date)
      ..generatedAt = date
      ..text = text;
  }
}
