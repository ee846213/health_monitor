import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_builder.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_window.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/features/briefing/briefing_suggestion_builder.dart';
import 'package:health_monitor/features/overview/providers/daily_rhythm_clock_provider.dart';
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
    required this.selectionKey,
    required this.selectedRange,
    required this.windowLabel,
    required this.screenState,
    required this.briefSnapshot,
    required this.permissionStatuses,
    required this.hasRealData,
    required this.isLoading,
    this.dashboard,
    this.missingDimensions = const <String>[],
  });

  final String selectionKey;
  final BriefingTimeRange selectedRange;
  final String windowLabel;
  final OverviewScreenState screenState;
  final DailyBriefSnapshot briefSnapshot;
  final DashboardSnapshot? dashboard;
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

/// 选择具体自然日时记录日期；最近 7 日汇总使用 `null`。
final briefingSelectedDateProvider = StateProvider<DateTime?>((Ref ref) {
  return null;
});

/// 当前 UI 选中的简报范围键，用于避免切换日期时短暂展示旧数据。
final briefingCurrentSelectionKeyProvider = Provider<String>((Ref ref) {
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final selectedDate = ref.watch(briefingSelectedDateProvider);
  final actualNow = ref.watch(briefingReferenceTimeProvider)();
  return _selectionKey(
    range: selectedRange,
    selectedDate: selectedDate,
    actualNow: actualNow,
  );
});

final briefingRangeRevisionProvider = Provider<String>((Ref ref) {
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final referenceTime = ref.watch(briefingSelectedDateProvider) ??
      ref.watch(briefingReferenceTimeProvider)();
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
  final dataCollector = ref.watch(dataCollectorProvider);
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final selectedDate = ref.watch(briefingSelectedDateProvider);
  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  final insightService = ref.watch(healthInsightServiceProvider);
  final dashboardService = ref.watch(dashboardServiceProvider);
  final actualNow = ref.watch(briefingReferenceTimeProvider)();
  final now = selectedDate ?? actualNow;
  await _syncHistoricalSelectionIfNeeded(
    ref: ref,
    dataCollector: dataCollector,
    range: selectedRange,
    referenceTime: now,
    actualNow: actualNow,
  );
  final snapshot = await insightService.buildSnapshot(
    window: _windowForRange(selectedRange, referenceTime: now),
    referenceTime: now,
  );
  final dashboard = selectedRange == BriefingTimeRange.recent7Days
      ? null
      : await dashboardService.buildFromInsight(
          insight: snapshot,
          referenceTime: now,
        );
  final selectionKey = _selectionKey(
    range: selectedRange,
    selectedDate: selectedDate,
    actualNow: actualNow,
  );

  return BriefingViewModel(
    selectionKey: selectionKey,
    selectedRange: selectedRange,
    windowLabel: _windowLabelForSelection(
      selectedRange,
      selectedDate,
      actualNow,
    ),
    screenState: resolveOverviewScreenState(
      permissionStatuses: permissionStatuses,
      hasRealData: snapshot.hasRealData,
      hasReminderHistory: snapshot.reminderHistory.isNotEmpty,
    ),
    briefSnapshot: _buildDailyBriefSnapshot(
      snapshot,
      dashboard: dashboard,
    ),
    dashboard: dashboard,
    permissionStatuses: permissionStatuses,
    missingDimensions: snapshot.input.missingDimensions
        .map(localizedDimensionLabel)
        .toList(growable: false),
    hasRealData: snapshot.hasRealData,
    isLoading: false,
  );
});

final briefingViewModelStateProvider = Provider<BriefingViewModel?>((Ref ref) {
  final currentKey = ref.watch(briefingCurrentSelectionKeyProvider);
  final value = ref.watch(briefingViewModelProvider).valueOrNull;
  if (value != null && value.selectionKey == currentKey) {
    return value;
  }
  return null;
});

/// 与 [briefingViewModelStateProvider] 相同，语义上强调「当前选中范围已就绪」。
final briefingEffectiveViewModelProvider = briefingViewModelStateProvider;

final briefingContentLoadingProvider = Provider<bool>((Ref ref) {
  return ref.watch(briefingViewModelStateProvider) == null;
});

final briefingPageRangeProvider =
    Provider<AsyncValue<BriefingTimeRange>>((Ref ref) {
  return AsyncData<BriefingTimeRange>(ref.watch(briefingTimeRangeProvider));
});

final briefingWindowLabelProvider = Provider<String>((Ref ref) {
  final viewModel = ref.watch(briefingViewModelStateProvider);
  if (viewModel != null) {
    return viewModel.windowLabel;
  }
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final selectedDate = ref.watch(briefingSelectedDateProvider);
  final actualNow = ref.watch(briefingReferenceTimeProvider)();
  return _windowLabelForSelection(selectedRange, selectedDate, actualNow);
});

