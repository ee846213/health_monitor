import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/motion/hourly_step_bucket.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/dashboard_service.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/health_connect_step_sync_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

void main() {
  test('今日简报累计久坐时间应与首页使用相同的当日裁剪口径', () async {
    final referenceTime = DateTime(2026, 6, 16, 10);
    final container = _createContainer(
      referenceTime: referenceTime,
      todaySedentaryActivityMinutes: 42,
      todaySedentaryMetricMinutes: 60,
    );
    addTearDown(container.dispose);

    final viewModel = await container.read(briefingViewModelProvider.future);
    final sedentaryMetric = viewModel.briefSnapshot.metrics.singleWhere(
      (DailyBriefMetric metric) => metric.label == '久坐',
    );

    expect(viewModel.dashboard?.sedentaryCard.totalMinutes, 42);
    expect(sedentaryMetric.value, '42');
  });

  test('查看昨日简报时，今日全局版本推进不应触发重新计算', () async {
    final referenceTime = DateTime(2026, 6, 16, 10);
    final container = _createContainer(referenceTime: referenceTime);
    addTearDown(container.dispose);

    container.read(briefingTimeRangeProvider.notifier).state =
        BriefingTimeRange.yesterday;
    await container.read(briefingViewModelProvider.future);

    var refreshCount = 0;
    final subscription = container.listen<AsyncValue<BriefingViewModel>>(
      briefingViewModelProvider,
      (previous, next) {
        refreshCount += 1;
      },
      fireImmediately: false,
    );
    addTearDown(subscription.close);

    container.read(dataCollectorRevisionProvider.notifier).state += 1;
    await container.read(briefingViewModelProvider.future);

    expect(refreshCount, 0);
  });

  test('查看昨日简报时，昨日相关版本推进应触发重新计算', () async {
    final referenceTime = DateTime(2026, 6, 16, 10);
    final yesterday = DateTime(2026, 6, 15);
    final container = _createContainer(referenceTime: referenceTime);
    addTearDown(container.dispose);

    container.read(briefingTimeRangeProvider.notifier).state =
        BriefingTimeRange.yesterday;
    await container.read(briefingViewModelProvider.future);

    var refreshCount = 0;
    final subscription = container.listen<AsyncValue<BriefingViewModel>>(
      briefingViewModelProvider,
      (previous, next) {
        refreshCount += 1;
      },
      fireImmediately: false,
    );
    addTearDown(subscription.close);

    container.read(dataCollectorDailyRevisionProvider.notifier).state =
        <String, int>{_dayKey(yesterday): 1};
    await container.read(briefingViewModelProvider.future);

    expect(refreshCount, greaterThan(0));
  });

  test('查看最近7日简报时，今日相关版本推进不应触发重新计算', () async {
    final referenceTime = DateTime(2026, 6, 16, 10);
    final today = DateTime(2026, 6, 16);
    final container = _createContainer(referenceTime: referenceTime);
    addTearDown(container.dispose);

    container.read(briefingTimeRangeProvider.notifier).state =
        BriefingTimeRange.recent7Days;
    await container.read(briefingViewModelProvider.future);

    var refreshCount = 0;
    final subscription = container.listen<AsyncValue<BriefingViewModel>>(
      briefingViewModelProvider,
      (previous, next) {
        refreshCount += 1;
      },
      fireImmediately: false,
    );
    addTearDown(subscription.close);

    container.read(dataCollectorDailyRevisionProvider.notifier).state =
        <String, int>{_dayKey(today): 1};
    await container.read(briefingViewModelProvider.future);

    expect(refreshCount, 0);
  });

  test('selected historical day syncs native data before building briefing',
      () async {
    final referenceTime = DateTime(2026, 6, 16, 10);
    final selectedDay = DateTime(2026, 6, 14);
    final stepSyncReferenceTimes = <DateTime>[];
    final usageSyncReferenceTimes = <DateTime>[];
    late SharedMetricsRepository metricsRepository;

    final container = _createContainer(
      referenceTime: referenceTime,
      androidUsageStatsBridge: _FakeAndroidUsageStatsBridge(
        onReadDailySummary: usageSyncReferenceTimes.add,
      ),
      syncHealthConnectStepsForDay: (DateTime syncReferenceTime) async {
        stepSyncReferenceTimes.add(syncReferenceTime);
        if (_dayKey(syncReferenceTime) == _dayKey(selectedDay)) {
          await metricsRepository.upsertMetrics(
            DailyMetrics(
              date: selectedDay,
              stepCount: 7899,
              sedentaryDuration: Duration.zero,
              screenOnDuration: Duration.zero,
              outdoorDuration: Duration.zero,
              postureRiskCount: 0,
              highNoiseExposureDuration: Duration.zero,
            ),
          );
          return HealthConnectStepSyncResult.synced(
            status: const HealthConnectStatus(
              isAvailable: true,
              hasStepsPermission: true,
              needsInstall: false,
            ),
            bucketCount: 1,
            totalSteps: 7899,
          );
        }
        return HealthConnectStepSyncResult.empty(
          status: const HealthConnectStatus(
            isAvailable: true,
            hasStepsPermission: true,
            needsInstall: false,
          ),
        );
      },
      exposeMetricsRepository: (SharedMetricsRepository repository) {
        metricsRepository = repository;
      },
    );
    addTearDown(container.dispose);

    container.read(briefingSelectedDateProvider.notifier).state = selectedDay;
    final viewModel = await container.read(briefingViewModelProvider.future);

    expect(
      stepSyncReferenceTimes.map(_dayKey),
      contains(_dayKey(selectedDay)),
    );
    expect(usageSyncReferenceTimes.single, selectedDay);
    expect(viewModel.briefSnapshot.metrics[0].value, '7899');
    expect(viewModel.briefSnapshot.metrics[2].value, '123');
  });
}

