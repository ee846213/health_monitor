import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

typedef DataCollectorRevisionCallback = void Function();

class SharedActivityRepository extends ActivityRepository {
  final List<ActivitySample> _buffer = <ActivitySample>[];

  List<ActivitySample> get samples => List<ActivitySample>.unmodifiable(_buffer);

  void addSample(ActivitySample sample) {
    _buffer.add(sample);
    if (_buffer.length > 500) {
      _buffer.removeAt(0);
    }
  }

  @override
  Future<List<ActivitySample>> listByWindow(QueryWindow window) async {
    final result = _buffer.where((sample) => window.contains(sample.capturedAt)).toList();
    result.sort(
      (ActivitySample left, ActivitySample right) =>
          left.capturedAt.compareTo(right.capturedAt),
    );
    return result;
  }
}

class SharedNoiseRepository extends NoiseSampleRepository {
  final List<NoiseSample> _buffer = <NoiseSample>[];

  List<NoiseSample> get samples => List<NoiseSample>.unmodifiable(_buffer);

  void addSample(NoiseSample sample) {
    _buffer.add(sample);
    if (_buffer.length > 300) {
      _buffer.removeAt(0);
    }
  }

  @override
  Future<List<NoiseSample>> listByWindow(QueryWindow window) async {
    final result = _buffer.where((sample) => window.contains(sample.capturedAt)).toList();
    result.sort(
      (NoiseSample left, NoiseSample right) =>
          left.capturedAt.compareTo(right.capturedAt),
    );
    return result;
  }
}

class SharedLocationRepository extends LocationSummaryRepository {
  final Map<String, LocationSummary> _dailySummaries = <String, LocationSummary>{};

  List<LocationSummary> get summaries =>
      _dailySummaries.values.toList(growable: false);

  void upsertSummary(LocationSummary summary) {
    _dailySummaries[_dayKey(summary.date)] = summary;
  }

  @override
  Future<List<LocationSummary>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final result = _dailySummaries.values.where((LocationSummary summary) {
      final difference = referenceDate.difference(summary.date).inDays;
      return difference >= 0 && difference < days;
    }).toList();
    result.sort(
      (LocationSummary left, LocationSummary right) =>
          left.date.compareTo(right.date),
    );
    return result;
  }
}

class SharedUsageRepository extends UsageSummaryRepository {
  final Map<String, DigitalUsageSummary> _dailySummaries =
      <String, DigitalUsageSummary>{};

  List<DigitalUsageSummary> get summaries =>
      _dailySummaries.values.toList(growable: false);

  void upsertSummary(DigitalUsageSummary summary) {
    _dailySummaries[_dayKey(summary.date)] = summary;
  }

  @override
  Future<DigitalUsageSummary?> getByDate(DateTime date) async {
    return _dailySummaries[_dayKey(date)];
  }
}

class SharedMetricsRepository extends MetricsRepository {
  final Map<String, DailyMetrics> _dailyMetrics = <String, DailyMetrics>{};

  void upsertMetrics(DailyMetrics metrics) {
    _dailyMetrics[_dayKey(metrics.date)] = metrics;
  }

  @override
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final result = _dailyMetrics.values.where((DailyMetrics item) {
      final difference = referenceDate.difference(item.date).inDays;
      return difference >= 0 && difference < days;
    }).toList();
    result.sort(
      (DailyMetrics left, DailyMetrics right) => left.date.compareTo(right.date),
    );
    return result;
  }
}

final sharedActivityRepo =
    Provider<SharedActivityRepository>((Ref ref) => SharedActivityRepository());
final sharedNoiseRepo =
    Provider<SharedNoiseRepository>((Ref ref) => SharedNoiseRepository());
final sharedLocationRepo =
    Provider<SharedLocationRepository>((Ref ref) => SharedLocationRepository());
final sharedUsageRepo =
    Provider<SharedUsageRepository>((Ref ref) => SharedUsageRepository());
final sharedMetricsRepo =
    Provider<SharedMetricsRepository>((Ref ref) => SharedMetricsRepository());

final dataCollectorRevisionProvider = StateProvider<int>((Ref ref) => 0);

class DataCollector {
  DataCollector({
    required this.activityRepository,
    required this.noiseRepository,
    required this.locationRepository,
    required this.usageRepository,
    required this.metricsRepository,
    MotionCaptureService? motionCaptureService,
    NoiseCaptureService? noiseCaptureService,
    LocationCaptureService? locationCaptureService,
    DigitalUsageCaptureService? digitalUsageCaptureService,
    DataCollectorRevisionCallback? onDataChanged,
  })  : _motionCaptureService = motionCaptureService ?? MotionCaptureService(),
        _noiseCaptureService = noiseCaptureService ?? NoiseCaptureService(),
        _locationCaptureService =
            locationCaptureService ?? LocationCaptureService(),
        _digitalUsageCaptureService =
            digitalUsageCaptureService ?? DigitalUsageCaptureService(),
        _onDataChanged = onDataChanged;

