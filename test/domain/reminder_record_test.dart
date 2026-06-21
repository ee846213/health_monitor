import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';

void main() {
  group('ReminderRecord', () {
    test('fromVerdict 应正确映射 sedentaryBreak 类型', () {
      final now = DateTime(2026, 6, 10, 14, 30);
      final record = ReminderRecord.fromVerdict(
        verdict: const RuleVerdict(
          dimension: 'activity',
          level: 'concern',
          summary: '活动量偏低',
          detail: '久坐占比过高。',
          shouldRemind: true,
          reminderTitle: '该起来活动一下了',
          reminderMessage: '起身走动 5 分钟。',
          reminderType: 'sedentaryBreak',
        ),
        now: now,
      );

      expect(record.type, ReminderType.sedentaryBreak);
      expect(record.title, '该起来活动一下了');
      expect(record.message, '起身走动 5 分钟。');
      expect(record.response, ReminderResponse.pending);
      expect(record.reminderTypeKey, 'sedentaryBreak');
      expect(record.sourceDimension, 'activity');
      expect(record.triggeredAt, now);
    });

    test('fromVerdict 应正确映射 postureRisk 类型', () {
      final record = ReminderRecord.fromVerdict(
        verdict: const RuleVerdict(
          dimension: 'posture',
          level: 'concern',
          summary: '久坐风险',
          detail: '长时间静止伴随不良坐姿。',
          shouldRemind: true,
          reminderTitle: '换个姿势',
          reminderMessage: '起身活动一下。',
          reminderType: 'postureRisk',
        ),
        now: DateTime(2026, 6, 10),
      );
      expect(record.type, ReminderType.postureRisk);
    });

    test('fromVerdict 应正确映射 walkingScreenRisk 类型', () {
      final record = ReminderRecord.fromVerdict(
        verdict: const RuleVerdict(
          dimension: 'posture',
          level: 'warning',
          summary: '走路看手机风险',
          detail: '摔倒风险增大。',
          shouldRemind: true,
          reminderTitle: '走路别看手机',
          reminderMessage: '安全第一。',
          reminderType: 'walkingScreenRisk',
        ),
        now: DateTime(2026, 6, 10),
      );
      expect(record.type, ReminderType.walkingScreenRisk);
    });

    test('fromWalkingScreenRiskEvent 应生成精确事件语义提醒', () {
      final record = ReminderRecord.fromWalkingScreenRiskEvent(
        eventId: 'risk-1',
        triggeredAt: DateTime(2026, 6, 10, 8, 0),
      );

      expect(record.type, ReminderType.walkingScreenRisk);
      expect(record.reasonSummary, '移动状态下连续亮屏超过 8 秒。');
      expect(record.actionSuggestion, '走路时先收起屏幕，等停下后再查看手机。');
      expect(record.sourceEventId, 'risk-1');
    });

    test('原生风险通知已送达时不应在 Flutter 恢复后重复投递', () {
      final triggeredAt = DateTime(2026, 6, 10, 8);
      final record = ReminderRecord.fromWalkingScreenRiskEvent(
        eventId: 'risk-delivered',
        triggeredAt: triggeredAt,
        notificationDelivered: true,
      );

      expect(record.deliveredAt, triggeredAt);
    });

    test('fromVerdict 应正确映射 noisyEnvironment 类型', () {
      final record = ReminderRecord.fromVerdict(
        verdict: const RuleVerdict(
          dimension: 'environment',
          level: 'concern',
          summary: '高噪音环境',
          detail: '听力损伤风险。',
          shouldRemind: true,
          reminderTitle: '环境噪音较大',
          reminderMessage: '转移至安静环境。',
          reminderType: 'noisyEnvironment',
        ),
        now: DateTime(2026, 6, 10),
      );
      expect(record.type, ReminderType.noisyEnvironment);
    });

    test('hasActioned 和 isIgnored 应正确反映状态', () {
      final record = ReminderRecord.fromVerdict(
        verdict: const RuleVerdict(
          dimension: 'activity',
          level: 'normal',
          summary: '',
          detail: '',
          shouldRemind: false,
        ),
        now: DateTime(2026, 6, 10),
        response: ReminderResponse.dismissed,
      );
      expect(record.hasActioned, isFalse);
      expect(record.isIgnored, isTrue);
    });
  });
}