ProviderContainer _createContainer({
  required DateTime referenceTime,
  int todaySedentaryActivityMinutes = 0,
  int todaySedentaryMetricMinutes = 60,
  AndroidUsageStatsBridge? androidUsageStatsBridge,
  SyncHealthConnectStepsForDay? syncHealthConnectStepsForDay,
  void Function(SharedMetricsRepository repository)? exposeMetricsRepository,
}) {
  final activityRepository = SharedActivityRepository();
  final ambientLightRepository = SharedAmbientLightRepository();
  final noiseRepository = SharedNoiseRepository();
  final locationRepository = SharedLocationRepository();
  final usageRepository = SharedUsageRepository();
  final metricsRepository = SharedMetricsRepository();
  exposeMetricsRepository?.call(metricsRepository);

  final collector = DataCollector(
    activityRepository: activityRepository,
    noiseRepository: noiseRepository,
    locationRepository: locationRepository,
    usageRepository: usageRepository,
    metricsRepository: metricsRepository,
    motionCaptureService: MotionCaptureService(
      sensorStreamFactory: ({
        Duration samplingPeriod = const Duration(milliseconds: 200),
      }) =>
          const Stream<MotionVectorSample>.empty(),
    ),
    noiseCaptureService: NoiseCaptureService(
      noiseStreamFactory: () => const Stream<NoiseReadingSample>.empty(),
    ),
    locationCaptureService: LocationCaptureService(
      positionStreamFactory: ({
        Duration samplingPeriod = const Duration(seconds: 30),
      }) =>
          const Stream<GeoPositionSample>.empty(),
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => GeoPermissionStatus.allowed,
      requestPermission: () async => GeoPermissionStatus.allowed,
    ),
    digitalUsageCaptureService: DigitalUsageCaptureService(
      lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
    ),
    androidUsageStatsBridge: androidUsageStatsBridge,
    syncHealthConnectStepsForDay: syncHealthConnectStepsForDay,
    syncBackgroundStepDeltas: () async => 0,
  );

  _seedDay(
    activityRepository: activityRepository,
    noiseRepository: noiseRepository,
    locationRepository: locationRepository,
    usageRepository: usageRepository,
    metricsRepository: metricsRepository,
    day: DateTime(2026, 6, 15),
    stepCount: 2400,
    screenMinutes: 150,
    outdoorMinutes: 35,
  );
  _seedDay(
    activityRepository: activityRepository,
    noiseRepository: noiseRepository,
    locationRepository: locationRepository,
    usageRepository: usageRepository,
    metricsRepository: metricsRepository,
    day: DateTime(2026, 6, 16),
    stepCount: 1200,
    screenMinutes: 90,
    outdoorMinutes: 20,
    sedentaryActivityMinutes: todaySedentaryActivityMinutes,
    sedentaryMetricMinutes: todaySedentaryMetricMinutes,
  );

  return ProviderContainer(
    overrides: <Override>[
      sharedActivityRepo.overrideWithValue(activityRepository),
      sharedAmbientLightRepo.overrideWithValue(ambientLightRepository),
      sharedNoiseRepo.overrideWithValue(noiseRepository),
      sharedLocationRepo.overrideWithValue(locationRepository),
      sharedUsageRepo.overrideWithValue(usageRepository),
      sharedMetricsRepo.overrideWithValue(metricsRepository),
      dataCollectorProvider.overrideWithValue(collector),
      briefingReferenceTimeProvider.overrideWithValue(() => referenceTime),
      overviewPermissionStatusServiceProvider.overrideWithValue(
        const _GrantedPermissionStatusService(),
      ),
      reminderRepositoryProvider.overrideWith(
        (Ref ref) async => InMemoryReminderRepository(),
      ),
      dashboardServiceProvider.overrideWith((Ref ref) {
        final insightService = ref.watch(healthInsightServiceProvider);
        return DashboardService(
          loadInsightSnapshot: insightService.buildSnapshot,
          buildDailyAdvice: ({
            required referenceTime,
            required input,
            required metrics,
            required verdicts,
            required environmentOverview,
          }) async {
            return const DailyAdviceBubble(
              text: '测试建议',
              source: DailyAdviceSource.fallback,
            );
          },
        );
      }),
    ],
  );
}

