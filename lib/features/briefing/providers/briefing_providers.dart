import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/briefing/briefing_suggestion_builder.dart';
import 'package:health_monitor/features/overview/providers/overview_detail_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

enum BriefingTimeRange {
  today,
  yesterday,
  recent7Days,
}

extension BriefingTimeRangeLabel on BriefingTimeRange {
  String get label {
    switch (this) {
      case BriefingTimeRange.today:
        return '今日';
      case BriefingTimeRange.yesterday:
        return '昨日';
      case BriefingTimeRange.recent7Days:
        return '最近 7 天';
    }
  }
}

class BriefingViewModel {
  const BriefingViewModel({
    required this.selectedRange,
    required this.windowLabel,
    required this.screenState,
    required this.briefSnapshot,
    required this.permissionStatuses,
    required this.hasRealData,
    required this.isLoading,
    this.missingDimensions = const <String>[],
  });

  final BriefingTimeRange selectedRange;
  final String windowLabel;
  final OverviewScreenState screenState;
  final DailyBriefSnapshot briefSnapshot;
  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
  final List<String> missingDimensions;
  final bool hasRealData;
  final bool isLoading;

  bool get hasMissingDimensions => missingDimensions.isNotEmpty;
}

final briefingReferenceTimeProvider = Provider<DateTime Function()>((Ref ref) {
  return DateTime.now;
});

final briefingTimeRangeProvider = StateProvider<BriefingTimeRange>((Ref ref) {
  return BriefingTimeRange.today;
});

final briefingRangeRevisionProvider = Provider<String>((Ref ref) {
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final referenceTime = ref.watch(briefingReferenceTimeProvider)();
  final dayKeys = _dayKeysForRange(selectedRange, referenceTime);

  return ref.watch(
    dataCollectorDailyRevisionProvider.select(
      (Map<String, int> revisions) =>
          dayKeys.map((String dayKey) => '${revisions[dayKey] ?? 0}').join('|'),
    ),
  );
});

final briefingViewModelProvider =
    FutureProvider<BriefingViewModel>((Ref ref) async {
  ref.watch(briefingRangeRevisionProvider);
  ref.watch(dataCollectorProvider);
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  final insightService = ref.watch(healthInsightServiceProvider);
  final now = ref.watch(briefingReferenceTimeProvider)();
  final snapshot = await insightService.buildSnapshot(
    window: _windowForRange(selectedRange, referenceTime: now),
    referenceTime: now,
  );

  return BriefingViewModel(
    selectedRange: selectedRange,
    windowLabel: _windowLabelForRange(selectedRange),
    screenState: resolveOverviewScreenState(
      permissionStatuses: permissionStatuses,
      hasRealData: snapshot.hasRealData,
      hasReminderHistory: snapshot.reminderHistory.isNotEmpty,
    ),
    briefSnapshot: _buildDailyBriefSnapshot(snapshot),
    permissionStatuses: permissionStatuses,
    missingDimensions: snapshot.input.missingDimensions
        .map(localizedDimensionLabel)
        .toList(growable: false),
    hasRealData: snapshot.hasRealData,
    isLoading: false,
  );
});

final _briefingViewModelCacheProvider =
    NotifierProvider<_BriefingViewModelCacheNotifier, BriefingViewModel?>(
  _BriefingViewModelCacheNotifier.new,
);

final briefingViewModelStateProvider = Provider<BriefingViewModel?>((Ref ref) {
  return ref.watch(_briefingViewModelCacheProvider);
});

class _BriefingViewModelCacheNotifier extends Notifier<BriefingViewModel?> {
  @override
  BriefingViewModel? build() {
    ref.listen<AsyncValue<BriefingViewModel>>(
      briefingViewModelProvider,
      (
        AsyncValue<BriefingViewModel>? previous,
        AsyncValue<BriefingViewModel> next,
      ) {
        final nextValue = next.valueOrNull;
        if (nextValue != null) {
          state = nextValue;
        }
      },
      fireImmediately: true,
    );
    return ref.read(briefingViewModelProvider).valueOrNull;
  }
}

