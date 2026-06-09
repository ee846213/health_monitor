import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:isar/isar.dart';

part 'activity_sample_record.g.dart';

@collection
class ActivitySampleRecord {
  Id id = Isar.autoIncrement;

  late DateTime capturedAt;
  late int durationSeconds;
  late String typeKey;
  late double confidence;
  late int stepCount;
  late String sourceKey;

  ActivitySampleRecord();

  factory ActivitySampleRecord.fromDomain(ActivitySample sample) {
    return ActivitySampleRecord()
      ..capturedAt = sample.capturedAt
      ..durationSeconds = sample.duration.inSeconds
      ..typeKey = sample.type.name
      ..confidence = sample.confidence
      ..stepCount = sample.stepCount
      ..sourceKey = sample.source.name;
  }
}
