import 'package:health_monitor/domain/notification/reminder_preferences.dart';
import 'package:health_monitor/storage/isar/collections/reminder_preferences_record.dart';
import 'package:isar/isar.dart';

abstract class ReminderPreferencesRepository {
  Future<ReminderPreferences> read();

  Future<void> save(ReminderPreferences preferences);
}

class InMemoryReminderPreferencesRepository
    implements ReminderPreferencesRepository {
  InMemoryReminderPreferencesRepository({
    ReminderPreferences? initialValue,
  }) : _value = initialValue ?? ReminderPreferences.defaults;

  ReminderPreferences _value;

  @override
  Future<ReminderPreferences> read() async => _value;

  @override
  Future<void> save(ReminderPreferences preferences) async {
    _value = preferences;
  }
}

class IsarReminderPreferencesRepository
    implements ReminderPreferencesRepository {
  IsarReminderPreferencesRepository(this._isar);

  final Isar _isar;

  @override
  Future<ReminderPreferences> read() async {
    final record = await _isar.reminderPreferencesRecords.get(1);
    return record?.toDomain() ?? ReminderPreferences.defaults;
  }

  @override
  Future<void> save(ReminderPreferences preferences) async {
    final record = ReminderPreferencesRecord.fromDomain(preferences);
    await _isar.writeTxn(() async {
      await _isar.reminderPreferencesRecords.put(record);
    });
  }
}
