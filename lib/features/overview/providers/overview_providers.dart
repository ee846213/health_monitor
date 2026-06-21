import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/overview_advice_builder.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/ai_suggestion_service.dart';
import 'package:health_monitor/services/android_risk_event_bridge.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/services/dashboard_service.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/ai_suggestion_cache_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

final overviewPermissionStatusServiceProvider =
    Provider<PermissionStatusService>((Ref ref) {
  return const PermissionHandlerStatusService();
});

final permissionStatusProvider =
    FutureProvider<Map<PermissionType, PermissionGrantStatus>>((Ref ref) async {
  final service = ref.watch(overviewPermissionStatusServiceProvider);
  return service.getStatuses();
});

final reminderRepositoryProvider = FutureProvider<ReminderRepository>(
  (Ref ref) async {
    final isar = await ref.watch(appIsarProvider.future);
    return IsarReminderRepository(isar);
  },
);

final aiSuggestionCacheRepositoryProvider =
    FutureProvider<AiSuggestionCacheRepository>((Ref ref) async {
  final isar = await ref.watch(appIsarProvider.future);
  return IsarAiSuggestionCacheRepository(isar);
});

final aiSuggestionDioProvider = Provider<Dio>((Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.openai.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
});

final aiSuggestionServiceProvider = FutureProvider<AiSuggestionService>(
  (Ref ref) async {
    final cacheRepository =
        await ref.watch(aiSuggestionCacheRepositoryProvider.future);
    return AiSuggestionService(
      cacheRepository: cacheRepository,
      dio: ref.watch(aiSuggestionDioProvider),
      apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
      model: const String.fromEnvironment(
        'OPENAI_MODEL',
        defaultValue: 'gpt-5.5',
      ),
      fallbackBuilder: (
        RuleInput input,
        HealthInsightMetrics metrics,
        List<RuleVerdict> verdicts,
        EnvironmentOverview? environmentOverview,
      ) {
        return buildDashboardFallbackAdvice(
          metrics: metrics,
          verdicts: verdicts,
          environmentOverview: environmentOverview,
        );
      },
    );
  },
);

final healthInsightServiceProvider = Provider<HealthInsightService>((Ref ref) {
  return HealthInsightService(
    activityRepository: ref.watch(sharedActivityRepo),
    ambientLightRepository: ref.watch(sharedAmbientLightRepo),
    locationRepository: ref.watch(sharedLocationRepo),
    noiseRepository: ref.watch(sharedNoiseRepo),
    usageRepository: ref.watch(sharedUsageRepo),
    metricsRepository: ref.watch(sharedMetricsRepo),
    reminderRepositoryLoader: () => ref.read(reminderRepositoryProvider.future),
    androidRiskEventBridge: AndroidRiskEventBridge(
      platformBridgeService: PlatformBridgeService(),
    ),
    androidUsageStatsBridge: AndroidUsageStatsBridge(
      platformBridgeService: PlatformBridgeService(),
    ),
  );
});

final dashboardServiceProvider = Provider<DashboardService>((Ref ref) {
  final insightService = ref.watch(healthInsightServiceProvider);
  return DashboardService(
    loadInsightSnapshot: ({
      required QueryWindow window,
      DateTime? referenceTime,
    }) {
      return insightService.buildSnapshot(
        window: window,
        referenceTime: referenceTime,
      );
    },
    buildDailyAdvice: ({
      required DateTime referenceTime,
      required RuleInput input,
      required HealthInsightMetrics metrics,
      required List<RuleVerdict> verdicts,
      required EnvironmentOverview? environmentOverview,
    }) async {
      final aiSuggestionService =
          await ref.read(aiSuggestionServiceProvider.future);
      return aiSuggestionService.buildDailyAdvice(
        referenceTime: referenceTime,
        input: input,
        metrics: metrics,
        verdicts: verdicts,
        environmentOverview: environmentOverview,
      );
    },
  );
});

enum OverviewScreenState {
  ready,
  permissionDenied,
  dataInsufficient,
}

