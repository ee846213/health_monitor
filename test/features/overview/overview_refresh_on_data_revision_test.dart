import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

void main() {
  test('数据写入后首页应重新计算并从数据不足切换为可用', () async {
    final activityRepository = SharedActivityRepository();
    final ambientLightRepository = SharedAmbientLightRepository();
    final noiseRepository = SharedNoiseRepository();
    final locationRepository = SharedLocationRepository();
    final usageRepository = SharedUsageRepository();
    final metricsRepository = SharedMetricsRepository();

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
    );
    addTearDown(collector.dispose);

    final container = ProviderContainer(
      overrides: <Override>[
        sharedActivityRepo.overrideWithValue(activityRepository),
        sharedAmbientLightRepo.overrideWithValue(ambientLightRepository),
        sharedNoiseRepo.overrideWithValue(noiseRepository),
        sharedLocationRepo.overrideWithValue(locationRepository),
        sharedUsageRepo.overrideWithValue(usageRepository),
        sharedMetricsRepo.overrideWithValue(metricsRepository),
        dataCollectorProvider.overrideWithValue(collector),
        overviewPermissionStatusServiceProvider.overrideWithValue(
          const _GrantedPermissionStatusService(),
        ),
        reminderRepositoryProvider.overrideWith(
          (Ref ref) async => InMemoryReminderRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(overviewViewModelProvider.future);
    expect(initial.screenState, OverviewScreenState.dataInsufficient);
    expect(initial.hasRealData, isFalse);

    activityRepository.addSample(
      ActivitySample(
        capturedAt: DateTime.now(),
        duration: const Duration(minutes: 10),
        type: ActivityType.walking,
        confidence: 0.92,
        stepCount: 120,
        source: MotionSampleSource.sensorFusion,
      ),
    );
    container.read(dataCollectorRevisionProvider.notifier).state += 1;

    final refreshed = await container.read(overviewViewModelProvider.future);
    expect(refreshed.screenState, OverviewScreenState.ready);
    expect(refreshed.hasRealData, isTrue);
  });

  test('同一天的汇总连续写入相同计算值时不应重复推进版本', () async {
    var revisionCount = 0;
    final locationController = StreamController<GeoPositionSample>.broadcast();

    final activityRepository = SharedActivityRepository();
    final ambientLightRepository = SharedAmbientLightRepository();
    final noiseRepository = SharedNoiseRepository();
    final locationRepository = SharedLocationRepository();
    final usageRepository = SharedUsageRepository();
    final metricsRepository = SharedMetricsRepository();

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
            locationController.stream,
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => GeoPermissionStatus.allowed,
        requestPermission: () async => GeoPermissionStatus.allowed,
      ),
      digitalUsageCaptureService: DigitalUsageCaptureService(
        lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
      ),
      onDataChanged: () {
        revisionCount += 1;
      },
    );
    collector.start();
    addTearDown(collector.dispose);
    addTearDown(locationController.close);

    final container = ProviderContainer(
      overrides: <Override>[
        sharedActivityRepo.overrideWithValue(activityRepository),
        sharedAmbientLightRepo.overrideWithValue(ambientLightRepository),
        sharedNoiseRepo.overrideWithValue(noiseRepository),
        sharedLocationRepo.overrideWithValue(locationRepository),
        sharedUsageRepo.overrideWithValue(usageRepository),
        sharedMetricsRepo.overrideWithValue(metricsRepository),
        dataCollectorProvider.overrideWithValue(collector),
        overviewPermissionStatusServiceProvider.overrideWithValue(
          const _GrantedPermissionStatusService(),
        ),
        reminderRepositoryProvider.overrideWith(
          (Ref ref) async => InMemoryReminderRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(overviewViewModelProvider.future);
    expect(revisionCount, 0);

    final sameDay = DateTime(2026, 6, 11, 8, 0);
    locationController.add(
      GeoPositionSample(
        capturedAt: sameDay,
        latitude: 30.0,
        longitude: 120.0,
        accuracy: 8.0,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    container.read(dataCollectorRevisionProvider.notifier).state += 1;
    await container.read(overviewViewModelProvider.future);

    expect(revisionCount, 1);

    locationController.add(
      GeoPositionSample(
        capturedAt: sameDay.add(const Duration(minutes: 5)),
        latitude: 30.0,
        longitude: 120.0,
        accuracy: 8.0,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    container.read(dataCollectorRevisionProvider.notifier).state += 1;
    await container.read(overviewViewModelProvider.future);

    expect(revisionCount, 1);
  });
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
