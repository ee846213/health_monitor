import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/diagnostics/providers/diagnostics_providers.dart';
import 'package:health_monitor/services/android_background_capture_bridge.dart';
import 'package:health_monitor/services/background_capture_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

void main() {
  test('调试页快照应聚合最近权限状态与最新样本', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        activityRepositoryProvider.overrideWithValue(
          InMemoryActivityRepository(
            samples: <ActivitySample>[
              ActivitySample(
                capturedAt: DateTime(2026, 6, 9, 18),
                duration: const Duration(minutes: 15),
                type: ActivityType.walking,
                confidence: 0.91,
                stepCount: 1600,
                source: MotionSampleSource.sensorFusion,
              ),
            ],
          ),
        ),
        locationSummaryRepositoryProvider.overrideWithValue(
          InMemoryLocationSummaryRepository(
            summaries: <LocationSummary>[
              LocationSummary(
                date: DateTime(2026, 6, 9),
                distanceMeters: 3200,
                outdoorDuration: const Duration(minutes: 35),
                visitCount: 4,
                commuteCount: 1,
              ),
            ],
          ),
        ),
        noiseSampleRepositoryProvider.overrideWithValue(
          InMemoryNoiseSampleRepository(
            samples: <NoiseSample>[
              NoiseSample.fromDecibel(
                capturedAt: DateTime(2026, 6, 9, 19),
                duration: const Duration(minutes: 8),
                decibel: 58,
              ),
            ],
          ),
        ),
        usageSummaryRepositoryProvider.overrideWithValue(
          InMemoryUsageSummaryRepository(
            summaries: <DigitalUsageSummary>[
              DigitalUsageSummary(
                date: DateTime(2026, 6, 9),
                screenOnDuration: const Duration(hours: 3),
                unlockCount: 28,
                nighttimeUsageDuration: const Duration(minutes: 20),
                focusSessionBreakCount: 8,
                topCategory: UsageCategory.tools,
              ),
            ],
          ),
        ),
        permissionStatusServiceProvider.overrideWithValue(
          const FakePermissionStatusService(
            <PermissionType, PermissionGrantStatus>{
              PermissionType.motion: PermissionGrantStatus.granted,
              PermissionType.location: PermissionGrantStatus.denied,
              PermissionType.microphone: PermissionGrantStatus.granted,
              PermissionType.notification: PermissionGrantStatus.granted,
              PermissionType.usageAccess: PermissionGrantStatus.denied,
              PermissionType.backgroundCapture: PermissionGrantStatus.restricted,
            },
          ),
        ),
        motionCaptureServiceProvider.overrideWithValue(
          MotionCaptureService(
            sensorStreamFactory: ({
              Duration samplingPeriod = const Duration(milliseconds: 200),
            }) {
              return Stream<MotionVectorSample>.value(
                MotionVectorSample(
                  capturedAt: DateTime(2026, 6, 9, 18, 30),
                  x: 1.2,
                  y: 0.8,
                  z: 0.6,
                ),
              );
            },
          ),
        ),
        locationCaptureServiceProvider.overrideWithValue(
          LocationCaptureService(
            positionStreamFactory: ({
              Duration samplingPeriod = const Duration(seconds: 30),
            }) {
              return Stream<GeoPositionSample>.value(
                GeoPositionSample(
                  capturedAt: DateTime(2026, 6, 9, 18, 40),
                  latitude: 31.2304,
                  longitude: 121.4737,
                  accuracy: 15,
                ),
              );
            },
            isLocationServiceEnabled: () async => true,
            checkPermission: () async => GeoPermissionStatus.allowed,
            requestPermission: () async => GeoPermissionStatus.allowed,
          ),
        ),
        noiseCaptureServiceProvider.overrideWithValue(
          NoiseCaptureService(
            noiseStreamFactory: () {
              return Stream<NoiseReadingSample>.value(
                NoiseReadingSample(
                  capturedAt: DateTime(2026, 6, 9, 18, 45),
                  meanDecibel: 57,
                  maxDecibel: 61,
                ),
              );
            },
          ),
        ),
        digitalUsageCaptureServiceProvider.overrideWithValue(
          DigitalUsageCaptureService(
            lifecycleEventStreamFactory: () {
              return Stream<AppUsageEvent>.value(
                AppUsageEvent(
                  occurredAt: DateTime(2026, 6, 9, 18, 50),
                  type: AppUsageEventType.foregroundEntered,
                ),
              );
            },
          ),
        ),
        backgroundCaptureServiceProvider.overrideWithValue(
          const FakeBackgroundCaptureService(
            BackgroundCaptureState(
              status: BackgroundCaptureStatus.running,
              label: '后台采集中',
              reason: '前台服务与调度都已就绪。',
            ),
          ),
        ),
        androidBackgroundHostStatusServiceProvider.overrideWithValue(
          const FakeAndroidBackgroundCaptureHostStatusService(
            AndroidBackgroundCaptureHostStatus(
              isRunning: true,
              summary: 'Android 宿主后台骨架已启动。',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(diagnosticsSnapshotProvider.future);

    expect(snapshot.permissionStatuses[PermissionType.motion], PermissionGrantStatus.granted);
    expect(snapshot.latestActivity?.type, ActivityType.walking);
    expect(snapshot.liveActivity?.type, ActivityType.walking);
    expect(snapshot.latestLocationSummary?.distanceMeters, 3200);
    expect(snapshot.latestNoise?.level, NoiseLevel.moderate);
    expect(snapshot.liveUsageSummary?.unlockCount, 1);
    expect(snapshot.latestUsageSummary?.topCategory, UsageCategory.tools);
    expect(snapshot.backgroundCaptureState.status, BackgroundCaptureStatus.running);
    expect(snapshot.androidHostStatus?.isRunning, isTrue);
    expect(snapshot.androidHostStatus?.summary, contains('宿主后台骨架'));
    expect(snapshot.storageStatus.kind, DiagnosticsStorageStatusKind.hasRecentWrites);
  });

  test('无数据时调试页快照应给出空写入状态', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        permissionStatusServiceProvider.overrideWithValue(
          const FakePermissionStatusService(<PermissionType, PermissionGrantStatus>{}),
        ),
        motionCaptureServiceProvider.overrideWithValue(
          MotionCaptureService(
            sensorStreamFactory: ({
              Duration samplingPeriod = const Duration(milliseconds: 200),
            }) {
              return const Stream<MotionVectorSample>.empty();
            },
          ),
        ),
        locationCaptureServiceProvider.overrideWithValue(
          LocationCaptureService(
            positionStreamFactory: ({
              Duration samplingPeriod = const Duration(seconds: 30),
            }) {
              return const Stream<GeoPositionSample>.empty();
            },
            isLocationServiceEnabled: () async => true,
            checkPermission: () async => GeoPermissionStatus.allowed,
            requestPermission: () async => GeoPermissionStatus.allowed,
          ),
        ),
        noiseCaptureServiceProvider.overrideWithValue(
          NoiseCaptureService(
            noiseStreamFactory: () => const Stream<NoiseReadingSample>.empty(),
          ),
        ),
        digitalUsageCaptureServiceProvider.overrideWithValue(
          DigitalUsageCaptureService(
            lifecycleEventStreamFactory: () => const Stream<AppUsageEvent>.empty(),
          ),
        ),
        backgroundCaptureServiceProvider.overrideWithValue(
          const FakeBackgroundCaptureService(
            BackgroundCaptureState(
              status: BackgroundCaptureStatus.permissionDenied,
              label: '后台权限未开启',
              reason: '当前只会在前台积累样本。',
            ),
          ),
        ),
        androidBackgroundHostStatusServiceProvider.overrideWithValue(
          const FakeAndroidBackgroundCaptureHostStatusService(
            AndroidBackgroundCaptureHostStatus(
              isRunning: false,
              summary: 'Android 宿主后台状态暂未启动。',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(diagnosticsSnapshotProvider.future);

    expect(snapshot.latestActivity, isNull);
    expect(snapshot.liveActivity, isNull);
    expect(snapshot.latestLocationSummary, isNull);
    expect(snapshot.latestNoise, isNull);
    expect(snapshot.liveUsageSummary, isNull);
    expect(snapshot.latestUsageSummary, isNull);
    expect(snapshot.backgroundCaptureState.status, BackgroundCaptureStatus.permissionDenied);
    expect(snapshot.androidHostStatus?.summary, contains('暂未启动'));
    expect(snapshot.storageStatus.kind, DiagnosticsStorageStatusKind.empty);
  });
}
