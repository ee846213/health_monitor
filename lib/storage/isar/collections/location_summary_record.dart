import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:isar/isar.dart';

part 'location_summary_record.g.dart';

@collection
class LocationSummaryRecord {
  Id id = Isar.autoIncrement;

  late String dateKey;
  late double distanceMeters;
  late int outdoorDurationSeconds;
  late int visitCount;
  late int commuteCount;

  LocationSummaryRecord();

  factory LocationSummaryRecord.fromDomain(LocationSummary summary) {
    return LocationSummaryRecord()
      ..dateKey = _dateKey(summary.date)
      ..distanceMeters = summary.distanceMeters
      ..outdoorDurationSeconds = summary.outdoorDuration.inSeconds
      ..visitCount = summary.visitCount
      ..commuteCount = summary.commuteCount;
  }

  LocationSummary toDomain() {
    return LocationSummary(
      date: _dateFromKey(dateKey),
      distanceMeters: distanceMeters,
      outdoorDuration: Duration(seconds: outdoorDurationSeconds),
      visitCount: visitCount,
      commuteCount: commuteCount,
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
      return DateTime(1970);
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return DateTime(1970);
    }
    return DateTime(
      year,
      month,
      day,
    );
  }
}