class OverviewDashboardViewModel {
  const OverviewDashboardViewModel({
    required this.screenState,
    required this.dashboard,
    required this.permissionStatuses,
    this.preciseDetectionNotice,
    this.missingDimensions = const <String>[],
    this.reminders = const <ReminderRecord>[],
  });

  final OverviewScreenState screenState;
  final DashboardSnapshot dashboard;
  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
  final String? preciseDetectionNotice;
  final List<String> missingDimensions;
  final List<ReminderRecord> reminders;

  bool get hasMissingDimensions => missingDimensions.isNotEmpty;
  bool get hasRealData => dashboard.hasRealData;
  bool get hasPreciseDetectionNotice =>
      preciseDetectionNotice != null && preciseDetectionNotice!.isNotEmpty;
}

final walkingScreenRiskNoticeProvider =
    FutureProvider<String?>((Ref ref) async {
  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  return buildWalkingScreenRiskPrecisionNotice(
    permissionStatuses: permissionStatuses,
    isAndroid: Platform.isAndroid,
    isIOS: Platform.isIOS,
  );
});

final overviewViewModelProvider =
    FutureProvider<OverviewDashboardViewModel>((Ref ref) async {
  ref.watch(dataCollectorMetricsRevisionProvider);
  ref.watch(dataCollectorEnvironmentRevisionProvider);
  ref.watch(dataCollectorUsageRevisionProvider);
  ref.watch(dataCollectorReminderRevisionProvider);
  ref.watch(dataCollectorProvider);

  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  final insightService = ref.watch(healthInsightServiceProvider);
  final dashboardService = ref.watch(dashboardServiceProvider);
  final referenceTime = DateTime.now();
  final insight = await insightService.buildSnapshot(
    window: QueryWindow.recentDay(referenceTime: referenceTime),
  );
  final dashboard = await dashboardService.buildFromInsight(
    insight: insight,
    referenceTime: referenceTime,
  );

  return OverviewDashboardViewModel(
    screenState: resolveOverviewScreenState(
      permissionStatuses: permissionStatuses,
      hasRealData: dashboard.hasRealData,
      hasReminderHistory: dashboard.hasReminderHistory,
    ),
    dashboard: dashboard,
    preciseDetectionNotice: buildWalkingScreenRiskPrecisionNotice(
      permissionStatuses: permissionStatuses,
      isAndroid: Platform.isAndroid,
      isIOS: Platform.isIOS,
    ),
    reminders: insight.reminderHistory,
    permissionStatuses: permissionStatuses,
    missingDimensions: insight.input.missingDimensions
        .map(localizedDimensionLabel)
        .toList(growable: false),
  );
});

final _profileViewModelCacheProvider = NotifierProvider<
    _ProfileViewModelCacheNotifier, OverviewDashboardViewModel?>(
  _ProfileViewModelCacheNotifier.new,
);

final profileViewModelStateProvider =
    Provider<OverviewDashboardViewModel?>((Ref ref) {
  return ref.watch(_profileViewModelCacheProvider);
});

final profilePageReadyProvider = Provider<AsyncValue<bool>>((Ref ref) {
  final hasCachedData = ref.watch(
    profileViewModelStateProvider.select(
      (OverviewDashboardViewModel? viewModel) => viewModel != null,
    ),
  );
  if (hasCachedData) {
    return const AsyncData<bool>(true);
  }
  return ref.watch(overviewViewModelProvider).whenData((_) => true);
});

final profileRemindersProvider = Provider<List<ReminderRecord>>((Ref ref) {
  return ref.watch(
        profileViewModelStateProvider.select(
          (OverviewDashboardViewModel? viewModel) => viewModel?.reminders,
        ),
      ) ??
      const <ReminderRecord>[];
});

final profilePermissionStatusesProvider =
    Provider<Map<PermissionType, PermissionGrantStatus>>((Ref ref) {
  return ref.watch(
        profileViewModelStateProvider.select(
          (OverviewDashboardViewModel? viewModel) =>
              viewModel?.permissionStatuses,
        ),
      ) ??
      const <PermissionType, PermissionGrantStatus>{};
});