final briefingHasRealDataProvider = Provider<bool>((Ref ref) {
  return ref.watch(
        briefingEffectiveViewModelProvider.select(
          (BriefingViewModel? viewModel) => viewModel?.hasRealData,
        ),
      ) ??
      false;
});

final briefingHeadlineProvider = Provider<String>((Ref ref) {
  return ref.watch(
        briefingEffectiveViewModelProvider.select(
          (BriefingViewModel? viewModel) => viewModel?.briefSnapshot.headline,
        ),
      ) ??
      '等待采集数据';
});

final briefingSupportingDetailProvider = Provider<String>((Ref ref) {
  return ref.watch(
        briefingEffectiveViewModelProvider.select(
          (BriefingViewModel? viewModel) =>
              viewModel?.briefSnapshot.supportingDetail,
        ),
      ) ??
      '数据正在积累。';
});

final briefingMetricsProvider = Provider<List<DailyBriefMetric>>((Ref ref) {
  return ref.watch(
        briefingEffectiveViewModelProvider.select(
          (BriefingViewModel? viewModel) => viewModel?.briefSnapshot.metrics,
        ),
      ) ??
      const <DailyBriefMetric>[];
});

final briefingSuggestionsProvider = Provider<List<String>>((Ref ref) {
  return ref.watch(
        briefingEffectiveViewModelProvider.select(
          (BriefingViewModel? viewModel) =>
              viewModel?.briefSnapshot.suggestions,
        ),
      ) ??
      const <String>[];
});

final briefingQualityNoteProvider = Provider<String?>((Ref ref) {
  return ref.watch(
    briefingEffectiveViewModelProvider.select(
      (BriefingViewModel? viewModel) => viewModel?.briefSnapshot.qualityNote,
    ),
  );
});

final briefingDailyRhythmProvider = Provider<DailyRhythmUiModel?>((Ref ref) {
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  if (selectedRange == BriefingTimeRange.recent7Days) {
    return null;
  }

  final viewModel = ref.watch(briefingEffectiveViewModelProvider);
  final dashboard = viewModel?.dashboard;
  if (dashboard == null) {
    return null;
  }

  final actualNow = ref.watch(briefingReferenceTimeProvider)();
  final selectedDate = ref.watch(briefingSelectedDateProvider) ?? actualNow;
  final calendarDay = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final isToday = DateKey.fromDate(calendarDay) == DateKey.fromDate(actualNow);
  final windowEnd = isToday
      ? _maxDateTime(
          ref.watch(dailyRhythmClockProvider),
          dashboard.generatedAt,
        )
      : DailyRhythmWindow.endOfCalendarDay(calendarDay);

  return buildDailyRhythmUiModel(
    dashboard: dashboard,
    missingDimensions: viewModel!.missingDimensions,
    calendarDay: calendarDay,
    windowEnd: windowEnd,
  );
});

final briefingStepDetailProvider =
    FutureProvider.family<OverviewStepDetailSnapshot, BriefingTimeRange>(
        (Ref ref, range) async {
  ref.watch(dataCollectorMetricsRevisionProvider);
  final repository = ref.watch(metricsRepositoryProvider);
  final referenceTime = ref.watch(briefingSelectedDateProvider) ??
      ref.watch(briefingReferenceTimeProvider)();
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
    final referenceTime = ref.watch(briefingSelectedDateProvider) ??
        ref.watch(briefingReferenceTimeProvider)();
    final anchorDate = _anchorDateForRange(range, referenceTime);

    if (range == BriefingTimeRange.recent7Days) {
      final metricsRepository = ref.watch(metricsRepositoryProvider);
      final metrics = await metricsRepository.listRecentDays(
        7,
        referenceDate: anchorDate,
      );
      final minutesByKey = <String, int>{
        for (final item in metrics)
          DateKey.fromDate(item.date): item.sedentaryDuration.inMinutes,
      };
      final points = <OverviewSedentaryTrendPoint>[];
      for (var offset = 6; offset >= 0; offset -= 1) {
        final date = DateTime(
          anchorDate.year,
          anchorDate.month,
          anchorDate.day,
        ).subtract(Duration(days: offset));
        final key = DateKey.fromDate(date);
        points.add(
          OverviewSedentaryTrendPoint(
            date: date,
            minutes: minutesByKey[key] ?? 0,
            isHighlight: offset == 0,
          ),
        );
      }
      const dailyReferenceMinutes = 120;
      final totalMinutes =
          points.fold<int>(0, (total, point) => total + point.minutes);
      final longestMinutes = points.fold<int>(
        0,
        (current, point) => math.max(current, point.minutes),
      );
      const rangeReferenceMinutes = dailyReferenceMinutes * 7;
      return OverviewSedentaryDetailSnapshot(
        totalDuration: Duration(minutes: totalMinutes),
        longestDuration: Duration(minutes: longestMinutes),
        segments: const <OverviewSedentarySegmentSnapshot>[],
        dailyPoints: points,
        referenceMinutes: rangeReferenceMinutes,
        rangeProgress: rangeReferenceMinutes == 0
            ? 0
            : totalMinutes / rangeReferenceMinutes,
      );
    }

    final repository = ref.watch(activityRepositoryProvider);
    final window = _windowForRange(range, referenceTime: referenceTime);
    final samples = await repository.listByWindow(window);
    final summary = summarizeSedentaryForWindow(
      activitySamples: samples,
      window: window,
    );
    final segments = summary.segments
        .map(
          (SedentaryActivitySegment segment) =>
              OverviewSedentarySegmentSnapshot(
            startedAt: segment.startedAt,
            endedAt: segment.endedAt,
            duration: segment.duration,
          ),
        )
        .toList(growable: false);

    return OverviewSedentaryDetailSnapshot(
      totalDuration: summary.totalDuration,
      longestDuration: summary.longestDuration,
      segments: segments,
    );
  },
);

