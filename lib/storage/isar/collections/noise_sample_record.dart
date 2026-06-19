import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:isar/isar.dart';

part 'noise_sample_record.g.dart';

@collection
class NoiseSampleRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime capturedAt;
  late int durationSeconds;
  late double decibel;
  late String levelKey;

  NoiseSampleRecord();

  factory NoiseSampleRecord.fromDomain(NoiseSample sample) {
    return NoiseSampleRecord()
      ..capturedAt = sample.capturedAt
      ..durationSeconds = sample.duration.inSeconds
      ..decibel = sample.decibel
      ..levelKey = sample.level.name;
  }

  NoiseSample toDomain() {
    return NoiseSample(
      capturedAt: capturedAt,
      duration: Duration(seconds: durationSeconds),
      decibel: decibel,
      level: _mapNoiseLevel(levelKey),
    );
  }

  NoiseLevel _mapNoiseLevel(String value) {
    return NoiseLevel.values.firstWhere(
      (NoiseLevel item) => item.name == value,
      orElse: () => NoiseLevel.quiet,
    );
  }
}
