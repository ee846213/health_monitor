import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

part 'reminder_record_entity.g.dart';

@collection
class ReminderRecordEntity {
  Id id = Isar.autoIncrement;

  late String dateKey;
  late DateTime triggeredAt;
  late String typeKey;
  late String title;
  late String message;
  late String reasonSummary;
  late String actionSuggestion;
  late String responseKey;

  ReminderRecordEntity();

  factory ReminderRecordEntity.fromDomain(ReminderRecord record) {
    return ReminderRecordEntity()
      ..dateKey = DateKey.fromDate(record.triggeredAt)
      ..triggeredAt = record.triggeredAt
      ..typeKey = record.type.name
      ..title = record.title
      ..message = record.message
      ..reasonSummary = record.reasonSummary
      ..actionSuggestion = record.actionSuggestion
      ..responseKey = record.response.name;
  }
}