final briefingScreenDetailProvider =
    FutureProvider.family<OverviewScreenDetailSnapshot, BriefingTimeRange>(
        (Ref ref, range) async {
  ref.watch(dataCollectorUsageRevisionProvider);
  final repository = ref.watch(usageSummaryRepositoryProvider);
  final referenceTime = ref.watch(briefingSelectedDateProvider) ??
      ref.watch(briefingReferenceTimeProvider)();
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

String _windowLabelForSelection(
  BriefingTimeRange range,
  DateTime? selectedDate,
  DateTime actualNow,
) {
  if (range == BriefingTimeRange.recent7Days) {
    return range.label;
  }
  final date = selectedDate ?? actualNow;
  if (_dayKey(date) == _dayKey(actualNow)) {
    return '今日';
  }
  if (_dayKey(date) == _dayKey(actualNow.subtract(const Duration(days: 1)))) {
    return '昨日';
  }
  return '${date.month}月${date.day}日';
}

DailyBriefSnapshot _buildDailyBriefSnapshot(
  HealthInsightSnapshot snapshot, {
  DashboardSnapshot? dashboard,
}) {
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
      value:
          '${dashboard?.sedentaryCard.totalMinutes ?? snapshot.metrics.sedentaryMinutes}',
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

String _selectionKey({
  required BriefingTimeRange range,
  required DateTime? selectedDate,
  required DateTime actualNow,
}) {
  if (range == BriefingTimeRange.recent7Days) {
    return 'recent7';
  }
  final date = selectedDate ?? actualNow;
  return 'day:${_dayKey(date)}';
}

DateTime _maxDateTime(DateTime left, DateTime right) {
  return left.isAfter(right) ? left : right;
}

Future<void> _syncHistoricalSelectionIfNeeded({
  required Ref ref,
  required DataCollector dataCollector,
  required BriefingTimeRange range,
  required DateTime referenceTime,
  required DateTime actualNow,
}) async {
  if (range == BriefingTimeRange.recent7Days) {
    return;
  }
  final anchorDate = _anchorDateForRange(range, referenceTime);
  final dayStart = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
  final todayStart = DateTime(actualNow.year, actualNow.month, actualNow.day);
  if (!dayStart.isBefore(todayStart)) {
    return;
  }

  final metricsRepository = ref.watch(metricsRepositoryProvider);
  final usageRepository = ref.watch(usageSummaryRepositoryProvider);
  final metrics = await metricsRepository.getByDate(dayStart);
  final usage = await usageRepository.getByDate(dayStart);
  final futures = <Future<void>>[];

  // 历史日简报读取的是本地仓库快照；当步数指标缺失或仍为 0 时，
  // 先给原生计步 / Health Connect 一次按日回补机会，再构建简报。
  if (metrics == null || metrics.stepCount == 0) {
    futures.add(dataCollector.syncNativeStepCount(referenceTime: dayStart));
  }

  // Android UsageStats 可以按 referenceTime 读取指定自然日摘要；
  // 本地没有屏幕使用摘要时，切换历史日应先补一次轻量同步。
  if (usage == null) {
    futures.add(dataCollector.syncUsageSummary(referenceTime: dayStart));
  }

  if (futures.isEmpty) {
    return;
  }
  await Future.wait<void>(futures);
}
