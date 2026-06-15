import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/health/capture_checkpoint.dart';
import 'package:health_monitor/domain/health/capture_health_event.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/posture_sample.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/isar/collections/activity_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/capture_checkpoint_record.dart';
import 'package:health_monitor/storage/isar/collections/capture_health_event_record.dart';
import 'package:health_monitor/storage/isar/collections/ambient_light_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/daily_metrics_record.dart';
import 'package:health_monitor/storage/isar/collections/location_summary_record.dart';
import 'package:health_monitor/storage/isar/collections/noise_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/posture_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/reminder_record_entity.dart';
import 'package:health_monitor/storage/isar/collections/usage_summary_record.dart';

void main() {
  test('活动样本应可映射为可落库记录并恢复语义字段', () {
    final sample = ActivitySample(
      capturedAt: DateTime(2026, 6, 9, 8),
      duration: const Duration(minutes: 40),
      type: ActivityType.stationary,
      confidence: 0.88,
      stepCount: 30,
      source: MotionSampleSource.sensorFusion,
    );

    final record = ActivitySampleRecord.fromDomain(sample);

    expect(record.capturedAt, sample.capturedAt);
    expect(record.durationSeconds, 2400);
    expect(record.typeKey, ActivityType.stationary.name);
    expect(record.sourceKey, MotionSampleSource.sensorFusion.name);
  });

  test('姿势样本应保留提醒判断所需字段', () {
    final sample = PostureSample(
      capturedAt: DateTime(2026, 6, 9, 21),
      duration: const Duration(minutes: 15),
      posture: PostureType.neckDown,
      riskLevel: PostureRiskLevel.high,
      continuousHold: const Duration(minutes: 12),
    );

    final record = PostureSampleRecord.fromDomain(sample);

    expect(record.postureKey, PostureType.neckDown.name);
    expect(record.riskLevelKey, PostureRiskLevel.high.name);
    expect(record.continuousHoldSeconds, 720);
  });

  test('位置与数字生活摘要应保留日级聚合主键', () {
    final location = LocationSummary(
      date: DateTime(2026, 6, 9),
      distanceMeters: 1800,
      outdoorDuration: const Duration(minutes: 26),
      visitCount: 3,
      commuteCount: 1,
    );
    final usage = DigitalUsageSummary(
      date: DateTime(2026, 6, 9),
      screenOnDuration: const Duration(hours: 3),
      unlockCount: 36,
      nighttimeUsageDuration: const Duration(minutes: 20),
      focusSessionBreakCount: 9,
      topCategory: UsageCategory.productivity,
    );

    final locationRecord = LocationSummaryRecord.fromDomain(location);
    final usageRecord = UsageSummaryRecord.fromDomain(usage);

    expect(locationRecord.dateKey, '2026-06-09');
    expect(usageRecord.dateKey, '2026-06-09');
    expect(usageRecord.topCategoryKey, UsageCategory.productivity.name);
  });

  test('噪音与每日指标记录应保留规则聚合所需核心字段', () {
    final noise = NoiseSample.fromDecibel(
      capturedAt: DateTime(2026, 6, 9, 23),
      duration: const Duration(minutes: 10),
      decibel: 74,
    );
    final metrics = DailyMetrics(
      date: DateTime(2026, 6, 9),
      stepCount: 4200,
      sedentaryDuration: const Duration(hours: 7),
      screenOnDuration: const Duration(hours: 4, minutes: 15),
      outdoorDuration: const Duration(minutes: 14),
      postureRiskCount: 2,
      highNoiseExposureDuration: const Duration(minutes: 35),
    );

    final noiseRecord = NoiseSampleRecord.fromDomain(noise);
    final metricsRecord = DailyMetricsRecord.fromDomain(metrics);

    expect(noiseRecord.levelKey, NoiseLevel.loud.name);
    expect(noiseRecord.durationSeconds, 600);
    expect(metricsRecord.dateKey, '2026-06-09');
    expect(metricsRecord.highNoiseExposureSeconds, 2100);
  });

  test('光照记录应保留 lux 与等级字段', () {
    final light = AmbientLightSample.fromLux(
      capturedAt: DateTime(2026, 6, 9, 10),
      duration: const Duration(minutes: 5),
      lux: 8,
    );

    final record = AmbientLightSampleRecord.fromDomain(light);

    expect(record.levelKey, AmbientLightLevel.dark.name);
    expect(record.durationSeconds, 300);
    expect(record.lux, 8);
  });

  test('提醒记录应保留解释与交互回写所需字段', () {
    final reminder = ReminderRecord(
      triggeredAt: DateTime(2026, 6, 9, 15, 30),
      type: ReminderType.sedentaryBreak,
      title: '起身走一走',
      message: '你下午已经连续坐了很久。',
      reasonSummary: '14:00 到 15:30 几乎没有活动。',
      actionSuggestion: '先活动两分钟再继续。',
      response: ReminderResponse.taken,
    );

    final record = ReminderRecordEntity.fromDomain(reminder);

    expect(record.dateKey, '2026-06-09');
    expect(record.typeKey, ReminderType.sedentaryBreak.name);
    expect(record.responseKey, ReminderResponse.taken.name);
    expect(record.reasonSummary, contains('没有活动'));
  });

  test('采集健康事件与检查点应保留恢复诊断所需字段', () {
    final event = CaptureHealthEvent(
      eventId: 'event-1',
      streamKey: 'digital_usage_android',
      eventType: CaptureHealthEventType.gapDetected,
      occurredAt: DateTime(2026, 6, 9, 18),
      detail: '摘要刷新延迟。',
      gapSeconds: 900,
      errorMessage: 'timeout',
    );
    final checkpoint = CaptureCheckpoint(
      streamKey: 'digital_usage_android',
      state: CaptureHealthState.degraded,
      sampleCount: 3,
      gapCount: 1,
      recoveryCount: 2,
      lastEventTypeKey: CaptureHealthEventType.gapDetected.name,
      lastEventAt: DateTime(2026, 6, 9, 18),
      lastSampleAt: DateTime(2026, 6, 9, 18),
      lastErrorAt: DateTime(2026, 6, 9, 17, 45),
      lastRecoveredAt: DateTime(2026, 6, 9, 18, 5),
      lastStateRebuiltAt: DateTime(2026, 6, 9, 18, 10),
      lastNativeSummaryDrainedAt: DateTime(2026, 6, 9, 18, 12),
      lastMessage: '摘要刷新延迟。',
      lastErrorMessage: 'timeout',
    );

    final eventRecord = CaptureHealthEventRecord.fromDomain(event);
    final checkpointRecord = CaptureCheckpointRecord.fromDomain(checkpoint);

    expect(eventRecord.streamKey, 'digital_usage_android');
    expect(eventRecord.eventTypeKey, CaptureHealthEventType.gapDetected.name);
    expect(checkpointRecord.streamKey, 'digital_usage_android');
    expect(checkpointRecord.stateKey, CaptureHealthState.degraded.name);
    expect(checkpointRecord.recoveryCount, 2);
  });
}
