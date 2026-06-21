import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/storage/isar/collections/reminder_record_entity.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';
import 'package:isar/isar.dart';

void main() {
  test('提醒仓储应按最近天数返回最新在前的历史结果', () async {
    final repository = InMemoryReminderRepository(
      records: <ReminderRecord>[
        ReminderRecord(
          triggeredAt: DateTime(2026, 6, 7, 21),
          type: ReminderType.nightUsage,
          title: '今晚早点休息',
          message: '深夜看屏幕的时间有点久了。',
          reasonSummary: '22 点前后屏幕活跃较集中。',
          actionSuggestion: '把剩下的内容明天再看。',
          response: ReminderResponse.dismissed,
        ),
        ReminderRecord(
          triggeredAt: DateTime(2026, 6, 9, 15),
          type: ReminderType.sedentaryBreak,
          title: '起身走一走',
          message: '你已经连续坐了很久。',
          reasonSummary: '过去一小时几乎没有活动。',
          actionSuggestion: '走两分钟再继续。',
          response: ReminderResponse.taken,
        ),
      ],
    );

    final result = await repository.listRecentDays(
      7,
      referenceDate: DateTime(2026, 6, 9),
    );

    expect(result.map((item) => item.triggeredAt.day), <int>[9, 7]);
  });

  test('提醒仓储应支持读取最近一条提醒', () async {
    final repository = InMemoryReminderRepository(
      records: <ReminderRecord>[
        ReminderRecord(
          triggeredAt: DateTime(2026, 6, 9, 10),
          type: ReminderType.postureRisk,
          title: '把手机抬高一点',
          message: '你的颈肩可能已经开始累了。',
          reasonSummary: '连续低头持机超过 15 分钟。',
          actionSuggestion: '换个姿势看一会儿。',
          response: ReminderResponse.pending,
        ),
        ReminderRecord(
          triggeredAt: DateTime(2026, 6, 9, 18),
          type: ReminderType.walkingScreenRisk,
          title: '先看路，再看手机',
          message: '你在移动时看屏有点久了。',
          reasonSummary: '移动状态下持续亮屏超过阈值。',
          actionSuggestion: '停下来处理完再继续走。',
          response: ReminderResponse.dismissed,
        ),
      ],
    );

    final latest = await repository.getLatest();

    expect(latest?.type, ReminderType.walkingScreenRisk);
    expect(latest?.triggeredAt.hour, 18);
  });

  test('提醒仓储保存历史时应去重同一日同类同原因提醒', () async {
    final repository = InMemoryReminderRepository();
    final record = ReminderRecord(
      triggeredAt: DateTime(2026, 6, 10, 9, 0),
      type: ReminderType.sedentaryBreak,
      title: '起身走一走',
      message: '你已经连续坐了很久。',
      reasonSummary: '过去一小时几乎没有活动。',
      actionSuggestion: '现在起身活动两分钟。',
      response: ReminderResponse.pending,
    );

    await repository.saveAll(<ReminderRecord>[record, record]);

    final result = await repository.listRecentDays(
      1,
      referenceDate: DateTime(2026, 6, 10),
    );

    expect(result, hasLength(1));
  });

  test('提醒仓储应优先按稳定 sourceEventId 去重精确风险事件', () async {
    final repository = InMemoryReminderRepository();
    final record = ReminderRecord.fromWalkingScreenRiskEvent(
      eventId: 'walking-risk-1',
      triggeredAt: DateTime(2026, 6, 10, 9, 0),
    );

    await repository.saveAll(<ReminderRecord>[record, record]);

    final result = await repository.listRecentDays(
      1,
      referenceDate: DateTime(2026, 6, 10),
    );

    expect(result, hasLength(1));
    expect(result.single.sourceEventId, 'walking-risk-1');
  });

  test('提醒仓储能查询未投递记录并标记为已投递', () async {
    final repository = InMemoryReminderRepository(
      records: <ReminderRecord>[
        ReminderRecord.fromVerdict(
          verdict: const RuleVerdict(
            dimension: 'activity',
            level: 'warning',
            summary: '起身活动一下',
            detail: '已经久坐一段时间',
            shouldRemind: true,
            reminderType: 'sedentaryBreak',
          ),
          now: DateTime(2026, 6, 16, 10, 0),
        ),
      ],
    );

    final pending = await repository.listUndeliveredSince(
      DateTime(2026, 6, 16, 0, 0),
    );
    await repository.markDelivered(
      pending,
      deliveredAt: DateTime(2026, 6, 16, 10, 1),
    );
    final afterDelivery = await repository.listUndeliveredSince(
      DateTime(2026, 6, 16, 0, 0),
    );

    expect(pending, hasLength(1));
    expect(pending.single.deliveredAt, isNull);
    expect(afterDelivery, isEmpty);
  });

  test('重复标记已投递提醒时不应改写首次投递时间', () async {
    final repository = InMemoryReminderRepository(
      records: <ReminderRecord>[
        ReminderRecord.fromVerdict(
          verdict: const RuleVerdict(
            dimension: 'activity',
            level: 'warning',
            summary: '起身活动一下',
            detail: '已经久坐一段时间',
            shouldRemind: true,
            reminderType: 'sedentaryBreak',
          ),
          now: DateTime(2026, 6, 16, 10, 0),
        ),
      ],
    );

    final pending = await repository.listUndeliveredSince(
      DateTime(2026, 6, 16, 0, 0),
    );
    await repository.markDelivered(
      pending,
      deliveredAt: DateTime(2026, 6, 16, 10, 1),
    );
    final deliveredRecord = (await repository.listRecentDays(
      1,
      referenceDate: DateTime(2026, 6, 16),
    ))
        .single;
    await repository.markDelivered(
      <ReminderRecord>[deliveredRecord],
      deliveredAt: DateTime(2026, 6, 16, 10, 5),
    );
    final stored = (await repository.listRecentDays(
      1,
      referenceDate: DateTime(2026, 6, 16),
    ))
        .single;

    expect(stored.deliveredAt, DateTime(2026, 6, 16, 10, 1));
  });

  test('提醒仓储应支持更新用户处理状态', () async {
    final record = ReminderRecord.fromWalkingScreenRiskEvent(
      eventId: 'response-update-1',
      triggeredAt: DateTime(2026, 6, 16, 10),
    );
    final repository =
        InMemoryReminderRepository(records: <ReminderRecord>[record]);

    await repository.updateResponse(record, ReminderResponse.taken);
    final stored = (await repository.listRecentDays(
      1,
      referenceDate: DateTime(2026, 6, 16),
    ))
        .single;

    expect(stored.response, ReminderResponse.taken);
  });

  test('Isar 提醒仓储能筛选未投递记录并保留首次投递时间', () async {
    await _initializeIsarCoreForTest();
    final dir = await Directory.systemTemp.createTemp('isar-reminder-test');
    final isar = await Isar.open(
      <CollectionSchema>[ReminderRecordEntitySchema],
      directory: dir.path,
      name: 'isar_reminder_repo_test',
    );
    final repository = IsarReminderRepository(isar);

    addTearDown(() async {
      await isar.close();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    final reminder = ReminderRecord.fromVerdict(
      verdict: const RuleVerdict(
        dimension: 'activity',
        level: 'warning',
        summary: '起身活动一下',
        detail: '已经久坐一段时间',
        shouldRemind: true,
        reminderType: 'sedentaryBreak',
      ),
      now: DateTime(2026, 6, 16, 10, 0),
    );

    await repository.saveAll(<ReminderRecord>[reminder]);
    final pending = await repository.listUndeliveredSince(
      DateTime(2026, 6, 16, 0, 0),
    );
    await repository.markDelivered(
      pending,
      deliveredAt: DateTime(2026, 6, 16, 10, 1),
    );
    final afterDelivery = await repository.listUndeliveredSince(
      DateTime(2026, 6, 16, 0, 0),
    );
    final deliveredRecord = (await repository.listRecentDays(
      1,
      referenceDate: DateTime(2026, 6, 16),
    ))
        .single;
    await repository.markDelivered(
      <ReminderRecord>[deliveredRecord],
      deliveredAt: DateTime(2026, 6, 16, 10, 5),
    );
    final stored = (await repository.listRecentDays(
      1,
      referenceDate: DateTime(2026, 6, 16),
    ))
        .single;

    expect(pending, hasLength(1));
    expect(afterDelivery, isEmpty);
    expect(stored.deliveredAt, DateTime(2026, 6, 16, 10, 1));
  });
}

Future<void> _initializeIsarCoreForTest() async {
  final localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData == null || localAppData.isEmpty) {
    throw StateError('缺少 LOCALAPPDATA，无法定位 Isar Windows 动态库。');
  }

  final hostedDirectory = Directory(
    '$localAppData\\Pub\\Cache\\hosted\\pub.dev',
  );
  final libraryDirectory =
      hostedDirectory.listSync().whereType<Directory>().firstWhere(
            (item) => item.path
                .split(Platform.pathSeparator)
                .last
                .startsWith('isar_flutter_libs-'),
          );
  final libraryPath =
      '${libraryDirectory.path}${Platform.pathSeparator}windows${Platform.pathSeparator}isar.dll';
  await Isar.initializeIsarCore(
    libraries: <Abi, String>{
      Abi.windowsX64: libraryPath,
    },
  );
}
