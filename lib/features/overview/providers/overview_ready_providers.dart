import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

class OverviewReadyData {
  const OverviewReadyData({
    required this.dashboard,
    required this.permissionStatuses,
    required this.missingDimensions,
    required this.reminders,
    required this.preciseDetectionNotice,
  });

  final DashboardSnapshot dashboard;
  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
  final List<String> missingDimensions;
  final List<ReminderRecord> reminders;
  final String? preciseDetectionNotice;
}

enum OverviewEnvironmentLightIcon {
  bright,
  comfortable,
  dark,
  waiting,
}

enum OverviewEnvironmentNoiseIcon {
  loud,
  normal,
  quiet,
  waiting,
}

final overviewReadyDataProvider = FutureProvider<OverviewReadyData>(
  (Ref ref) async {
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
      referenceTime: referenceTime,
    );
    final dashboard = await dashboardService.buildFromInsight(
      insight: insight,
      referenceTime: referenceTime,
    );

    return OverviewReadyData(
      dashboard: dashboard,
      permissionStatuses: permissionStatuses,
      missingDimensions: insight.input.missingDimensions
          .map(localizedDimensionLabel)
          .toList(growable: false),
      reminders: insight.reminderHistory,
      preciseDetectionNotice: buildWalkingScreenRiskPrecisionNotice(
        permissionStatuses: permissionStatuses,
        isAndroid: Platform.isAndroid,
        isIOS: Platform.isIOS,
      ),
    );
  },
);

final _overviewReadyDataCacheProvider =
    NotifierProvider<_OverviewReadyDataStateNotifier, OverviewReadyData?>(
  _OverviewReadyDataStateNotifier.new,
);

final overviewReadyDataStateProvider = Provider<OverviewReadyData?>((Ref ref) {
  return ref.watch(_overviewReadyDataCacheProvider);
});

final overviewScreenStateProvider = Provider<AsyncValue<OverviewScreenState>>(
  (Ref ref) {
    final cachedScreenState = ref.watch(
      overviewReadyDataStateProvider.select(
        (OverviewReadyData? data) => data == null
            ? null
            : resolveOverviewScreenState(
                permissionStatuses: data.permissionStatuses,
                hasRealData: data.dashboard.hasRealData,
                hasReminderHistory: data.dashboard.hasReminderHistory,
              ),
      ),
    );
    if (cachedScreenState != null) {
      // 首页已有内容后，外层只关心页面状态是否发生切换。
      // 后续采集刷新由字段级 provider 消费，避免整页跟随每次数据版本重建。
      return AsyncData<OverviewScreenState>(cachedScreenState);
    }

    return ref.watch(overviewReadyDataProvider).whenData(
          (OverviewReadyData data) => resolveOverviewScreenState(
            permissionStatuses: data.permissionStatuses,
            hasRealData: data.dashboard.hasRealData,
            hasReminderHistory: data.dashboard.hasReminderHistory,
          ),
        );
  },
);

final overviewDashboardSnapshotProvider = Provider<DashboardSnapshot?>(
  (Ref ref) {
    return ref.watch(
      overviewReadyDataStateProvider.select(
        (OverviewReadyData? data) => data?.dashboard,
      ),
    );
  },
);

class _OverviewReadyDataStateNotifier extends Notifier<OverviewReadyData?> {
  @override
  OverviewReadyData? build() {
    ref.listen<AsyncValue<OverviewReadyData>>(
      overviewReadyDataProvider,
      (AsyncValue<OverviewReadyData>? previous,
          AsyncValue<OverviewReadyData> next) {
        final nextValue = next.valueOrNull;
        if (nextValue != null) {
          state = nextValue;
        }
      },
      fireImmediately: true,
    );
    return ref.read(overviewReadyDataProvider).valueOrNull;
  }
}

final overviewStepValueTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select(
          (OverviewReadyData? data) =>
              data?.dashboard.stepCard.currentSteps.toString(),
        ),
      ) ??
      '--';
});

final overviewStepCaptionTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final stepCard = data?.dashboard.stepCard;
          if (stepCard == null) {
            return null;
          }
          return '目标 ${stepCard.goalSteps} · ${stepCard.achievementPercent}%';
        }),
      ) ??
      '--';
});

final overviewSedentaryValueTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select(
          (OverviewReadyData? data) =>
              data?.dashboard.sedentaryCard.totalMinutes.toString(),
        ),
      ) ??
      '--';
});

final overviewSedentaryCaptionTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final card = data?.dashboard.sedentaryCard;
          if (card == null) {
            return null;
          }
          return '最长 ${card.longestSingleMinutes} 分钟';
        }),
      ) ??
      '--';
});

final overviewScreenValueTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select(
          (OverviewReadyData? data) =>
              data?.dashboard.screenCard.totalMinutes.toString(),
        ),
      ) ??
      '--';
});

final overviewScreenCaptionTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final card = data?.dashboard.screenCard;
          if (card == null) {
            return null;
          }
          final longestHint = card.longestSingleMinutes > 0
              ? '最长一段 ${card.longestSingleMinutes} 分钟 · '
              : '';
          switch (card.changeDirection) {
            case DashboardChangeDirection.up:
              return '${longestHint}较昨日 ↑ ${card.yesterdayDeltaMinutes.abs()} 分钟';
            case DashboardChangeDirection.down:
              return '${longestHint}较昨日 ↓ ${card.yesterdayDeltaMinutes.abs()} 分钟';
            case DashboardChangeDirection.steady:
              return longestHint.isEmpty
                  ? '和昨日基本持平'
                  : '${longestHint}和昨日基本持平';
          }
        }),
      ) ??
      '--';
});

final overviewHealthScoreValueProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select(
          (OverviewReadyData? data) =>
              data?.dashboard.healthScore.totalScore.toString(),
        ),
      ) ??
      '--';
});

final overviewHealthScoreProgressProvider = Provider<double>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final score = data?.dashboard.healthScore.totalScore;
          if (score == null) {
            return null;
          }
          return score / 100;
        }),
      ) ??
      0;
});

final overviewHealthScoreSummaryProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final score = data?.dashboard.healthScore.totalScore;
          if (score == null) {
            return null;
          }
          return _scoreSummary(score);
        }),
      ) ??
      '--';
});

final overviewHealthScoreStepPillProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final score = data?.dashboard.healthScore.stepScore;
          if (score == null) {
            return null;
          }
          return '步数 $score';
        }),
      ) ??
      '--';
});

final overviewHealthScoreSedentaryPillProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final score = data?.dashboard.healthScore.sedentaryScore;
          if (score == null) {
            return null;
          }
          return '久坐 $score';
        }),
      ) ??
      '--';
});

final overviewHealthScoreScreenPillProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final score = data?.dashboard.healthScore.screenScore;
          if (score == null) {
            return null;
          }
          return '屏幕 $score';
        }),
      ) ??
      '--';
});

final overviewEnvironmentLightTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select(
          (OverviewReadyData? data) =>
              data?.dashboard.environmentSnapshot.lightLabel,
        ),
      ) ??
      '等待采集';
});

final overviewEnvironmentLightIconProvider =
    Provider<OverviewEnvironmentLightIcon>((Ref ref) {
  final label = ref.watch(overviewEnvironmentLightTextProvider);
  switch (label) {
    case '明亮':
      return OverviewEnvironmentLightIcon.bright;
    case '舒适':
      return OverviewEnvironmentLightIcon.comfortable;
    case '过暗':
      return OverviewEnvironmentLightIcon.dark;
    default:
      return OverviewEnvironmentLightIcon.waiting;
  }
});

final overviewEnvironmentNoiseTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select(
          (OverviewReadyData? data) =>
              data?.dashboard.environmentSnapshot.noiseLabel,
        ),
      ) ??
      '等待采集';
});

final overviewEnvironmentNoiseIconProvider =
    Provider<OverviewEnvironmentNoiseIcon>((Ref ref) {
  final label = ref.watch(overviewEnvironmentNoiseTextProvider);
  switch (label) {
    case '嘈杂':
      return OverviewEnvironmentNoiseIcon.loud;
    case '正常':
      return OverviewEnvironmentNoiseIcon.normal;
    case '安静':
      return OverviewEnvironmentNoiseIcon.quiet;
    default:
      return OverviewEnvironmentNoiseIcon.waiting;
  }
});

final overviewAdviceSourceTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select((OverviewReadyData? data) {
          final source = data?.dashboard.dailyAdviceBubble.source;
          if (source == null) {
            return null;
          }
          return 'AI 建议 · ${_sourceLabel(source)}';
        }),
      ) ??
      'AI 建议 · 等待生成';
});

final overviewAdviceBodyTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewReadyDataStateProvider.select(
          (OverviewReadyData? data) => data?.dashboard.dailyAdviceBubble.text,
        ),
      ) ??
      '--';
});

final overviewPreciseDetectionNoticeTextProvider = Provider<String?>((Ref ref) {
  return ref.watch(
    overviewReadyDataStateProvider.select(
      (OverviewReadyData? data) => data?.preciseDetectionNotice,
    ),
  );
});

final overviewMissingDimensionsTextProvider = Provider<String?>((Ref ref) {
  return ref.watch(
    overviewReadyDataStateProvider.select((OverviewReadyData? data) {
      final missingDimensions = data?.missingDimensions;
      if (missingDimensions == null || missingDimensions.isEmpty) {
        return null;
      }
      return '部分维度仍在采集中：${missingDimensions.join('、')}';
    }),
  );
});

String _scoreSummary(int score) {
  if (score >= 85) {
    return '今天整体节奏比较稳，适合继续保持当前活动边界。';
  }
  if (score >= 70) {
    return '整体状态还不错，再补一点步数或减少久坐会更漂亮。';
  }
  return '今天还有提升空间，先从最容易调整的一项开始就好。';
}

String _sourceLabel(DailyAdviceSource source) {
  switch (source) {
    case DailyAdviceSource.llm:
      return '直连';
    case DailyAdviceSource.cache:
      return '缓存';
    case DailyAdviceSource.fallback:
      return '降级';
  }
}
