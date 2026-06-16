import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:isar/isar.dart';

part 'notification_preference_record.g.dart';

@collection
class NotificationPreferenceRecord {
  Id id = 1;
  late bool enabled;
  late int startHour;
  late int startMinute;
  late int endHour;
  late int endMinute;

  static NotificationPreferenceRecord fromDomain(
    NotificationPreference preference,
  ) {
    return NotificationPreferenceRecord()
      ..enabled = preference.enabled
      ..startHour = preference.startHour
      ..startMinute = preference.startMinute
      ..endHour = preference.endHour
      ..endMinute = preference.endMinute;
  }

  NotificationPreference toDomain() {
    return NotificationPreference(
      enabled: enabled,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
    );
  }
}
