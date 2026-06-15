import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
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
}
