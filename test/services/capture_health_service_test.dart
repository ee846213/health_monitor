import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/core/logging/diagnostics_logger.dart';
import 'package:health_monitor/domain/health/capture_checkpoint.dart';
import 'package:health_monitor/domain/health/capture_health_event.dart';
import 'package:health_monitor/services/capture_health_service.dart';
import 'package:health_monitor/storage/repositories/capture_health_repository.dart';

void main() {
  test('采集健康服务应记录事件并重建检查点', () async {
    final repository = InMemoryCaptureHealthRepository();
    final service = CaptureHealthService(
      repository: repository,
      diagnosticsLogger: const DiagnosticsLogger(),
    );

    await service.recordStreamStarted(streamLight,
        occurredAt: DateTime(2026, 6, 16, 9));
    await service.recordFirstSampleReceived(
      streamLight,
      occurredAt: DateTime(2026, 6, 16, 9, 1),
    );
    await service.recordGapDetected(
      streamLight,
      gap: const Duration(minutes: 20),
      occurredAt: DateTime(2026, 6, 16, 9, 21),
    );
    await service.recordStreamRecovered(
      streamLight,
      occurredAt: DateTime(2026, 6, 16, 9, 22),
    );
    await service.recordNativeSummaryDrained(
      streamDigitalUsageAndroid,
      occurredAt: DateTime(2026, 6, 16, 9, 30),
    );

    final events = await service.recentEvents(limit: 10);
    final checkpoints = await service.checkpoints();

    expect(events, hasLength(5));
    expect(
      events.first.eventType,
      CaptureHealthEventType.nativeSummaryDrained,
    );

    final lightCheckpoint = checkpoints.singleWhere(
      (CaptureCheckpoint checkpoint) => checkpoint.streamKey == streamLight,
    );
    expect(lightCheckpoint.state, CaptureHealthState.healthy);
    expect(lightCheckpoint.gapCount, 1);
    expect(lightCheckpoint.recoveryCount, 1);
    expect(lightCheckpoint.lastEventTypeKey,
        CaptureHealthEventType.streamRecovered.name);

    final usageCheckpoint = checkpoints.singleWhere(
      (CaptureCheckpoint checkpoint) =>
          checkpoint.streamKey == streamDigitalUsageAndroid,
    );
    expect(usageCheckpoint.lastNativeSummaryDrainedAt, isNotNull);
  });
}
