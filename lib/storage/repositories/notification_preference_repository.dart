import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/storage/isar/collections/notification_preference_record.dart';
import 'package:isar/isar.dart';

const NotificationPreference kDefaultNotificationPreference =
    NotificationPreference(
  enabled: false,
  startHour: 22,
  startMinute: 30,
  endHour: 7,
  endMinute: 0,
);

abstract class NotificationPreferenceRepository {
  Future<NotificationPreference> read();

  Future<void> save(NotificationPreference preference);
}

class InMemoryNotificationPreferenceRepository
    implements NotificationPreferenceRepository {
  InMemoryNotificationPreferenceRepository({
    NotificationPreference initialValue = kDefaultNotificationPreference,
  }) : _value = initialValue;

  NotificationPreference _value;

  @override
  Future<NotificationPreference> read() async {
    return _value;
  }

  @override
  Future<void> save(NotificationPreference preference) async {
    _value = preference;
  }
}

class IsarNotificationPreferenceRepository
    implements NotificationPreferenceRepository {
  IsarNotificationPreferenceRepository(this._isar);

  final Isar _isar;

  @override
  Future<NotificationPreference> read() async {
    final record = await _isar.notificationPreferenceRecords.get(1);
    return record?.toDomain() ?? kDefaultNotificationPreference;
  }

  @override
  Future<void> save(NotificationPreference preference) async {
    final record = NotificationPreferenceRecord.fromDomain(preference);
    await _isar.writeTxn(() async {
      await _isar.notificationPreferenceRecords.put(record);
    });
  }
}
