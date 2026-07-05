import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/background_step_delta_event.dart';
import 'package:health_monitor/domain/motion/native_step_day_summary.dart';
import 'package:health_monitor/services/android_step_delta_bridge.dart';
import 'package:health_monitor/services/background_step_delta_sync_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('普通计步历史天汇总应写入跨日日指标', () async {
    final activityRepository =
        InMemoryActivityRepository(samples: <ActivitySample>[]);
    final metricsRepository = _MemoryMetricsRepository();
    final service = BackgroundStepDeltaSyncService(
      bridge: _FakeStepDeltaBridge(
        events: const <BackgroundStepDeltaEvent>[],
        historicalSummaries: <NativeStepDaySummary>[
          NativeStepDaySummary(
            date: DateTime(2026, 7, 4),
            capturedAt: DateTime(2026, 7, 4, 23, 58),
            stepCount: 4860,
          ),
        ],
      ),
      activityRepository: activityRepository,
      metricsRepository: metricsRepository,
    );

    final syncedCount = await service.syncDrainedEvents();

    expect(syncedCount, 1);
    final metrics = await metricsRepository.getByDate(DateTime(2026, 7, 4));
    expect(metrics?.stepCount, 4860);
  });

  test('普通计步历史不应覆盖已有更高步数', () async {
    final activityRepository =
        InMemoryActivityRepository(samples: <ActivitySample>[]);
    final metricsRepository = _MemoryMetricsRepository()
      ..seed(
        DailyMetrics(
          date: DateTime(2026, 7, 4),
          stepCount: 6200,
          sedentaryDuration: const Duration(minutes: 40),
          screenOnDuration: const Duration(minutes: 120),
          outdoorDuration: Duration.zero,
          postureRiskCount: 1,
          highNoiseExposureDuration: Duration.zero,
        ),
      );
    final service = BackgroundStepDeltaSyncService(
      bridge: _FakeStepDeltaBridge(
        events: const <BackgroundStepDeltaEvent>[],
        historicalSummaries: <NativeStepDaySummary>[
          NativeStepDaySummary(
            date: DateTime(2026, 7, 4),
            capturedAt: DateTime(2026, 7, 4, 23, 58),
            stepCount: 4860,
          ),
        ],
      ),
      activityRepository: activityRepository,
      metricsRepository: metricsRepository,
    );

    final syncedCount = await service.syncDrainedEvents();

    expect(syncedCount, 0);
    final metrics = await metricsRepository.getByDate(DateTime(2026, 7, 4));
    expect(metrics?.stepCount, 6200);
    expect(metrics?.screenOnDuration, const Duration(minutes: 120));
  });

  test('后台步数增量应写入活动样本并更新日指标', () async {
    final activityRepository =
        InMemoryActivityRepository(samples: <ActivitySample>[]);
    final metricsRepository = _MemoryMetricsRepository();
    final service = BackgroundStepDeltaSyncService(
      bridge: _FakeStepDeltaBridge(
        events: <BackgroundStepDeltaEvent>[
          BackgroundStepDeltaEvent(
            eventId: '1',
            capturedAt: DateTime(2026, 6, 22, 8, 15),
            stepDelta: 420,
            dayStepTotal: 1200,
          ),
          BackgroundStepDeltaEvent(
            eventId: '2',
            capturedAt: DateTime(2026, 6, 22, 18, 30),
            stepDelta: 260,
            dayStepTotal: 3800,
          ),
        ],
      ),
      activityRepository: activityRepository,
      metricsRepository: metricsRepository,
    );

    final syncedCount = await service.syncDrainedEvents();

    expect(syncedCount, 2);
    final samples = await activityRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: DateTime(2026, 6, 22)),
    );
    expect(samples, hasLength(2));
    expect(samples.first.source, MotionSampleSource.platformActivity);
    expect(samples.first.stepCount, 420);
    final metrics = await metricsRepository.getByDate(DateTime(2026, 6, 22));
    expect(metrics?.stepCount, 3800);
  });

  test('已有 Health Connect 小时桶时不应重复写入同小时后台增量', () async {
    final activityRepository = InMemoryActivityRepository(
      samples: <ActivitySample>[
        ActivitySample(
          capturedAt: DateTime(2026, 6, 22, 8),
          duration: const Duration(hours: 1),
          type: ActivityType.walking,
          confidence: 0.85,
          stepCount: 3200,
          source: MotionSampleSource.healthConnectHourly,
        ),
      ],
    );
    final metricsRepository = _MemoryMetricsRepository();
    final service = BackgroundStepDeltaSyncService(
      bridge: _FakeStepDeltaBridge(
        events: <BackgroundStepDeltaEvent>[
          BackgroundStepDeltaEvent(
            eventId: '1',
            capturedAt: DateTime(2026, 6, 22, 8, 15),
            stepDelta: 420,
            dayStepTotal: 1200,
          ),
          BackgroundStepDeltaEvent(
            eventId: '2',
            capturedAt: DateTime(2026, 6, 22, 18, 30),
            stepDelta: 260,
            dayStepTotal: 3800,
          ),
        ],
      ),
      activityRepository: activityRepository,
      metricsRepository: metricsRepository,
    );

    final syncedCount = await service.syncDrainedEvents();

    expect(syncedCount, 1);
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
  });
  test('后台无步数变化事件应补写静止片段用于久坐统计', () async {
    final activityRepository =
        InMemoryActivityRepository(samples: <ActivitySample>[]);
    final metricsRepository = _MemoryMetricsRepository();
    final service = BackgroundStepDeltaSyncService(
      bridge: _FakeStepDeltaBridge(
        events: <BackgroundStepDeltaEvent>[
          BackgroundStepDeltaEvent(
            eventId: 'stationary-1',
            capturedAt: DateTime(2026, 6, 22, 10, 45),
            stepDelta: 0,
            dayStepTotal: 1200,
            stationaryDuration: const Duration(minutes: 45),
          ),
        ],
      ),
      activityRepository: activityRepository,
      metricsRepository: metricsRepository,
    );

    final syncedCount = await service.syncDrainedEvents();

    expect(syncedCount, 1);
    final samples = await activityRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: DateTime(2026, 6, 22)),
    );
    expect(samples, hasLength(1));
    expect(samples.single.type, ActivityType.stationary);
    expect(samples.single.capturedAt, DateTime(2026, 6, 22, 10));
    expect(samples.single.duration, const Duration(minutes: 45));
    expect(samples.single.isSedentary, isTrue);
  });

  test('Health Connect 覆盖同小时步数时仍保留后台静止片段', () async {
    final activityRepository = InMemoryActivityRepository(
      samples: <ActivitySample>[
        ActivitySample(
          capturedAt: DateTime(2026, 6, 22, 10),
          duration: const Duration(hours: 1),
          type: ActivityType.walking,
          confidence: 0.85,
          stepCount: 3200,
          source: MotionSampleSource.healthConnectHourly,
        ),
      ],
    );
    final metricsRepository = _MemoryMetricsRepository();
    final service = BackgroundStepDeltaSyncService(
      bridge: _FakeStepDeltaBridge(
        events: <BackgroundStepDeltaEvent>[
          BackgroundStepDeltaEvent(
            eventId: 'stationary-1',
            capturedAt: DateTime(2026, 6, 22, 10, 45),
            stepDelta: 0,
            dayStepTotal: 3200,
            stationaryDuration: const Duration(minutes: 15),
          ),
        ],
      ),
      activityRepository: activityRepository,
      metricsRepository: metricsRepository,
    );

    final syncedCount = await service.syncDrainedEvents();

    expect(syncedCount, 1);
    final samples = await activityRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: DateTime(2026, 6, 22)),
    );
    expect(
      samples.where(
        (ActivitySample sample) => sample.type == ActivityType.stationary,
      ),
      hasLength(1),
    );
  });
}

class _FakeStepDeltaBridge extends AndroidStepDeltaBridge {
  _FakeStepDeltaBridge({
    required this.events,
    this.historicalSummaries = const <NativeStepDaySummary>[],
  }) : super(isAndroid: () => true);

  final List<BackgroundStepDeltaEvent> events;
  final List<NativeStepDaySummary> historicalSummaries;

  @override
  Future<List<BackgroundStepDeltaEvent>> drainBackgroundStepDeltas() async {
    return events;
  }

  @override
  Future<List<NativeStepDaySummary>> readHistoricalStepDays({
    int maxDays = 30,
  }) async {
    return historicalSummaries;
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
  Future<List<DailyMetrics>> listRecentDays(int days,
      {DateTime? referenceDate}) {
    throw UnimplementedError();
  }
}
