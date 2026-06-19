import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/ambient_light_capture_service.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/services/step_counter_service.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel =
      MethodChannel('health_monitor/platform_bridge_usage_sync');
  const eventChannel =
      EventChannel('health_monitor/platform_events_usage_sync');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('Android 授予 Usage Access 时应优先写入 android_usage_stats', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
      switch (call.method) {
        case 'android.usage.getCapabilityStatus':
          return <Object?, Object?>{
            'isSupported': true,
            'hasUsageAccess': true,
          };
        case 'android.usage.drainPendingSummaries':
          return <Object?>[];
        case 'android.usage.readDailySummary':
          return <Object?, Object?>{
            'dateKey': '2026-06-16',
            'screenOnDurationMillis': 3600000,
            'unlockCount': 12,
            'viewCount': 24,
            'nighttimeUsageDurationMillis': 300000,
            'focusSessionBreakCount': 4,
            'longestContinuousUsageDurationMillis': 1200000,
            'topCategoryKey': 'tools',
            'completenessKey': 'full',
          };
        default:
          return null;
      }
    });

    final usageRepository = InMemoryUsageSummaryRepository(
      summaries: const <DigitalUsageSummary>[],
    );
    final metricsRepository = InMemoryMetricsRepository(
      metrics: const [],
    );
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
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
      androidUsageStatsBridge: AndroidUsageStatsBridge(
        platformBridgeService: PlatformBridgeService(
          methodChannel: methodChannel,
          eventChannel: eventChannel,
        ),
        isAndroid: () => true,
      ),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
      ),
    );
    addTearDown(collector.dispose);

    await collector.syncUsageSummary(
      referenceTime: DateTime(2026, 6, 16, 10),
    );

    final summary = await usageRepository.getByDate(DateTime(2026, 6, 16));
    expect(summary, isNotNull);
    expect(summary!.source, DigitalUsageSource.androidUsageStats);
    expect(summary.viewCount, 24);
  });

  test('Android 刷新返回空快照时不应覆盖当天已有使用数据', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
      switch (call.method) {
        case 'android.usage.getCapabilityStatus':
          return <Object?, Object?>{
            'isSupported': true,
            'hasUsageAccess': true,
          };
        case 'android.usage.drainPendingSummaries':
          return <Object?>[];
        case 'android.usage.readDailySummary':
          return <Object?, Object?>{
            'dateKey': '2026-06-16',
            'screenOnDurationMillis': 0,
            'unlockCount': 0,
            'viewCount': 0,
            'nighttimeUsageDurationMillis': 0,
            'focusSessionBreakCount': 0,
            'longestContinuousUsageDurationMillis': 0,
            'topCategoryKey': 'unknown',
            'completenessKey': 'full',
          };
        default:
          return null;
      }
    });

    final usageRepository = InMemoryUsageSummaryRepository(
      summaries: <DigitalUsageSummary>[
        DigitalUsageSummary(
          date: DateTime(2026, 6, 16),
          screenOnDuration: const Duration(minutes: 148),
          unlockCount: 20,
          viewCount: 32,
          nighttimeUsageDuration: const Duration(minutes: 38),
          focusSessionBreakCount: 4,
          longestContinuousUsageDuration: const Duration(minutes: 25),
          topCategory: UsageCategory.social,
          source: DigitalUsageSource.androidUsageStats,
        ),
      ],
    );
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
      usageRepository: usageRepository,
      metricsRepository: InMemoryMetricsRepository(metrics: const []),
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
      androidUsageStatsBridge: AndroidUsageStatsBridge(
        platformBridgeService: PlatformBridgeService(
          methodChannel: methodChannel,
          eventChannel: eventChannel,
        ),
        isAndroid: () => true,
      ),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
      ),
    );
    addTearDown(collector.dispose);

    await collector.syncUsageSummary(
      referenceTime: DateTime(2026, 6, 16, 10),
    );

    final summary = await usageRepository.getByDate(DateTime(2026, 6, 16));
    expect(summary, isNotNull);
    expect(summary!.screenOnDuration, const Duration(minutes: 148));
    expect(summary.nighttimeUsageDuration, const Duration(minutes: 38));
    expect(summary.viewCount, 32);
    expect(summary.topCategory, UsageCategory.social);
  });

  test('syncUsageSummary 在重建日指标后会触发提醒投递钩子', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
      switch (call.method) {
        case 'android.usage.getCapabilityStatus':
          return <Object?, Object?>{
            'isSupported': true,
            'hasUsageAccess': true,
          };
        case 'android.usage.drainPendingSummaries':
          return <Object?>[];
        case 'android.usage.readDailySummary':
          return <Object?, Object?>{
            'dateKey': '2026-06-16',
            'screenOnDurationMillis': 1200000,
            'unlockCount': 8,
            'viewCount': 16,
            'nighttimeUsageDurationMillis': 180000,
            'focusSessionBreakCount': 2,
            'longestContinuousUsageDurationMillis': 600000,
            'topCategoryKey': 'tools',
            'completenessKey': 'full',
          };
        default:
          return null;
      }
    });

    final deliveredAt = <DateTime>[];
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
      usageRepository: InMemoryUsageSummaryRepository(
        summaries: const <DigitalUsageSummary>[],
      ),
      metricsRepository: InMemoryMetricsRepository(metrics: const []),
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
      androidUsageStatsBridge: AndroidUsageStatsBridge(
        platformBridgeService: PlatformBridgeService(
          methodChannel: methodChannel,
          eventChannel: eventChannel,
        ),
        isAndroid: () => true,
      ),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
      ),
      deliverRuleReminders: (DateTime referenceTime) async {
        deliveredAt.add(referenceTime);
      },
    );
    addTearDown(collector.dispose);

    await collector.syncUsageSummary(
      referenceTime: DateTime(2026, 6, 16, 10),
    );

    expect(deliveredAt, hasLength(1));
    expect(deliveredAt.single, DateTime(2026, 6, 16));
  });

  test('Android 未授予 Usage Access 时应回退 lifecycle_alternative', () async {
    final controller = StreamController<AppUsageEvent>.broadcast();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
      if (call.method == 'android.usage.getCapabilityStatus') {
        return <Object?, Object?>{
          'isSupported': true,
          'hasUsageAccess': false,
        };
      }
      return null;
    });

    final usageRepository = InMemoryUsageSummaryRepository(
      summaries: const <DigitalUsageSummary>[],
    );
    final metricsRepository = InMemoryMetricsRepository(
      metrics: const [],
    );
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
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
      androidUsageStatsBridge: AndroidUsageStatsBridge(
        platformBridgeService: PlatformBridgeService(
          methodChannel: methodChannel,
          eventChannel: eventChannel,
        ),
        isAndroid: () => true,
      ),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => controller.stream,
      ),
    );
    addTearDown(collector.dispose);
    addTearDown(controller.close);

    await collector.syncUsageSummary(
      referenceTime: DateTime(2026, 6, 16, 10),
    );
    controller
      ..add(
        AppUsageEvent(
          occurredAt: DateTime(2026, 6, 16, 10, 0),
          type: AppUsageEventType.foregroundEntered,
        ),
      )
      ..add(
        AppUsageEvent(
          occurredAt: DateTime(2026, 6, 16, 10, 20),
          type: AppUsageEventType.foregroundExited,
        ),
      );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final summary = await usageRepository.getByDate(DateTime(2026, 6, 16));
    expect(summary, isNotNull);
    expect(summary!.source, DigitalUsageSource.lifecycleAlternative);
    expect(summary.completeness, UsageDataCompleteness.degraded);
    expect(summary.screenOnDuration, const Duration(minutes: 20));
  });

  test('同步原生风险事件后应触发提醒投递', () async {
    final deliveredAt = <DateTime>[];
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
      usageRepository: InMemoryUsageSummaryRepository(
        summaries: const <DigitalUsageSummary>[],
      ),
      metricsRepository: InMemoryMetricsRepository(metrics: const []),
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
      syncNativeRiskEvents: () async => 1,
      deliverRuleReminders: (DateTime referenceTime) async {
        deliveredAt.add(referenceTime);
      },
    );
    addTearDown(collector.dispose);

    await collector.syncNativeRiskEvents();

    expect(deliveredAt, hasLength(1));
  });

  test('没有原生风险事件时不应重复触发提醒投递', () async {
    var deliveredCount = 0;
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
      usageRepository: InMemoryUsageSummaryRepository(
        summaries: const <DigitalUsageSummary>[],
      ),
      metricsRepository: InMemoryMetricsRepository(metrics: const []),
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
      syncNativeRiskEvents: () async => 0,
      deliverRuleReminders: (DateTime referenceTime) async {
        deliveredCount += 1;
      },
    );
    addTearDown(collector.dispose);

    await collector.syncNativeRiskEvents();

    expect(deliveredCount, 0);
  });

  test('高频活动样本应合并每日指标重算，避免每条样本触发全量查询', () async {
    final motionController = StreamController<MotionVectorSample>();
    final metricsRepository = _CountingMetricsRepository();
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
      usageRepository: InMemoryUsageSummaryRepository(
        summaries: const <DigitalUsageSummary>[],
      ),
      metricsRepository: metricsRepository,
      motionCaptureService: MotionCaptureService(
        sensorStreamFactory: ({
          Duration samplingPeriod = const Duration(milliseconds: 200),
        }) =>
            motionController.stream,
      ),
      ambientLightCaptureService: AmbientLightCaptureService(
        isAndroid: () => false,
      ),
      stepCounterService: StepCounterService(isAndroid: () => false),
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
      androidUsageStatsBridge: AndroidUsageStatsBridge(
        isAndroid: () => false,
      ),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
      ),
      dailyMetricsRefreshInterval: const Duration(milliseconds: 20),
    );
    addTearDown(collector.dispose);
    addTearDown(motionController.close);

    collector.start();
    final capturedAt = DateTime(2026, 6, 18, 10);
    for (var index = 0; index < 30; index += 1) {
      motionController.add(
        MotionVectorSample(
          capturedAt: capturedAt.add(Duration(milliseconds: index)),
          x: 0,
          y: 0,
          z: 9.8,
        ),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(metricsRepository.upsertCount, lessThanOrEqualTo(2));
  });

  test('计步流尚未返回时，其他数据刷新不应把当天已有步数覆盖为 0', () async {
    final motionController = StreamController<MotionVectorSample>();
    final capturedAt = DateTime(2026, 6, 18, 10);
    final metricsRepository = InMemoryMetricsRepository(
      metrics: <DailyMetrics>[
        DailyMetrics(
          date: DateTime(2026, 6, 18),
          stepCount: 4321,
          sedentaryDuration: const Duration(minutes: 20),
          screenOnDuration: const Duration(hours: 1),
          outdoorDuration: const Duration(minutes: 15),
          postureRiskCount: 1,
          highNoiseExposureDuration: Duration.zero,
        ),
      ],
    );
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
      usageRepository: InMemoryUsageSummaryRepository(
        summaries: const <DigitalUsageSummary>[],
      ),
      metricsRepository: metricsRepository,
      motionCaptureService: MotionCaptureService(
        sensorStreamFactory: ({
          Duration samplingPeriod = const Duration(milliseconds: 200),
        }) =>
            motionController.stream,
      ),
      ambientLightCaptureService: AmbientLightCaptureService(
        isAndroid: () => false,
      ),
      stepCounterService: StepCounterService(isAndroid: () => false),
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
      androidUsageStatsBridge: AndroidUsageStatsBridge(
        isAndroid: () => false,
      ),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
      ),
      dailyMetricsRefreshInterval: const Duration(milliseconds: 10),
    );
    addTearDown(collector.dispose);
    addTearDown(motionController.close);

    collector.start();
    motionController.add(
      MotionVectorSample(
        capturedAt: capturedAt,
        x: 0,
        y: 0,
        z: 9.8,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 80));

    final metrics = await metricsRepository.listRecentDays(
      1,
      referenceDate: capturedAt,
    );
    expect(metrics.single.stepCount, 4321);
  });

  test('高频采集缓冲区达到上限时保持有界且记录丢弃计数', () async {
    final motionController = StreamController<MotionVectorSample>();
    final collector = DataCollector(
      activityRepository: SharedActivityRepository(),
      ambientLightRepository: SharedAmbientLightRepository(),
      noiseRepository: SharedNoiseRepository(),
      locationRepository: SharedLocationRepository(),
      usageRepository: SharedUsageRepository(),
      metricsRepository: SharedMetricsRepository(),
      motionCaptureService: MotionCaptureService(
        sensorStreamFactory: ({
          Duration samplingPeriod = const Duration(milliseconds: 200),
        }) =>
            motionController.stream,
      ),
      ambientLightCaptureService:
          AmbientLightCaptureService(isAndroid: () => false),
      stepCounterService: StepCounterService(isAndroid: () => false),
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
      androidUsageStatsBridge: AndroidUsageStatsBridge(isAndroid: () => false),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
      ),
      dailyMetricsRefreshInterval: const Duration(days: 1),
      maxBufferedSamplesPerStream: 3,
    );
    addTearDown(collector.dispose);
    addTearDown(motionController.close);

    collector.start();
    final start = DateTime(2026, 6, 18, 10);
    for (var index = 0; index < 8; index += 1) {
      motionController.add(
        MotionVectorSample(
          capturedAt: start.add(Duration(seconds: index)),
          x: 0,
          y: 0,
          z: 9.8,
        ),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(collector.performanceStats.bufferedSamples, 3);
    expect(collector.performanceStats.droppedSamples, greaterThan(0));
  });

  test('启动后清理超过 9 天的活动、噪音和光照原始样本', () async {
    final now = DateTime.now();
    final oldAt = now.subtract(const Duration(days: 10));
    final recentAt = now.subtract(const Duration(days: 8));
    final activityRepository = SharedActivityRepository()
      ..addSample(
        ActivitySample(
          capturedAt: oldAt,
          duration: const Duration(seconds: 1),
          type: ActivityType.walking,
          confidence: 0.9,
          stepCount: 0,
          source: MotionSampleSource.sensorFusion,
        ),
      )
      ..addSample(
        ActivitySample(
          capturedAt: recentAt,
          duration: const Duration(seconds: 1),
          type: ActivityType.walking,
          confidence: 0.9,
          stepCount: 0,
          source: MotionSampleSource.sensorFusion,
        ),
      );
    final noiseRepository = SharedNoiseRepository()
      ..addSample(
        NoiseSample.fromDecibel(
          capturedAt: oldAt,
          duration: const Duration(seconds: 1),
          decibel: 45,
        ),
      )
      ..addSample(
        NoiseSample.fromDecibel(
          capturedAt: recentAt,
          duration: const Duration(seconds: 1),
          decibel: 45,
        ),
      );
    final lightRepository = SharedAmbientLightRepository()
      ..addSample(
        AmbientLightSample.fromLux(
          capturedAt: oldAt,
          duration: const Duration(seconds: 1),
          lux: 100,
        ),
      )
      ..addSample(
        AmbientLightSample.fromLux(
          capturedAt: recentAt,
          duration: const Duration(seconds: 1),
          lux: 100,
        ),
      );
    final collector = DataCollector(
      activityRepository: activityRepository,
      ambientLightRepository: lightRepository,
      noiseRepository: noiseRepository,
      locationRepository: SharedLocationRepository(),
      usageRepository: SharedUsageRepository(),
      metricsRepository: SharedMetricsRepository(),
      motionCaptureService: MotionCaptureService(
        sensorStreamFactory: ({
          Duration samplingPeriod = const Duration(milliseconds: 200),
        }) =>
            const Stream<MotionVectorSample>.empty(),
      ),
      ambientLightCaptureService:
          AmbientLightCaptureService(isAndroid: () => false),
      stepCounterService: StepCounterService(isAndroid: () => false),
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
      androidUsageStatsBridge: AndroidUsageStatsBridge(isAndroid: () => false),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
      ),
    );
    addTearDown(collector.dispose);

    collector.start();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final window = QueryWindow.recentCalendarDays(
      20,
      referenceDate: now,
    );

    expect(await activityRepository.listByWindow(window), hasLength(1));
    expect(await noiseRepository.listByWindow(window), hasLength(1));
    expect(await lightRepository.listByWindow(window), hasLength(1));
  });
}

class _CountingMetricsRepository implements MetricsRepository {
  int upsertCount = 0;

  @override
  Future<DailyMetrics?> getByDate(DateTime date) async => null;

  @override
  Future<List<DailyMetrics>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    return const <DailyMetrics>[];
  }

  @override
  Future<void> upsertMetrics(DailyMetrics metrics) async {
    upsertCount += 1;
  }
}
