import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:isar/isar.dart';

part 'usage_summary_record.g.dart';

@collection
class UsageSummaryRecord {
  Id id = Isar.autoIncrement;

  late String dateKey;
  late int screenOnSeconds;
  late int unlockCount;
  late int nighttimeUsageSeconds;
  late int focusSessionBreakCount;
  late String topCategoryKey;

  UsageSummaryRecord();

  factory UsageSummaryRecord.fromDomain(DigitalUsageSummary summary) {
    return UsageSummaryRecord()
      ..dateKey = _dateKey(summary.date)
      ..screenOnSeconds = summary.screenOnDuration.inSeconds
      ..unlockCount = summary.unlockCount
      ..nighttimeUsageSeconds = summary.nighttimeUsageDuration.inSeconds
      ..focusSessionBreakCount = summary.focusSessionBreakCount
      ..topCategoryKey = summary.topCategory.name;
  }

  static String _dateKey(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
