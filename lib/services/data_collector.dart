import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/step_count_state.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/ambient_light_capture_service.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/services/capture_health_service.dart';
import 'package:health_monitor/services/capture_stream_gap_policy.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/services/local_notification_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/services/reminder_delivery_service.dart';
import 'package:health_monitor/services/step_counter_service.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/capture_health_repository.dart';
import 'package:health_monitor/storage/repositories/ambient_light_sample_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/notification_preference_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/android_risk_event_bridge.dart';
import 'package:health_monitor/services/android_step_delta_bridge.dart';
import 'package:health_monitor/services/background_step_delta_sync_service.dart';
import 'package:health_monitor/services/health_connect_bridge.dart';
import 'package:health_monitor/services/health_connect_step_sync_service.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/storage/repositories/reminder_preferences_repository.dart';

typedef DataCollectorRevisionCallback = void Function();
typedef DataCollectorDayRevisionCallback = void Function(DateTime changedAt);
typedef SyncHealthConnectStepsForDay = Future<HealthConnectStepSyncResult>
    Function(DateTime referenceTime);
typedef SyncBackgroundStepDeltas = Future<int> Function();

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

  @override
  Future<int> deleteBefore(DateTime cutoff) async {
    final before = _buffer.length;
    _buffer.removeWhere((sample) => sample.capturedAt.isBefore(cutoff));
    return before - _buffer.length;
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

  @override
  Future<int> deleteBefore(DateTime cutoff) async {
    final before = _buffer.length;
    _buffer.removeWhere((sample) => sample.capturedAt.isBefore(cutoff));
    return before - _buffer.length;
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

  @override
  Future<int> deleteBefore(DateTime cutoff) async {
    final before = _buffer.length;
    _buffer.removeWhere((sample) => sample.capturedAt.isBefore(cutoff));
    return before - _buffer.length;
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

  @override
  Future<List<DigitalUsageSummary>> listByWindow(QueryWindow window) async {
    final summaries = _dailySummaries.values
        .where((summary) => window.contains(summary.date))
        .toList(growable: false);
    summaries.sort((left, right) => left.date.compareTo(right.date));
    return summaries;
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
  Future<DailyMetrics?> getByDate(DateTime date) async {
    return _dailyMetrics[_dayKey(date)];
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
final dataCollectorMetricsRevisionProvider = StateProvider<int>((Ref ref) => 0);
final dataCollectorEnvironmentRevisionProvider =
    StateProvider<int>((Ref ref) => 0);
final dataCollectorUsageRevisionProvider = StateProvider<int>((Ref ref) => 0);
final dataCollectorReminderRevisionProvider =
    StateProvider<int>((Ref ref) => 0);
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

class DataCollectorPerformanceStats {
  const DataCollectorPerformanceStats({
    required this.bufferedSamples,
    required this.droppedSamples,
    required this.completedFlushes,
    required this.flushRunning,
  });

  final int bufferedSamples;
  final int droppedSamples;
  final int completedFlushes;
  final bool flushRunning;
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
    DataCollectorRevisionCallback? onMetricsChanged,
    DataCollectorRevisionCallback? onEnvironmentChanged,
    DataCollectorRevisionCallback? onUsageChanged,
    DataCollectorRevisionCallback? onRemindersChanged,
    Future<void> Function(DateTime referenceTime)? persistRuleReminders,
    Future<void> Function(DateTime referenceTime)? deliverRuleReminders,
    Future<int> Function()? syncNativeRiskEvents,
    SyncHealthConnectStepsForDay? syncHealthConnectStepsForDay,
    SyncBackgroundStepDeltas? syncBackgroundStepDeltas,
    int healthConnectBackfillDays = _maxHealthConnectBackfillDays,
    Duration dailyMetricsRefreshInterval = const Duration(seconds: 30),
    int maxBufferedSamplesPerStream = 120,
    Duration rawSampleRetention = const Duration(days: 9),
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
        _onMetricsChanged = onMetricsChanged,
        _onEnvironmentChanged = onEnvironmentChanged,
        _onUsageChanged = onUsageChanged,
        _onRemindersChanged = onRemindersChanged,
        _persistRuleReminders = persistRuleReminders,
        _deliverRuleReminders = deliverRuleReminders,
        _syncNativeRiskEvents = syncNativeRiskEvents,
        _syncHealthConnectStepsForDay = syncHealthConnectStepsForDay ??
            ((DateTime syncReferenceTime) {
              final platformBridge = PlatformBridgeService();
              return HealthConnectStepSyncService(
                bridge: HealthConnectBridge(
                  platformBridgeService: platformBridge,
                ),
                activityRepository: activityRepository,
                metricsRepository: metricsRepository,
              ).syncForDay(referenceTime: syncReferenceTime);
            }),
        _syncBackgroundStepDeltas = syncBackgroundStepDeltas ??
            (() {
              final platformBridge = PlatformBridgeService();
              return BackgroundStepDeltaSyncService(
                bridge: AndroidStepDeltaBridge(
                  platformBridgeService: platformBridge,
                ),
                activityRepository: activityRepository,
                metricsRepository: metricsRepository,
              ).syncDrainedEvents();
            }),
        _healthConnectBackfillDays =
            _clampHealthConnectBackfillDays(healthConnectBackfillDays),
        _batchFlushInterval = dailyMetricsRefreshInterval,
        _maxBufferedSamplesPerStream = maxBufferedSamplesPerStream,
        _rawSampleRetention = rawSampleRetention;

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
  final DataCollectorRevisionCallback? _onMetricsChanged;
  final DataCollectorRevisionCallback? _onEnvironmentChanged;
  final DataCollectorRevisionCallback? _onUsageChanged;
  final DataCollectorRevisionCallback? _onRemindersChanged;
  final Future<void> Function(DateTime referenceTime)? _persistRuleReminders;
  final Future<void> Function(DateTime referenceTime)? _deliverRuleReminders;
  final Future<int> Function()? _syncNativeRiskEvents;
  final SyncHealthConnectStepsForDay _syncHealthConnectStepsForDay;
  final SyncBackgroundStepDeltas _syncBackgroundStepDeltas;
  final int _healthConnectBackfillDays;
  final Duration _batchFlushInterval;
  final int _maxBufferedSamplesPerStream;
  final Duration _rawSampleRetention;
  final List<StreamSubscription<dynamic>> _captureSubscriptions =
      <StreamSubscription<dynamic>>[];
  final List<ActivitySample> _activityBuffer = <ActivitySample>[];
  final List<NoiseSample> _noiseBuffer = <NoiseSample>[];
  final List<AmbientLightSample> _lightBuffer = <AmbientLightSample>[];
  final Map<String, LocationSummary> _locationBuffer =
      <String, LocationSummary>{};
  bool _started = false;
  bool _foregroundCaptureActive = false;
  _DailyMetricsSignature? _lastDailyMetricsSignature;
  StepCountState? _latestStepCountState;
  StreamSubscription<DigitalUsageSummary>? _usageSummarySubscription;
  AndroidUsageCapabilityStatus? _latestUsageCapabilityStatus;
  Future<void>? _usageSummarySyncFuture;
  Future<void>? _riskEventSyncFuture;
  Future<void>? _stepCountSyncFuture;
  final Map<String, DateTime> _lastSampleAtByStreamKey = <String, DateTime>{};
  final Set<String> _startedStreamKeys = <String>{};
  Timer? _batchFlushTimer;
  Timer? _reminderDeliveryTimer;
  static const Duration _reminderDeliveryRetryInterval = Duration(minutes: 5);
  Future<void> _flushSerial = Future<void>.value();
  bool _flushRunning = false;
  int _droppedSamples = 0;
  int _completedFlushes = 0;
  bool _overflowReported = false;
  String? _lastCleanupDateKey;
  DateTime? _lastReminderEvaluationAt;
  final Map<String, String> _lastLocationSignatureByDay = <String, String>{};

  DataCollectorPerformanceStats get performanceStats {
    return DataCollectorPerformanceStats(
      bufferedSamples:
          _activityBuffer.length + _noiseBuffer.length + _lightBuffer.length,
      droppedSamples: _droppedSamples,
      completedFlushes: _completedFlushes,
      flushRunning: _flushRunning,
    );
  }

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
    unawaited(_rebuildRecentDailyMetrics(DateTime.now()));
    unawaited(_runRetentionCleanupIfNeeded(DateTime.now()));
    _startReminderDeliveryRetryTimer();
    resumeForegroundCapture();
    unawaited(_ensureUsageCollectionInitialized());
  }

  void resumeForegroundCapture() {
    if (!_started || _foregroundCaptureActive) {
      return;
    }
    _foregroundCaptureActive = true;
    _captureSubscriptions.add(
      _motionCaptureService.watchActivitySamples().listen(
        (ActivitySample sample) {
          _addBounded(_activityBuffer, sample, streamMotion);
          _scheduleBatchFlush();
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
    _captureSubscriptions.add(
      _ambientLightCaptureService.watchAmbientLightSamples().listen(
        (AmbientLightSample sample) {
          _addBounded(_lightBuffer, sample, streamLight);
          _scheduleBatchFlush();
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
    _captureSubscriptions.add(
      _stepCounterService.watchStepCounts().listen(
        (StepCountState state) {
          if (!state.isAvailable) {
            return;
          }
          _latestStepCountState = state;
          _scheduleBatchFlush();
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
    _captureSubscriptions.add(
      _noiseCaptureService.watchNoiseSamples().listen(
        (NoiseSample sample) {
          _addBounded(_noiseBuffer, sample, streamNoise);
          _scheduleBatchFlush();
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
    _captureSubscriptions.add(
      _locationCaptureService.watchLocationSummaries().listen(
        (LocationSummary summary) {
          _locationBuffer[_dayKey(summary.date)] = summary;
          _scheduleBatchFlush();
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
  }

  Future<void> pauseForegroundCapture() async {
    if (!_foregroundCaptureActive) {
      return;
    }
    _foregroundCaptureActive = false;
    _batchFlushTimer?.cancel();
    _batchFlushTimer = null;
    final subscriptions = List<StreamSubscription<dynamic>>.from(
      _captureSubscriptions,
    );
    _captureSubscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await flushPendingSamples();
  }

  Future<void> dispose() async {
    _started = false;
    _reminderDeliveryTimer?.cancel();
    _reminderDeliveryTimer = null;
    await pauseForegroundCapture();
    await _stopLifecycleUsageCollection();
    await _flushSerial;
  }

  void _addBounded<T>(List<T> buffer, T sample, String streamKey) {
    if (buffer.length >= _maxBufferedSamplesPerStream) {
      buffer.removeAt(0);
      _droppedSamples += 1;
      if (!_overflowReported) {
        _overflowReported = true;
        unawaited(
          _captureHealthService.recordStateRebuilt(
            'capture_buffer',
            detail: '$streamKey 缓冲区达到上限，已合并为最新样本以避免任务堆积。',
          ),
        );
      }
    }
    buffer.add(sample);
  }

  void _scheduleBatchFlush() {
    if (_batchFlushTimer != null) {
      return;
    }
    _batchFlushTimer = Timer(
      _batchFlushInterval,
      () {
        _batchFlushTimer = null;
        unawaited(
          flushPendingSamples().catchError((Object _, StackTrace __) {}),
        );
      },
    );
  }

  Future<void> flushPendingSamples() {
    _flushSerial = _flushSerial
        .catchError((Object _, StackTrace __) {})
        .then((_) => _flushPendingSamplesOnce());
    return _flushSerial;
  }

  Future<void> _flushPendingSamplesOnce() async {
    if (_flushRunning) {
      return;
    }
    final activities = List<ActivitySample>.from(_activityBuffer);
    final noises = List<NoiseSample>.from(_noiseBuffer);
    final lights = List<AmbientLightSample>.from(_lightBuffer);
    final locations = List<LocationSummary>.from(_locationBuffer.values);
    _activityBuffer.clear();
    _noiseBuffer.clear();
    _lightBuffer.clear();
    _locationBuffer.clear();
    final stepState = _latestStepCountState;

    if (activities.isEmpty &&
        noises.isEmpty &&
        lights.isEmpty &&
        locations.isEmpty &&
        stepState == null) {
      return;
    }

    _flushRunning = true;
    try {
      await Future.wait<void>(<Future<void>>[
        activityRepository.saveAll(activities),
        noiseRepository.saveAll(noises),
        ambientLightRepository.saveAll(lights),
        _saveLocations(locations),
      ]);
      final locationsChanged = _locationsChanged(locations);
      if (activities.isNotEmpty) {
        await _observeSample(streamMotion, activities.last.capturedAt);
      }
      if (noises.isNotEmpty) {
        await _observeSample(streamNoise, noises.last.capturedAt);
      }
      if (lights.isNotEmpty) {
        await _observeSample(streamLight, lights.last.capturedAt);
      }
      if (locations.isNotEmpty) {
        await _observeSample(streamLocation, locations.last.date);
      }
      if (stepState?.isAvailable == true) {
        await _observeSample(streamSteps, stepState!.capturedAt);
      }

      final metricsChanged = await _applyMetricsDelta(
        activities: activities,
        noises: noises,
        locations: locations,
        stepState: stepState,
      );
      if (activities.isNotEmpty && !metricsChanged) {
        _onMetricsChanged?.call();
      }
      if (lights.isNotEmpty || noises.isNotEmpty) {
        _onEnvironmentChanged?.call();
      }
      if (activities.isNotEmpty ||
          noises.isNotEmpty ||
          lights.isNotEmpty ||
          locationsChanged ||
          metricsChanged) {
        _onDataChanged?.call();
      }
      _completedFlushes += 1;
      _overflowReported = false;
      await _runRetentionCleanupIfNeeded(DateTime.now());
    } catch (error, stackTrace) {
      _restoreFailedBatch(
        activities: activities,
        noises: noises,
        lights: lights,
        locations: locations,
      );
      await _captureHealthService.recordStreamError(
        'batch_flush',
        errorMessage: error.toString(),
        detail: '批量写入失败，已保留待重试样本。',
      );
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      _flushRunning = false;
      if (_started &&
          (_activityBuffer.isNotEmpty ||
              _noiseBuffer.isNotEmpty ||
              _lightBuffer.isNotEmpty ||
              _locationBuffer.isNotEmpty)) {
        _scheduleBatchFlush();
      }
    }
  }

  Future<void> _saveLocations(List<LocationSummary> locations) async {
    for (final summary in locations) {
      await locationRepository.upsertSummary(summary);
    }
  }

  bool _locationsChanged(List<LocationSummary> locations) {
    var changed = false;
    for (final summary in locations) {
      final key = _dayKey(summary.date);
      final signature = [
        summary.distanceMeters.toStringAsFixed(1),
        summary.outdoorDuration.inSeconds,
        summary.visitCount,
        summary.commuteCount,
      ].join('|');
      if (_lastLocationSignatureByDay[key] != signature) {
        _lastLocationSignatureByDay[key] = signature;
        changed = true;
      }
    }
    return changed;
  }

  void _restoreFailedBatch({
    required List<ActivitySample> activities,
    required List<NoiseSample> noises,
    required List<AmbientLightSample> lights,
    required List<LocationSummary> locations,
  }) {
    for (final sample in activities.reversed) {
      if (_activityBuffer.length < _maxBufferedSamplesPerStream) {
        _activityBuffer.insert(0, sample);
      }
    }
    for (final sample in noises.reversed) {
      if (_noiseBuffer.length < _maxBufferedSamplesPerStream) {
        _noiseBuffer.insert(0, sample);
      }
    }
    for (final sample in lights.reversed) {
      if (_lightBuffer.length < _maxBufferedSamplesPerStream) {
        _lightBuffer.insert(0, sample);
      }
    }
    for (final summary in locations) {
      _locationBuffer.putIfAbsent(_dayKey(summary.date), () => summary);
    }
  }

  Future<bool> _applyMetricsDelta({
    required List<ActivitySample> activities,
    required List<NoiseSample> noises,
    required List<LocationSummary> locations,
    required StepCountState? stepState,
  }) async {
    final dayKeys = <String>{
      ...activities.map((sample) => _dayKey(sample.capturedAt)),
      ...noises.map((sample) => _dayKey(sample.capturedAt)),
      ...locations.map((summary) => _dayKey(summary.date)),
      if (stepState?.isAvailable == true) _dayKey(stepState!.capturedAt),
    };
    var changed = false;
    for (final dayKey in dayKeys) {
      final referenceTime = _dateFromDayKey(dayKey);
      changed = await _rebuildDailyMetrics(referenceTime) || changed;
    }
    return changed;
  }

  Future<void> _runRetentionCleanupIfNeeded(DateTime now) async {
    final todayKey = _dayKey(now);
    if (_lastCleanupDateKey == todayKey) {
      return;
    }
    final cutoff = _dayStart(now).subtract(_rawSampleRetention);
    await Future.wait<int>(<Future<int>>[
      activityRepository.deleteBefore(cutoff),
      noiseRepository.deleteBefore(cutoff),
      ambientLightRepository.deleteBefore(cutoff),
    ]);
    _lastCleanupDateKey = todayKey;
  }

  Future<void> syncNativeRiskEvents() {
    final runningSync = _riskEventSyncFuture;
    if (runningSync != null) {
      return runningSync;
    }
    final syncFuture = _syncNativeRiskEventsOnce();
    _riskEventSyncFuture = syncFuture;
    return syncFuture.whenComplete(() {
      if (identical(_riskEventSyncFuture, syncFuture)) {
        _riskEventSyncFuture = null;
      }
    });
  }

  Future<void> _syncNativeRiskEventsOnce() async {
    if (_syncNativeRiskEvents == null) {
      return;
    }
    final syncedCount = await _syncNativeRiskEvents.call();
    if (syncedCount == 0) {
      return;
    }
    await _captureHealthService.recordNativeSummaryDrained(
      streamNativeRisk,
      detail: '原生风险事件已同步到本地仓储。',
    );
    if (_deliverRuleReminders != null) {
      await _deliverRuleReminders.call(DateTime.now());
    }
    _onRemindersChanged?.call();
    _onDataChanged?.call();
  }

  Future<void> syncNativeStepCount({DateTime? referenceTime}) {
    final runningSync = _stepCountSyncFuture;
    if (runningSync != null) {
      return runningSync;
    }
    final syncFuture = _syncNativeStepCountOnce(referenceTime: referenceTime);
    _stepCountSyncFuture = syncFuture;
    return syncFuture.whenComplete(() {
      if (identical(_stepCountSyncFuture, syncFuture)) {
        _stepCountSyncFuture = null;
      }
    });
  }

  Future<void> _syncNativeStepCountOnce({DateTime? referenceTime}) async {
    final now = referenceTime ?? DateTime.now();
    var syncedHistoricalSteps = false;
    var healthConnectReadDayCount = 0;
    var healthConnectSyncedDayCount = 0;

    final syncReferenceTimes = await _nativeStepSyncReferenceTimes(now);
    for (final syncReferenceTime in syncReferenceTimes) {
      final result = await _syncHealthConnectStepsForDay(syncReferenceTime);
      if (result.outcome == HealthConnectStepSyncOutcome.unavailable ||
          result.outcome == HealthConnectStepSyncOutcome.permissionDenied) {
        break;
      }
      if (result.outcome == HealthConnectStepSyncOutcome.synced ||
          result.outcome == HealthConnectStepSyncOutcome.empty) {
        healthConnectReadDayCount += 1;
      }
      if (!result.didSync) {
        continue;
      }
      healthConnectSyncedDayCount += 1;
      if (_dayKey(syncReferenceTime) == _dayKey(now)) {
        continue;
      }
      // 跨日或多日后打开应用时，Health Connect 小时桶需要回填到历史日指标。
      // 历史日重建不触发提醒投递，避免把过去几天的规则提醒当作当前提醒发出。
      await _rebuildDailyMetrics(
        syncReferenceTime,
        evaluateReminders: false,
      );
      syncedHistoricalSteps = true;
    }

    final drainedCount = await _syncBackgroundStepDeltas();

    final stepState = await _stepCounterService.readCurrent();
    if (stepState.isAvailable) {
      _latestStepCountState = stepState;
      await _observeSample(streamSteps, stepState.capturedAt);
    }

    final signatureBefore = _lastDailyMetricsSignature;
    await _rebuildDailyMetrics(now);
    final metricsChanged = _lastDailyMetricsSignature != signatureBefore;

    if (healthConnectReadDayCount > 0) {
      await _captureHealthService.recordNativeSummaryDrained(
        streamHealthConnectSteps,
        detail: 'Health Connect 步数回补已检查 $healthConnectReadDayCount 天，'
            '其中 $healthConnectSyncedDayCount 天写入小时步数桶。',
      );
    }

    if (drainedCount > 0 ||
        syncedHistoricalSteps ||
        healthConnectReadDayCount > 0 ||
        stepState.isAvailable ||
        metricsChanged) {
      if (drainedCount > 0) {
        await _captureHealthService.recordNativeSummaryDrained(
          streamSteps,
          detail: '后台步数增量已同步到本地仓储。',
        );
      }
      _onDataChanged?.call();
      if (metricsChanged || syncedHistoricalSteps) {
        _onMetricsChanged?.call();
      }
    }
  }

  Future<List<DateTime>> _nativeStepSyncReferenceTimes(
    DateTime referenceTime,
  ) async {
    // Health Connect 的步数来源可能在用户授权后才开始同步，或由系统/健康 App 延迟写入。
    // 因此 checkpoint 只能作为健康事件记录，不能用来截断历史窗口；否则一次空读就会让
    // 昨天/前几天永远不再回补。这里固定滚动检查最近 30 天以内的窗口。
    return _buildNativeStepSyncReferenceTimes(
      referenceTime,
      lastSyncedAt: null,
      maxBackfillDays: _healthConnectBackfillDays,
    );
  }

  void _startReminderDeliveryRetryTimer() {
    if (_deliverRuleReminders == null || _reminderDeliveryTimer != null) {
      return;
    }
    _reminderDeliveryTimer = Timer.periodic(
      _reminderDeliveryRetryInterval,
      (_) {
        unawaited(
          _attemptDeliverRuleReminders(DateTime.now()).catchError(
            (Object _, StackTrace __) {},
          ),
        );
      },
    );
  }

  Future<void> _attemptDeliverRuleReminders(DateTime referenceTime) async {
    if (_deliverRuleReminders == null) {
      return;
    }
    await _deliverRuleReminders.call(referenceTime);
  }

  Future<void> syncUsageSummary({
    DateTime? referenceTime,
  }) {
    final runningSync = _usageSummarySyncFuture;
    if (runningSync != null) {
      return runningSync;
    }

    final syncFuture = _syncUsageSummary(referenceTime: referenceTime);
    _usageSummarySyncFuture = syncFuture;
    return syncFuture.whenComplete(() {
      if (identical(_usageSummarySyncFuture, syncFuture)) {
        _usageSummarySyncFuture = null;
      }
    });
  }

  Future<void> _syncUsageSummary({
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
        await _upsertUsageSummariesPreservingProgress(dedupedSummaries);
        await _captureHealthService.recordNativeSummaryDrained(
          streamDigitalUsageAndroid,
          detail: '已写入 ${dedupedSummaries.length} 条 Android 使用统计摘要。',
        );
        for (final summary in dedupedSummaries) {
          await _updateMetricsFromUsage(summary);
        }
        _onUsageChanged?.call();
        _onDataChanged?.call();
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
        await _updateMetricsFromUsage(normalizedSummary);
        _onUsageChanged?.call();
        _onDataChanged?.call();
      }
    }
  }

  Future<void> _upsertUsageSummariesPreservingProgress(
    List<DigitalUsageSummary> summaries,
  ) async {
    await usageRepository.upsertAll(summaries);
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
        await _updateMetricsFromUsage(normalizedSummary);
        _onUsageChanged?.call();
        _onDataChanged?.call();
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
  }

  Future<void> _stopLifecycleUsageCollection() async {
    final subscription = _usageSummarySubscription;
    if (subscription == null) {
      return;
    }
    _usageSummarySubscription = null;
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

  Future<void> _updateMetricsFromUsage(DigitalUsageSummary summary) async {
    final dayStart = _dayStart(summary.date);
    final existing = await metricsRepository.getByDate(dayStart) ??
        DailyMetrics(
          date: dayStart,
          stepCount: 0,
          sedentaryDuration: Duration.zero,
          screenOnDuration: Duration.zero,
          outdoorDuration: Duration.zero,
          postureRiskCount: 0,
          highNoiseExposureDuration: Duration.zero,
        );
    final next = DailyMetrics(
      date: dayStart,
      stepCount: existing.stepCount,
      sedentaryDuration: existing.sedentaryDuration,
      screenOnDuration: summary.screenOnDuration,
      outdoorDuration: existing.outdoorDuration,
      postureRiskCount: existing.postureRiskCount,
      highNoiseExposureDuration: existing.highNoiseExposureDuration,
    );
    await metricsRepository.upsertMetrics(next);
    await _publishMetricsChanged(next, dayStart);
  }

  Future<void> _rebuildRecentDailyMetrics(DateTime referenceTime) async {
    final days =
        _rawSampleRetention.inDays < 1 ? 1 : _rawSampleRetention.inDays;
    for (var offset = days - 1; offset >= 0; offset -= 1) {
      await _rebuildDailyMetrics(
        _dayStart(referenceTime).subtract(Duration(days: offset)),
        evaluateReminders: false,
      );
    }
  }

  Future<bool> _rebuildDailyMetrics(
    DateTime referenceTime, {
    bool evaluateReminders = true,
  }) async {
    final dayStart = DateTime(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
    );
    final activitiesFuture = activityRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: dayStart),
    );
    final noisesFuture = noiseRepository.listByWindow(
      QueryWindow.calendarDay(referenceDate: dayStart),
    );
    final locationFuture = locationRepository.listRecentDays(
      1,
      referenceDate: dayStart,
    );
    final usageFuture = usageRepository.getByDate(dayStart);
    final existingFuture = metricsRepository.getByDate(dayStart);
    final dayActivities = await activitiesFuture;
    final dayNoises = await noisesFuture;
    final locationSummary = await locationFuture;
    final usageSummary = await usageFuture;
    final existingMetrics = await existingFuture;

    final activityStepCount = dayActivities.fold<int>(
      0,
      (int total, ActivitySample sample) => total + sample.stepCount,
    );
    final latestStepState = _latestStepCountState;
    final liveStepCount = latestStepState?.isAvailable == true &&
            _dayKey(latestStepState!.capturedAt) == _dayKey(dayStart)
        ? latestStepState.stepCount
        : 0;
    final persistedStepCount = existingMetrics?.stepCount ?? 0;
    if (existingMetrics == null &&
        dayActivities.isEmpty &&
        dayNoises.isEmpty &&
        locationSummary.isEmpty &&
        usageSummary == null &&
        liveStepCount == 0) {
      return false;
    }
    final window = QueryWindow.calendarDay(referenceDate: dayStart);
    final sedentarySummary = dayActivities.isEmpty
        ? null
        : summarizeSedentaryForWindow(
            activitySamples: dayActivities,
            window: window,
          );
    // 当日步数是累计值。其他传感器先于计步流刷新时，不能用活动样本中的占位 0
    // 覆盖已经落库的系统步数；系统计步短暂回退时也保留当天已确认的最大值。
    final stepCount = <int>[
      persistedStepCount,
      activityStepCount,
      liveStepCount,
    ].reduce((int left, int right) => left > right ? left : right);
    final highNoiseExposureDuration = dayNoises
        .where((NoiseSample sample) => sample.level == NoiseLevel.loud)
        .fold<Duration>(
          Duration.zero,
          (Duration total, NoiseSample sample) => total + sample.duration,
        );

    final nextMetrics = DailyMetrics(
      date: dayStart,
      stepCount: stepCount,
      sedentaryDuration: sedentarySummary?.totalDuration ??
          existingMetrics?.sedentaryDuration ??
          Duration.zero,
      screenOnDuration: usageSummary?.screenOnDuration ?? Duration.zero,
      outdoorDuration: locationSummary.isNotEmpty
          ? locationSummary.last.outdoorDuration
          : Duration.zero,
      postureRiskCount: sedentarySummary?.segments.length ??
          existingMetrics?.postureRiskCount ??
          0,
      highNoiseExposureDuration: highNoiseExposureDuration,
    );
    await metricsRepository.upsertMetrics(nextMetrics);
    return _publishMetricsChanged(
      nextMetrics,
      referenceTime,
      evaluateReminders: evaluateReminders,
    );
  }

  Future<bool> _publishMetricsChanged(
    DailyMetrics nextMetrics,
    DateTime referenceTime, {
    bool evaluateReminders = true,
  }) async {
    final nextSignature = _DailyMetricsSignature.fromMetrics(nextMetrics);
    if (_lastDailyMetricsSignature != null &&
        _lastDailyMetricsSignature == nextSignature) {
      return false;
    }

    _lastDailyMetricsSignature = nextSignature;
    await _captureHealthService.recordStateRebuilt(
      'daily_metrics',
      detail: '已重建当日汇总指标。',
    );
    final now = DateTime.now();
    final lastEvaluationAt = _lastReminderEvaluationAt;
    if (evaluateReminders &&
        (lastEvaluationAt == null ||
            now.difference(lastEvaluationAt) >= const Duration(minutes: 5))) {
      _lastReminderEvaluationAt = now;
      if (_persistRuleReminders != null) {
        await _persistRuleReminders.call(referenceTime);
      }
      if (_deliverRuleReminders != null) {
        await _deliverRuleReminders.call(referenceTime);
      }
    }
    _onDayChanged?.call(_dayStart(referenceTime));
    _onMetricsChanged?.call();
    return true;
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
    interval: const Duration(seconds: 30),
    onThrottledTick: () {
      ref.read(dataCollectorRevisionProvider.notifier).state += 1;
    },
  );
  final metricsRevisionThrottle = _RevisionThrottle(
    interval: const Duration(seconds: 30),
    onThrottledTick: () {
      ref.read(dataCollectorMetricsRevisionProvider.notifier).state += 1;
    },
  );
  final environmentRevisionThrottle = _RevisionThrottle(
    interval: const Duration(seconds: 30),
    onThrottledTick: () {
      ref.read(dataCollectorEnvironmentRevisionProvider.notifier).state += 1;
    },
  );
  final usageRevisionThrottle = _RevisionThrottle(
    interval: const Duration(seconds: 30),
    onThrottledTick: () {
      ref.read(dataCollectorUsageRevisionProvider.notifier).state += 1;
    },
  );
  final reminderRevisionThrottle = _RevisionThrottle(
    interval: const Duration(seconds: 30),
    onThrottledTick: () {
      ref.read(dataCollectorReminderRevisionProvider.notifier).state += 1;
    },
  );
  final dayRevisionThrottle = _DayRevisionThrottle(
    interval: const Duration(seconds: 30),
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
    onMetricsChanged: metricsRevisionThrottle.markChanged,
    onEnvironmentChanged: environmentRevisionThrottle.markChanged,
    onUsageChanged: usageRevisionThrottle.markChanged,
    onRemindersChanged: reminderRevisionThrottle.markChanged,
    persistRuleReminders: (DateTime referenceTime) async {
      final isar = await ref.read(appIsarProvider.future);
      final insightService = HealthInsightService(
        activityRepository: ref.read(sharedActivityRepo),
        ambientLightRepository: ref.read(sharedAmbientLightRepo),
        locationRepository: ref.read(sharedLocationRepo),
        noiseRepository: ref.read(sharedNoiseRepo),
        usageRepository: ref.read(sharedUsageRepo),
        metricsRepository: ref.read(sharedMetricsRepo),
        reminderRepositoryLoader: () async {
          return IsarReminderRepository(isar);
        },
        reminderPreferencesRepositoryLoader: () async {
          return IsarReminderPreferencesRepository(isar);
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
      final isar = await ref.read(appIsarProvider.future);
      final insightService = HealthInsightService(
        activityRepository: ref.read(sharedActivityRepo),
        ambientLightRepository: ref.read(sharedAmbientLightRepo),
        locationRepository: ref.read(sharedLocationRepo),
        noiseRepository: ref.read(sharedNoiseRepo),
        usageRepository: ref.read(sharedUsageRepo),
        metricsRepository: ref.read(sharedMetricsRepo),
        reminderRepositoryLoader: () async {
          return IsarReminderRepository(isar);
        },
        reminderPreferencesRepositoryLoader: () async {
          return IsarReminderPreferencesRepository(isar);
        },
        androidRiskEventBridge: AndroidRiskEventBridge(
          platformBridgeService: PlatformBridgeService(),
        ),
        androidUsageStatsBridge: AndroidUsageStatsBridge(
          platformBridgeService: PlatformBridgeService(),
        ),
      );
      final records = await insightService.syncNativeWalkingScreenRiskEvents();
      return records.length;
    },
    deliverRuleReminders: (DateTime referenceTime) async {
      final isar = await ref.read(appIsarProvider.future);
      final reminderRepository = IsarReminderRepository(isar);
      final reminderDeliveryService = ReminderDeliveryService(
        notificationPreferenceRepository:
            IsarNotificationPreferenceRepository(isar),
        reminderPreferencesRepository: IsarReminderPreferencesRepository(isar),
        notificationPermissionReader: () async {
          final statuses =
              await const PermissionHandlerStatusService().getStatuses();
          return statuses[PermissionType.notification] ??
              PermissionGrantStatus.unknown;
        },
      );
      final localNotificationService = LocalNotificationService();
      await localNotificationService.initialize();
      final startOfDay = DateTime(
        referenceTime.year,
        referenceTime.month,
        referenceTime.day,
      );
      final undelivered =
          await reminderRepository.listUndeliveredSince(startOfDay);
      if (undelivered.isEmpty) {
        return;
      }

      final plan = await reminderDeliveryService.buildPlan(
        records: undelivered,
        referenceTime: referenceTime,
      );
      await localNotificationService.sendPlan(plan);
      await reminderRepository.markDelivered(
        plan.readyRecords,
        deliveredAt: referenceTime,
      );
      if (plan.readyRecords.isNotEmpty) {
        ref.read(dataCollectorReminderRevisionProvider.notifier).state += 1;
      }
    },
  );
  collector.start();
  ref.onDispose(() {
    revisionThrottle.dispose();
    metricsRevisionThrottle.dispose();
    environmentRevisionThrottle.dispose();
    usageRevisionThrottle.dispose();
    reminderRevisionThrottle.dispose();
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

DateTime _dateFromDayKey(String dayKey) {
  final parts = dayKey.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

const int _maxHealthConnectBackfillDays = 30;

int _clampHealthConnectBackfillDays(int days) {
  if (days < 1) {
    return 1;
  }
  if (days > _maxHealthConnectBackfillDays) {
    return _maxHealthConnectBackfillDays;
  }
  return days;
}

List<DateTime> _buildNativeStepSyncReferenceTimes(
  DateTime referenceTime, {
  required DateTime? lastSyncedAt,
  required int maxBackfillDays,
}) {
  final todayStart = _dayStart(referenceTime);
  final clampedBackfillDays = _clampHealthConnectBackfillDays(maxBackfillDays);
  final earliestStart = todayStart.subtract(
    Duration(days: clampedBackfillDays - 1),
  );
  final startDay = lastSyncedAt == null
      ? earliestStart
      : _maxDateTime(_dayStart(lastSyncedAt), earliestStart);
  final result = <DateTime>[];
  var cursor = startDay;
  while (!cursor.isAfter(todayStart)) {
    if (_dayKey(cursor) == _dayKey(todayStart)) {
      result.add(referenceTime);
    } else {
      result.add(
        cursor.add(const Duration(days: 1)).subtract(
              const Duration(milliseconds: 1),
            ),
      );
    }
    cursor = cursor.add(const Duration(days: 1));
  }
  return result;
}

DateTime _maxDateTime(DateTime left, DateTime right) {
  return left.isAfter(right) ? left : right;
}

List<DigitalUsageSummary> _dedupeUsageSummaries(
  List<DigitalUsageSummary> summaries,
) {
  final keyedSummaries = <String, DigitalUsageSummary>{};
  for (final summary in summaries) {
    final key = _dayKey(summary.date);
    final existing = keyedSummaries[key];
    keyedSummaries[key] = existing == null
        ? summary
        : mergeUsageSummaryPreservingProgress(existing, summary);
  }
  return keyedSummaries.values.toList(growable: false);
}
