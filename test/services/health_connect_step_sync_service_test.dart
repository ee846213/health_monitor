import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/hourly_step_bucket.dart';
import 'package:health_monitor/services/health_connect_bridge.dart';
import 'package:health_monitor/services/health_connect_step_sync_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('Health Connect 小时桶应覆盖写入节奏轴样本', () async {
    final activityRepository =
        InMemoryActivityRepository(samples: <ActivitySample>[]);
    final metricsRepository = _MemoryMetricsRepository();
    final service = HealthConnectStepSyncService(
      bridge: _FakeHealthConnectBridge(
        buckets: <HourlyStepBucket>[
          HourlyStepBucket(
            startAt: DateTime(2026, 6, 22, 8),
            endAt: DateTime(2026, 6, 22, 9),
            stepCount: 3200,
          ),
          HourlyStepBucket(
            startAt: DateTime(2026, 6, 22, 18),
            endAt: DateTime(2026, 6, 22, 19),
            stepCount: 900,
          ),
        ],
      ),
      activityRepository: activityRepository,
      metricsRepository: metricsRepository,
    );

    final result = await service.syncForDay(
      referenceTime: DateTime(2026, 6, 22, 21),
    );

    expect(result.didSync, isTrue);
    expect(result.totalSteps, 4100);
    final samples = await activityRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: DateTime(2026, 6, 22)),
    );
    expect(samples, hasLength(2));
    expect(samples.first.source, MotionSampleSource.healthConnectHourly);
    expect(samples.first.stepCount, 3200);
    final metrics = await metricsRepository.getByDate(DateTime(2026, 6, 22));
    expect(metrics?.stepCount, 4100);
  });

  test('Health Connect 同步应清除同小时系统计步增量', () async {
    final activityRepository = InMemoryActivityRepository(
      samples: <ActivitySample>[
        ActivitySample(
          capturedAt: DateTime(2026, 6, 22, 8, 15),
          duration: const Duration(seconds: 1),
          type: ActivityType.walking,
          confidence: 0.85,
          stepCount: 420,
          source: MotionSampleSource.platformActivity,
        ),
        ActivitySample(
          capturedAt: DateTime(2026, 6, 22, 18, 30),
          duration: const Duration(seconds: 1),
          type: ActivityType.walking,
          confidence: 0.85,
          stepCount: 260,
          source: MotionSampleSource.platformActivity,
        ),
      ],
    );
    final service = HealthConnectStepSyncService(
      bridge: _FakeHealthConnectBridge(
        buckets: <HourlyStepBucket>[
          HourlyStepBucket(
            startAt: DateTime(2026, 6, 22, 8),
            endAt: DateTime(2026, 6, 22, 9),
            stepCount: 3200,
          ),
        ],
      ),
      activityRepository: activityRepository,
      metricsRepository: _MemoryMetricsRepository(),
    );

    await service.syncForDay(referenceTime: DateTime(2026, 6, 22, 21));

    final samples = await activityRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: DateTime(2026, 6, 22)),
    );
    expect(samples, hasLength(2));
    expect(
      samples.where(
        (ActivitySample sample) =>
            sample.source == MotionSampleSource.platformActivity,
      ),
      hasLength(1),
    );
    expect(samples.last.capturedAt.hour, 18);
    expect(samples.last.stepCount, 260);
  });

  test('历史整天 Health Connect 结果应纠正本地更高的错误步数', () async {
    final metricsRepository = _MemoryMetricsRepository()
      ..seed(
        DailyMetrics(
          date: DateTime(2026, 7, 12),
          stepCount: 11941,
          sedentaryDuration: Duration.zero,
          screenOnDuration: Duration.zero,
          outdoorDuration: Duration.zero,
          postureRiskCount: 0,
          highNoiseExposureDuration: Duration.zero,
        ),
      );
    final service = HealthConnectStepSyncService(
      bridge: _FakeHealthConnectBridge(
        buckets: <HourlyStepBucket>[
          HourlyStepBucket(
            startAt: DateTime(2026, 7, 12, 10),
            endAt: DateTime(2026, 7, 12, 11),
            stepCount: 1200,
          ),
        ],
      ),
      activityRepository:
          InMemoryActivityRepository(samples: const <ActivitySample>[]),
      metricsRepository: metricsRepository,
    );

    await service.syncForDay(
      referenceTime: DateTime(2026, 7, 12, 23, 59, 59, 999),
    );

    final metrics = await metricsRepository.getByDate(DateTime(2026, 7, 12));
    expect(metrics?.stepCount, 1200);
  });

  test('历史整天 Health Connect 为空时不应清除本地已有步数', () async {
    final metricsRepository = _MemoryMetricsRepository()
      ..seed(
        DailyMetrics(
          date: DateTime(2026, 7, 12),
          stepCount: 11941,
          sedentaryDuration: Duration.zero,
          screenOnDuration: Duration.zero,
          outdoorDuration: Duration.zero,
          postureRiskCount: 0,
          highNoiseExposureDuration: Duration.zero,
        ),
      );
    final service = HealthConnectStepSyncService(
      bridge: _FakeHealthConnectBridge(buckets: const <HourlyStepBucket>[]),
      activityRepository:
          InMemoryActivityRepository(samples: const <ActivitySample>[]),
      metricsRepository: metricsRepository,
    );

    await service.syncForDay(
      referenceTime: DateTime(2026, 7, 12, 23, 59, 59, 999),
    );

    final metrics = await metricsRepository.getByDate(DateTime(2026, 7, 12));
    expect(metrics?.stepCount, 11941);
  });
}

class _FakeHealthConnectBridge extends HealthConnectBridge {
  _FakeHealthConnectBridge({
    required this.buckets,
  }) : super(isAndroid: () => true);

  final List<HourlyStepBucket> buckets;

  @override
  Future<HealthConnectStatus> getStatus() async {
    return const HealthConnectStatus(
      isAvailable: true,
      hasStepsPermission: true,
      needsInstall: false,
    );
  }

  @override
  Future<List<HourlyStepBucket>> readHourlySteps({
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    return buckets;
  }
}

class _MemoryMetricsRepository implements MetricsRepository {
  final Map<String, DailyMetrics> _store = <String, DailyMetrics>{};

  String _key(DateTime date) => '${date.year}-${date.month}-${date.day}';

  void seed(DailyMetrics metrics) {
    _store[_key(metrics.date)] = metrics;
  }

  @override
  Future<DailyMetrics?> getByDate(DateTime date) async {
    return _store[_key(date)];
  }

  @override
  Future<void> upsertMetrics(DailyMetrics metrics) async {
    _store[_key(metrics.date)] = metrics;
  }

  @override
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) {
    throw UnimplementedError();
  }
}
