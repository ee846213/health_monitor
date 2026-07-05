import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/core/logging/diagnostics_logger.dart';
import 'package:health_monitor/domain/health/capture_checkpoint.dart';
import 'package:health_monitor/domain/health/capture_health_event.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/capture_health_repository.dart';

const String streamMotion = 'motion';
const String streamSteps = 'steps';
const String streamHealthConnectSteps = 'steps_health_connect';
const String streamNoise = 'noise';
const String streamLight = 'light';
const String streamLocation = 'location';
const String streamDigitalUsageAndroid = 'digital_usage_android';
const String streamDigitalUsageAlternative = 'digital_usage_alternative';
const String streamNativeRisk = 'native_risk';

final captureHealthRepositoryProvider =
    Provider<CaptureHealthRepository>((Ref ref) {
  return IsarCaptureHealthRepository(ref.watch(appIsarProvider.future));
});

final captureHealthServiceProvider = Provider<CaptureHealthService>((Ref ref) {
  return CaptureHealthService(
    repository: ref.watch(captureHealthRepositoryProvider),
    diagnosticsLogger: const DiagnosticsLogger(),
  );
});

class CaptureHealthService {
  CaptureHealthService({
    required CaptureHealthRepository repository,
    DiagnosticsLogger? diagnosticsLogger,
  })  : _repository = repository,
        _diagnosticsLogger = diagnosticsLogger ?? const DiagnosticsLogger();

  final CaptureHealthRepository _repository;
  final DiagnosticsLogger _diagnosticsLogger;

  Future<void> recordStreamStarted(
    String streamKey, {
    String? detail,
    DateTime? occurredAt,
  }) async {
    await _recordEvent(
      streamKey,
      CaptureHealthEventType.streamStarted,
      detail: detail ?? '采集流已启动。',
      occurredAt: occurredAt,
    );
    await _updateCheckpoint(
      streamKey,
      occurredAt: occurredAt ?? DateTime.now(),
      state: CaptureHealthState.recovering,
      eventType: CaptureHealthEventType.streamStarted,
      message: detail ?? '采集流已启动。',
    );
  }

  Future<void> recordFirstSampleReceived(
    String streamKey, {
    String? detail,
    DateTime? occurredAt,
  }) async {
    final when = occurredAt ?? DateTime.now();
    await _recordEvent(
      streamKey,
      CaptureHealthEventType.firstSampleReceived,
      detail: detail ?? '首个样本已到达。',
      occurredAt: when,
    );
    await _updateCheckpoint(
      streamKey,
      occurredAt: when,
      state: CaptureHealthState.healthy,
      eventType: CaptureHealthEventType.firstSampleReceived,
      message: detail ?? '首个样本已到达。',
      sampleCountDelta: 1,
      updateSampleAt: true,
    );
  }

  Future<void> recordGapDetected(
    String streamKey, {
    required Duration gap,
    String? detail,
    DateTime? occurredAt,
  }) async {
    final when = occurredAt ?? DateTime.now();
    final message = detail ?? '采集缺口 ${_formatDuration(gap)}。';
    await _recordEvent(
      streamKey,
      CaptureHealthEventType.gapDetected,
      detail: message,
      gapSeconds: gap.inSeconds,
      occurredAt: when,
    );
    await _updateCheckpoint(
      streamKey,
      occurredAt: when,
      state: CaptureHealthState.degraded,
      eventType: CaptureHealthEventType.gapDetected,
      message: message,
      gapCountDelta: 1,
    );
  }

  Future<void> recordStreamError(
    String streamKey, {
    required String errorMessage,
    String? detail,
    DateTime? occurredAt,
  }) async {
    final when = occurredAt ?? DateTime.now();
    final message = detail ?? '采集错误: $errorMessage';
    await _recordEvent(
      streamKey,
      CaptureHealthEventType.streamError,
      detail: message,
      errorMessage: errorMessage,
      occurredAt: when,
    );
    await _updateCheckpoint(
      streamKey,
      occurredAt: when,
      state: CaptureHealthState.degraded,
      eventType: CaptureHealthEventType.streamError,
      message: message,
      errorMessage: errorMessage,
    );
  }

  Future<void> recordStreamRecovered(
    String streamKey, {
    String? detail,
    DateTime? occurredAt,
  }) async {
    final when = occurredAt ?? DateTime.now();
    final message = detail ?? '采集已恢复。';
    await _recordEvent(
      streamKey,
      CaptureHealthEventType.streamRecovered,
      detail: message,
      occurredAt: when,
    );
    await _updateCheckpoint(
      streamKey,
      occurredAt: when,
      state: CaptureHealthState.healthy,
      eventType: CaptureHealthEventType.streamRecovered,
      message: message,
      recoveryCountDelta: 1,
      updateRecoveredAt: true,
    );
  }

