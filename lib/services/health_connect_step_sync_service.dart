import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/hourly_step_bucket.dart';
import 'package:health_monitor/services/health_connect_bridge.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';

/// 将 Health Connect 小时步数桶同步为活动样本，供节奏轴定位活动集中时段。
class HealthConnectStepSyncService {
  const HealthConnectStepSyncService({
    required HealthConnectBridge bridge,
    required ActivityRepository activityRepository,
    required MetricsRepository metricsRepository,
  })  : _bridge = bridge,
        _activityRepository = activityRepository,
        _metricsRepository = metricsRepository;

  final HealthConnectBridge _bridge;
  final ActivityRepository _activityRepository;
  final MetricsRepository _metricsRepository;

  Future<HealthConnectStepSyncResult> syncForDay({
    required DateTime referenceTime,
    bool requestPermissionIfNeeded = false,
  }) async {
    var status = await _bridge.getStatus();
    if (!status.isAvailable) {
      return HealthConnectStepSyncResult.unavailable(status: status);
    }
    if (!status.hasStepsPermission) {
      if (!requestPermissionIfNeeded) {
        return HealthConnectStepSyncResult.permissionDenied(status: status);
      }
      final granted = await _bridge.requestPermissions();
      if (!granted) {
        return HealthConnectStepSyncResult.permissionDenied(status: status);
      }
      status = await _bridge.getStatus();
      if (!status.hasStepsPermission) {
        return HealthConnectStepSyncResult.permissionDenied(status: status);
      }
    }

    final dayStart = DateTime(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));
    final queryEnd = referenceTime.isBefore(dayEnd) ? referenceTime : dayEnd;
    final buckets = await _bridge.readHourlySteps(
      startAt: dayStart,
      endAt: queryEnd,
    );
    final isFullDayQuery = _isFullDayQuery(dayEnd, queryEnd);
    if (buckets.isEmpty) {
      if (isFullDayQuery) {
        await _upsertDailyMetrics(
          dayStart,
          buckets,
          allowStepCountDecrease: true,
        );
      }
      return HealthConnectStepSyncResult.empty(status: status);
    }

    final samples = buckets.map(_toActivitySample).toList(growable: false);
    await _activityRepository.replaceHealthConnectHourlyForDay(
      dayStart,
      samples,
    );
    await _upsertDailyMetrics(
      dayStart,
      buckets,
      allowStepCountDecrease: isFullDayQuery,
    );
    return HealthConnectStepSyncResult.synced(
      status: status,
      bucketCount: buckets.length,
      totalSteps: buckets.fold<int>(
          0, (int sum, HourlyStepBucket b) => sum + b.stepCount),
    );
  }

  ActivitySample _toActivitySample(HourlyStepBucket bucket) {
    return ActivitySample(
      capturedAt: bucket.startAt,
      duration: bucket.endAt.difference(bucket.startAt),
      type: ActivityType.walking,
      confidence: 0.85,
      stepCount: bucket.stepCount,
      source: MotionSampleSource.healthConnectHourly,
    );
  }

  Future<void> _upsertDailyMetrics(
    DateTime dayStart,
    List<HourlyStepBucket> buckets, {
    required bool allowStepCountDecrease,
  }) async {
    final bucketTotal = buckets.fold<int>(
        0, (int sum, HourlyStepBucket b) => sum + b.stepCount);
    final existing = await _metricsRepository.getByDate(dayStart) ??
        DailyMetrics(
          date: dayStart,
          stepCount: 0,
          sedentaryDuration: Duration.zero,
          screenOnDuration: Duration.zero,
          outdoorDuration: Duration.zero,
          postureRiskCount: 0,
          highNoiseExposureDuration: Duration.zero,
        );
    final nextStepCount = allowStepCountDecrease
        ? bucketTotal
        : existing.stepCount > bucketTotal
            ? existing.stepCount
            : bucketTotal;
    if (nextStepCount == existing.stepCount) {
      return;
    }
    await _metricsRepository.upsertMetrics(
      DailyMetrics(
        date: dayStart,
        stepCount: nextStepCount,
        sedentaryDuration: existing.sedentaryDuration,
        screenOnDuration: existing.screenOnDuration,
        outdoorDuration: existing.outdoorDuration,
        postureRiskCount: existing.postureRiskCount,
        highNoiseExposureDuration: existing.highNoiseExposureDuration,
      ),
    );
  }

  bool _isFullDayQuery(DateTime dayEnd, DateTime queryEnd) {
    return !queryEnd.add(const Duration(milliseconds: 1)).isBefore(dayEnd);
  }
}

class HealthConnectStepSyncResult {
  const HealthConnectStepSyncResult._({
    required this.status,
    required this.outcome,
    this.bucketCount = 0,
    this.totalSteps = 0,
  });

  factory HealthConnectStepSyncResult.unavailable({
    required HealthConnectStatus status,
  }) {
    return HealthConnectStepSyncResult._(
      status: status,
      outcome: HealthConnectStepSyncOutcome.unavailable,
    );
  }

  factory HealthConnectStepSyncResult.permissionDenied({
    required HealthConnectStatus status,
  }) {
    return HealthConnectStepSyncResult._(
      status: status,
      outcome: HealthConnectStepSyncOutcome.permissionDenied,
    );
  }

  factory HealthConnectStepSyncResult.empty({
    required HealthConnectStatus status,
  }) {
    return HealthConnectStepSyncResult._(
      status: status,
      outcome: HealthConnectStepSyncOutcome.empty,
    );
  }

  factory HealthConnectStepSyncResult.synced({
    required HealthConnectStatus status,
    required int bucketCount,
    required int totalSteps,
  }) {
    return HealthConnectStepSyncResult._(
      status: status,
      outcome: HealthConnectStepSyncOutcome.synced,
      bucketCount: bucketCount,
      totalSteps: totalSteps,
    );
  }

  final HealthConnectStatus status;
  final HealthConnectStepSyncOutcome outcome;
  final int bucketCount;
  final int totalSteps;

  bool get didSync => outcome == HealthConnectStepSyncOutcome.synced;
}

enum HealthConnectStepSyncOutcome {
  unavailable,
  permissionDenied,
  empty,
  synced,
}
