import 'package:health_monitor/domain/health/capture_checkpoint.dart';
import 'package:isar/isar.dart';

part 'capture_checkpoint_record.g.dart';

@collection
class CaptureCheckpointRecord {
  Id id = Isar.autoIncrement;

  late String streamKey;
  late String stateKey;
  late int sampleCount;
  late int gapCount;
  late int recoveryCount;
  String? lastEventTypeKey;
  DateTime? lastEventAt;
  DateTime? lastSampleAt;
  DateTime? lastErrorAt;
  DateTime? lastRecoveredAt;
  DateTime? lastStateRebuiltAt;
  DateTime? lastNativeSummaryDrainedAt;
  String? lastMessage;
  String? lastErrorMessage;

  CaptureCheckpointRecord();

  factory CaptureCheckpointRecord.fromDomain(CaptureCheckpoint checkpoint) {
    return CaptureCheckpointRecord()
      ..streamKey = checkpoint.streamKey
      ..stateKey = checkpoint.state.name
      ..sampleCount = checkpoint.sampleCount
      ..gapCount = checkpoint.gapCount
      ..recoveryCount = checkpoint.recoveryCount
      ..lastEventTypeKey = checkpoint.lastEventTypeKey
      ..lastEventAt = checkpoint.lastEventAt
      ..lastSampleAt = checkpoint.lastSampleAt
      ..lastErrorAt = checkpoint.lastErrorAt
      ..lastRecoveredAt = checkpoint.lastRecoveredAt
      ..lastStateRebuiltAt = checkpoint.lastStateRebuiltAt
      ..lastNativeSummaryDrainedAt = checkpoint.lastNativeSummaryDrainedAt
      ..lastMessage = checkpoint.lastMessage
      ..lastErrorMessage = checkpoint.lastErrorMessage;
  }

  CaptureCheckpoint toDomain() {
    return CaptureCheckpoint(
      streamKey: streamKey,
      state: _mapState(stateKey),
      sampleCount: sampleCount,
      gapCount: gapCount,
      recoveryCount: recoveryCount,
      lastEventTypeKey: lastEventTypeKey,
      lastEventAt: lastEventAt,
      lastSampleAt: lastSampleAt,
      lastErrorAt: lastErrorAt,
      lastRecoveredAt: lastRecoveredAt,
      lastStateRebuiltAt: lastStateRebuiltAt,
      lastNativeSummaryDrainedAt: lastNativeSummaryDrainedAt,
      lastMessage: lastMessage,
      lastErrorMessage: lastErrorMessage,
    );
  }

  static CaptureHealthState _mapState(String value) {
    return CaptureHealthState.values.firstWhere(
      (CaptureHealthState item) => item.name == value,
      orElse: () => CaptureHealthState.recovering,
    );
  }
}
