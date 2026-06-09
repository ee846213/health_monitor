import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/android_foreground_service_strategy.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/android_background_capture_bridge.dart';
import 'package:health_monitor/services/background_capture_service.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((Ref ref) {
  return InMemoryActivityRepository(samples: const <ActivitySample>[]);
});

final locationSummaryRepositoryProvider = Provider<LocationSummaryRepository>((Ref ref) {
  return InMemoryLocationSummaryRepository(summaries: const <LocationSummary>[]);
});

final noiseSampleRepositoryProvider = Provider<NoiseSampleRepository>((Ref ref) {
  return InMemoryNoiseSampleRepository(samples: const <NoiseSample>[]);
});

final usageSummaryRepositoryProvider = Provider<UsageSummaryRepository>((Ref ref) {
  return InMemoryUsageSummaryRepository(summaries: const <DigitalUsageSummary>[]);
});

final capabilityMatrixProvider = Provider<CapabilityMatrix>((Ref ref) {
  return CapabilityMatrix.defaultMatrix();
});

final permissionStatusServiceProvider = Provider<PermissionStatusService>((Ref ref) {
  return const PermissionHandlerStatusService();
});

final motionCaptureServiceProvider = Provider<MotionCaptureService>((Ref ref) {
  return MotionCaptureService();
});

final locationCaptureServiceProvider = Provider<LocationCaptureService>((Ref ref) {
  return LocationCaptureService();
});

final noiseCaptureServiceProvider = Provider<NoiseCaptureService>((Ref ref) {
  return NoiseCaptureService();
});

final digitalUsageCaptureServiceProvider = Provider<DigitalUsageCaptureService>((Ref ref) {
  return DigitalUsageCaptureService();
});

final backgroundCaptureServiceProvider = Provider<BackgroundCaptureStateService>((Ref ref) {
  return const BackgroundCaptureService();
});

final androidForegroundServiceStrategyResolverProvider =
    Provider<AndroidForegroundServiceStrategyResolver>((Ref ref) {
      return const AndroidForegroundServiceStrategyResolver();
    });

final androidBackgroundHostStatusServiceProvider =
    Provider<AndroidBackgroundCaptureHostStatusService>((Ref ref) {
      return AndroidBackgroundCaptureBridge(
        platformBridgeService: PlatformBridgeService(),
      );
    });

enum DiagnosticsStorageStatusKind {
  empty,
  hasRecentWrites,
}

class DiagnosticsStorageStatus {
  const DiagnosticsStorageStatus({
    required this.kind,
    required this.label,
  });

  final DiagnosticsStorageStatusKind kind;
  final String label;
}

class DiagnosticsSnapshot {
  const DiagnosticsSnapshot({
    required this.permissionStatuses,
    required this.liveActivity,
    required this.latestActivity,
    required this.latestLocationSummary,
    required this.latestNoise,
    required this.liveUsageSummary,
    required this.latestUsageSummary,
    required this.backgroundCaptureState,
    required this.androidHostStatus,
    required this.androidForegroundServiceStrategy,
    required this.storageStatus,
  });

  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
  final ActivitySample? liveActivity;
  final ActivitySample? latestActivity;
  final LocationSummary? latestLocationSummary;
  final NoiseSample? latestNoise;
  final DigitalUsageSummary? liveUsageSummary;
  final DigitalUsageSummary? latestUsageSummary;
  final BackgroundCaptureState backgroundCaptureState;
  final AndroidBackgroundCaptureHostStatus? androidHostStatus;
  final AndroidForegroundServiceStrategy androidForegroundServiceStrategy;
  final DiagnosticsStorageStatus storageStatus;
}