final briefingPageRangeProvider =
    Provider<AsyncValue<BriefingTimeRange>>((Ref ref) {
  final cachedRange = ref.watch(
    briefingViewModelStateProvider.select(
      (BriefingViewModel? viewModel) => viewModel?.selectedRange,
    ),
  );
  if (cachedRange != null) {
    return AsyncData<BriefingTimeRange>(cachedRange);
  }
  return ref.watch(briefingViewModelProvider).whenData(
        (BriefingViewModel viewModel) => viewModel.selectedRange,
      );
});

final briefingWindowLabelProvider = Provider<String>((Ref ref) {
  return ref.watch(
        briefingViewModelStateProvider.select(
          (BriefingViewModel? viewModel) => viewModel?.windowLabel,
        ),
      ) ??
      ref.watch(briefingTimeRangeProvider).label;
});

final briefingHasRealDataProvider = Provider<bool>((Ref ref) {
  return ref.watch(
        briefingViewModelStateProvider.select(
          (BriefingViewModel? viewModel) => viewModel?.hasRealData,
        ),
      ) ??
      false;
});

final briefingHeadlineProvider = Provider<String>((Ref ref) {
  return ref.watch(
        briefingViewModelStateProvider.select(
          (BriefingViewModel? viewModel) => viewModel?.briefSnapshot.headline,
        ),
      ) ??
      '等待采集数据';
});

final briefingSupportingDetailProvider = Provider<String>((Ref ref) {
  return ref.watch(
        briefingViewModelStateProvider.select(
          (BriefingViewModel? viewModel) =>
              viewModel?.briefSnapshot.supportingDetail,
        ),
      ) ??
      '数据正在积累。';
});

final briefingMetricsProvider = Provider<List<DailyBriefMetric>>((Ref ref) {
  return ref.watch(
        briefingViewModelStateProvider.select(
          (BriefingViewModel? viewModel) => viewModel?.briefSnapshot.metrics,
        ),
      ) ??
      const <DailyBriefMetric>[];
});

final briefingSuggestionsProvider = Provider<List<String>>((Ref ref) {
  return ref.watch(
        briefingViewModelStateProvider.select(
          (BriefingViewModel? viewModel) =>
              viewModel?.briefSnapshot.suggestions,
        ),
      ) ??
      const <String>[];
});

final briefingQualityNoteProvider = Provider<String?>((Ref ref) {
  return ref.watch(
    briefingViewModelStateProvider.select(
      (BriefingViewModel? viewModel) => viewModel?.briefSnapshot.qualityNote,
    ),
  );
});

final briefingStepDetailProvider =
    FutureProvider.family<OverviewStepDetailSnapshot, BriefingTimeRange>(
        (Ref ref, range) async {
  ref.watch(dataCollectorMetricsRevisionProvider);
  final repository = ref.watch(metricsRepositoryProvider);
  final referenceTime = ref.watch(briefingReferenceTimeProvider)();
  final anchorDate = _anchorDateForRange(range, referenceTime);
  final metrics = await repository.listRecentDays(
    7,
    referenceDate: anchorDate,
  );
  final metricsByKey = <String, int>{
    for (final item in metrics) DateKey.fromDate(item.date): item.stepCount,
  };
  final anchorKey = DateKey.fromDate(anchorDate);
  final points = <OverviewStepTrendPoint>[];

  for (var offset = 6; offset >= 0; offset -= 1) {
    final date = DateTime(anchorDate.year, anchorDate.month, anchorDate.day)
        .subtract(Duration(days: offset));
    final key = DateKey.fromDate(date);
    points.add(
      OverviewStepTrendPoint(
        date: date,
        steps: metricsByKey[key] ?? 0,
        isToday: range == BriefingTimeRange.today && key == anchorKey,
      ),
    );
  }

  const goalSteps = 6000;
  final rangeSteps = range == BriefingTimeRange.recent7Days
      ? points.fold<int>(0, (total, point) => total + point.steps)
      : points.last.steps;
  final goalForRange =
      range == BriefingTimeRange.recent7Days ? goalSteps * 7 : goalSteps;

  return OverviewStepDetailSnapshot(
    goalSteps: goalForRange,
    todaySteps: rangeSteps,
    todayProgress: goalForRange == 0 ? 0 : rangeSteps / goalForRange,
    points: points,
  );
});

