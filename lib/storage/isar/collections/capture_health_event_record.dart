import 'package:health_monitor/domain/health/capture_health_event.dart';
import 'package:isar/isar.dart';

part 'capture_health_event_record.g.dart';

@collection
class CaptureHealthEventRecord {
  Id id = Isar.autoIncrement;

  late String eventId;
  late String streamKey;
  late String eventTypeKey;
  late DateTime occurredAt;
  String? detail;
  int? sampleCount;
  int? gapSeconds;
  String? errorMessage;

  CaptureHealthEventRecord();

  factory CaptureHealthEventRecord.fromDomain(CaptureHealthEvent event) {
    return CaptureHealthEventRecord()
      ..eventId = event.eventId
      ..streamKey = event.streamKey
      ..eventTypeKey = event.eventType.name
      ..occurredAt = event.occurredAt
      ..detail = event.detail
      ..sampleCount = event.sampleCount
      ..gapSeconds = event.gapSeconds
      ..errorMessage = event.errorMessage;
  }

  CaptureHealthEvent toDomain() {
    return CaptureHealthEvent(
      eventId: eventId,
      streamKey: streamKey,
      eventType: _mapEventType(eventTypeKey),
      occurredAt: occurredAt,
      detail: detail,
      sampleCount: sampleCount,
      gapSeconds: gapSeconds,
      errorMessage: errorMessage,
    );
  }

  static CaptureHealthEventType _mapEventType(String value) {
    return CaptureHealthEventType.values.firstWhere(
      (CaptureHealthEventType item) => item.name == value,
      orElse: () => CaptureHealthEventType.stateRebuilt,
    );
  }
}
