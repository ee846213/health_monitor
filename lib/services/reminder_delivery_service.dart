import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/notification_preference_repository.dart';

typedef NotificationPermissionReader = Future<PermissionGrantStatus> Function();

class ReminderDeliveryService {
  ReminderDeliveryService({
    required NotificationPreferenceRepository notificationPreferenceRepository,
    required NotificationPermissionReader notificationPermissionReader,
  })  : _notificationPreferenceRepository = notificationPreferenceRepository,
        _notificationPermissionReader = notificationPermissionReader;

  final NotificationPreferenceRepository _notificationPreferenceRepository;
  final NotificationPermissionReader _notificationPermissionReader;

  Future<ReminderDeliveryPlan> buildPlan({
    required Iterable<ReminderRecord> records,
    required DateTime referenceTime,
  }) async {
    final permissionStatus = await _notificationPermissionReader();
    final preference = await _notificationPreferenceRepository.read();
    final entries = <ReminderDeliveryEntry>[];

    for (final record in records) {
      if (permissionStatus != PermissionGrantStatus.granted) {
        entries.add(
          ReminderDeliveryEntry.blockedByPermission(
            record,
            plannedAt: referenceTime,
          ),
        );
        continue;
      }

      if (preference.isWithinWindow(referenceTime)) {
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
