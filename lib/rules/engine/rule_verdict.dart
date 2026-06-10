import 'package:health_monitor/rules/input/rule_input.dart';

/// 单个维度的规则评估结果。
///
/// 每条规则输出一个 [RuleVerdict]，包含结论摘要以及是否需要提醒。
/// 多个维度的 [RuleVerdict] 由上层汇总为首页核心结论和简报。
class RuleVerdict {
  const RuleVerdict({
    required this.dimension,
    required this.level,
    required this.summary,
    required this.detail,
    this.shouldRemind = false,
    this.reminderTitle,
    this.reminderMessage,
    this.reminderType,
  });

  final String dimension;
  final String level;
  final String summary;
  final String detail;
  final bool shouldRemind;
  final String? reminderTitle;
  final String? reminderMessage;
  final String? reminderType;
}

/// 规则引擎的通用接口。
abstract class HealthRule {
  String get name;
  String get dimension;
  List<RuleVerdict> evaluate(RuleInput input);
}
