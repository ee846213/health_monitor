import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:isar/isar.dart';

part 'daily_metrics_record.g.dart';

@collection
class DailyMetricsRecord {
  Id id = Isar.autoIncrement;

  late String dateKey;
  late int stepCount;
  late int sedentarySeconds;
  late int screenOnSeconds;
  late int outdoorSeconds;
  late int postureRiskCount;
  late int highNoiseExposureSeconds;

  DailyMetricsRecord();

  factory DailyMetricsRecord.fromDomain(DailyMetrics metrics) {
    return DailyMetricsRecord()
      ..dateKey = _dateKey(metrics.date)
      ..stepCount = metrics.stepCount
      ..sedentarySeconds = metrics.sedentaryDuration.inSeconds
      ..screenOnSeconds = metrics.screenOnDuration.inSeconds
      ..outdoorSeconds = metrics.outdoorDuration.inSeconds
      ..postureRiskCount = metrics.postureRiskCount
      ..highNoiseExposureSeconds = metrics.highNoiseExposureDuration.inSeconds;
  }

  // 日级聚合统一使用稳定 dateKey，避免直接依赖本地时区格式化结果，
  // 这样后续 repository 做最近 7 天查询时更容易保持一致。
  static String _dateKey(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
