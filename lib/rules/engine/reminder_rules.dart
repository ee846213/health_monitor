import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';

/// 提醒规则：汇总各维度评估结果，输出需要触发的提醒列表。
///
/// 不直接分析原始数据，而是从其他规则的 [RuleVerdict] 中聚合
/// 所有 [shouldRemind] 为 true 的结论。
///
/// 由上层消费方（如提醒记录服务）根据返回的提醒列表写入 [ReminderRecord]。
class ReminderRule implements HealthRule {
  /// 参与提醒汇总的规则列表。
  final List<HealthRule> sourceRules;

  const ReminderRule({
    required this.sourceRules,
  });

  @override
  String get name => '提醒规则';

  @override
  String get dimension => 'reminder';

  @override
  List<RuleVerdict> evaluate(RuleInput input) {
    final reminders = <RuleVerdict>[];

    for (final rule in sourceRules) {
      for (final verdict in rule.evaluate(input)) {
        if (verdict.shouldRemind) {
          reminders.add(verdict);
        }
      }
    }

    // 避免重复提醒同一类型。
    final seen = <String>{};
    final deduped = <RuleVerdict>[];
    for (final r in reminders) {
      final key = r.reminderType ?? '';
      if (key.isNotEmpty && !seen.contains(key)) {
        seen.add(key);
        deduped.add(r);
      }
    }

    return deduped;
  }
}
