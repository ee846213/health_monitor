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
  });

  final DateTime triggeredAt;
  final ReminderType type;
  final String title;
  final String message;
  final String reasonSummary;
  final String actionSuggestion;
  final ReminderResponse response;

  bool get hasActioned => response == ReminderResponse.taken;

  bool get isIgnored =>
      response == ReminderResponse.ignored ||
      response == ReminderResponse.dismissed;
}