final briefingSedentaryDetailProvider =
    FutureProvider.family<OverviewSedentaryDetailSnapshot, BriefingTimeRange>(
  (Ref ref, range) async {
    ref.watch(dataCollectorMetricsRevisionProvider);
    final repository = ref.watch(activityRepositoryProvider);
    final referenceTime = ref.watch(briefingReferenceTimeProvider)();
    final window = _windowForRange(range, referenceTime: referenceTime);
    final samples = await repository.listByWindow(window);
    final input = RuleInput(
      window: window,
      activitySamples: samples,
      locationSummaries: const <LocationSummary>[],
      noiseSamples: const <NoiseSample>[],
      ambientLightSamples: const <AmbientLightSample>[],
      usageSummaries: const <DigitalUsageSummary>[],
      dailyMetricsList: const <DailyMetrics>[],
      missingDimensions: const <String>[],
    );
    final segments = input.sedentarySegments
        .map(
          (segment) => OverviewSedentarySegmentSnapshot(
            startedAt: segment.startedAt,
            endedAt: segment.endedAt,
            duration: segment.duration,
          ),
        )
        .toList(growable: false);
    final totalDuration = segments.fold<Duration>(
      Duration.zero,
      (total, segment) => total + segment.duration,
    );
    final longestDuration = segments.fold<Duration>(
      Duration.zero,
      (longest, segment) =>
          segment.duration > longest ? segment.duration : longest,
    );

    return OverviewSedentaryDetailSnapshot(
      totalDuration: totalDuration,
      longestDuration: longestDuration,
      segments: segments,
    );
  },
);

final briefingScreenDetailProvider =
    FutureProvider.family<OverviewScreenDetailSnapshot, BriefingTimeRange>(
        (Ref ref, range) async {
  ref.watch(dataCollectorUsageRevisionProvider);
  final repository = ref.watch(usageSummaryRepositoryProvider);
  final referenceTime = ref.watch(briefingReferenceTimeProvider)();
  final window = _windowForRange(range, referenceTime: referenceTime);
  final summaries = <DigitalUsageSummary>[];
  for (final date in window.dailyDates()) {
    final summary = await repository.getByDate(date);
    if (summary != null) {
      summaries.add(summary);
    }
  }

  final totalDuration = summaries.fold<Duration>(
    Duration.zero,
    (total, summary) => total + summary.screenOnDuration,
  );
  final nightDuration = summaries.fold<Duration>(
    Duration.zero,
    (total, summary) => total + summary.nighttimeUsageDuration,
  );
  final dayDuration = totalDuration > nightDuration
      ? totalDuration - nightDuration
      : Duration.zero;
  final hasDegraded = summaries.any(
    (summary) => summary.completeness == UsageDataCompleteness.degraded,
  );
  final hasGap = summaries.any(
    (summary) => summary.completeness == UsageDataCompleteness.partialGap,
  );

  return OverviewScreenDetailSnapshot(
    todaySummary: summaries.isEmpty ? null : summaries.last,
    yesterdaySummary: null,
    totalDuration: totalDuration,
    deltaMinutes: 0,
    buckets: <OverviewScreenUsageBucket>[
      OverviewScreenUsageBucket(
        label: '白天',
        duration: dayDuration,
        subtitle: '06:00 - 22:00',
      ),
      OverviewScreenUsageBucket(
        label: '夜间',
        duration: nightDuration,
        subtitle: '22:00 - 06:00',
      ),
    ],
    sourceLabel: summaries.isEmpty ? '暂无数据源' : '简报范围汇总',
    qualityLabel: hasDegraded
        ? '当前范围包含降级口径数据'
        : hasGap
            ? '当前范围部分时段有缺口'
            : null,
  );
});

String _windowLabelForRange(BriefingTimeRange range) {
  return range.label;
}