  final SharedActivityRepository activityRepository;
  final SharedNoiseRepository noiseRepository;
  final SharedLocationRepository locationRepository;
  final SharedUsageRepository usageRepository;
  final SharedMetricsRepository metricsRepository;
  final MotionCaptureService _motionCaptureService;
  final NoiseCaptureService _noiseCaptureService;
  final LocationCaptureService _locationCaptureService;
  final DigitalUsageCaptureService _digitalUsageCaptureService;
  final DataCollectorRevisionCallback? _onDataChanged;
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  bool _started = false;

  void start() {
    if (_started) {
      return;
    }
    _started = true;

    _subscriptions.add(
      _motionCaptureService.watchActivitySamples().listen(
        (ActivitySample sample) {
          activityRepository.addSample(sample);
          _refreshDailyMetrics(sample.capturedAt);
        },
        onError: (_) {},
      ),
    );
    _subscriptions.add(
      _noiseCaptureService.watchNoiseSamples().listen(
        (NoiseSample sample) {
          noiseRepository.addSample(sample);
          _refreshDailyMetrics(sample.capturedAt);
        },
        onError: (_) {},
      ),
    );
    _subscriptions.add(
      _locationCaptureService.watchLocationSummaries().listen(
        (LocationSummary summary) {
          locationRepository.upsertSummary(summary);
          _refreshDailyMetrics(summary.date);
        },
        onError: (_) {},
      ),
    );
    _subscriptions.add(
      _digitalUsageCaptureService.watchUsageSummaries().listen(
        (DigitalUsageSummary summary) {
          usageRepository.upsertSummary(summary);
          _refreshDailyMetrics(summary.date);
        },
        onError: (_) {},
      ),
    );
  }

  Future<void> dispose() async {
    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _started = false;
  }

  void _refreshDailyMetrics(DateTime referenceTime) {
    final dayStart = DateTime(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));
    final dayActivities = activityRepository.samples.where((ActivitySample sample) {
      return !sample.capturedAt.isBefore(dayStart) &&
          sample.capturedAt.isBefore(dayEnd);
    }).toList();
    final dayNoises = noiseRepository.samples.where((NoiseSample sample) {
      return !sample.capturedAt.isBefore(dayStart) &&
          sample.capturedAt.isBefore(dayEnd);
    }).toList();
    final locationSummary = locationRepository.summaries
        .where((LocationSummary summary) => _dayKey(summary.date) == _dayKey(referenceTime))
        .fold<LocationSummary?>(
          null,
          (LocationSummary? latest, LocationSummary summary) {
            if (latest == null || summary.date.isAfter(latest.date)) {
              return summary;
            }
            return latest;
          },
        );
    final usageSummary = usageRepository.summaries
        .where((DigitalUsageSummary summary) => _dayKey(summary.date) == _dayKey(referenceTime))
        .fold<DigitalUsageSummary?>(
          null,
          (DigitalUsageSummary? latest, DigitalUsageSummary summary) {
            if (latest == null || summary.date.isAfter(latest.date)) {
              return summary;
            }
            return latest;
          },
        );

    final sedentaryDuration = dayActivities
        .where((ActivitySample sample) => sample.type == ActivityType.stationary)
        .fold<Duration>(
          Duration.zero,
          (Duration total, ActivitySample sample) => total + sample.duration,
        );
    final stepCount = dayActivities.fold<int>(
      0,
      (int total, ActivitySample sample) => total + sample.stepCount,
    );
    final highNoiseExposureDuration = dayNoises
        .where((NoiseSample sample) => sample.level == NoiseLevel.loud)
        .fold<Duration>(
          Duration.zero,
          (Duration total, NoiseSample sample) => total + sample.duration,
        );

    metricsRepository.upsertMetrics(
      DailyMetrics(
        date: dayStart,
        stepCount: stepCount,
        sedentaryDuration: sedentaryDuration,
        screenOnDuration: usageSummary?.screenOnDuration ?? Duration.zero,
        outdoorDuration: locationSummary?.outdoorDuration ?? Duration.zero,
        postureRiskCount:
            dayActivities.where((ActivitySample sample) => sample.isSedentary).length,
        highNoiseExposureDuration: highNoiseExposureDuration,
      ),
    );
    // 首页和提醒页不直接监听原始流，而是监听这个轻量变化信号。
    // 这样真实样本一写入，本地聚合和页面重算就能同步触发，不需要轮询。
    _onDataChanged?.call();
  }
}

final dataCollectorProvider = Provider<DataCollector>((Ref ref) {
  final collector = DataCollector(
    activityRepository: ref.watch(sharedActivityRepo),
    noiseRepository: ref.watch(sharedNoiseRepo),
    locationRepository: ref.watch(sharedLocationRepo),
    usageRepository: ref.watch(sharedUsageRepo),
    metricsRepository: ref.watch(sharedMetricsRepo),
    onDataChanged: () {
      ref.read(dataCollectorRevisionProvider.notifier).state += 1;
    },
  );
  collector.start();
  ref.onDispose(collector.dispose);
  return collector;
});

String _dayKey(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day';
}
