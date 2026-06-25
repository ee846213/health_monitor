import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/notification_preference_repository.dart';
import 'package:health_monitor/storage/repositories/reminder_preferences_repository.dart';

typedef NotificationPermissionReader = Future<PermissionGrantStatus> Function();

class ReminderDeliveryService {
  ReminderDeliveryService({
    required NotificationPreferenceRepository notificationPreferenceRepository,
    required ReminderPreferencesRepository reminderPreferencesRepository,
    required NotificationPermissionReader notificationPermissionReader,
  })  : _notificationPreferenceRepository = notificationPreferenceRepository,
        _reminderPreferencesRepository = reminderPreferencesRepository,
        _notificationPermissionReader = notificationPermissionReader;

  final NotificationPreferenceRepository _notificationPreferenceRepository;
  final ReminderPreferencesRepository _reminderPreferencesRepository;
  final NotificationPermissionReader _notificationPermissionReader;

  Future<ReminderDeliveryPlan> buildPlan({
    required Iterable<ReminderRecord> records,
    required DateTime referenceTime,
  }) async {
    final permissionStatus = await _notificationPermissionReader();
    final notificationPreference =
        await _notificationPreferenceRepository.read();
    final reminderPreferences = await _reminderPreferencesRepository.read();
    final entries = <ReminderDeliveryEntry>[];

    for (final record in records) {
      if (!reminderPreferences
          .isReminderTypeAllowed(record.reminderTypeKey)) {
        entries.add(
          ReminderDeliveryEntry.blockedByPreference(
            record,
            plannedAt: referenceTime,
          ),
        );
        continue;
      }

      if (permissionStatus != PermissionGrantStatus.granted) {
        entries.add(
          ReminderDeliveryEntry.blockedByPermission(
            record,
            plannedAt: referenceTime,
          ),
        );
        continue;
      }

      if (notificationPreference.isWithinWindow(referenceTime)) {
        entries.add(
          ReminderDeliveryEntry.blockedByDnd(
            record,
            plannedAt: referenceTime,
          ),
        );
        continue;
      }

      entries.add(
        ReminderDeliveryEntry.ready(
          record,
          plannedAt: referenceTime,
        ),
      );
    }

    return ReminderDeliveryPlan(entries: entries);
  }
}