DailyBriefSnapshot _buildDailyBriefSnapshot(HealthInsightSnapshot snapshot) {
  final usageSummary = snapshot.screenUsageHabitSummary;
  final primaryVerdict =
      snapshot.verdicts.isEmpty ? null : snapshot.verdicts.first;
  final headline =
      usageSummary?.headline ?? primaryVerdict?.summary ?? '等待采集数据';
  final supportingDetail = usageSummary?.supportingDetail ??
      primaryVerdict?.detail ??
      '应用刚启动，数据还在积累，稍后再回来查看简报。';

  final suggestions = _buildSuggestions(snapshot);
  final metrics = <DailyBriefMetric>[
    DailyBriefMetric(
      label: '步数',
      value: '${snapshot.metrics.stepCount}',
      unit: '步',
    ),
    DailyBriefMetric(
      label: '久坐',
      value: '${snapshot.metrics.sedentaryMinutes}',
      unit: '分钟',
    ),
    DailyBriefMetric(
      label: '屏幕使用',
      value: '${snapshot.metrics.screenMinutes}',
      unit: '分钟',
    ),
  ];

  final qualityNote = usageSummary?.qualityNote ??
      (snapshot.input.missingDimensions.isNotEmpty
          ? '部分维度仍在积累：'
              '${snapshot.input.missingDimensions.map(localizedDimensionLabel).join('、')}。'
          : null);

  return DailyBriefSnapshot(
    headline: headline,
    supportingDetail: supportingDetail,
    metrics: metrics,
    suggestions: suggestions,
    qualityNote: qualityNote,
  );
}

List<String> _buildSuggestions(HealthInsightSnapshot snapshot) {
  return buildBriefingSuggestions(snapshot);

  final suggestions = <String>[];
  final metrics = snapshot.metrics;
  final usageSummary = snapshot.screenUsageHabitSummary;

  if (usageSummary != null && usageSummary.headline.contains('深夜')) {
    suggestions.add('今晚尽量提前结束看屏，把最后十分钟留给放松和入睡准备。');
  } else if (usageSummary != null && usageSummary.headline.contains('查看频率偏高')) {
    suggestions.add('把零散查看压缩到固定时段，给连续专注留出完整区间。');
  } else if (usageSummary != null && usageSummary.headline.contains('时段激活过密')) {
    suggestions.add('遇到短间隔再次拿起手机时，先停一秒确认是否真的需要查看。');
  }

  final environmentOverview = snapshot.environmentOverview;
  if (environmentOverview != null &&
      environmentOverview.primaryConcern ==
          EnvironmentPrimaryConcern.highNoise) {
    suggestions.add('夜间环境偏嘈杂，睡前尽量切到更安静的空间。');
  } else if (environmentOverview != null &&
      environmentOverview.primaryConcern ==
          EnvironmentPrimaryConcern.lowLight) {
    suggestions.add('白天光线偏暗，工作或学习时尽量靠近自然光。');
  }

  if (metrics.stepCount < 5000) {
    suggestions.add('今天活动量偏少，可以安排一次 10 到 15 分钟的补步。');
  } else if (metrics.sedentaryMinutes >= 180) {
    suggestions.add('久坐时间偏长，接下来每小时起身活动两三分钟会更稳妥。');
  }

  if (suggestions.isEmpty) {
    suggestions.add('整体节奏比较平稳，继续保持现在的作息和用机边界。');
  }

  return suggestions.take(2).toList(growable: false);
}

QueryWindow _windowForRange(
  BriefingTimeRange range, {
  required DateTime referenceTime,
}) {
  final anchorDate = _anchorDateForRange(range, referenceTime);
  switch (range) {
    case BriefingTimeRange.today:
      return QueryWindow.calendarDay(referenceDate: anchorDate);
    case BriefingTimeRange.yesterday:
      return QueryWindow.calendarDay(referenceDate: anchorDate);
    case BriefingTimeRange.recent7Days:
      // 最近 7 日简报只回顾已完成自然日，避免今日实时采集持续拉动页面刷新。
      return QueryWindow.recentCalendarDays(
        7,
        referenceDate: anchorDate,
      );
  }
}

DateTime _anchorDateForRange(
  BriefingTimeRange range,
  DateTime referenceTime,
) {
  switch (range) {
    case BriefingTimeRange.today:
      return referenceTime;
    case BriefingTimeRange.yesterday:
    case BriefingTimeRange.recent7Days:
      return referenceTime.subtract(const Duration(days: 1));
  }
}

List<String> _dayKeysForRange(
  BriefingTimeRange range,
  DateTime referenceTime,
) {
  final window = _windowForRange(range, referenceTime: referenceTime);
  return window.dailyDates().map(_dayKey).toList(growable: false);
}

String _dayKey(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day';
}
