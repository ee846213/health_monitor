import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/reminders/pages/reminder_pages.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

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

  testWidgets('提醒筛选只展示匹配类型并可清除', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          reminderListProvider.overrideWith(
            (ref) async => <ReminderRecord>[
              _record('久坐提醒'),
              ReminderRecord(
                type: ReminderType.noisyEnvironment,
                title: '噪音提醒',
                message: '环境偏吵',
                reasonSummary: '噪音等级偏高',
                actionSuggestion: '换到安静区域',
                triggeredAt: DateTime(2026, 6, 18, 10),
                response: ReminderResponse.pending,
              ),
            ],
          ),
          walkingScreenRiskNoticeProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(home: ReminderListPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reminder-filter-button')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('环境噪音'));
    await tester.pumpAndSettle();

    expect(find.text('噪音提醒'), findsOneWidget);
    expect(find.text('久坐提醒'), findsNothing);
  });

  testWidgets('提醒详情可更新为已处理状态', (tester) async {
    final record = _record('需要处理的提醒');
    final repository =
        InMemoryReminderRepository(records: <ReminderRecord>[record]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          reminderRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: MaterialApp(home: ReminderDetailPage(record: record)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('我已处理'));
    await tester.pumpAndSettle();

    final stored = (await repository.listRecentDays(
      1,
      referenceDate: record.triggeredAt,
    ))
        .single;
    expect(stored.response, ReminderResponse.taken);
    expect(find.text('我已处理'), findsNothing);
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
