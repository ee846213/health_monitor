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
  DateTime? deliveredAt;
  String? sourceEventId;
  String? reminderTypeKey;
  String? sourceDimension;

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
      ..responseKey = record.response.name
      ..deliveredAt = record.deliveredAt
      ..sourceEventId = record.sourceEventId
      ..reminderTypeKey = record.reminderTypeKey
      ..sourceDimension = record.sourceDimension;
  }

  ReminderRecord toDomain() {
    return ReminderRecord(
      triggeredAt: triggeredAt,
      type: _mapReminderType(typeKey),
      title: title,
      message: message,
      reasonSummary: reasonSummary,
      actionSuggestion: actionSuggestion,
      response: _mapReminderResponse(responseKey),
      deliveredAt: deliveredAt,
      sourceEventId: sourceEventId,
      reminderTypeKey: reminderTypeKey,
      sourceDimension: sourceDimension,
    );
  }

  ReminderType _mapReminderType(String value) {
    return ReminderType.values.firstWhere(
      (ReminderType item) => item.name == value,
      orElse: () => ReminderType.sedentaryBreak,
    );
  }

  ReminderResponse _mapReminderResponse(String value) {
    return ReminderResponse.values.firstWhere(
      (ReminderResponse item) => item.name == value,
      orElse: () => ReminderResponse.pending,
    );
  }
}
