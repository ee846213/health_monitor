import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/features/profile/providers/notification_preference_provider.dart';
import 'package:health_monitor/features/profile/widgets/do_not_disturb_section.dart';

void main() {
  testWidgets('勿扰设置区块会展示开关和时间段', (WidgetTester tester) async {
    final notifier = _FakeNotificationPreferenceNotifier(
      const NotificationPreference(
        enabled: true,
        startHour: 22,
        startMinute: 30,
        endHour: 7,
        endMinute: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          notificationPreferenceProvider.overrideWith(() => notifier),
        ],
        child: const MaterialApp(home: Scaffold(body: DoNotDisturbSection())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('勿扰时间'), findsOneWidget);
    await tester.tap(find.byKey(const Key('do-not-disturb-row')));
    await tester.pumpAndSettle();
    expect(find.text('启用勿扰'), findsOneWidget);
    expect(find.text('22:30'), findsOneWidget);
    expect(find.text('07:00'), findsOneWidget);
  });

  testWidgets('点击开关后会更新勿扰启用状态', (WidgetTester tester) async {
    final notifier = _FakeNotificationPreferenceNotifier(
      const NotificationPreference(
        enabled: true,
        startHour: 22,
        startMinute: 30,
        endHour: 7,
        endMinute: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          notificationPreferenceProvider.overrideWith(() => notifier),
        ],
        child: const MaterialApp(home: Scaffold(body: DoNotDisturbSection())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('do-not-disturb-row')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(notifier.state.requireValue.enabled, isFalse);
  });
}

class _FakeNotificationPreferenceNotifier
    extends NotificationPreferenceNotifier {
  _FakeNotificationPreferenceNotifier(NotificationPreference initialValue)
      : _initialValue = initialValue;

  final NotificationPreference _initialValue;

  @override
  Future<NotificationPreference> build() async {
    return _initialValue;
  }

  @override
  Future<void> save(NotificationPreference preference) async {
    state = AsyncData(preference);
  }
}
