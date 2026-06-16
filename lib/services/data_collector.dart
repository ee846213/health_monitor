import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/step_count_state.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/ambient_light_capture_service.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/services/capture_health_service.dart';
import 'package:health_monitor/services/capture_stream_gap_policy.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/step_counter_service.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/capture_health_repository.dart';
import 'package:health_monitor/storage/repositories/ambient_light_sample_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';
import 'package:health_monitor/services/android_risk_event_bridge.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

typedef DataCollectorRevisionCallback = void Function();
typedef DataCollectorDayRevisionCallback = void Function(DateTime changedAt);

class SharedActivityRepository extends InMemoryActivityRepository {
  SharedActivityRepository() : super(samples: <ActivitySample>[]);

  void addSample(ActivitySample sample) {
    _buffer.add(sample);
  }

  final List<ActivitySample> _buffer = <ActivitySample>[];

  @override
  Future<List<ActivitySample>> listByWindow(QueryWindow window) async {
    final result =
        _buffer.where((sample) => window.contains(sample.capturedAt)).toList();
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
    final result =
        _buffer.where((sample) => window.contains(sample.capturedAt)).toList();
    result.sort((left, right) => left.capturedAt.compareTo(right.capturedAt));
    return result;
  }
}

class SharedAmbientLightRepository
    extends InMemoryAmbientLightSampleRepository {
  SharedAmbientLightRepository() : super(samples: <AmbientLightSample>[]);

  void addSample(AmbientLightSample sample) {
    _buffer.add(sample);
  }

  final List<AmbientLightSample> _buffer = <AmbientLightSample>[];

  @override
  Future<List<AmbientLightSample>> listByWindow(QueryWindow window) async {
    final result = _buffer
        .where(
            (AmbientLightSample sample) => window.contains(sample.capturedAt))
        .toList();
    result.sort(
      (AmbientLightSample left, AmbientLightSample right) =>
          left.capturedAt.compareTo(right.capturedAt),
    );
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

  final Map<String, LocationSummary> _dailySummaries =
      <String, LocationSummary>{};

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

  final Map<String, DigitalUsageSummary> _dailySummaries =
      <String, DigitalUsageSummary>{};

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

final sharedAmbientLightRepo =
    Provider<AmbientLightSampleRepository>((Ref ref) {
  return IsarAmbientLightSampleRepository(ref.watch(appIsarProvider.future));
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
final ambientLightSampleRepositoryProvider = sharedAmbientLightRepo;
final locationSummaryRepositoryProvider = sharedLocationRepo;
final noiseSampleRepositoryProvider = sharedNoiseRepo;
final usageSummaryRepositoryProvider = sharedUsageRepo;
final metricsRepositoryProvider = sharedMetricsRepo;

final dataCollectorRevisionProvider = StateProvider<int>((Ref ref) => 0);
final dataCollectorDailyRevisionProvider =
    StateProvider<Map<String, int>>((Ref ref) => <String, int>{});

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

class _DayRevisionThrottle {
  _DayRevisionThrottle({
    required this.onThrottledTick,
    this.interval = const Duration(seconds: 2),
  });

  final Duration interval;
  final void Function(DateTime changedAt) onThrottledTick;
  final Map<String, _RevisionThrottle> _throttles =
      <String, _RevisionThrottle>{};

  void markChanged(DateTime changedAt) {
    final dayStart = _dayStart(changedAt);
    final dayKey = _dayKey(dayStart);
    final throttle = _throttles.putIfAbsent(
      dayKey,
      () => _RevisionThrottle(
        interval: interval,
        onThrottledTick: () => onThrottledTick(dayStart),
      ),
    );
    throttle.markChanged();
  }

  void dispose() {
    for (final throttle in _throttles.values) {
      throttle.dispose();
    }
    _throttles.clear();
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
    AmbientLightSampleRepository? ambientLightRepository,
    required this.noiseRepository,
    required this.locationRepository,
    required this.usageRepository,
    required this.metricsRepository,
    MotionCaptureService? motionCaptureService,
    AmbientLightCaptureService? ambientLightCaptureService,
    StepCounterService? stepCounterService,
    NoiseCaptureService? noiseCaptureService,
    LocationCaptureService? locationCaptureService,
    DigitalUsageCaptureService? digitalUsageCaptureService,
    DigitalUsageCaptureService Function(DigitalUsageSummary? restoredSummary)?
        digitalUsageCaptureServiceFactory,
    AndroidUsageStatsBridge? androidUsageStatsBridge,
    CaptureHealthService? captureHealthService,
    DataCollectorRevisionCallback? onDataChanged,
    DataCollectorDayRevisionCallback? onDayChanged,
    Future<void> Function(DateTime referenceTime)? persistRuleReminders,
    Future<void> Function()? syncNativeRiskEvents,
  })  : _motionCaptureService = motionCaptureService ?? MotionCaptureService(),
        ambientLightRepository = ambientLightRepository ??
            InMemoryAmbientLightSampleRepository(
              samples: const <AmbientLightSample>[],
            ),
        _ambientLightCaptureService =
            ambientLightCaptureService ?? AmbientLightCaptureService(),
        _stepCounterService = stepCounterService ?? StepCounterService(),
        _noiseCaptureService = noiseCaptureService ?? NoiseCaptureService(),
        _locationCaptureService =
            locationCaptureService ?? LocationCaptureService(),
        _digitalUsageCaptureServiceFactory =
            digitalUsageCaptureServiceFactory ??
                ((DigitalUsageSummary? restoredSummary) {
                  if (digitalUsageCaptureService != null) {
                    return digitalUsageCaptureService;
                  }
                  return DigitalUsageCaptureService(
                    restoredSummary: restoredSummary,
                  );
                }),
        _androidUsageStatsBridge =
            androidUsageStatsBridge ?? AndroidUsageStatsBridge(),
        _captureHealthService = captureHealthService ??
            CaptureHealthService(
              repository: InMemoryCaptureHealthRepository(),
            ),
        _onDataChanged = onDataChanged,
        _onDayChanged = onDayChanged,
        _persistRuleReminders = persistRuleReminders,
        _syncNativeRiskEvents = syncNativeRiskEvents;

  final ActivityRepository activityRepository;
  final AmbientLightSampleRepository ambientLightRepository;
  final NoiseSampleRepository noiseRepository;
  final LocationSummaryRepository locationRepository;
  final UsageSummaryRepository usageRepository;
  final MetricsRepository metricsRepository;
  final MotionCaptureService _motionCaptureService;
  final AmbientLightCaptureService _ambientLightCaptureService;
  final StepCounterService _stepCounterService;
  final NoiseCaptureService _noiseCaptureService;
  final LocationCaptureService _locationCaptureService;
  final DigitalUsageCaptureService Function(
      DigitalUsageSummary? restoredSummary) _digitalUsageCaptureServiceFactory;
  final AndroidUsageStatsBridge _androidUsageStatsBridge;
  final CaptureHealthService _captureHealthService;
  final DataCollectorRevisionCallback? _onDataChanged;
  final DataCollectorDayRevisionCallback? _onDayChanged;
  final Future<void> Function(DateTime referenceTime)? _persistRuleReminders;
  final Future<void> Function()? _syncNativeRiskEvents;
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  bool _started = false;
  _DailyMetricsSignature? _lastDailyMetricsSignature;
  StepCountState? _latestStepCountState;
  StreamSubscription<DigitalUsageSummary>? _usageSummarySubscription;
  AndroidUsageCapabilityStatus? _latestUsageCapabilityStatus;
  final Map<String, DateTime> _lastSampleAtByStreamKey = <String, DateTime>{};
  final Set<String> _startedStreamKeys = <String>{};

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    _markStreamStarted(streamMotion);
    _markStreamStarted(streamSteps);
    _markStreamStarted(streamNoise);
    _markStreamStarted(streamLight);
    _markStreamStarted(streamLocation);
    _markStreamStarted(streamNativeRisk);
    unawaited(syncNativeRiskEvents());
    unawaited(syncUsageSummary());

    _subscriptions.add(
      _motionCaptureService.watchActivitySamples().listen(
        (ActivitySample sample) async {
          await _observeSample(streamMotion, sample.capturedAt);
          await activityRepository.saveAll(<ActivitySample>[sample]);
          await _refreshDailyMetrics(sample.capturedAt);
        },
        onError: (Object error, StackTrace stackTrace) {
          unawaited(
            _captureHealthService.recordStreamError(
              streamMotion,
              errorMessage: error.toString(),
              detail: '活动流采集失败。',
            ),
          );
        },
      ),
    );
    _subscriptions.add(
      _ambientLightCaptureService.watchAmbientLightSamples().listen(
        (AmbientLightSample sample) async {
          await _observeSample(streamLight, sample.capturedAt);
          await ambientLightRepository.saveAll(<AmbientLightSample>[sample]);
          await _refreshDailyMetrics(sample.capturedAt);
        },
        onError: (Object error, StackTrace stackTrace) {
          unawaited(
            _captureHealthService.recordStreamError(
              streamLight,
              errorMessage: error.toString(),
              detail: '光照流采集失败。',
            ),
          );
        },
      ),
    );
    _subscriptions.add(
      _stepCounterService.watchStepCounts().listen(
        (StepCountState state) async {
          if (!state.isAvailable) {
            return;
          }
          _latestStepCountState = state;
          await _observeSample(streamSteps, state.capturedAt);
          await _refreshDailyMetrics(state.capturedAt);
        },
        onError: (Object error, StackTrace stackTrace) {
          unawaited(
            _captureHealthService.recordStreamError(
              streamSteps,
              errorMessage: error.toString(),
              detail: '步数流采集失败。',
            ),
          );
        },
      ),
    );
    _subscriptions.add(
      _noiseCaptureService.watchNoiseSamples().listen(
        (NoiseSample sample) async {
          await _observeSample(streamNoise, sample.capturedAt);
          await noiseRepository.saveAll(<NoiseSample>[sample]);
          await _refreshDailyMetrics(sample.capturedAt);
        },
        onError: (Object error, StackTrace stackTrace) {
          unawaited(
            _captureHealthService.recordStreamError(
              streamNoise,
              errorMessage: error.toString(),
              detail: '噪音流采集失败。',
            ),
          );
        },
      ),
    );
    _subscriptions.add(
      _locationCaptureService.watchLocationSummaries().listen(
        (LocationSummary summary) async {
          await _observeSample(streamLocation, summary.date);
          await locationRepository.upsertSummary(summary);
          await _refreshDailyMetrics(summary.date);
        },
        onError: (Object error, StackTrace stackTrace) {
          unawaited(
            _captureHealthService.recordStreamError(
              streamLocation,
              errorMessage: error.toString(),
              detail: '位置流采集失败。',
            ),
          );
        },
      ),
    );
    unawaited(_ensureUsageCollectionInitialized());
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
    await _syncNativeRiskEvents.call();
    await _captureHealthService.recordNativeSummaryDrained(
      streamNativeRisk,
      detail: '原生风险事件已同步到本地仓储。',
    );
    _onDataChanged?.call();
  }

  Future<void> syncUsageSummary({
    DateTime? referenceTime,
  }) async {
    final now = referenceTime ?? DateTime.now();
    final capabilityStatus =
        await _androidUsageStatsBridge.getCapabilityStatus();
    _latestUsageCapabilityStatus = capabilityStatus;

    if (capabilityStatus.canReadUsageStats) {
      await _stopLifecycleUsageCollection();
      _markStreamStarted(streamDigitalUsageAndroid);

      final summaries = <DigitalUsageSummary>[
        ...await _androidUsageStatsBridge.drainPendingSummaries(),
      ];
      final dailySummary = await _androidUsageStatsBridge.readDailySummary(
        referenceTime: now,
      );
      if (dailySummary != null) {
        summaries.add(dailySummary);
      }
      if (summaries.isNotEmpty) {
        final dedupedSummaries = _dedupeUsageSummaries(summaries);
        await usageRepository.upsertAll(dedupedSummaries);
        await _captureHealthService.recordNativeSummaryDrained(
          streamDigitalUsageAndroid,
          detail: '已写入 ${dedupedSummaries.length} 条 Android 使用统计摘要。',
        );
        for (final summary in dedupedSummaries) {
          await _refreshDailyMetrics(summary.date);
        }
      } else {
        await _captureHealthService.recordGapDetected(
          streamDigitalUsageAndroid,
          gap: captureGapThresholdFor(streamDigitalUsageAndroid),
          detail: 'Android 使用统计暂未返回可写入摘要。',
        );
        _onDataChanged?.call();
      }
      return;
    }

    _markStreamStarted(streamDigitalUsageAlternative);
    await _ensureLifecycleUsageCollectionInitialized(referenceTime: now);
    final restoredSummary = await usageRepository.getByDate(_dayStart(now));
    if (restoredSummary != null &&
        restoredSummary.source == DigitalUsageSource.lifecycleAlternative) {
      final normalizedSummary = _normalizeLifecycleSummary(restoredSummary);
      if (normalizedSummary.completeness != restoredSummary.completeness) {
        await usageRepository.upsertSummary(normalizedSummary);
        await _captureHealthService.recordStateRebuilt(
          streamDigitalUsageAlternative,
          detail: '已基于本地替代指标重建数字生活摘要。',
        );
        await _refreshDailyMetrics(normalizedSummary.date);
      }
    }
  }

  Future<void> _ensureUsageCollectionInitialized({
    DateTime? referenceTime,
  }) async {
    final capabilityStatus = _latestUsageCapabilityStatus ??
        await _androidUsageStatsBridge.getCapabilityStatus();
    _latestUsageCapabilityStatus = capabilityStatus;

    if (capabilityStatus.canReadUsageStats) {
      await _stopLifecycleUsageCollection();
      return;
    }

    await _ensureLifecycleUsageCollectionInitialized(
        referenceTime: referenceTime);
  }

  Future<void> _ensureLifecycleUsageCollectionInitialized({
    DateTime? referenceTime,
  }) async {
    if (_usageSummarySubscription != null) {
      return;
    }

    final restoredSummary = await _resolveLifecycleRestoredSummary(
      referenceTime ?? DateTime.now(),
    );
    final digitalUsageCaptureService = _digitalUsageCaptureServiceFactory(
      restoredSummary,
    );
    final subscription =
        digitalUsageCaptureService.watchUsageSummaries().listen(
      (DigitalUsageSummary summary) async {
        await _observeSample(streamDigitalUsageAlternative, summary.date);
        final normalizedSummary = _normalizeLifecycleSummary(summary);
        await usageRepository.upsertSummary(normalizedSummary);
        await _refreshDailyMetrics(normalizedSummary.date);
      },
      onError: (Object error, StackTrace stackTrace) {
        unawaited(
          _captureHealthService.recordStreamError(
            streamDigitalUsageAlternative,
            errorMessage: error.toString(),
            detail: '数字生活替代流采集失败。',
          ),
        );
      },
    );
    _usageSummarySubscription = subscription;
    _subscriptions.add(subscription);
  }

  Future<void> _stopLifecycleUsageCollection() async {
    final subscription = _usageSummarySubscription;
    if (subscription == null) {
      return;
    }
    _usageSummarySubscription = null;
    _subscriptions.remove(subscription);
    await subscription.cancel();
  }

  Future<DigitalUsageSummary?> _resolveLifecycleRestoredSummary(
    DateTime referenceTime,
  ) async {
    final existing = await usageRepository.getByDate(_dayStart(referenceTime));
    if (existing == null ||
        existing.source == DigitalUsageSource.androidUsageStats) {
      return null;
    }
    return _normalizeLifecycleSummary(existing);
  }

  DigitalUsageSummary _normalizeLifecycleSummary(DigitalUsageSummary summary) {
    final completeness = _latestUsageCapabilityStatus?.isSupported == true &&
            _latestUsageCapabilityStatus?.hasUsageAccess == false
        ? UsageDataCompleteness.degraded
        : summary.completeness;
    return DigitalUsageSummary(
      date: summary.date,
      screenOnDuration: summary.screenOnDuration,
      unlockCount: summary.unlockCount,
      viewCount: summary.viewCount,
      nighttimeUsageDuration: summary.nighttimeUsageDuration,
      focusSessionBreakCount: summary.focusSessionBreakCount,
      longestContinuousUsageDuration: summary.longestContinuousUsageDuration,
      topCategory: summary.topCategory,
      source: DigitalUsageSource.lifecycleAlternative,
      completeness: completeness,
    );
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
        .where(
            (ActivitySample sample) => sample.type == ActivityType.stationary)
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
    await _captureHealthService.recordStateRebuilt(
      'daily_metrics',
      detail: '已重建当日汇总指标。',
    );
    if (_persistRuleReminders != null) {
      await _persistRuleReminders.call(referenceTime);
    }
    _onDayChanged?.call(dayStart);
    _onDataChanged?.call();
  }

  void _markStreamStarted(String streamKey) {
    if (_startedStreamKeys.add(streamKey)) {
      unawaited(_captureHealthService.recordStreamStarted(streamKey));
    }
  }

  Future<void> _observeSample(String streamKey, DateTime capturedAt) async {
    final previous = _lastSampleAtByStreamKey[streamKey];
    if (previous == null) {
      await _captureHealthService.recordFirstSampleReceived(
        streamKey,
        occurredAt: capturedAt,
      );
      _lastSampleAtByStreamKey[streamKey] = capturedAt;
      return;
    }

    final gap = capturedAt.difference(previous);
    final threshold = captureGapThresholdFor(streamKey);
    if (gap > threshold) {
      await _captureHealthService.recordGapDetected(
        streamKey,
        gap: gap,
        detail:
            '${_streamLabel(streamKey)} 与上次样本间隔 ${_formatGap(gap)}，超过预期 ${_formatGap(threshold)}。',
        occurredAt: capturedAt,
      );
      await _captureHealthService.recordStreamRecovered(
        streamKey,
        occurredAt: capturedAt,
      );
    }
    _lastSampleAtByStreamKey[streamKey] = capturedAt;
  }

  String _streamLabel(String streamKey) {
    switch (streamKey) {
      case streamMotion:
        return '活动流';
      case streamSteps:
        return '步数流';
      case streamNoise:
        return '噪音流';
      case streamLight:
        return '光照流';
      case streamLocation:
        return '定位流';
      case streamDigitalUsageAndroid:
        return 'Android 使用统计';
      case streamDigitalUsageAlternative:
        return '替代数字生活流';
      case streamNativeRisk:
        return '原生风险流';
      default:
        return streamKey;
    }
  }

  String _formatGap(Duration duration) {
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
}

final dataCollectorProvider = Provider<DataCollector>((Ref ref) {
  final revisionThrottle = _RevisionThrottle(
    interval: const Duration(seconds: 2),
    onThrottledTick: () {
      ref.read(dataCollectorRevisionProvider.notifier).state += 1;
    },
  );
  final dayRevisionThrottle = _DayRevisionThrottle(
    interval: const Duration(seconds: 2),
    onThrottledTick: (DateTime changedAt) {
      final dayKey = _dayKey(changedAt);
      final notifier = ref.read(dataCollectorDailyRevisionProvider.notifier);
      final current = notifier.state;
      notifier.state = <String, int>{
        ...current,
        dayKey: (current[dayKey] ?? 0) + 1,
      };
    },
  );
  final collector = DataCollector(
    activityRepository: ref.watch(sharedActivityRepo),
    ambientLightRepository: ref.watch(sharedAmbientLightRepo),
    noiseRepository: ref.watch(sharedNoiseRepo),
    locationRepository: ref.watch(sharedLocationRepo),
    usageRepository: ref.watch(sharedUsageRepo),
    metricsRepository: ref.watch(sharedMetricsRepo),
    androidUsageStatsBridge: AndroidUsageStatsBridge(
      platformBridgeService: PlatformBridgeService(),
    ),
    captureHealthService: ref.watch(captureHealthServiceProvider),
    onDataChanged: revisionThrottle.markChanged,
    onDayChanged: dayRevisionThrottle.markChanged,
    persistRuleReminders: (DateTime referenceTime) async {
      final insightService = HealthInsightService(
        activityRepository: ref.read(sharedActivityRepo),
        ambientLightRepository: ref.read(sharedAmbientLightRepo),
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
        androidUsageStatsBridge: AndroidUsageStatsBridge(
          platformBridgeService: PlatformBridgeService(),
        ),
      );
      await insightService.persistRuleReminders(referenceTime: referenceTime);
    },
    syncNativeRiskEvents: () async {
      final insightService = HealthInsightService(
        activityRepository: ref.read(sharedActivityRepo),
        ambientLightRepository: ref.read(sharedAmbientLightRepo),
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
        androidUsageStatsBridge: AndroidUsageStatsBridge(
          platformBridgeService: PlatformBridgeService(),
        ),
      );
      await insightService.syncNativeWalkingScreenRiskEvents();
    },
  );
  collector.start();
  ref.onDispose(() {
    revisionThrottle.dispose();
    dayRevisionThrottle.dispose();
    collector.dispose();
  });
  return collector;
});

String _dayKey(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day';
}

DateTime _dayStart(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

List<DigitalUsageSummary> _dedupeUsageSummaries(
  List<DigitalUsageSummary> summaries,
) {
  final keyedSummaries = <String, DigitalUsageSummary>{};
  for (final summary in summaries) {
    keyedSummaries[_dayKey(summary.date)] = summary;
  }
  return keyedSummaries.values.toList(growable: false);
}