class _ProfileViewModelCacheNotifier
    extends Notifier<OverviewDashboardViewModel?> {
  @override
  OverviewDashboardViewModel? build() {
    ref.listen<AsyncValue<OverviewDashboardViewModel>>(
      overviewViewModelProvider,
      (
        AsyncValue<OverviewDashboardViewModel>? previous,
        AsyncValue<OverviewDashboardViewModel> next,
      ) {
        final viewModel = next.valueOrNull;
        if (viewModel != null) {
          state = viewModel;
        }
      },
      fireImmediately: true,
    );
    return ref.read(overviewViewModelProvider).valueOrNull;
  }
}

final reminderListProvider =
    FutureProvider<List<ReminderRecord>>((Ref ref) async {
  ref.watch(dataCollectorReminderRevisionProvider);
  final repository = await ref.watch(reminderRepositoryProvider.future);
  return repository.listRecentDays(
    7,
    referenceDate: DateTime.now(),
  );
});

final _reminderListCacheProvider =
    NotifierProvider<_ReminderListCacheNotifier, List<ReminderRecord>?>(
  _ReminderListCacheNotifier.new,
);

final reminderListStateProvider =
    Provider<AsyncValue<List<ReminderRecord>>>((Ref ref) {
  final cachedRecords = ref.watch(_reminderListCacheProvider);
  if (cachedRecords != null) {
    return AsyncData<List<ReminderRecord>>(cachedRecords);
  }
  return ref.watch(reminderListProvider);
});

class _ReminderListCacheNotifier extends Notifier<List<ReminderRecord>?> {
  @override
  List<ReminderRecord>? build() {
    ref.listen<AsyncValue<List<ReminderRecord>>>(
      reminderListProvider,
      (
        AsyncValue<List<ReminderRecord>>? previous,
        AsyncValue<List<ReminderRecord>> next,
      ) {
        final records = next.valueOrNull;
        if (records != null) {
          state = records;
        }
      },
      fireImmediately: true,
    );
    return ref.read(reminderListProvider).valueOrNull;
  }
}

final latestReminderProvider = FutureProvider<ReminderRecord?>((Ref ref) async {
  ref.watch(dataCollectorReminderRevisionProvider);
  final repository = await ref.watch(reminderRepositoryProvider.future);
  return repository.getLatest();
});

OverviewScreenState resolveOverviewScreenState({
  required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  required bool hasRealData,
  required bool hasReminderHistory,
}) {
  final motionStatus = permissionStatuses[PermissionType.motion];
  final locationStatus = permissionStatuses[PermissionType.location];
  final microphoneStatus = permissionStatuses[PermissionType.microphone];
  final corePermissionsDenied = <PermissionGrantStatus?>[
    motionStatus,
    locationStatus,
    microphoneStatus,
  ].every(_isUnavailablePermission);

  if (corePermissionsDenied && !hasRealData && !hasReminderHistory) {
    return OverviewScreenState.permissionDenied;
  }
  if (!hasRealData && !hasReminderHistory) {
    return OverviewScreenState.dataInsufficient;
  }
  return OverviewScreenState.ready;
}

bool _isUnavailablePermission(PermissionGrantStatus? status) {
  return status == PermissionGrantStatus.denied ||
      status == PermissionGrantStatus.restricted;
}

String localizedDimensionLabel(String dimension) {
  switch (dimension) {
    case 'activity':
      return '活动状态';
    case 'location':
      return '位置摘要';
    case 'noise':
      return '环境噪音';
    case 'light':
      return '环境光照';
    case 'digital_usage':
      return '数字生活';
    case 'daily_metrics':
      return '日指标聚合';
    default:
      return dimension;
  }
}

String? buildWalkingScreenRiskPrecisionNotice({
  required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  required bool isAndroid,
  required bool isIOS,
}) {
  if (isIOS) {
    return '当前平台仅提供替代指标，不提供走路看屏精确事件识别。';
  }
  if (!isAndroid) {
    return null;
  }

  final backgroundStatus =
      permissionStatuses[PermissionType.backgroundCapture] ??
          PermissionGrantStatus.unknown;
  if (backgroundStatus != PermissionGrantStatus.granted) {
    return '移动中看屏风险仅在后台采集开启后可精确识别。';
  }
  return null;
}
