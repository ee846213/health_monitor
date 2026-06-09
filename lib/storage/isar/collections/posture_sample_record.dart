import 'package:health_monitor/domain/motion/posture_sample.dart';
import 'package:isar/isar.dart';

part 'posture_sample_record.g.dart';

@collection
class PostureSampleRecord {
  Id id = Isar.autoIncrement;

  late DateTime capturedAt;
  late int durationSeconds;
  late String postureKey;
  late String riskLevelKey;
  late int continuousHoldSeconds;

  PostureSampleRecord();

  factory PostureSampleRecord.fromDomain(PostureSample sample) {
    return PostureSampleRecord()
      ..capturedAt = sample.capturedAt
      ..durationSeconds = sample.duration.inSeconds
      ..postureKey = sample.posture.name
      ..riskLevelKey = sample.riskLevel.name
      ..continuousHoldSeconds = sample.continuousHold.inSeconds;
  }
}
