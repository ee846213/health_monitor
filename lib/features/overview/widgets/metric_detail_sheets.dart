import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/features/overview/providers/overview_detail_providers.dart';

const Color _sheetSurface = Color(0xFFFFFBF5);
const Color _sheetLine = Color(0xFFDDD8CF);
const Color _sheetText = Color(0xFF1F2320);
const Color _sheetMuted = Color(0xFF5D645B);
const Color _sheetSage = Color(0xFF6F8B78);
const Color _sheetSageSoft = Color(0xFFDDE8DF);
const Color _sheetSand = Color(0xFFE8CDAF);
const Color _sheetBlue = Color(0xFF9CBCC5);

class StepTrendDetailSheet extends ConsumerWidget {
  const StepTrendDetailSheet({
    super.key,
    required this.card,
    this.detailProvider,
    this.title = '近 7 天步数',
    this.summary,
    this.progressLabel = '今日进度',
  });

  final DashboardStepCard card;
  final ProviderListenable<AsyncValue<OverviewStepDetailSnapshot>>?
      detailProvider;
  final String title;
  final String? summary;
  final String progressLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(detailProvider ?? overviewStepDetailProvider);
    return _DetailScaffold(
      title: title,
      summary: summary ??
          '今日 ${card.currentSteps} 步，目标 ${card.goalSteps} 步，达成 ${card.achievementPercent}%。',
      child: detail.when(
        skipLoadingOnRefresh: true,
        loading: () => const _SheetLoading(),
        error: (_, __) => const _SheetError(message: '步数趋势暂时无法读取'),
        data: (OverviewStepDetailSnapshot snapshot) =>
            _StepBarChart(snapshot: snapshot, progressLabel: progressLabel),
      ),
    );
  }
}

class SedentaryTimelineDetailSheet extends ConsumerWidget {
  const SedentaryTimelineDetailSheet({
    super.key,
    required this.card,
    this.detailProvider,
    this.title = '今日久坐分布',
    this.summary,
    this.progressLabel,
  });

  final DashboardSedentaryCard card;
  final ProviderListenable<AsyncValue<OverviewSedentaryDetailSnapshot>>?
      detailProvider;
  final String title;
  final String? summary;
  final String? progressLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(detailProvider ?? overviewSedentaryDetailProvider);
    return detail.when(
      skipLoadingOnRefresh: true,
      loading: () => _DetailScaffold(
        title: title,
        summary: summary ??
            '累计久坐 ${card.totalMinutes} 分钟，单次最长 ${card.longestSingleMinutes} 分钟。',
        child: const _SheetLoading(),
      ),
      error: (_, __) => _DetailScaffold(
        title: title,
        summary: summary ??
            '累计久坐 ${card.totalMinutes} 分钟，单次最长 ${card.longestSingleMinutes} 分钟。',
        child: const _SheetError(message: '久坐时段暂时无法读取'),
      ),
      data: (OverviewSedentaryDetailSnapshot snapshot) => _DetailScaffold(
        title: title,
        summary: summary ??
            '累计久坐 ${snapshot.totalDuration.inMinutes} 分钟，'
            '单次最长 ${snapshot.longestDuration.inMinutes} 分钟。',
        child: snapshot.dailyPoints.isNotEmpty
            ? _SedentaryBarChart(
                snapshot: snapshot,
                progressLabel: progressLabel,
              )
            : _SedentaryTimeline(snapshot: snapshot),
      ),
    );
  }
}

class ScreenUsageDetailSheet extends ConsumerWidget {
  const ScreenUsageDetailSheet({
    super.key,
    required this.card,
    this.detailProvider,
    this.title = '分时段使用分布',
    this.summary,
  });

  final DashboardScreenCard card;
  final ProviderListenable<AsyncValue<OverviewScreenDetailSnapshot>>?
      detailProvider;
  final String title;
  final String? summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(detailProvider ?? overviewScreenDetailProvider);
    return _DetailScaffold(
      title: title,
      summary: summary ??
          '今日累计亮屏 ${card.totalMinutes} 分钟'
          '${card.longestSingleMinutes > 0 ? '，最长一段连续 ${card.longestSingleMinutes} 分钟' : ''}'
          '，${_deltaLabel(card)}。',
      child: detail.when(
        skipLoadingOnRefresh: true,
        loading: () => const _SheetLoading(),
        error: (_, __) => const _SheetError(message: '屏幕使用分布暂时无法读取'),
        data: (OverviewScreenDetailSnapshot snapshot) =>
            _ScreenUsageBars(snapshot: snapshot),
      ),
    );
  }
}

class EnvironmentSnapshotDetailSheet extends ConsumerWidget {
  const EnvironmentSnapshotDetailSheet({
    super.key,
    required this.snapshot,
    this.detailProvider,
  });

