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

  DigitalUsageSummary toDomain() {
    return DigitalUsageSummary(
      date: _dateFromKey(dateKey),
      screenOnDuration: Duration(seconds: screenOnSeconds),
      unlockCount: unlockCount,
      nighttimeUsageDuration: Duration(seconds: nighttimeUsageSeconds),
      focusSessionBreakCount: focusSessionBreakCount,
      topCategory: _mapUsageCategory(topCategoryKey),
    );
  }

  static String _dateKey(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime _dateFromKey(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return DateTime.now();
    }
    return DateTime(
      int.tryParse(parts[0]) ?? DateTime.now().year,
      int.tryParse(parts[1]) ?? DateTime.now().month,
      int.tryParse(parts[2]) ?? DateTime.now().day,
    );
  }

  static UsageCategory _mapUsageCategory(String value) {
    return UsageCategory.values.firstWhere(
      (UsageCategory item) => item.name == value,
      orElse: () => UsageCategory.unknown,
    );
  }
}
