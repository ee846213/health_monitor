import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/step_count_state.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/step_counter_service.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';
import 'package:health_monitor/services/android_risk_event_bridge.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

typedef DataCollectorRevisionCallback = void Function();

class SharedActivityRepository extends InMemoryActivityRepository {
  SharedActivityRepository() : super(samples: <ActivitySample>[]);

  void addSample(ActivitySample sample) {
    _buffer.add(sample);
  }

  final List<ActivitySample> _buffer = <ActivitySample>[];

  @override
  Future<List<ActivitySample>> listByWindow(QueryWindow window) async {
    final result = _buffer.where((sample) => window.contains(sample.capturedAt)).toList();
    result.sort((left, right) => left.capturedAt.compareTo(right.capturedAt));
    return result;
  }
}

class SharedNoiseRepository extends InMemoryNoiseSampleRepository {
  SharedNoiseRepository() : super(samples: <NoiseSample>[]);

  void addSample(NoiseSample sample) {
    _buffer.add(sample);
  }

  final List<NoiseSample> _buffer = <NoiseSample>[];

  @override
  Future<List<NoiseSample>> listByWindow(QueryWindow window) async {
    final result = _buffer.where((sample) => window.contains(sample.capturedAt)).toList();
    result.sort((left, right) => left.capturedAt.compareTo(right.capturedAt));
    return result;
  }
}

class SharedLocationRepository extends InMemoryLocationSummaryRepository {
  SharedLocationRepository() : super(summaries: <LocationSummary>[]);

  @override
  Future<void> upsertSummary(LocationSummary summary) async {
    final key = _dayKey(summary.date);
    _dailySummaries[key] = summary;
  }

  final Map<String, LocationSummary> _dailySummaries = <String, LocationSummary>{};

  @override
  Future<List<LocationSummary>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final result = _dailySummaries.values.where((LocationSummary summary) {
      final difference = referenceDate.difference(summary.date).inDays;
      return difference >= 0 && difference < days;
    }).toList();
    result.sort((left, right) => left.date.compareTo(right.date));
    return result;
  }
}

class SharedUsageRepository extends InMemoryUsageSummaryRepository {
  SharedUsageRepository() : super(summaries: <DigitalUsageSummary>[]);

  @override
  Future<void> upsertSummary(DigitalUsageSummary summary) async {
    final key = _dayKey(summary.date);
    _dailySummaries[key] = summary;
  }

  final Map<String, DigitalUsageSummary> _dailySummaries = <String, DigitalUsageSummary>{};

  @override
  Future<DigitalUsageSummary?> getByDate(DateTime date) async {
    return _dailySummaries[_dayKey(date)];
  }
}

class SharedMetricsRepository extends InMemoryMetricsRepository {
  SharedMetricsRepository() : super(metrics: <DailyMetrics>[]);

  @override
  Future<void> upsertMetrics(DailyMetrics metrics) async {
    final key = _dayKey(metrics.date);
    _dailyMetrics[key] = metrics;
  }

  final Map<String, DailyMetrics> _dailyMetrics = <String, DailyMetrics>{};

  @override
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final result = _dailyMetrics.values.where((DailyMetrics item) {
      final difference = referenceDate.difference(item.date).inDays;
      return difference >= 0 && difference < days;
    }).toList();
    result.sort((left, right) => left.date.compareTo(right.date));
    return result;
  }
}

final sharedActivityRepo = Provider<ActivityRepository>((Ref ref) {
  return IsarActivityRepository(ref.watch(appIsarProvider.future));
});

final sharedNoiseRepo = Provider<NoiseSampleRepository>((Ref ref) {
  return IsarNoiseSampleRepository(ref.watch(appIsarProvider.future));
});

final sharedLocationRepo = Provider<LocationSummaryRepository>((Ref ref) {
  return IsarLocationSummaryRepository(ref.watch(appIsarProvider.future));
});