  final DashboardEnvironmentSnapshot snapshot;
  final ProviderListenable<AsyncValue<OverviewEnvironmentDetailSnapshot>>?
      detailProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail =
        ref.watch(detailProvider ?? overviewEnvironmentDetailProvider);
    return _DetailScaffold(
      title: '当前环境',
      summary: '展示今天最近一次有效光照与噪音样本，不保存原始音频。',
      child: detail.when(
        skipLoadingOnRefresh: true,
        loading: () => const _SheetLoading(),
        error: (_, __) => const _SheetError(message: '环境数据暂时无法读取'),
        data: (OverviewEnvironmentDetailSnapshot data) =>
            _EnvironmentReadingPanel(
          dashboardSnapshot: snapshot,
          detail: data,
        ),
      ),
    );
  }
}

class _EnvironmentReadingPanel extends StatelessWidget {
  const _EnvironmentReadingPanel({
    required this.dashboardSnapshot,
    required this.detail,
  });

  final DashboardEnvironmentSnapshot dashboardSnapshot;
  final OverviewEnvironmentDetailSnapshot detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _EnvironmentMetricCard(
          icon: 'wb_sunny',
          title: '光照',
          label: detail.lightLabel,
          value: _formatEnvironmentReading(detail.lux, 'lx'),
          timeLabel: _capturedAtLabel(detail.lightCapturedAt),
          tint: _sheetSand,
        ),
        const SizedBox(height: 12),
        _EnvironmentMetricCard(
          icon: 'graphic_eq',
          title: '噪音',
          label: detail.noiseLabel,
          value: _formatEnvironmentReading(detail.decibel, 'dB'),
          timeLabel: _capturedAtLabel(detail.noiseCapturedAt),
          tint: _sheetBlue,
        ),
        if (dashboardSnapshot.lightLabel == '等待采集' &&
            dashboardSnapshot.noiseLabel == '等待采集') ...<Widget>[
          const SizedBox(height: 12),
          const Text(
            '开启麦克风与光照相关权限后，可在这里看到实时环境读数。',
            style: TextStyle(fontSize: 12, color: _sheetMuted, height: 1.45),
          ),
        ],
      ],
    );
  }

  String _capturedAtLabel(DateTime? capturedAt) {
    if (capturedAt == null) {
      return '今天尚无有效样本';
    }
    final hour = capturedAt.hour.toString().padLeft(2, '0');
    final minute = capturedAt.minute.toString().padLeft(2, '0');
    return '最近样本 $hour:$minute';
  }
}

String _formatEnvironmentReading(double? value, String unit) {
  if (value == null || !value.isFinite) {
    return '暂无样本';
  }
  return '${value.round()} $unit';
}

class _EnvironmentMetricCard extends StatelessWidget {
  const _EnvironmentMetricCard({
    required this.icon,
    required this.title,
    required this.label,
    required this.value,
    required this.timeLabel,
    required this.tint,
  });

