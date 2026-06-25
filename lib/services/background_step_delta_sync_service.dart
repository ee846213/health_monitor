import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/background_step_delta_event.dart';
import 'package:health_monitor/domain/motion/rhythm_step_sample_dedup.dart';
import 'package:health_monitor/services/android_step_delta_bridge.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

/// 将后台定期记录的步数增量同步为活动样本，供节奏轴定位活动时段。
class BackgroundStepDeltaSyncService {
  const BackgroundStepDeltaSyncService({
    required AndroidStepDeltaBridge bridge,
    required ActivityRepository activityRepository,
    required MetricsRepository metricsRepository,
  })  : _bridge = bridge,
        _activityRepository = activityRepository,
        _metricsRepository = metricsRepository;

  final AndroidStepDeltaBridge _bridge;
  final ActivityRepository _activityRepository;
  final MetricsRepository _metricsRepository;

  Future<int> syncDrainedEvents() async {
    final events = await _bridge.drainBackgroundStepDeltas();
    if (events.isEmpty) {
      return 0;
    }

    final filteredEvents = await _filterEventsNotCoveredByHealthConnect(events);
    if (filteredEvents.isEmpty) {
      return 0;
    }

    final samples = filteredEvents.map(_toActivitySample).toList(growable: false);
    await _activityRepository.saveAll(samples);
    await _upsertDailyMetricsFromEvents(filteredEvents);
    return filteredEvents.length;
  }

  Future<List<BackgroundStepDeltaEvent>> _filterEventsNotCoveredByHealthConnect(
    List<BackgroundStepDeltaEvent> events,
  ) async {
    final eventsByDay = <DateTime, List<BackgroundStepDeltaEvent>>{};
    for (final event in events) {
      final dayStart = DateTime(
        event.capturedAt.year,
        event.capturedAt.month,
        event.capturedAt.day,
      );
      eventsByDay.putIfAbsent(dayStart, () => <BackgroundStepDeltaEvent>[]).add(event);
    }

    final filtered = <BackgroundStepDeltaEvent>[];
    for (final entry in eventsByDay.entries) {
      final daySamples = await _activityRepository.listByWindow(
        QueryWindow.calendarDay(referenceDate: entry.key),
      );
      final coveredHours = healthConnectHourStarts(daySamples);
      for (final event in entry.value) {
        if (!isCoveredByHealthConnectHour(event.capturedAt, coveredHours)) {
          filtered.add(event);
        }
      }
    }
    return filtered;
  }

  ActivitySample _toActivitySample(BackgroundStepDeltaEvent event) {
    return ActivitySample(
      capturedAt: event.capturedAt,
      duration: const Duration(seconds: 1),
      type: ActivityType.walking,
      confidence: 0.85,
      stepCount: event.stepDelta,
      source: MotionSampleSource.platformActivity,
    );
  }

  Future<void> _upsertDailyMetricsFromEvents(
    List<BackgroundStepDeltaEvent> events,
  ) async {
    final latestByDay = <DateTime, BackgroundStepDeltaEvent>{};
    for (final event in events) {
      final dayStart = DateTime(
        event.capturedAt.year,
        event.capturedAt.month,
        event.capturedAt.day,
      );
      final current = latestByDay[dayStart];
      if (current == null || event.capturedAt.isAfter(current.capturedAt)) {
        latestByDay[dayStart] = event;
      }
    }

    for (final entry in latestByDay.entries) {
      final dayStart = entry.key;
      final dayStepTotal = entry.value.dayStepTotal;
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
      if (dayStepTotal <= existing.stepCount) {
        continue;
      }
      await _metricsRepository.upsertMetrics(
        DailyMetrics(
          date: dayStart,
          stepCount: dayStepTotal,
          sedentaryDuration: existing.sedentaryDuration,
          screenOnDuration: existing.screenOnDuration,
          outdoorDuration: existing.outdoorDuration,
          postureRiskCount: existing.postureRiskCount,
          highNoiseExposureDuration: existing.highNoiseExposureDuration,
        ),
      );
    }
  }
}