void _seedDay({
  required SharedActivityRepository activityRepository,
  required SharedNoiseRepository noiseRepository,
  required SharedLocationRepository locationRepository,
  required SharedUsageRepository usageRepository,
  required SharedMetricsRepository metricsRepository,
  required DateTime day,
  required int stepCount,
  required int screenMinutes,
  required int outdoorMinutes,
  int sedentaryActivityMinutes = 0,
  int sedentaryMetricMinutes = 60,
}) {
  activityRepository.addSample(
    ActivitySample(
      capturedAt: day.add(const Duration(hours: 9)),
      duration: const Duration(minutes: 30),
      type: ActivityType.walking,
      confidence: 0.9,
      stepCount: stepCount,
      source: MotionSampleSource.sensorFusion,
    ),
  );
  if (sedentaryActivityMinutes > 0) {
    activityRepository.addSample(
      ActivitySample(
        capturedAt: day.add(const Duration(hours: 13)),
        duration: Duration(minutes: sedentaryActivityMinutes),
        type: ActivityType.stationary,
        confidence: 0.9,
        stepCount: 0,
        source: MotionSampleSource.sensorFusion,
      ),
    );
  }
  noiseRepository.addSample(
    NoiseSample(
      capturedAt: day.add(const Duration(hours: 12)),
      duration: const Duration(minutes: 10),
      decibel: 45,
      level: NoiseLevel.quiet,
    ),
  );
  unawaited(
    locationRepository.upsertSummary(
      LocationSummary(
        date: day,
        distanceMeters: 1000 + stepCount.toDouble(),
        outdoorDuration: Duration(minutes: outdoorMinutes),
        visitCount: 1,
        commuteCount: 0,
      ),
    ),
  );
  unawaited(
    usageRepository.upsertSummary(
      DigitalUsageSummary(
        date: day,
        screenOnDuration: Duration(minutes: screenMinutes),
        unlockCount: 20,
        nighttimeUsageDuration: Duration.zero,
        focusSessionBreakCount: 0,
        topCategory: UsageCategory.unknown,
      ),
    ),
  );
  unawaited(
    metricsRepository.upsertMetrics(
      DailyMetrics(
        date: day,
        stepCount: stepCount,
        sedentaryDuration: Duration(minutes: sedentaryMetricMinutes),
        screenOnDuration: Duration(minutes: screenMinutes),
        outdoorDuration: Duration(minutes: outdoorMinutes),
        postureRiskCount: 0,
        highNoiseExposureDuration: Duration.zero,
      ),
    ),
  );
}

class _GrantedPermissionStatusService implements PermissionStatusService {
  const _GrantedPermissionStatusService();

  @override
  Future<Map<PermissionType, PermissionGrantStatus>> getStatuses() async {
    return <PermissionType, PermissionGrantStatus>{
      PermissionType.motion: PermissionGrantStatus.granted,
      PermissionType.location: PermissionGrantStatus.granted,
      PermissionType.microphone: PermissionGrantStatus.granted,
      PermissionType.notification: PermissionGrantStatus.granted,
      PermissionType.usageAccess: PermissionGrantStatus.granted,
      PermissionType.backgroundCapture: PermissionGrantStatus.granted,
    };
  }
}

class _FakeAndroidUsageStatsBridge extends AndroidUsageStatsBridge {
  _FakeAndroidUsageStatsBridge({
    required this.onReadDailySummary,
  }) : super(isAndroid: () => true);

  final void Function(DateTime referenceTime) onReadDailySummary;

  @override
  Future<AndroidUsageCapabilityStatus> getCapabilityStatus() async {
    return const AndroidUsageCapabilityStatus(
      isSupported: true,
      hasUsageAccess: true,
    );
  }

  @override
  Future<List<DigitalUsageSummary>> drainPendingSummaries() async {
    return const <DigitalUsageSummary>[];
  }

  @override
  Future<DigitalUsageSummary?> readDailySummary({
    DateTime? referenceTime,
  }) async {
    final day = referenceTime ?? DateTime(2026, 6, 14);
    onReadDailySummary(day);
    return DigitalUsageSummary(
      date: day,
      screenOnDuration: const Duration(minutes: 123),
      unlockCount: 12,
      nighttimeUsageDuration: const Duration(minutes: 20),
      focusSessionBreakCount: 2,
      topCategory: UsageCategory.tools,
      source: DigitalUsageSource.androidUsageStats,
    );
  }
}

String _dayKey(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day';
}
