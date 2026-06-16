import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/notification_preference_repository.dart';

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
    state = AsyncData(preference);
    await repository.save(preference);
  }
}
