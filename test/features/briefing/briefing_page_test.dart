import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/briefing/pages/briefing_page.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

void main() {
  testWidgets('简报页默认显示今日时间段并支持切换', (WidgetTester tester) async {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final yesterdayDay = todayDay.subtract(const Duration(days: 1));
    final weekAgoDay = todayDay.subtract(const Duration(days: 2));

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

    _seedDay(
      activityRepository: activityRepository,
      noiseRepository: noiseRepository,
      locationRepository: locationRepository,
      usageRepository: usageRepository,
      metricsRepository: metricsRepository,
      day: todayDay,
      stepCount: 1200,
      screenMinutes: 90,
      outdoorMinutes: 20,
      stationarySamples: 2,
    );
    _seedDay(
      activityRepository: activityRepository,
      noiseRepository: noiseRepository,
      locationRepository: locationRepository,
      usageRepository: usageRepository,
      metricsRepository: metricsRepository,
      day: yesterdayDay,
      stepCount: 2400,
      screenMinutes: 150,
      outdoorMinutes: 35,
      stationarySamples: 0,
    );
    _seedDay(
      activityRepository: activityRepository,
      noiseRepository: noiseRepository,
      locationRepository: locationRepository,
      usageRepository: usageRepository,
      metricsRepository: metricsRepository,
      day: weekAgoDay,
      stepCount: 3600,
      screenMinutes: 210,
      outdoorMinutes: 50,
      stationarySamples: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
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
        child: const MaterialApp(home: Scaffold(body: BriefingPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SegmentedButton<BriefingTimeRange>),
        matching: find.text('今日'),
      ),
      findsOneWidget,
    );
    expect(find.text('1200 步'), findsOneWidget);

    await tester.tap(find.text('昨日'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SegmentedButton<BriefingTimeRange>),
        matching: find.text('昨日'),
      ),
      findsOneWidget,
    );
    expect(find.text('2400 步'), findsOneWidget);

    await tester.tap(find.text('最近 7 天'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SegmentedButton<BriefingTimeRange>),
        matching: find.text('最近 7 天'),
      ),
      findsOneWidget,
    );
    expect(find.text('6000 步'), findsOneWidget);
  });
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
  required int stationarySamples,
}) {
  if (stationarySamples > 0) {
    for (var index = 0; index < stationarySamples; index += 1) {
      activityRepository.addSample(
        ActivitySample(
          capturedAt: day.add(Duration(hours: 9 + index * 2)),
          duration: const Duration(minutes: 35),
          type: ActivityType.stationary,
          confidence: 0.9,
          stepCount: 0,
          source: MotionSampleSource.sensorFusion,
        ),
      );
    }
  } else {
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
  }
  noiseRepository.addSample(
    NoiseSample(
      capturedAt: day.add(const Duration(hours: 12)),
      duration: const Duration(minutes: 10),
      decibel: 45,
      level: NoiseLevel.quiet,
    ),
  );
  locationRepository.upsertSummary(
    LocationSummary(
      date: day,
      distanceMeters: 1000 + stepCount.toDouble(),
      outdoorDuration: Duration(minutes: outdoorMinutes),
      visitCount: 1,
      commuteCount: 0,
    ),
  );
  usageRepository.upsertSummary(
    DigitalUsageSummary(
      date: day,
      screenOnDuration: Duration(minutes: screenMinutes),
      unlockCount: 20,
      nighttimeUsageDuration: Duration.zero,
      focusSessionBreakCount: 0,
      topCategory: UsageCategory.unknown,
    ),
  );
  metricsRepository.upsertMetrics(
    DailyMetrics(
      date: day,
      stepCount: stepCount,
      sedentaryDuration: const Duration(minutes: 60),
      screenOnDuration: Duration(minutes: screenMinutes),
      outdoorDuration: Duration(minutes: outdoorMinutes),
      postureRiskCount: 0,
      highNoiseExposureDuration: Duration.zero,
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
