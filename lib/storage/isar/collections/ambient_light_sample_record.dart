import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:isar/isar.dart';

part 'ambient_light_sample_record.g.dart';

@collection
class AmbientLightSampleRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime capturedAt;
  late int durationSeconds;
  late double lux;
  late String levelKey;

  AmbientLightSampleRecord();

  factory AmbientLightSampleRecord.fromDomain(AmbientLightSample sample) {
    return AmbientLightSampleRecord()
      ..capturedAt = sample.capturedAt
      ..durationSeconds = sample.duration.inSeconds
      ..lux = sample.lux
      ..levelKey = sample.level.name;
  }

  AmbientLightSample toDomain() {
    return AmbientLightSample(
      capturedAt: capturedAt,
      duration: Duration(seconds: durationSeconds),
      lux: lux,
      level: _mapLevel(levelKey),
    );
  }

  static AmbientLightLevel _mapLevel(String value) {
    return AmbientLightLevel.values.firstWhere(
      (AmbientLightLevel item) => item.name == value,
      orElse: () => AmbientLightLevel.comfortable,
    );
  }
}
