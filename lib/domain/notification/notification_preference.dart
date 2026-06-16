class NotificationPreference {
  const NotificationPreference({
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  bool isWithinWindow(DateTime moment) {
    if (!enabled) {
      return false;
    }

    final currentMinutes = moment.hour * 60 + moment.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (startMinutes == endMinutes) {
      return false;
    }

    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }

    // 跨午夜时，分成“当天晚间”和“次日凌晨”两段判断。
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }

  NotificationPreference copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return NotificationPreference(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  String get startLabel => _formatTime(startHour, startMinute);

  String get endLabel => _formatTime(endHour, endMinute);
}

String _formatTime(int hour, int minute) {
  final paddedHour = hour.toString().padLeft(2, '0');
  final paddedMinute = minute.toString().padLeft(2, '0');
  return '$paddedHour:$paddedMinute';
}
