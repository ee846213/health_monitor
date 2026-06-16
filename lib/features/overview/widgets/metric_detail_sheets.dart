import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_icons.dart';
import 'package:health_monitor/features/overview/providers/overview_detail_providers.dart';

const Color _surface = Color(0xFFFFFDF8);
const Color _surfaceSoft = Color(0xFFF0ECE4);
const Color _sageSoft = Color(0xFFE6EEE8);
const Color _sageDeep = Color(0xFF5C7768);
const Color _textPrimary = Color(0xFF1F2320);
const Color _textSecondary = Color(0xFF505750);
const Color _textMuted = Color(0xFF7A8179);
const Color _line = Color(0xFFDDD8CF);
const Color _warmSand = Color(0xFFF4E8DA);
const Color _mistBlue = Color(0xFFE0EBEE);

Future<void> showStepDetailSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: _surface,
    isScrollControlled: true,
    builder: (_) => const _StepDetailSheet(),
  );
}

Future<void> showSedentaryDetailSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: _surface,
    isScrollControlled: true,
    builder: (_) => const _SedentaryDetailSheet(),
  );
}

Future<void> showScreenDetailSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: _surface,
    isScrollControlled: true,
    builder: (_) => const _ScreenDetailSheet(),
  );
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          10,
          18,
          18 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: _line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _StepDetailSheet extends ConsumerWidget {
  const _StepDetailSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnapshot = ref.watch(overviewStepDetailProvider);
    return _SheetScaffold(
      title: '步数详情',
      subtitle: '看一眼过去 7 天的步数变化，再判断今天是不是该补一段活动。',
      child: asyncSnapshot.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (Object error, StackTrace _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '步数详情加载失败：$error',
            style: const TextStyle(color: _textSecondary),
          ),
        ),
        data: (OverviewStepDetailSnapshot snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SummaryCard(
                backgroundColor: _warmSand,
                label: '今日步数',
                value: '${snapshot.todaySteps}',
                unit: '步',
                detail:
                    '目标 ${snapshot.goalSteps} 步 · 完成率 ${_percentLabel(snapshot.todayProgress)}',
              ),
              const SizedBox(height: 16),
              const Text(
                '过去 7 天柱状图',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _StepBars(points: snapshot.points),
              const SizedBox(height: 12),
              const Text(
                '这里直接读取最近 7 天的日聚合，不会用静态占位图。',
                style: TextStyle(fontSize: 12, color: _textMuted, height: 1.5),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepBars extends StatelessWidget {
  const _StepBars({required this.points});

  final List<OverviewStepTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _EmptyState(
        text: '还没有 7 天步数数据，继续采集后会在这里显示。',
      );
    }

    final maxSteps = points.fold<int>(
      1,
      (int current, OverviewStepTrendPoint point) =>
          point.steps > current ? point.steps : current,
    );

    return SizedBox(
      height: 210,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points
            .map(
              (OverviewStepTrendPoint point) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: <Widget>[
                      Text(
                        '${point.steps}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: point.steps / maxSteps,
                            widthFactor: 0.84,
                            child: Container(
                              decoration: BoxDecoration(
                                color: point.isToday ? _sageDeep : _sageSoft,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        point.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: point.isToday ? _textPrimary : _textMuted,
                          fontWeight:
                              point.isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _SedentaryDetailSheet extends ConsumerWidget {
  const _SedentaryDetailSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnapshot = ref.watch(overviewSedentaryDetailProvider);
    return _SheetScaffold(
      title: '久坐详情',
      subtitle: '这里展示今天的连续久坐片段，帮助你快速找到最该起来活动的时段。',
      child: asyncSnapshot.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (Object error, StackTrace _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '久坐详情加载失败：$error',
            style: const TextStyle(color: _textSecondary),
          ),
        ),
        data: (OverviewSedentaryDetailSnapshot snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SummaryCard(
                backgroundColor: _warmSand,
                label: '今日累计久坐',
                value: snapshot.totalDuration.inMinutes.toString(),
                unit: '分钟',
                detail: '最长单次 ${snapshot.longestDuration.inMinutes} 分钟',
              ),
              const SizedBox(height: 16),
              const Text(
                '今日久坐时段时间轴',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              if (snapshot.segments.isEmpty)
                const _EmptyState(
                  text: '今天还没有识别到连续久坐片段，继续使用后这里会自动更新。',
                )
              else
                Column(
                  children: snapshot.segments
                      .map(
                        (OverviewSedentarySegmentSnapshot segment) =>
                            _TimelineRow(segment: segment),
                      )
                      .toList(growable: false),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.segment});

  final OverviewSedentarySegmentSnapshot segment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 68,
            child: Text(
              segment.timeLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _sageDeep,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Container(
                width: 2,
                height: 52,
                color: _line,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _line),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '连续久坐 ${segment.duration.inMinutes} 分钟',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    AppIcons.chevronRight,
                    size: 16,
                    color: _textMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenDetailSheet extends ConsumerWidget {
  const _ScreenDetailSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnapshot = ref.watch(overviewScreenDetailProvider);
    return _SheetScaffold(
      title: '屏幕详情',
      subtitle: '我们用当前可用的真实聚合摘要拆分时段，并对比昨天的变化。',
      child: asyncSnapshot.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (Object error, StackTrace _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '屏幕详情加载失败：$error',
            style: const TextStyle(color: _textSecondary),
          ),
        ),
        data: (OverviewScreenDetailSnapshot snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SummaryCard(
                backgroundColor: _mistBlue,
                label: '今日亮屏总时长',
                value: _durationLabel(snapshot.totalDuration),
                unit: '',
                detail: _deltaLabel(snapshot.deltaMinutes),
              ),
              const SizedBox(height: 16),
              const Text(
                '分时段使用分布',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _ScreenBuckets(buckets: snapshot.buckets),
              const SizedBox(height: 12),
              _TagRow(
                tags: <String>[
                  snapshot.sourceLabel,
                  if (snapshot.qualityLabel != null) snapshot.qualityLabel!,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScreenBuckets extends StatelessWidget {
  const _ScreenBuckets({required this.buckets});

  final List<OverviewScreenUsageBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final maxDuration = buckets.fold<Duration>(
      Duration.zero,
      (Duration current, OverviewScreenUsageBucket bucket) =>
          bucket.duration > current ? bucket.duration : current,
    );
    if (maxDuration == Duration.zero) {
      return const _EmptyState(
        text: '今天还没有可用的屏幕聚合摘要，数据补齐后会自动展示。',
      );
    }

    return Column(
      children: buckets
          .map(
            (OverviewScreenUsageBucket bucket) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _UsageBucketRow(
                bucket: bucket,
                maxDuration: maxDuration,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _UsageBucketRow extends StatelessWidget {
  const _UsageBucketRow({
    required this.bucket,
    required this.maxDuration,
  });

  final OverviewScreenUsageBucket bucket;
  final Duration maxDuration;

  @override
  Widget build(BuildContext context) {
    final ratio = maxDuration.inMilliseconds == 0
        ? 0.0
        : bucket.duration.inMilliseconds / maxDuration.inMilliseconds;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                bucket.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Text(
                _durationLabel(bucket.duration),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _sageDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bucket.subtitle,
            style: const TextStyle(fontSize: 12, color: _textMuted),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: ratio,
              backgroundColor: _line,
              valueColor: const AlwaysStoppedAnimation<Color>(_sageDeep),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.backgroundColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.detail,
  });

  final Color backgroundColor;
  final String label;
  final String value;
  final String unit;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              if (unit.isNotEmpty) ...<Widget>[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (String tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _line),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Text(
        text,
        style:
            const TextStyle(fontSize: 13, color: _textSecondary, height: 1.5),
      ),
    );
  }
}

String _durationLabel(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes <= 0) {
    return '0 分钟';
  }
  final hours = duration.inHours;
  final remainingMinutes = minutes % 60;
  if (hours <= 0) {
    return '$minutes 分钟';
  }
  if (remainingMinutes == 0) {
    return '$hours 小时';
  }
  return '$hours 小时 $remainingMinutes 分钟';
}

String _percentLabel(double value) {
  final safeValue = value < 0 ? 0 : value;
  return '${(safeValue * 100).round()}%';
}

String _deltaLabel(int deltaMinutes) {
  if (deltaMinutes == 0) {
    return '与昨日持平';
  }
  final sign = deltaMinutes > 0 ? '↑' : '↓';
  final absolute = deltaMinutes.abs();
  return '与昨日 $sign $absolute 分钟';
}
