import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/reminders/pages/reminder_pages.dart';

void main() {
  testWidgets('提醒记录刷新时保留已有卡片，不切换为整页加载', (
    WidgetTester tester,
  ) async {
    var completer = Completer<List<ReminderRecord>>();
    final container = ProviderContainer(
      overrides: <Override>[
        reminderListProvider.overrideWith((Ref ref) => completer.future),
        walkingScreenRiskNoticeProvider.overrideWith(
          (Ref ref) async => null,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ReminderListPage()),
      ),
    );

    completer.complete(<ReminderRecord>[_record('首次提醒')]);
    await tester.pumpAndSettle();
    expect(find.text('首次提醒'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    completer = Completer<List<ReminderRecord>>();
    container.invalidate(reminderListProvider);
    await tester.pump();

    expect(find.text('首次提醒'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    completer.complete(<ReminderRecord>[_record('更新后的提醒')]);
    await tester.pumpAndSettle();
    expect(find.text('更新后的提醒'), findsOneWidget);
  });
}

ReminderRecord _record(String title) {
  return ReminderRecord(
    type: ReminderType.sedentaryBreak,
    title: title,
    message: '测试消息',
    reasonSummary: '测试原因',
    actionSuggestion: '测试建议',
    triggeredAt: DateTime(2026, 6, 18, 9),
    response: ReminderResponse.pending,
  );
}