final diagnosticsSnapshotProvider = FutureProvider<DiagnosticsSnapshot>((Ref ref) async {
  final capabilityMatrix = ref.watch(capabilityMatrixProvider);
  final activityRepository = ref.watch(activityRepositoryProvider);
  final locationRepository = ref.watch(locationSummaryRepositoryProvider);
  final noiseRepository = ref.watch(noiseSampleRepositoryProvider);
  final usageRepository = ref.watch(usageSummaryRepositoryProvider);
  final permissionService = ref.watch(permissionStatusServiceProvider);
  final motionCaptureService = ref.watch(motionCaptureServiceProvider);
  final locationCaptureService = ref.watch(locationCaptureServiceProvider);
  final noiseCaptureService = ref.watch(noiseCaptureServiceProvider);
  final digitalUsageCaptureService = ref.watch(digitalUsageCaptureServiceProvider);
  final backgroundCaptureService = ref.watch(backgroundCaptureServiceProvider);
  final androidForegroundServiceStrategyResolver = ref.watch(
    androidForegroundServiceStrategyResolverProvider,
  );
  final androidBackgroundHostStatusService = ref.watch(
    androidBackgroundHostStatusServiceProvider,
  );

  final referenceTime = DateTime(2026, 6, 9, 23, 59);
  final activitySamples = await activityRepository.listByWindow(
    QueryWindow.recentHours(24, referenceTime: referenceTime),
  );
  final noiseSamples = await noiseRepository.listByWindow(
    QueryWindow.recentHours(24, referenceTime: referenceTime),
  );
  final locationSummaries = await locationRepository.listRecentDays(
    1,
    referenceDate: referenceTime,
  );
  final usageSummary = await usageRepository.getByDate(referenceTime);
  final permissionStatuses = await permissionService.getStatuses();
  final backgroundCaptureState = await backgroundCaptureService.evaluateState(
    capabilitySet: capabilityMatrix.android,
    permissionStatuses: permissionStatuses,
  );
  final androidForegroundServiceStrategy = androidForegroundServiceStrategyResolver.resolve(
    capabilitySet: capabilityMatrix.android,
    permissionStatuses: permissionStatuses,
    config: const AndroidBackgroundCaptureConfig(
      notificationTitle: '健康监测正在后台运行',
      notificationBody: '用于持续积累活动、位置与用机样本。',
      enableMotion: true,
      enableLocation: true,
      enableNoise: false,
      enableDigitalUsage: true,
      sampleIntervalMinutes: 15,
    ),
  );
  AndroidBackgroundCaptureHostStatus? androidHostStatus;
  try {
    androidHostStatus = await androidBackgroundHostStatusService.getHostStatus();
  } on AndroidBackgroundCaptureException {
    androidHostStatus = null;
  }
  ActivitySample? liveActivity;
  try {
    liveActivity = await motionCaptureService.watchActivitySamples().first;
  } on MotionCaptureException {
    liveActivity = null;
  } on StateError {
    liveActivity = null;
  }
  LocationSummary? liveLocationSummary;
  try {
    liveLocationSummary = await locationCaptureService.watchLocationSummaries().first;
  } on LocationCaptureException {
    liveLocationSummary = null;
  } on StateError {
    liveLocationSummary = null;
  }
  NoiseSample? liveNoise;
  try {
    liveNoise = await noiseCaptureService.watchNoiseSamples().first;
  } on NoiseCaptureException {
    liveNoise = null;
  } on StateError {
    liveNoise = null;
  }
  DigitalUsageSummary? liveUsageSummary;
  try {
    liveUsageSummary = await digitalUsageCaptureService.watchUsageSummaries().first;
  } on DigitalUsageCaptureException {
    liveUsageSummary = null;
  } on StateError {
    liveUsageSummary = null;
  }

  final hasRecentWrites =
      activitySamples.isNotEmpty ||
      noiseSamples.isNotEmpty ||
      locationSummaries.isNotEmpty ||
      usageSummary != null;

  return DiagnosticsSnapshot(
    permissionStatuses: permissionStatuses,
    liveActivity: liveActivity,
    latestActivity: activitySamples.isEmpty ? null : activitySamples.last,
    latestLocationSummary: locationSummaries.isEmpty
        ? liveLocationSummary
        : locationSummaries.last,
    latestNoise: noiseSamples.isEmpty ? liveNoise : noiseSamples.last,
    liveUsageSummary: liveUsageSummary,
    latestUsageSummary: usageSummary ?? liveUsageSummary,
    backgroundCaptureState: backgroundCaptureState,
    androidHostStatus: androidHostStatus,
    androidForegroundServiceStrategy: androidForegroundServiceStrategy,
    storageStatus: DiagnosticsStorageStatus(
      kind: hasRecentWrites
          ? DiagnosticsStorageStatusKind.hasRecentWrites
          : DiagnosticsStorageStatusKind.empty,
      label: hasRecentWrites ? '最近已写入本地记录' : '暂无本地写入记录',
    ),
  );
});
