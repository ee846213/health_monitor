import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

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
}
