import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';
import 'package:health_monitor/features/trends/widgets/trend_chart_panel.dart';
import 'package:health_monitor/features/trends/widgets/trend_tab_bar.dart';

class TrendAnalysisPage extends ConsumerStatefulWidget {
  const TrendAnalysisPage({super.key});

  @override
  ConsumerState<TrendAnalysisPage> createState() => _TrendAnalysisPageState();
}

class _TrendAnalysisPageState extends ConsumerState<TrendAnalysisPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    PrimaryTabScrollRegistry.register(1, _controller);
  }

  @override
  void dispose() {
    PrimaryTabScrollRegistry.unregister(1, _controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(trendSelectedTabProvider);
    final selectedRange = ref.watch(trendSelectedRangeProvider);
    return Scaffold(
      backgroundColor: context.healthTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller: _controller,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 112),
          children: <Widget>[
            HealthStaggeredEntrance(
              index: 0,
              child: HealthPageHeader(
                title: '趋势分析',
                trailing: HealthNavIconButton(
                  key: const Key('trend-range-button'),
                  icon: 'calendar_month',
                  onTap: _openRangePicker,
                  semanticLabel: '选择趋势范围',
                ),
              ),
            ),
            const SizedBox(height: 17),
            HealthStaggeredEntrance(
              index: 1,
              child: HealthSegmentedControl<TrendRange>(
                values: TrendRange.values,
                selected: selectedRange,
                labelBuilder: (range) => range.label,
                onSelected: (range) {
                  ref
                      .read(trendRangeForTabProvider(selectedTab).notifier)
                      .state = range;
                },
              ),
            ),
            const SizedBox(height: 16),
            HealthStaggeredEntrance(
              index: 2,
              child: TrendTabBar(
                selectedTab: selectedTab,
                onSelected: (tab) {
                  ref.read(trendSelectedTabProvider.notifier).state = tab;
                },
              ),
            ),
            const SizedBox(height: 18),
            const HealthStaggeredEntrance(
              index: 3,
              child: _TrendChartSection(),
            ),
            const SizedBox(height: 16),
            const HealthStaggeredEntrance(
              index: 4,
              child: _TrendInsightSection(),
            ),
            const SizedBox(height: 16),
            const HealthStaggeredEntrance(
              index: 5,
              child: _DailyComparisonSection(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRangePicker() async {
    final selectedTab = ref.read(trendSelectedTabProvider);
    final selectedRange = ref.read(trendRangeForTabProvider(selectedTab));
    final tokens = context.healthTheme;
    final selected = await showModalBottomSheet<TrendRange>(
      context: context,
      showDragHandle: true,
      backgroundColor: tokens.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('选择趋势范围', style: tokens.sectionTitleStyle),
              const SizedBox(height: 8),
              ...TrendRange.values.map((range) {
                final active = range == selectedRange;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  selected: active,
                  selectedColor: tokens.sage,
                  title: Text(range.label),
                  subtitle: Text(
                    range == TrendRange.days7 ? '观察最近一周变化' : '观察近 30 天变化',
                  ),
                  trailing: active
                      ? Icon(Icons.check_rounded, color: tokens.sage, size: 20)
                      : null,
                  onTap: () => Navigator.of(context).pop(range),
                );
              }),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null || selected == selectedRange) {
      return;
    }
    ref.read(trendRangeForTabProvider(selectedTab).notifier).state = selected;
    await _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}

class _TrendChartSection extends ConsumerWidget {
  const _TrendChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(trendChartSnapshotProvider);
    return snapshot.when(
      skipLoadingOnRefresh: true,
      loading: () => const _CardLoadingPlaceholder(height: 330),
      error: (error, stackTrace) => _CardErrorPlaceholder(
        message: '趋势数据暂时无法加载',
        onRetry: () => ref.invalidate(trendAnalysisViewModelProvider),
      ),
      data: (value) => HealthAnimatedSwitcher(
        childKey: ValueKey<Object>((value.selectedTab, value.range)),
        child: TrendChartPanel(snapshot: value),
      ),
    );
  }
}

class _TrendInsightSection extends ConsumerWidget {
  const _TrendInsightSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(trendSnapshotStateProvider);
    return snapshot.when(
      skipLoadingOnRefresh: true,
      loading: () => const _CardLoadingPlaceholder(height: 138),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (value) => HealthAnimatedSwitcher(
        childKey: ValueKey<String>(value.insightText),
        child: HealthElevatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  HealthIconBubble(
                    icon: 'info',
                    foreground: context.healthTheme.sage,
                    background: context.healthTheme.sageSoft,
                  ),
                  const SizedBox(width: 10),
                  Text('本期洞察', style: context.healthTheme.sectionTitleStyle),
                ],
              ),
              const SizedBox(height: 12),
              Text(value.insightText, style: context.healthTheme.bodyStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyComparisonSection extends ConsumerStatefulWidget {
  const _DailyComparisonSection();

  @override
  ConsumerState<_DailyComparisonSection> createState() =>
      _DailyComparisonSectionState();
}

class _DailyComparisonSectionState
    extends ConsumerState<_DailyComparisonSection> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(trendSnapshotStateProvider).valueOrNull;
    if (snapshot == null || snapshot.points.isEmpty) {
      return const SizedBox.shrink();
    }
    final motion = context.healthMotion;
    final selected = _selectedIndex ?? snapshot.defaultSelectedIndex ?? 0;
    final max = snapshot.points.where((item) => item.hasData).fold<num>(
          1,
          (value, item) => item.value > value ? item.value : value,
        );
    return HealthElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('每日对比', style: context.healthTheme.sectionTitleStyle),
          const SizedBox(height: 6),
          Text(
            snapshot.points[selected].hasData
                ? '${snapshot.points[selected].label} · ${snapshot.points[selected].value.round()} ${snapshot.unitLabel}'
                : '${snapshot.points[selected].label} · 数据暂缺',
            style: context.healthTheme.dataStyle.copyWith(
              fontSize: 11,
              color: context.healthTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 86,
            child: HealthAnimatedValue(
              key: ValueKey<String>(_dailyComparisonAnimationKey(snapshot)),
              value: 1,
              duration: motion.data,
              builder: (context, progress, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:
                      List<Widget>.generate(snapshot.points.length, (index) {
                    final point = snapshot.points[index];
                    final active = index == selected;
                    final barProgress = _staggeredBarProgress(
                      progress,
                      index,
                      snapshot.points.length,
                    );
                    final targetHeight =
                        point.hasData ? 18 + 58 * point.value / max : 4;
                    final animatedHeight = point.hasData
                        ? 4 + (targetHeight - 4) * barProgress
                        : 4;
                    return Expanded(
                      child: Semantics(
                        button: true,
                        label:
                            '${point.label} ${point.value}${snapshot.unitLabel}',
                        child: InkWell(
                          onTap: () => setState(() => _selectedIndex = index),
                          borderRadius: BorderRadius.circular(12),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: context.motionDuration(motion.fast),
                              curve: motion.standardCurve,
                              width: snapshot.points.length > 12 ? 7 : 18,
                              height: animatedHeight.toDouble(),
                              decoration: BoxDecoration(
                                color: active
                                    ? context.healthTheme.sage
                                    : context.healthTheme.sageSoft,
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _dailyComparisonAnimationKey(TrendSnapshot snapshot) {
  final buffer = StringBuffer()
    ..write(snapshot.selectedTab.name)
    ..write('|')
    ..write(snapshot.range.name)
    ..write('|daily|');
  for (final point in snapshot.points) {
    buffer
      ..write(point.label)
      ..write(':')
      ..write(point.value)
      ..write(':')
      ..write(point.hasData)
      ..write(';');
  }
  return buffer.toString();
}

double _staggeredBarProgress(double progress, int index, int total) {
  if (total <= 1) {
    return progress.clamp(0.0, 1.0).toDouble();
  }
  final delay = (index / total) * 0.28;
  final available = 1 - delay;
  if (available <= 0) {
    return 1;
  }
  return ((progress - delay) / available).clamp(0.0, 1.0).toDouble();
}

class _CardLoadingPlaceholder extends StatelessWidget {
  const _CardLoadingPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return HealthElevatedCard(
      child: SizedBox(
        height: height,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.healthTheme.sage,
          ),
        ),
      ),
    );
  }
}

class _CardErrorPlaceholder extends StatelessWidget {
  const _CardErrorPlaceholder({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HealthElevatedCard(
      child: Column(
        children: <Widget>[
          const HealthVectorIcon('info', size: 24),
          const SizedBox(height: 10),
          Text(message, style: context.healthTheme.bodyStyle),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
