import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/services/android_reminder_policy_bridge.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/notification_preference_repository.dart';
import 'package:health_monitor/storage/repositories/reminder_preferences_repository.dart';

final notificationPreferenceRepositoryProvider =
    FutureProvider<NotificationPreferenceRepository>((Ref ref) async {
  final isar = await ref.watch(appIsarProvider.future);
  return IsarNotificationPreferenceRepository(isar);
});

final notificationPreferenceProvider = AsyncNotifierProvider<
    NotificationPreferenceNotifier,
    NotificationPreference>(NotificationPreferenceNotifier.new);

class NotificationPreferenceNotifier
    extends AsyncNotifier<NotificationPreference> {
  @override
  Future<NotificationPreference> build() async {
    final repository =
        await ref.watch(notificationPreferenceRepositoryProvider.future);
    return repository.read();
  }

  Future<void> save(NotificationPreference preference) async {
    final repository =
        await ref.read(notificationPreferenceRepositoryProvider.future);
    final previous = state.valueOrNull;
    state = AsyncData(preference);
    try {
      await repository.save(preference);
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(previous);
      } else {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
    unawaited(_syncNativeReminderPolicy(preference));
  }

  Future<void> _syncNativeReminderPolicy(
    NotificationPreference notificationPreference,
  ) async {
    try {
      final isar = await ref.read(appIsarProvider.future);
      final reminderPreferences =
          await IsarReminderPreferencesRepository(isar).read();
      await AndroidReminderPolicyBridge().updatePolicy(
        reminderPreferences: reminderPreferences,
        notificationPreference: notificationPreference,
      );
    } catch (_) {
      // 原生策略同步失败不影响本地勿扰设置已落库的结果。
    }
  }
}