  final String icon;
  final String title;
  final String label;
  final String value;
  final String timeLabel;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _sheetLine.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: HealthVectorIcon(icon, size: 20, color: _sheetText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _sheetMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$label · $value',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _sheetText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeLabel,
                  style: const TextStyle(fontSize: 11, color: _sheetMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBarChart extends StatelessWidget {
  const _StepBarChart({
    required this.snapshot,
    required this.progressLabel,
  });

  final OverviewStepDetailSnapshot snapshot;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    final maxSteps = math.max(
      snapshot.goalSteps,
      snapshot.points.fold<int>(
        0,
        (int current, OverviewStepTrendPoint point) =>
            math.max(current, point.steps),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 190,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: snapshot.points.map((OverviewStepTrendPoint point) {
              final ratio = maxSteps == 0 ? 0.0 : point.steps / maxSteps;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${point.steps}',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _sheetMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      HealthAnimatedValue(
                        key: ValueKey<String>('step-bar-${point.label}'),
                        value: ratio,
                        duration: const Duration(milliseconds: 500),
                        builder: (_, double value, __) => Container(
                          height: math.max(8, 120 * value),
                          decoration: BoxDecoration(
                            color: point.isToday ? _sheetSage : _sheetSageSoft,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        point.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              point.isToday ? FontWeight.w700 : FontWeight.w500,
                          color: point.isToday ? _sheetText : _sheetMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ),
        const SizedBox(height: 12),
        _InfoRow(
          label: progressLabel,
          value: '${(snapshot.todayProgress * 100).round()}%',
        ),
      ],
    );
  }
}

class _SedentaryBarChart extends StatelessWidget {
  const _SedentaryBarChart({
    required this.snapshot,
    this.progressLabel,
  });

  final OverviewSedentaryDetailSnapshot snapshot;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final referenceMinutes = snapshot.referenceMinutes ?? 120;
    final maxMinutes = math.max(
      referenceMinutes,
      snapshot.dailyPoints.fold<int>(
        0,
        (int current, OverviewSedentaryTrendPoint point) =>
            math.max(current, point.minutes),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 190,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: snapshot.dailyPoints.map((OverviewSedentaryTrendPoint point) {
              final ratio = maxMinutes == 0 ? 0.0 : point.minutes / maxMinutes;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${point.minutes}',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _sheetMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      HealthAnimatedValue(
                        key: ValueKey<String>('sedentary-bar-${point.label}'),
                        value: ratio,
                        duration: const Duration(milliseconds: 500),
                        builder: (_, double value, __) => Container(
                          height: math.max(8, 120 * value),
                          decoration: BoxDecoration(
                            color:
                                point.isHighlight ? _sheetSand : const Color(0xFFF2E9DE),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        point.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: point.isHighlight
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: point.isHighlight ? _sheetText : _sheetMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ),
        if (progressLabel != null && snapshot.rangeProgress != null) ...<Widget>[
          const SizedBox(height: 12),
          _InfoRow(
            label: progressLabel!,
            value: '${(snapshot.rangeProgress! * 100).round()}%',
          ),
        ],
      ],
    );
  }
}

class _SedentaryTimeline extends StatelessWidget {
  const _SedentaryTimeline({required this.snapshot});

  final OverviewSedentaryDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.segments.isEmpty) {
      return const _EmptyChart(message: '暂未识别到连续久坐时段');
    }
    return Column(
      children: snapshot.segments.map((OverviewSedentarySegmentSnapshot item) {
        final widthFactor =
            (item.duration.inMinutes / 60).clamp(0.12, 1.0).toDouble();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _sheetText,
                      ),
                    ),
                  ),
                  Text(
                    '${item.duration.inMinutes} 分钟',
                    style: const TextStyle(fontSize: 12, color: _sheetMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              HealthAnimatedValue(
                key: ValueKey<DateTime>(item.startedAt),
                value: widthFactor,
                duration: const Duration(milliseconds: 500),
                builder: (_, double value, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 12,
                    value: value,
                    color: _sheetSand,
                    backgroundColor: const Color(0xFFF2E9DE),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _ScreenUsageBars extends StatelessWidget {
  const _ScreenUsageBars({required this.snapshot});

  final OverviewScreenDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final totalMinutes = snapshot.totalDuration.inMinutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...snapshot.buckets.map((OverviewScreenUsageBucket bucket) {
          final minutes = bucket.duration.inMinutes;
          final ratio = totalMinutes == 0 ? 0.0 : minutes / totalMinutes;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${bucket.label} · ${bucket.subtitle}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _sheetText,
                        ),
                      ),
                    ),
                    Text(
                      '$minutes 分钟',
                      style: const TextStyle(fontSize: 12, color: _sheetMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                HealthAnimatedValue(
                  key: ValueKey<String>('screen-${bucket.label}'),
                  value: ratio,
                  duration: const Duration(milliseconds: 500),
                  builder: (_, double value, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 12,
                      value: value,
                      color: bucket.label == '夜间' ? _sheetSage : _sheetBlue,
                      backgroundColor: const Color(0xFFE8EEF0),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        _InfoRow(label: '数据来源', value: snapshot.sourceLabel),
        if (snapshot.qualityLabel != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            snapshot.qualityLabel!,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: _sheetMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({
    required this.title,
    required this.summary,
    required this.child,
  });

  final String title;
  final String summary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        margin: const EdgeInsets.only(top: 24),
        decoration: const BoxDecoration(
          color: _sheetSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _sheetLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              HealthStaggeredEntrance(
                index: 0,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _sheetText,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              HealthStaggeredEntrance(
                index: 1,
                child: Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: _sheetMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              HealthStaggeredEntrance(
                index: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _sheetLine),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 12, color: _sheetMuted)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _sheetText,
          ),
        ),
      ],
    );
  }
}

class _SheetLoading extends StatelessWidget {
  const _SheetLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SheetError extends StatelessWidget {
  const _SheetError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _EmptyChart(message: message);
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: _sheetMuted),
        ),
      ),
    );
  }
}

String _deltaLabel(DashboardScreenCard card) {
  switch (card.changeDirection) {
    case DashboardChangeDirection.up:
      return '较昨日增加 ${card.yesterdayDeltaMinutes.abs()} 分钟';
    case DashboardChangeDirection.down:
      return '较昨日减少 ${card.yesterdayDeltaMinutes.abs()} 分钟';
    case DashboardChangeDirection.steady:
      return '与昨日基本持平';
  }
}

Future<void> showMetricDetailSheet(
  BuildContext context,
  Widget child,
) {
  final duration = context.reduceMotion
      ? const Duration(milliseconds: 80)
      : context.healthMotion.emphasized;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // 使用根导航器，让浮层覆盖在底部 tabbar 之上，从屏幕底部弹出并盖住导航栏
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    sheetAnimationStyle: AnimationStyle(
      duration: duration,
      reverseDuration: context.reduceMotion
          ? const Duration(milliseconds: 80)
          : context.healthMotion.base,
    ),
    builder: (BuildContext context) => child,
  );
}