final sharedUsageRepo = Provider<UsageSummaryRepository>((Ref ref) {
  return IsarUsageSummaryRepository(ref.watch(appIsarProvider.future));
});

final sharedMetricsRepo = Provider<MetricsRepository>((Ref ref) {
  return IsarMetricsRepository(ref.watch(appIsarProvider.future));
});

final activityRepositoryProvider = sharedActivityRepo;
final locationSummaryRepositoryProvider = sharedLocationRepo;
final noiseSampleRepositoryProvider = sharedNoiseRepo;
final usageSummaryRepositoryProvider = sharedUsageRepo;
final metricsRepositoryProvider = sharedMetricsRepo;

final dataCollectorRevisionProvider = StateProvider<int>((Ref ref) => 0);

class _RevisionThrottle {
  _RevisionThrottle({
    required this.onThrottledTick,
    this.interval = const Duration(seconds: 2),
  });

  final Duration interval;
  final void Function() onThrottledTick;
  DateTime? _lastTickAt;
  bool _pending = false;
  Timer? _timer;

  void markChanged() {
    final now = DateTime.now();
    final lastTickAt = _lastTickAt;
    if (lastTickAt == null || now.difference(lastTickAt) >= interval) {
      _emit(now);
      return;
    }

    _pending = true;
    _timer ??= Timer(interval - now.difference(lastTickAt), () {
      _timer = null;
      if (!_pending) {
        return;
      }
      _emit(DateTime.now());
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pending = false;
  }

  void _emit(DateTime now) {
    _pending = false;
    _lastTickAt = now;
    onThrottledTick();
  }
}

class _DailyMetricsSignature {
  const _DailyMetricsSignature({
    required this.dateKey,
    required this.stepCount,
    required this.sedentaryMinutes,
    required this.screenMinutes,
    required this.outdoorMinutes,
    required this.postureRiskCount,
    required this.highNoiseExposureMinutes,
  });

  factory _DailyMetricsSignature.fromMetrics(DailyMetrics metrics) {
    return _DailyMetricsSignature(
      dateKey: _dayKey(metrics.date),
      stepCount: metrics.stepCount,
      sedentaryMinutes: metrics.sedentaryDuration.inMinutes,
      screenMinutes: metrics.screenOnDuration.inMinutes,
      outdoorMinutes: metrics.outdoorDuration.inMinutes,
      postureRiskCount: metrics.postureRiskCount,
      highNoiseExposureMinutes: metrics.highNoiseExposureDuration.inMinutes,
    );
  }

  final String dateKey;
  final int stepCount;
  final int sedentaryMinutes;
  final int screenMinutes;
  final int outdoorMinutes;
  final int postureRiskCount;
  final int highNoiseExposureMinutes;

  @override
  bool operator ==(Object other) {
    return other is _DailyMetricsSignature &&
        other.dateKey == dateKey &&
        other.stepCount == stepCount &&
        other.sedentaryMinutes == sedentaryMinutes &&
        other.screenMinutes == screenMinutes &&
        other.outdoorMinutes == outdoorMinutes &&
        other.postureRiskCount == postureRiskCount &&
        other.highNoiseExposureMinutes == highNoiseExposureMinutes;
  }

  @override
  int get hashCode => Object.hash(
        dateKey,
        stepCount,
        sedentaryMinutes,
        screenMinutes,
        outdoorMinutes,
        postureRiskCount,
        highNoiseExposureMinutes,
      );
}

class DataCollector {
  DataCollector({
    required this.activityRepository,
    required this.noiseRepository,
    required this.locationRepository,
    required this.usageRepository,
    required this.metricsRepository,
    MotionCaptureService? motionCaptureService,
    StepCounterService? stepCounterService,
    NoiseCaptureService? noiseCaptureService,
    LocationCaptureService? locationCaptureService,
    DigitalUsageCaptureService? digitalUsageCaptureService,
    DataCollectorRevisionCallback? onDataChanged,
    Future<void> Function(DateTime referenceTime)? persistRuleReminders,
    Future<void> Function()? syncNativeRiskEvents,
  })  : _motionCaptureService = motionCaptureService ?? MotionCaptureService(),
        _stepCounterService = stepCounterService ?? StepCounterService(),
        _noiseCaptureService = noiseCaptureService ?? NoiseCaptureService(),
        _locationCaptureService =
            locationCaptureService ?? LocationCaptureService(),
        _digitalUsageCaptureService =
            digitalUsageCaptureService ?? DigitalUsageCaptureService(),
        _onDataChanged = onDataChanged,
        _persistRuleReminders = persistRuleReminders,
        _syncNativeRiskEvents = syncNativeRiskEvents;

  final ActivityRepository activityRepository;
  final NoiseSampleRepository noiseRepository;
  final LocationSummaryRepository locationRepository;
  final UsageSummaryRepository usageRepository;
  final MetricsRepository metricsRepository;
  final MotionCaptureService _motionCaptureService;
  final StepCounterService _stepCounterService;
  final NoiseCaptureService _noiseCaptureService;
  final LocationCaptureService _locationCaptureService;
  final DigitalUsageCaptureService _digitalUsageCaptureService;
  final DataCollectorRevisionCallback? _onDataChanged;
  final Future<void> Function(DateTime referenceTime)? _persistRuleReminders;
  final Future<void> Function()? _syncNativeRiskEvents;
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  bool _started = false;
  _DailyMetricsSignature? _lastDailyMetricsSignature;
  StepCountState? _latestStepCountState;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    unawaited(syncNativeRiskEvents());

    _subscriptions.add(
      _motionCaptureService.watchActivitySamples().listen(
        (ActivitySample sample) async {
          await activityRepository.saveAll(<ActivitySample>[sample]);
          await _refreshDailyMetrics(sample.capturedAt);
        },
        onError: (_) {},
      ),
    );
    _subscriptions.add(
      _stepCounterService.watchStepCounts().listen(
        (StepCountState state) async {
          if (!state.isAvailable) {
            return;
          }
          _latestStepCountState = state;
          await _refreshDailyMetrics(state.capturedAt);
        },
        onError: (_) {},
      ),
    );
    _subscriptions.add(
      _noiseCaptureService.watchNoiseSamples().listen(
        (NoiseSample sample) async {
          await noiseRepository.saveAll(<NoiseSample>[sample]);
          await _refreshDailyMetrics(sample.capturedAt);
        },
        onError: (_) {},
      ),
    );
    _subscriptions.add(
      _locationCaptureService.watchLocationSummaries().listen(
        (LocationSummary summary) async {
          await locationRepository.upsertSummary(summary);
          await _refreshDailyMetrics(summary.date);
        },
        onError: (_) {},
      ),
    );
    _subscriptions.add(
      _digitalUsageCaptureService.watchUsageSummaries().listen(
        (DigitalUsageSummary summary) async {
          await usageRepository.upsertSummary(summary);
          await _refreshDailyMetrics(summary.date);
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

  Future<void> syncNativeRiskEvents() async {
    if (_syncNativeRiskEvents == null) {
      return;
    }
    await _syncNativeRiskEvents!.call();
    _onDataChanged?.call();
  }

  Future<void> _refreshDailyMetrics(DateTime referenceTime) async {
    final dayStart = DateTime(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
    );
    final dayActivities = await activityRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: dayStart),
    );
    final dayNoises = await noiseRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: dayStart),
    );
    final locationSummary = await locationRepository.listRecentDays(
      1,
      referenceDate: dayStart,
    );
    final usageSummary = await usageRepository.getByDate(dayStart);

    final sedentaryDuration = dayActivities
        .where((ActivitySample sample) => sample.type == ActivityType.stationary)
        .fold<Duration>(
          Duration.zero,
          (Duration total, ActivitySample sample) => total + sample.duration,
        );
    final stepCount = _latestStepCountState?.isAvailable == true
        ? _latestStepCountState!.stepCount
        : dayActivities.fold<int>(
            0,
            (int total, ActivitySample sample) => total + sample.stepCount,
          );
    final highNoiseExposureDuration = dayNoises
        .where((NoiseSample sample) => sample.level == NoiseLevel.loud)
        .fold<Duration>(
          Duration.zero,
          (Duration total, NoiseSample sample) => total + sample.duration,
        );

    final nextMetrics = DailyMetrics(
      date: dayStart,
      stepCount: stepCount,
      sedentaryDuration: sedentaryDuration,
      screenOnDuration: usageSummary?.screenOnDuration ?? Duration.zero,
      outdoorDuration: locationSummary.isNotEmpty
          ? locationSummary.last.outdoorDuration
          : Duration.zero,
      postureRiskCount: dayActivities
          .where((ActivitySample sample) => sample.isSedentary)
          .length,
      highNoiseExposureDuration: highNoiseExposureDuration,
    );
    await metricsRepository.upsertMetrics(nextMetrics);

    final nextSignature = _DailyMetricsSignature.fromMetrics(nextMetrics);
    if (_lastDailyMetricsSignature != null &&
        _lastDailyMetricsSignature == nextSignature) {
      return;
    }

    _lastDailyMetricsSignature = nextSignature;
    if (_persistRuleReminders != null) {
      await _persistRuleReminders!.call(referenceTime);
    }
    _onDataChanged?.call();
  }
}

final dataCollectorProvider = Provider<DataCollector>((Ref ref) {
  final revisionThrottle = _RevisionThrottle(
    interval: const Duration(seconds: 2),
    onThrottledTick: () {
      ref.read(dataCollectorRevisionProvider.notifier).state += 1;
    },
  );
  final collector = DataCollector(
    activityRepository: ref.watch(sharedActivityRepo),
    noiseRepository: ref.watch(sharedNoiseRepo),
    locationRepository: ref.watch(sharedLocationRepo),
    usageRepository: ref.watch(sharedUsageRepo),
    metricsRepository: ref.watch(sharedMetricsRepo),
    onDataChanged: revisionThrottle.markChanged,
    persistRuleReminders: (DateTime referenceTime) async {
      final insightService = HealthInsightService(
        activityRepository: ref.read(sharedActivityRepo),
        locationRepository: ref.read(sharedLocationRepo),
        noiseRepository: ref.read(sharedNoiseRepo),
        usageRepository: ref.read(sharedUsageRepo),
        metricsRepository: ref.read(sharedMetricsRepo),
        reminderRepositoryLoader: () async {
          final isar = await ref.read(appIsarProvider.future);
          return IsarReminderRepository(isar);
        },
        androidRiskEventBridge: AndroidRiskEventBridge(
          platformBridgeService: PlatformBridgeService(),
        ),
      );
      await insightService.persistRuleReminders(referenceTime: referenceTime);
    },
    syncNativeRiskEvents: () async {
      final insightService = HealthInsightService(
        activityRepository: ref.read(sharedActivityRepo),
        locationRepository: ref.read(sharedLocationRepo),
        noiseRepository: ref.read(sharedNoiseRepo),
        usageRepository: ref.read(sharedUsageRepo),
        metricsRepository: ref.read(sharedMetricsRepo),
        reminderRepositoryLoader: () async {
          final isar = await ref.read(appIsarProvider.future);
          return IsarReminderRepository(isar);
        },
        androidRiskEventBridge: AndroidRiskEventBridge(
          platformBridgeService: PlatformBridgeService(),
        ),
      );
      await insightService.syncNativeWalkingScreenRiskEvents();
    },
  );
  collector.start();
  ref.onDispose(() {
    revisionThrottle.dispose();
    collector.dispose();
  });
  return collector;
});

String _dayKey(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day';
}
