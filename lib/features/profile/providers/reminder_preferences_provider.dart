import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/domain/notification/reminder_preferences.dart';
import 'package:health_monitor/features/profile/providers/notification_preference_provider.dart';
import 'package:health_monitor/services/android_reminder_policy_bridge.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/reminder_preferences_repository.dart';

final reminderPreferencesRepositoryProvider =
    FutureProvider<ReminderPreferencesRepository>((Ref ref) async {
  final isar = await ref.watch(appIsarProvider.future);
  return IsarReminderPreferencesRepository(isar);
});

final androidReminderPolicyBridgeProvider =
    Provider<AndroidReminderPolicyBridge>((Ref ref) {
  return AndroidReminderPolicyBridge();
});

final reminderPreferencesProvider = AsyncNotifierProvider<
    ReminderPreferencesNotifier,
    ReminderPreferences>(ReminderPreferencesNotifier.new);

class ReminderPreferencesNotifier extends AsyncNotifier<ReminderPreferences> {
  @override
  Future<ReminderPreferences> build() async {
    final repository =
        await ref.watch(reminderPreferencesRepositoryProvider.future);
    final preferences = await repository.read();
    unawaited(_syncPolicyToNative(preferences));
    return preferences;
  }

  Future<void> save(ReminderPreferences preferences) async {
    final repository =
        await ref.read(reminderPreferencesRepositoryProvider.future);
    final previous = state.valueOrNull;
    state = AsyncData(preferences);
    try {
      await repository.save(preferences);
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(previous);
      } else {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
    unawaited(_syncPolicyToNative(preferences));
  }

  Future<void> _syncPolicyToNative(ReminderPreferences preferences) async {
    try {
      final bridge = ref.read(androidReminderPolicyBridgeProvider);
      NotificationPreference notificationPreference;
      final cached = ref.read(notificationPreferenceProvider).valueOrNull;
      if (cached != null) {
        notificationPreference = cached;
      } else {
        final repository =
            await ref.read(notificationPreferenceRepositoryProvider.future);
        notificationPreference = await repository.read();
      }
      await bridge.updatePolicy(
        reminderPreferences: preferences,
        notificationPreference: notificationPreference,
      );
    } catch (_) {
      // 原生策略同步失败不影响本地偏好已落库的结果。
    }
  }
}