  Future<void> recordStateRebuilt(
    String streamKey, {
    String? detail,
    DateTime? occurredAt,
  }) async {
    final when = occurredAt ?? DateTime.now();
    final message = detail ?? '已重建当前状态。';
    await _recordEvent(
      streamKey,
      CaptureHealthEventType.stateRebuilt,
      detail: message,
      occurredAt: when,
    );
    await _updateCheckpoint(
      streamKey,
      occurredAt: when,
      state: CaptureHealthState.recovering,
      eventType: CaptureHealthEventType.stateRebuilt,
      message: message,
      updateStateRebuiltAt: true,
    );
  }

  Future<void> recordNativeSummaryDrained(
    String streamKey, {
    String? detail,
    DateTime? occurredAt,
  }) async {
    final when = occurredAt ?? DateTime.now();
    final message = detail ?? '已读取原生摘要队列。';
    await _recordEvent(
      streamKey,
      CaptureHealthEventType.nativeSummaryDrained,
      detail: message,
      occurredAt: when,
    );
    await _updateCheckpoint(
      streamKey,
      occurredAt: when,
      state: CaptureHealthState.healthy,
      eventType: CaptureHealthEventType.nativeSummaryDrained,
      message: message,
      updateNativeDrainAt: true,
    );
  }

  Future<List<CaptureHealthEvent>> recentEvents({
    int limit = 20,
    String? streamKey,
  }) {
    return _repository.listRecentEvents(limit: limit, streamKey: streamKey);
  }

  Future<List<CaptureCheckpoint>> checkpoints() {
    return _repository.listCheckpoints();
  }

  Future<CaptureCheckpoint?> checkpointFor(String streamKey) {
    return _repository.getCheckpoint(streamKey);
  }

  Future<void> _recordEvent(
    String streamKey,
    CaptureHealthEventType eventType, {
    String? detail,
    int? sampleCount,
    int? gapSeconds,
    String? errorMessage,
    DateTime? occurredAt,
  }) async {
    final when = occurredAt ?? DateTime.now();
    final event = CaptureHealthEvent(
      eventId: _buildEventId(streamKey, eventType, when),
      streamKey: streamKey,
      eventType: eventType,
      occurredAt: when,
      detail: detail,
      sampleCount: sampleCount,
      gapSeconds: gapSeconds,
      errorMessage: errorMessage,
    );
    await _repository.saveEvent(event);
    _diagnosticsLogger.logCaptureHealthEvent(event);
  }

  Future<void> _updateCheckpoint(
    String streamKey, {
    required DateTime occurredAt,
    required CaptureHealthState state,
    required CaptureHealthEventType eventType,
    required String message,
    String? errorMessage,
    int gapCountDelta = 0,
    int recoveryCountDelta = 0,
    int sampleCountDelta = 0,
    bool updateSampleAt = false,
    bool updateRecoveredAt = false,
    bool updateStateRebuiltAt = false,
    bool updateNativeDrainAt = false,
  }) async {
    final existing = await _repository.getCheckpoint(streamKey);
    final checkpoint = existing ??
        CaptureCheckpoint(
          streamKey: streamKey,
          state: state,
          sampleCount: 0,
          gapCount: 0,
          recoveryCount: 0,
        );

    final next = CaptureCheckpoint(
      streamKey: streamKey,
      state: state,
      sampleCount: checkpoint.sampleCount + sampleCountDelta,
      gapCount: checkpoint.gapCount + gapCountDelta,
      recoveryCount: checkpoint.recoveryCount + recoveryCountDelta,
      lastEventTypeKey: eventType.name,
      lastEventAt: occurredAt,
      lastSampleAt: updateSampleAt ? occurredAt : checkpoint.lastSampleAt,
      lastErrorAt: errorMessage != null ? occurredAt : checkpoint.lastErrorAt,
      lastRecoveredAt:
          updateRecoveredAt ? occurredAt : checkpoint.lastRecoveredAt,
      lastStateRebuiltAt:
          updateStateRebuiltAt ? occurredAt : checkpoint.lastStateRebuiltAt,
      lastNativeSummaryDrainedAt: updateNativeDrainAt
          ? occurredAt
          : checkpoint.lastNativeSummaryDrainedAt,
      lastMessage: message,
      lastErrorMessage: errorMessage ?? checkpoint.lastErrorMessage,
    );

    await _repository.upsertCheckpoint(next);
    _logCheckpoint(next);
  }

  void _logCheckpoint(CaptureCheckpoint checkpoint) {
    _diagnosticsLogger.logCaptureCheckpoint(checkpoint);
  }
}

String _buildEventId(
  String streamKey,
  CaptureHealthEventType eventType,
  DateTime occurredAt,
) {
  return '${occurredAt.microsecondsSinceEpoch}-$streamKey-${eventType.name}';
}

String _formatDuration(Duration duration) {
  if (duration.inHours >= 1) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (minutes == 0) {
      return '$hours 小时';
    }
    return '$hours 小时 $minutes 分钟';
  }
  if (duration.inMinutes >= 1) {
    return '${duration.inMinutes} 分钟';
  }
  return '${duration.inSeconds} 秒';
}
