import 'package:health_monitor/rules/engine/rule_verdict.dart';

enum ReminderType {
  sedentaryBreak,
  postureRisk,
  walkingScreenRisk,
  nightUsage,
  noisyEnvironment,
}

enum ReminderResponse {
  pending,
  dismissed,
  ignored,
  taken,
}

class ReminderRecord {
  const ReminderRecord({
    required this.triggeredAt,
    required this.type,
    required this.title,
    required this.message,
    required this.reasonSummary,
    required this.actionSuggestion,
    required this.response,
    this.deliveredAt,
    this.reminderTypeKey,
    this.sourceDimension,
    this.sourceEventId,
  });

  final DateTime triggeredAt;
  final ReminderType type;
  final String title;
  final String message;
  final String reasonSummary;
  final String actionSuggestion;
  final ReminderResponse response;
  final DateTime? deliveredAt;
  final String? reminderTypeKey;
  final String? sourceDimension;
  final String? sourceEventId;

  bool get hasActioned => response == ReminderResponse.taken;
  bool get isIgnored =>
      response == ReminderResponse.ignored ||
      response == ReminderResponse.dismissed;

  /// 从规则引擎的 [RuleVerdict] 创建提醒记录。
  ///
  /// [response] 默认为 [ReminderResponse.pending]。
  factory ReminderRecord.fromVerdict({
    required RuleVerdict verdict,
    required DateTime now,
    ReminderResponse response = ReminderResponse.pending,
  }) {
    return ReminderRecord(
      triggeredAt: now,
      type: _mapReminderType(verdict.reminderType),
      title: verdict.reminderTitle ?? verdict.summary,
      message: verdict.reminderMessage ?? verdict.detail,
      reasonSummary: verdict.summary,
      actionSuggestion: verdict.detail,
      response: response,
      deliveredAt: null,
      reminderTypeKey: verdict.reminderType,
      sourceDimension: verdict.dimension,
    );
  }

  factory ReminderRecord.fromWalkingScreenRiskEvent({
    required String eventId,
    required DateTime triggeredAt,
    ReminderResponse response = ReminderResponse.pending,
  }) {
    return ReminderRecord(
      triggeredAt: triggeredAt,
      type: ReminderType.walkingScreenRisk,
      title: '先看路，再看手机',
      message: '检测到你在移动时持续亮屏超过 8 秒。',
      reasonSummary: '移动状态下连续亮屏超过 8 秒。',
      actionSuggestion: '走路时先收起屏幕，等停下后再查看手机。',
      response: response,
      deliveredAt: null,
      reminderTypeKey: 'walkingScreenRisk',
      sourceDimension: 'android_risk_event',
      sourceEventId: eventId,
    );
  }

  ReminderRecord copyWith({
    DateTime? deliveredAt,
  }) {
    return ReminderRecord(
      triggeredAt: triggeredAt,
      type: type,
      title: title,
      message: message,
      reasonSummary: reasonSummary,
      actionSuggestion: actionSuggestion,
      response: response,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      reminderTypeKey: reminderTypeKey,
      sourceDimension: sourceDimension,
      sourceEventId: sourceEventId,
    );
  }

  static ReminderType _mapReminderType(String? key) {
    switch (key) {
      case 'sedentaryBreak':
        return ReminderType.sedentaryBreak;
      case 'postureRisk':
        return ReminderType.postureRisk;
      case 'walkingScreenRisk':
        return ReminderType.walkingScreenRisk;
      case 'nightUsage':
        return ReminderType.nightUsage;
      case 'noisyEnvironment':
        return ReminderType.noisyEnvironment;
      default:
        return ReminderType.sedentaryBreak;
    }
  }
}
