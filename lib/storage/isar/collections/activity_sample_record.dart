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

  ActivitySample toDomain() {
    return ActivitySample(
      capturedAt: capturedAt,
      duration: Duration(seconds: durationSeconds),
      type: _mapActivityType(typeKey),
      confidence: confidence,
      stepCount: stepCount,
      source: _mapMotionSampleSource(sourceKey),
    );
  }

  ActivityType _mapActivityType(String value) {
    return ActivityType.values.firstWhere(
      (ActivityType item) => item.name == value,
      orElse: () => ActivityType.unknown,
    );
  }

  MotionSampleSource _mapMotionSampleSource(String value) {
    return MotionSampleSource.values.firstWhere(
      (MotionSampleSource item) => item.name == value,
      orElse: () => MotionSampleSource.sensorFusion,
    );
  }
}
