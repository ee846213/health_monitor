import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';

void main() {
  test('提醒记录应暴露轻提醒所需的解释与交互语义', () {
    final record = ReminderRecord(
      triggeredAt: DateTime(2026, 6, 9, 15),
      type: ReminderType.sedentaryBreak,
      title: '起身走一走',
      message: '你下午已经连续坐了很久，起来活动两分钟会更舒服。',
      reasonSummary: '14:00 到 15:00 基本没有起身活动。',
      actionSuggestion: '先去接杯水，再顺手走两分钟。',
      response: ReminderResponse.taken,
    );

    expect(record.type, ReminderType.sedentaryBreak);
    expect(record.response, ReminderResponse.taken);
    expect(record.hasActioned, isTrue);
    expect(record.isIgnored, isFalse);
  });

  test('忽略提醒的记录应保留后续频率调节所需状态', () {
    final record = ReminderRecord(
      triggeredAt: DateTime(2026, 6, 9, 22, 30),
      type: ReminderType.nightUsage,
      title: '今晚可以早点放下手机',
      message: '你已经连续看了一阵子屏幕，现在收一收更容易休息。',
      reasonSummary: '22 点后亮屏时长已经偏高。',
      actionSuggestion: '把最后十分钟留给放松而不是继续刷内容。',
      response: ReminderResponse.ignored,
    );

    expect(record.isIgnored, isTrue);
    expect(record.hasActioned, isFalse);
  });
}
