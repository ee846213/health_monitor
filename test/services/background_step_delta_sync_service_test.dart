import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/background_step_delta_event.dart';
import 'package:health_monitor/services/android_step_delta_bridge.dart';
import 'package:health_monitor/services/background_step_delta_sync_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('后台步数增量应写入活动样本并更新日指标', () async {
    final activityRepository = InMemoryActivityRepository(samples: <ActivitySample>[]);
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
}

class _FakeStepDeltaBridge extends AndroidStepDeltaBridge {
  _FakeStepDeltaBridge({
    required this.events,
  }) : super(isAndroid: () => true);

  final List<BackgroundStepDeltaEvent> events;

  @override
  Future<List<BackgroundStepDeltaEvent>> drainBackgroundStepDeltas() async {
    return events;
  }
}

class _MemoryMetricsRepository implements MetricsRepository {
  final Map<String, DailyMetrics> _store = <String, DailyMetrics>{};

  String _key(DateTime date) => '${date.year}-${date.month}-${date.day}';

  @override
  Future<DailyMetrics?> getByDate(DateTime date) async {
    return _store[_key(date)];
  }

  @override
  Future<void> upsertMetrics(DailyMetrics metrics) async {
    _store[_key(metrics.date)] = metrics;
  }

  @override
  Future<List<DailyMetrics>> listRecentDays(int days, {DateTime? referenceDate}) {
    throw UnimplementedError();
  }
}
