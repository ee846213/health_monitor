import 'package:health_monitor/domain/reminder/reminder_record.dart';

enum DeliveryBlockReason {
  doNotDisturb,
  notificationPermissionDenied,
  reminderPreferenceDisabled,
}

class ReminderDeliveryEntry {
  const ReminderDeliveryEntry._({
    required this.record,
    this.plannedAt,
    this.reason,
  });

  final ReminderRecord record;
  final DateTime? plannedAt;
  final DeliveryBlockReason? reason;

  String get title => record.title;

  bool get isReady => reason == null;

  bool get isBlocked => reason != null;

  factory ReminderDeliveryEntry.ready(
    ReminderRecord record, {
    DateTime? plannedAt,
  }) {
    return ReminderDeliveryEntry._(
      record: record,
      plannedAt: plannedAt,
    );
  }

  factory ReminderDeliveryEntry.blockedByDnd(
    ReminderRecord record, {
    DateTime? plannedAt,
  }) {
    return ReminderDeliveryEntry._(
      record: record,
      plannedAt: plannedAt,
      reason: DeliveryBlockReason.doNotDisturb,
    );
  }

  factory ReminderDeliveryEntry.blockedByPermission(
    ReminderRecord record, {
    DateTime? plannedAt,
  }) {
    return ReminderDeliveryEntry._(
      record: record,
      plannedAt: plannedAt,
      reason: DeliveryBlockReason.notificationPermissionDenied,
    );
  }

  factory ReminderDeliveryEntry.blockedByPreference(
    ReminderRecord record, {
    DateTime? plannedAt,
  }) {
    return ReminderDeliveryEntry._(
      record: record,
      plannedAt: plannedAt,
      reason: DeliveryBlockReason.reminderPreferenceDisabled,
    );
  }
}

class ReminderDeliveryPlan {
  ReminderDeliveryPlan({
    required List<ReminderDeliveryEntry> entries,
  }) : entries = List.unmodifiable(entries);

  final List<ReminderDeliveryEntry> entries;

  List<ReminderRecord> get readyRecords {
    return entries
        .where((entry) => entry.isReady)
        .map((entry) => entry.record)
        .toList(growable: false);
  }

  List<ReminderDeliveryEntry> get blockedRecords {
    return entries.where((entry) => entry.isBlocked).toList(growable: false);
  }
}
